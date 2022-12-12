//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Dec 2022  Brian Frank  Creation
//

using pog

**
** Lint that overrides fit their proto
**
@Js
const class LintFit : LintRule
{

  override Void lint(LintContext cx)
  {
    // find the type's proto for the current object
    proto := cx.proto
    parent := cx.parent
    if (parent == null) return
    type := parent.type
    if (type == null) return
    base := type.get(cx.proto.name, false)
    if (base == null || base.type == null) return base

// TODO
if (parent.qname.toStr == "sys.Obj._doc") return

    if (!proto.fits(base.type))
      cx.err("Invalid type for '$base.qname': $proto.type does not fit $base.type")
  }

}