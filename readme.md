# Overview
Xeto is a data-only type system.  The name is derived from the phrase "eXtensible
Explicitly Typed Objects".  Xeto defines a simple plain text format used to
declare types and to exchange typed data.  It is designed to build and validate
[Project Haystack](https://project-haystack.org/) data models.  But Xeto is general
purpose enough to use with any structured data including CSV, JSON, or SQL data.

# Videos
The following series of videos provide instructions on how to use this software to validate data:

- [Overview](https://youtu.be/fr-K-MVbAa8): presentation of high level concepts

- [Axon Shell](https://youtu.be/9Bu1Rtd8VWE): setting up and getting around Axon shell

- [Axon Basics](https://youtu.be/17frHt2b4Ts): brief intro to Axon language

- [Type System](https://youtu.be/y2OVyS2jfbY): nominal and structural typing via typeof, isa, and fits

- [Queries](https://youtu.be/Q7Z3F1dkdQ4): name relationship queries

- [Constrained Queries](https://youtu.be/jZcFVCxLGek): create equip types with required points

# Setup

Xeto is packaged as a simple zip file with a command line tool that
requires the Java VM to run.  Steps to download and run:

1. Make sure you have Java installed

2. Download the latest [release](https://github.com/briansfrank/proto/releases)

3. Unzip to your local machine

4. You might need to run 'chmod +x' on the bin scripts (OS X)

5. Run 'bin/axon -v' to verify the install

6. Watch the videos above to learn how to use the axon shell to validate your data

# License
Protos is licensed under the [Academic Free License 3.0](https://opensource.org/licenses/AFL-3.0).


