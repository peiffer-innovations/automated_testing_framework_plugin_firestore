import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firestore/automated_testing_framework_plugin_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assert_firestore_value', () {
    TestFirestoreHelper.registerTestSteps();
    final availStep = TestStepRegistry.instance.getAvailableTestStep(
      'assert_firestore_value',
    )!;

    expect(availStep.form.runtimeType, AssertFirestoreValueForm);
    expect(availStep.help,
        TestFirestoreTranslations.atf_firestore_help_assert_firestore_value);
    expect(availStep.id, 'assert_firestore_value');
    expect(
      availStep.title,
      TestFirestoreTranslations.atf_firestore_title_assert_firestore_value,
    );
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('set_firestore_value', () {
    TestFirestoreHelper.registerTestSteps();
    final availStep = TestStepRegistry.instance.getAvailableTestStep(
      'set_firestore_value',
    )!;

    expect(availStep.form.runtimeType, SetFirestoreValueForm);
    expect(availStep.help,
        TestFirestoreTranslations.atf_firestore_help_set_firestore_value);
    expect(availStep.id, 'set_firestore_value');
    expect(
      availStep.title,
      TestFirestoreTranslations.atf_firestore_title_set_firestore_value,
    );
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });
}
