//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Dec 2022  Brian Frank  Creation
//

using pog

**
** Lint report which encapsulates the output of a validation process
**
@Js
const class LintReport : Proto
{
  /* pog-start */

  ** Number of error level items
  Int numErrs
  {
    get { get("numErrs").val }
    set { set("numErrs", it) }
  }

  ** Number of warning level items
  Int numWarn
  {
    get { get("numWarn").val }
    set { set("numWarn", it) }
  }

  ** Number of info level items
  Int numInfo
  {
    get { get("numInfo").val }
    set { set("numInfo", it) }
  }

  ** List of items in report
  LintItem[] items
  {
    get { get("items").listOwn }
    set { set("items", it) }
  }

  /* pog-end */
}