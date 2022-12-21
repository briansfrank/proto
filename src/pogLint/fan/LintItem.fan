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
const class LintItem : AbstractProto
{
  /* pog-start */

  ** TODO Target proto that is the subject of this message
  Str target
  {
    get { get("target").val.toStr }
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