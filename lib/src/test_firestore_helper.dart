import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firestore/automated_testing_framework_plugin_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

/// Helper for the Firestore reference that the automated testing framework will
/// use when running the tests.  Set the static [firestore] value to the one to
/// use within the test steps.
///
/// This also provides a simple way to ensure all the test steps are registered
/// on the [TestStepRegistry] via the [registerTestSteps] function.
class TestFirestoreHelper {
  /// A config variable that instructs the JSON value to autoformat the JSON as
  /// it is being entered or not.  Set to [true] to enable the autoformatter.
  /// Set to [null] or [false] to disable it.
  static bool autoformatJson = false;
  static FirebaseFirestore _firestore;

  static Widget buildJsonEditText({
    @required BuildContext context,
    @required String id,
    String defaultValue,
    @required TranslationEntry label,
    List<ValueValidator> validators,
    @required Map<String, dynamic> values,
  }) {
    assert(context != null);
    assert(id?.isNotEmpty == true);
    assert(label != null);
    assert(values != null);

    if (values[id] == null && defaultValue != null) {
      values[id] = defaultValue;
    }

    var translator = Translator.of(context);
    var encoder = JsonEncoder.withIndent('  ');
    var initialValue = values[id]?.toString();
    if (initialValue?.isNotEmpty == true) {
      try {
        initialValue = encoder.convert(json.decode(initialValue));
      } catch (e) {
        // no-op
      }
    }

    return TextFormField(
      autovalidate: validators?.isNotEmpty == true,
      decoration: InputDecoration(
        labelText: translator.translate(label),
      ),
      initialValue: initialValue,
      inputFormatters:
          autoformatJson == true ? [_JsonTextInputFormatter()] : null,
      maxLines: 5,
      onChanged: (value) {
        var encoded = '';

        try {
          encoded = json.encode(json.decode(value));
        } catch (e) {
          encoded = '';
        }
        values[id] = encoded;
      },
      onEditingComplete: () {},
      smartQuotesType: SmartQuotesType.disabled,
      validator: (value) => validators?.isNotEmpty == true
          ? Validator(validators: [
              ...(validators ?? []),
              _JsonValidator(),
            ]).validate(
              context: context,
              label: translator.translate(label),
              value: value,
            )
          : null,
    );
  }

  /// Returns either the custom set [FirebaseFirestore] reference, or the
  /// default instance if one has not been set.
  static FirebaseFirestore get firestore =>
      _firestore ?? FirebaseFirestore.instance;

  /// Sets the custom [FirebaseFirestore] reference for the test steps to use.
  /// Set to [null] to use the default reference.
  static set firestore(FirebaseFirestore firestore) => _firestore = firestore;

  /// Registers the test steps to the optional [registry].  If not set, the
  /// default [TestStepRegistry] will be used.
  static void registerTestSteps([TestStepRegistry registry]) {
    (registry ?? TestStepRegistry.instance).registerCustomSteps([
      TestStepBuilder(
        availableTestStep: AvailableTestStep(
          form: AssertFirestoreValueForm(),
          help: TestFirestoreTranslations
              .atf_firestore_help_assert_firestore_value,
          id: 'assert_firestore_value',
          keys: const {'collectionPath', 'documentId', 'equals', 'value'},
          quickAddValues: null,
          title: TestFirestoreTranslations
              .atf_firestore_title_assert_firestore_value,
          widgetless: true,
          type: null,
        ),
        testRunnerStepBuilder: AssertFirestoreValueStep.fromDynamic,
      ),
      TestStepBuilder(
        availableTestStep: AvailableTestStep(
          form: SetFirestoreValueForm(),
          help:
              TestFirestoreTranslations.atf_firestore_help_set_firestore_value,
          id: 'set_firestore_value',
          keys: const {'collectionPath', 'documentId', 'value'},
          quickAddValues: null,
          title:
              TestFirestoreTranslations.atf_firestore_title_set_firestore_value,
          widgetless: true,
          type: null,
        ),
        testRunnerStepBuilder: SetFirestoreValueStep.fromDynamic,
      ),
    ]);
  }
}

class _JsonTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var encoder = JsonEncoder.withIndent('  ');
    var encoded = newValue.text;

    try {
      encoded = encoder.convert(json.decode(encoded));
    } catch (e) {
      // no-op
    }

    return encoded == newValue.text
        ? newValue
        : TextEditingValue(text: encoded);
  }
}

class _JsonValidator extends ValueValidator {
  @override
  String validate({
    @required String label,
    @required Translator translator,
    @required String value,
  }) {
    String error;

    try {
      json.decode(value);
    } catch (e) {
      error = translator.translate(
        TestFirestoreTranslations.atf_firestore_error_not_valid_json,
      );
    }

    return error;
  }

  @override
  Map<String, dynamic> toJson() => {};
}
