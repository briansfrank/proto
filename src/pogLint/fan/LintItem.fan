//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Dec 2022  Brian Frank  Creation
//

using pog

**
** Lint item models one validation message
**
@Js
const class LintItem : Proto
{
  /* pog-start */

  ** Lint rule specifies one validation constraint
  LintRule rule
  {
    get { get("rule") }
    set { set("rule", it) }
  }

  ** Root type for all objects
  Proto target
  {
    get { get("target") }
    set { set("target", it) }
  }

  ** Severity of the issue
  LintLevel level
  {
    get { get("level") }
    set { set("level", it) }
  }

  ** Unicode string of characters
  Str msg
  {
    get { get("msg").val }
    set { set("msg", it) }
  }

  /* pog-end */
}

**************************************************************************
** LintLevel
**************************************************************************

** TODO
@Js
const class LintLevel : Proto {}