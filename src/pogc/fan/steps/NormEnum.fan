//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 2022  Brian Frank  Creation
//

using concurrent
using pog

**
** Normalize enum types:
**
** Source:
**   Foo : Enum { alpha, beta }
**
** Generate:
**   Foo : Enum <final> {
**     alpha: Foo
**     beta: Foo
**   }
**
**
internal class NormEnum : Step
{

  override Void run()
  {
    norm(root)
  }

  private Void norm(CProto p)
  {
    if (p.type != null && p.type.deref.isEnum) normEnum(p)
    p.each |kid| { norm(kid) }
  }

  private Void normEnum(CProto enum)
  {
    // all the non-meta markers are the enumerated range items
    items := CProto[,]
    enum.children.each |kid|
    {
      if (kid.type != null && kid.type.deref.isMarker && !kid.isMeta)
        items.add(normEnumItem(enum, kid))
    }

    // infer the final meta marker
    if (enum.children["_final"] != null)
      err("Final is implied by Enum", enum.loc)
    else
      addSlot(enum, CProto(enum.loc, "_final", null, CType(enum.loc, sys.marker), null))
  }

  private CProto normEnumItem(CProto enum, CProto p)
  {
    p.type = CType.makeResolved(p.loc, enum)
    return p
  }
}