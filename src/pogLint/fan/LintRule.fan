//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Dec 2022  Brian Frank  Creation
//

using pog

**
** Lint rule specifies one validation constraint
**
@Js
abstract const class LintRule
{

  ** Run this rule with the given context
  abstract Void lint(LintContext cx)

}