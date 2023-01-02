# Overview

The pog test suite is provided as a directory of YAML files.
Each file tests one transducer or other feature of the pog
infrastructure.  A test file contains one or more test cases
as YAML documents.

# YAML Format

Each test case is one YAML document structed with the following fields:

 - name: unique identifier for the test within its file
 - test: Pog CLI expression used to execute the tests
 - remainder of fields are variables to the test expression

Example:

    name: readTrio
    test: read trio:src, verify zinc:expect
    src: |
      id:@a
      dis:"Alpha"
      site
    expect: |
      ver:"3.0"
      id,dis,site
      @a,"Alpha",M

In the example above the YAML test has four fields.  The `name`
field is just an identifier for the test.  The `test` field
specifies the series of transducers to run separated by a comma.
The transducer arguments use test field names:

    // run read trio:<input> using the 'src' field as input
    read trio:src

    // verify last result as zinc grid against 'expect' field
    verify zinc:expect

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

The following verify modes are supports:

  - **pog**: verify last result is Proto and printed string matches variable
  - **json**: verify last result is JSON and printed string matches variable
  - **zinc**: verify last result is Grid and printed string matches variable
  - **events**: delimited table of expected error events

In the Fantom reference implementation all verifies are whitespace
sensitive (to ensure pretty print is tested exactly).





