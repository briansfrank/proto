//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Dec 2022  Brian Frank  Creation
//

using pog

**
**  Lint plan specifies options to a validation engine.
**
@Js
const class LintPlan : Proto
{
  /* pog-start */

  ** Maximum number of items to report
  Int? maxItems
  {
    get { get("maxItems", false)?.val }
    set { set("maxItems", it) }
  }

  /* pog-end */
}