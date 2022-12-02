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

  ** Rule which triggered this issue
  LintRule rule
  {
    get { get("rule") }
    set { set("rule", it) }
  }

  ** Target proto that is the subject of this message
  Proto target
  {
    get { get("target") }
    set { set("target", it) }
  }

  ** Severity of the message: err, warn, info
  LintLevel level
  {
    get { get("level").val }
    set { set("level", it) }
  }

  ** Free form message string describing issue
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

** Severity of the issue
@Js
enum class LintLevel
{
  /* pog-start */

  ** Error level
  err,

  ** Warning level
  warn,

  ** Informational level
  info

  /* pog-end */
}