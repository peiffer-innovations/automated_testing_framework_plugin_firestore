import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firestore/automated_testing_framework_plugin_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Sets a value on the identified Firestore Document identified by the
/// [collectionPath] and [documentId].
class SetFirestoreValueStep extends TestRunnerStep {
  SetFirestoreValueStep({
    @required this.collectionPath,
    @required this.documentId,
    @required this.value,
  })  : assert(collectionPath?.isNotEmpty == true),
        assert(documentId?.isNotEmpty == true),
        assert(value?.isNotEmpty == true);

  /// The collection path to look for the Document in.
  final String collectionPath;

  /// The id of the Document to look for.
  final String documentId;

  /// The string representation of the value to set.
  final String value;

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
  static SetFirestoreValueStep fromDynamic(dynamic map) {
    SetFirestoreValueStep result;

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
    @required TestReport report,
    @required TestController tester,
  }) async {
    String collectionPath = tester.resolveVariable(this.collectionPath);
    String documentId = tester.resolveVariable(this.documentId);
    String value = tester.resolveVariable(this.value);
    assert(collectionPath?.isNotEmpty == true);
    assert(documentId?.isNotEmpty == true);

    var name =
        "set_firestore_value('$collectionPath', '$documentId', '$value')";
    log(
      name,
      tester: tester,
    );

    var firestore = TestFirestoreHelper.firestore;

    var doc = firestore.collection(collectionPath).doc(documentId);
    var data = json.decode(value);
    await doc.set(data);
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
