//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Dec 2022  Brian Frank  Creation
//

**
** Proto object graph linting support - result of calling `Graph.lint`.
**
@Js
mixin PogLint
{
  ** Graph that was linted
  abstract Graph graph()

  ** Was there zero error level messages.  Even when false,
  ** there might still be info and warning messages.
  abstract Bool isOk()

  ** Was there one or more error level messages.
  abstract Bool isErr()

  ** Instance of 'sys.lint.LintReport' with lint messages
  abstract Proto report()
}



