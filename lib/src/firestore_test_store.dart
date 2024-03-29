import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firebase_storage/automated_testing_framework_plugin_firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:logging/logging.dart';

/// Test Store for the Automated Testing Framework that can read and write tests
/// to Cloud Firestore.  This optionally can save screenshots to Firebase
/// Storage, when initialized and not on the `web` platform.
class FirestoreTestStore {
  /// Initializes the test store.  This requires the [FirebaseFirestore] to be
  /// assigned and initialized.
  ///
  /// The [imagePath] is optional and is the path within Firebase Storage where
  /// the screenshots must be saved.  If omitted, this defaults to 'images'.
  /// This only is utilized if the [storage] is not-null.  If the [storage] is
  /// null then this is ignored and screenshots are not uploaded.
  ///
  /// The [testCollectionPath] is optional and is the collection within Cloud
  /// Firestore where the tests themselves must be saved.  If omitted, this
  /// defaults to 'tests'.
  ///
  /// The [reportCollectionPath] is optional and is the collection within Cloud
  /// Firestore where the test reports must be saved.  If omitted, this defaults
  /// to 'reports'.
  FirestoreTestStore({
    required this.db,
    this.imagePath,
    this.reportCollectionPath,
    this.storage,
    this.testCollectionPath,
  });

  static final Logger _logger = Logger('FirestoreTestStore');

  /// The initialized Cloud Firestore reference that will be used to save tests,
  /// read tests, or submit test reports.
  final FirebaseFirestore db;

  /// Optional path for screenshots to be uploated to within Firebase Storage.
  /// If [storage] is null or if this is on the web platform, this value is
  /// ignored.
  final String? imagePath;

  /// Optional collection path to store test reports.  If omitted, this defaults
  /// to 'reports'.  Provided to allow for a single Firestore instance the
  /// ability to host multiple applications or environments.
  final String? reportCollectionPath;

  /// Optional [FirebaseStorage] reference object.  If set, and the platform is
  /// not web, then this will be used to upload screenshot results from test
  /// reports.  If omitted, screenshots will not be uploaded anywhere and will
  /// be lost if this test store is used for test reports.
  final FirebaseStorage? storage;

  /// Optional collection path to store test data.  If omitted, this defaults
  /// to 'tests'.  Provided to allow for a single Firestore instance the ability
  /// to host multiple applications or environments.
  final String? testCollectionPath;

  /// Implementation of the [TestReader] functional interface that can read test
  /// data from Cloud Firestore.
  Future<List<PendingTest>> testReader(
    BuildContext? context, {
    String? suiteName,
  }) async {
    List<PendingTest>? results;

    try {
      results = [];
      final actualCollectionPath = (testCollectionPath ?? 'tests');

      final collection = db.collection(actualCollectionPath);
      final query = await collection.orderBy('name').get();
      for (var doc in query.docs) {
        final data = doc.data();
        final pTest = PendingTest(
          loader: AsyncTestLoader(({bool? ignoreImages}) async {
            final testDoc = await db
                .collection(actualCollectionPath)
                .doc(doc.id)
                .collection('versions')
                .doc(data['activeVersion'].toString())
                .get();

            final version = JsonClass.parseInt(testDoc.id)!;
            return Test(
              active: true,
              name: data['name'],
              steps: JsonClass.fromDynamicList(
                testDoc.data()!['steps'],
                (entry) => TestStep.fromDynamic(entry),
              ),
              suiteName: data['suiteName'],
              version: version,
            );
          }),
          name: data['name'],
          numSteps: data['numSteps'],
          suiteName: data['suiteName'],
          version: data['version'],
        );

        if (suiteName == null || pTest.suiteName == suiteName) {
          results.add(pTest);
        }
      }
    } catch (e, stack) {
      _logger.severe('Error loading tests', e, stack);
    }

    return results ?? <PendingTest>[];
  }

  /// Implementation of the [TestReport] functional interface that can submit
  /// test reports to Cloud Firestore.
  Future<bool> testReporter(TestReport report) async {
    final result = false;

    final actualCollectionPath = (reportCollectionPath ?? 'reports');
    final collection = db.collection(actualCollectionPath);

    final doc = collection
        .doc('${report.name}_${report.version}')
        .collection('devices')
        .doc(
            '${report.deviceInfo!.deviceSignature}_${report.startTime!.millisecondsSinceEpoch}');

    await doc.set(report.toJson(false));

    if (!kIsWeb && storage != null) {
      final testStorage = FirebaseStorageTestStore(
        storage: storage!,
        imagePath: imagePath,
      );
      await testStorage.uploadImages(report);
    }

    return result;
  }

  /// Implementation of the [TestWriter] functional interface that can submit
  /// test data to Cloud Firestore.
  Future<bool> testWriter(
    BuildContext context,
    Test test,
  ) async {
    var result = false;

    try {
      final actualCollectionPath = (testCollectionPath ?? 'tests');
      final collection = db.collection(actualCollectionPath);

      final version = test.version + 1;

      final testData = <String, dynamic>{
        'activeVersion': version,
        'name': test.name,
        'numSteps': test.steps.length,
        'timestamp': DateTime.now(),
        'version': version,
      };
      final versionData = <Map<String, dynamic>>[];
      for (var step in test.steps) {
        versionData.add(
          step
              .copyWith(
                image: Uint8List.fromList([]),
              )
              .toJson(),
        );
      }

      await db.runTransaction((transaction) async {
        transaction.set(collection.doc(test.name), testData);
        transaction.set(
          collection
              .doc(test.name)
              .collection('versions')
              .doc(version.toString()),
          {
            'steps': versionData,
          },
        );
      });

      result = true;
    } catch (e, stack) {
      _logger.severe('Error writing test', e, stack);
    }
    return result;
  }
}
