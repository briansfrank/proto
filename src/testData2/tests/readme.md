# Overview

The Xeto test suite is provided as a directory of YAML files.
Each file tests one major feature of the infrastructure.  A test
file contains one or more test cases as YAML documents.

# Verify Fields

The following verify fields are supported:

## verifyBase

Verify the base qnamne of a data type.

## verifyVal

Verify the scalar default value of a data type as "type encoding"

## verifyMeta

Verify the declared and inherited meta data fields of a spec as "flag type encoding".
Flags are "o" for own and "i" for inherited"

