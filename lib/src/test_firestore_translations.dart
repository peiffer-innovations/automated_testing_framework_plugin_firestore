import 'package:static_translations/static_translations.dart';

class TestFirestoreTranslations {
  static const atf_firestore_error_not_valid_json = TranslationEntry(
    key: 'atf_firestore_error_not_valid_json',
    value: 'Not valid JSON',
  );

  static const atf_firestore_form_collection_path = TranslationEntry(
    key: 'atf_firestore_form_collection_path',
    value: 'Collection Path',
  );

  static const atf_firestore_form_document_id = TranslationEntry(
    key: 'atf_firestore_form_document_id',
    value: 'Document ID',
  );

  static const atf_firestore_help_assert_firestore_value = TranslationEntry(
    key: 'atf_firestore_help_assert_firestore_value',
    value:
        'Attempts to read a document from the collection path with the given id and compares it to a set value.',
  );

  static const atf_firestore_help_set_firestore_value = TranslationEntry(
    key: 'atf_firestore_help_set_firestore_value',
    value:
        'Attempts to create or update a document on the collection path and given id with the given value.',
  );

  static const atf_firestore_title_assert_firestore_value = TranslationEntry(
    key: 'atf_firestore_title_assert_firestore_value',
    value: 'Assert Firestore Value',
  );

  static const atf_firestore_title_set_firestore_value = TranslationEntry(
    key: 'atf_firestore_title_set_firestore_value',
    value: 'Set Firestore Value',
  );
}
