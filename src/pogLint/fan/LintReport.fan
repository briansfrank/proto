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

  ** Ordered list of zero or more values
  LintItem[] items
  {
    get { get("items").listOwn }
    set { set("items", it) }
  }

  /* pog-end */
}