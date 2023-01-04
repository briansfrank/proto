# Overview

The pog test suite is provided as a directory of YAML files.
Each file tests one transducer or other feature of the pog
infrastructure.  A test file contains one or more test cases
as YAML documents.

# YAML Format

Each test case is one YAML document structed with the following fields:

 - **name**: unique identifier for the test within its file
 - **test**: Pog CLI expression used to execute the tests
 - remainder of fields are variables to the test expression

Example:

    name: example
    test: parse src, verify json:expect
    src: |
      foo: Str
    expect: |
      {"foo":{"_is":"Str"}}

In the example above the YAML test has four fields.  The `name`
field is just an identifier for the test.  The `test` field
specifies the series of transducers to run separated by a comma.
The transducer arguments use test field names:

    // run parse transducer using 'src' field as input
    parse src

    // verify last result as JSON  against 'expect' field
    verify json:expect

All evaluations should provide access to an implicit "temp"
variable which is an in-memory buffer used for scratch results.

# Verify Modes

The special "verify" expression in a test is used to verify the last
result (it) against an expected string format.  The usage for verify is:

    verify <mode>:<field>

You can omit the "field" name in which case it defaults to the mode
name.  For example:

    verify json         // short hand
    verify json:json    // long hand

The "mode" determines how to perform the verification; and "field"
specifies which YAML field to use for the expected results.

The following verify modes are supported:

  - **pog**: last result is Proto and printed string matches field
  - **json**: last result is JSON and printed string matches field
  - **zinc**: last result is Grid and printed string matches field
  - **str**: last result is in-memory buffer that matches expected string
  - **events**: last result events as delimited table of expected error events

In the Fantom reference implementation all verifies are whitespace
sensitive (to ensure pretty print is tested exactly).  However, we do trim
the start and end of the string before comparison.




