import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firestore/automated_testing_framework_plugin_firestore.dart';

/// Sets a value on the identified Firestore Document identified by the
/// [collectionPath] and [documentId].
class SetFirestoreValueStep extends TestRunnerStep {
  SetFirestoreValueStep({
    required this.collectionPath,
    required this.documentId,
    required this.value,
  });

  static const id = 'set_firestore_value';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        "set the value in firestore's `{{collectionPath}}` collection and `{{documentId}}` document to `{{value}}`.",
      ]);

  /// The collection path to look for the Document in.
  final String collectionPath;

  /// The id of the Document to look for.
  final String documentId;

  /// The string representation of the value to set.
  final String? value;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "collectionPath": <String>,
  ///   "documentId": <String>,
  ///   "value": <String>
  /// }
  /// ```
  static SetFirestoreValueStep? fromDynamic(dynamic map) {
    SetFirestoreValueStep? result;

    if (map != null) {
      result = SetFirestoreValueStep(
        collectionPath: map['collectionPath'],
        documentId: map['documentId'],
        value: map['value']?.toString(),
      );
    }

    return result;
  }

  /// Attempts to locate the [Testable] identified by the [testableId] and will
  /// then set the associated [value] to the found widget.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    final collectionPath = tester.resolveVariable(this.collectionPath);
    final documentId = tester.resolveVariable(this.documentId);
    final value = tester.resolveVariable(this.value);
    assert(collectionPath.isNotEmpty == true);
    assert(documentId?.isNotEmpty == true);

    final name = "$id('$collectionPath', '$documentId', '$value')";
    log(
      name,
      tester: tester,
    );

    final firestore = TestFirestoreHelper.firestore;

    final doc = firestore.collection(collectionPath).doc(documentId);
    final data = json.decode(value);
    await doc.set(data);
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) {
    var result = behaviorDrivenDescriptions[0];

    result = result.replaceAll('{{collectionPath}}', collectionPath);
    result = result.replaceAll('{{documentId}}', documentId);
    result = result.replaceAll('{{value}}', value ?? 'null');

    return result;
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'collectionPath': collectionPath,
        'documentId': documentId,
        'value': value,
      };
}
