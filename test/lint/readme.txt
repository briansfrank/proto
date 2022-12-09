This directory contains the test cases for the pog lint engine.

Test cases are formatted as:

  ===
  summary
  ---
  input
  ---
  output
  ===

The input of each test is a snippet of a pog file which should
be compiled into a library named "test".  The test library has
only a dependency on "sys".

The output is a line for each expected lint report item.
The format of a given lint item line is:

  level | qname | msg







