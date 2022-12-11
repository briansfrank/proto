//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Dec 2022  Brian Frank  Creation
//

using pog

**
** Lint scalar values
**
@Js
const class LintScalar : LintRule
{

  override Void lint(LintContext cx)
  {
    // only run on scalars
    if (!cx.proto.fits(cx.graph.sys->Scalar)) return

    // TODO: eventually all scalars must have default value
    if (!cx.proto.hasVal) return

    lintPattern(cx)
  }

  private Void lintPattern(LintContext cx)
  {
    pattern := cx.proto.get("_pattern", false)
    if (pattern == null || !pattern.hasVal) return

    val := cx.proto.val.toStr
    if (!Regex(pattern.val.toStr).matches(val))
    {
// TODO: lets move qname into pog
patternType := pattern.qname.split('.')[0..-2].join(".")
      cx.err("Scalar does not match $patternType pattern: $val.toCode")
    }
  }

}