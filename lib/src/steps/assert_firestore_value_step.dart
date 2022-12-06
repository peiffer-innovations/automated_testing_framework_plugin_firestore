import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firestore/automated_testing_framework_plugin_firestore.dart';
import 'package:json_class/json_class.dart';

/// Test step that asserts that the value equals (or does not equal) a specific
/// value.
class AssertFirestoreValueStep extends TestRunnerStep {
  AssertFirestoreValueStep({
    required this.collectionPath,
    required this.documentId,
    required this.equals,
    required this.value,
  });

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        "assert the value in firestore's `{{collectionPath}}` collection and `{{documentId}}` document is `{{equals}}` to `{{value}}`.",
      ]);

  static const id = 'assert_firestore_value';

  /// The collection path to look for the Document in.
  final String collectionPath;

  /// The id of the Document to look for.
  final String documentId;

  /// Set to [true] if the value from the [Testable] must equal the set [value].
  /// Set to [false] if the value from the [Testable] must not equal the
  /// [value].
  final bool equals;

  /// The [value] to test againt when comparing the [Testable]'s value.
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
  ///   "equals": <bool>,
  ///   "value": <String>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseBool]
  static AssertFirestoreValueStep? fromDynamic(dynamic map) {
    AssertFirestoreValueStep? result;

    if (map != null) {
      result = AssertFirestoreValueStep(
        collectionPath: map['collectionPath'],
        documentId: map['documentId'],
        equals:
            map['equals'] == null ? true : JsonClass.parseBool(map['equals']),
        value: map['value']?.toString(),
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the Document then compare the
  /// value form the document to the [value].
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

    final name = "$id('$collectionPath', '$documentId', '$value', '$equals')";
    log(
      name,
      tester: tester,
    );

    final firestore = TestFirestoreHelper.firestore;

    final doc = firestore.collection(collectionPath).doc(documentId);
    final data = json.encode((await doc.get()).data());

    if ((data == value) != equals) {
      throw Exception(
        'document: [$collectionPath/$documentId] -- actualValue: [$data] ${equals == true ? '!=' : '=='} [$value].',
      );
    }
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) {
    var result = behaviorDrivenDescriptions[0];

    result = result.replaceAll('{{collectionPath}}', collectionPath);
    result = result.replaceAll('{{documentId}}', documentId);
    result = result.replaceAll(
      '{{equals}}',
      equals == true ? 'equal' : 'not equal',
    );
    result = result.replaceAll('{{value}}', value ?? 'null');

    return result;
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'collectionPath': collectionPath,
        'documentId': documentId,
        'equals': equals,
        'value': value,
      };
}
