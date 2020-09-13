# Test Steps

## Table of Contents

* [Introduction](#introduction)
* [Test Step Summary](#test-step-summary)
* [Details](#details)
  * [assert_firestore_value](#assert_firestore_document)
  * [set_firestore_value](#set_firestore_value)


## Introduction

This plugin provides a few new [Test Steps](https://github.com/peiffer-innovations/automated_testing_framework/blob/main/documentation/STEPS.md) related to Firestore actions.

The included steps will get the `FirebaseFirestore` reference from the `TestFirestoreHelper`.  If you would like the test steps to use a different reference than the application's default, you can set the `firestore` property to the reference the test steps should use instead.

The `TestFirestoreHelper` also provides a mechanism to register the steps supported by this plugin via the `TestFirestoreHelper.registerTestSteps` function.  That will place the custom steps on the registry for use within your application.

---

## Test Step Summary

Test Step IDs                                     | Description
--------------------------------------------------|-------------
[assert_firestore_value](#assert_firestore_value) | Asserts the value on the Firestore document equals the `value`.
[set_firestore_value](#set_firestore_value)       | Sets the value on the Firestore document to the `value`.


---
## Details


### assert_firestore_value

**How it Works**

1. Attempts to find the Document with the given `documentId` inside of the `collectionPath`; fails if not found.
2. Gets the data from the Document, encodes it as a JSON string then compares it to the `value`.  This will fail if one of the follosing is true:
    1. The `equals` is `true` or undefined and the Document's value does not match the `value`.
    2. The `equals` is `false` Document's value does match the `error`.


**Example**

```json
{
  "id": "assert_firebase_value",
  "image": "<optional_base_64_image>",
  "values": {
    "collectionPath": "myCollectionPath",
    "documentId": "myDocId",
    "equals": true,
    "value": "{\"foo\":\"bar\"}"
  }
}
```

**Values**

Key              | Type    | Required | Description
-----------------|---------|----------|-------------
`collectionPath` | String  | Yes      | The `collectionPath` to the Document. 
`documentId`     | String  | Yes      | The `id` of the Firestore Document to check.
`equals`         | boolean | No       | Defines whether the Document's value must equal the `value` or must not equal the `value`.  Defaults to `true` if not defined.
`value`          | String  | Yes      | The value to evaluate against.


---

### set_firestore_value

**How it Works**

1. JSON decodes the `value` into a Map object.
2. Attempts to set the value of the Document with `documentId` inside of the `collectionPath` to the decoded Map; fails if unable to.

**Example**

```json
{
  "id": "set_firestore_value",
  "image": "<optional_base_64_image>",
  "values": {
    "collectionPath": "myCollectionPath",
    "documentId": "myDocId",
    "value": "{\"foo\":\"bar\"}"
  }
}
```

**Values**

Key              | Type    | Required | Description
-----------------|---------|----------|-------------
`collectionPath` | String  | Yes      | The `id` of the `Testable` to evaluate the value.
`documentId`     | String  | Yes      | The `id` of the Firestore Document to check.
`value`          | String  | Yes      | The String-encoded JSON value to set to the Document.

