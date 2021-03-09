import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_firestore/automated_testing_framework_plugin_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class SetFirestoreValueForm extends TestStepForm {
  const SetFirestoreValueForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title =>
      TestFirestoreTranslations.atf_firestore_title_set_firestore_value;

  @override
  Widget buildForm(
    BuildContext context,
    Map<String, dynamic>? values, {
    bool minify = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (minify != true)
          buildHelpSection(
            context,
            TestFirestoreTranslations.atf_firestore_help_set_firestore_value,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              id: 'collectionPath',
              label:
                  TestFirestoreTranslations.atf_firestore_form_collection_path,
              validators: [
                RequiredValidator(),
              ],
              values: values!,
            ),
            SizedBox(height: 16.0),
            buildEditText(
              context: context,
              id: 'documentId',
              label: TestFirestoreTranslations.atf_firestore_form_document_id,
              validators: [
                RequiredValidator(),
              ],
              values: values,
            ),
            SizedBox(height: 16.0),
            TestFirestoreHelper.buildJsonEditText(
              context: context,
              id: 'value',
              label: TestStepTranslations.atf_form_value,
              validators: [RequiredValidator()],
              values: values,
            ),
          ],
          minify: minify,
        ),
      ],
    );
  }
}
