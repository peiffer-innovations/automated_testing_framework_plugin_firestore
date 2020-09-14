import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firestore/automated_testing_framework_plugin_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Test step that asserts that the value equals (or does not equal) a specific
/// value.
class AssertFirestoreValueStep extends TestRunnerStep {
  AssertFirestoreValueStep({
    @required this.collectionPath,
    @required this.documentId,
    @required this.equals,
    @required this.value,
  })  : assert(collectionPath?.isNotEmpty == true),
        assert(documentId?.isNotEmpty == true),
        assert(equals != null);

  /// The collection path to look for the Document in.
  final String collectionPath;

  /// The id of the Document to look for.
  final String documentId;

  /// Set to [true] if the value from the [Testable] must equal the set [value].
  /// Set to [false] if the value from the [Testable] must not equal the
  /// [value].
  final bool equals;

  /// The [value] to test againt when comparing the [Testable]'s value.
  final String value;

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
  static AssertFirestoreValueStep fromDynamic(dynamic map) {
    AssertFirestoreValueStep result;

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
    @required TestReport report,
    @required TestController tester,
  }) async {
    String collectionPath = tester.resolveVariable(this.collectionPath);
    String documentId = tester.resolveVariable(this.documentId);
    String value = tester.resolveVariable(this.value);
    assert(collectionPath?.isNotEmpty == true);
    assert(documentId?.isNotEmpty == true);

    var name =
        "assert_firestore_value('$collectionPath', '$documentId', '$value', '$equals')";
    log(
      name,
      tester: tester,
    );

    var firestore = TestFirestoreHelper.firestore;

    var doc = firestore.collection(collectionPath).doc(documentId);
    var data = json.encode((await doc.get()).data());

    if ((data == value) != equals) {
      throw Exception(
        'document: [$collectionPath/$documentId] -- actualValue: [$data] ${equals == true ? '!=' : '=='} [$value].',
      );
    }
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
