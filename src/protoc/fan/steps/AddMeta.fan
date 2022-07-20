//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jul 2022  Brian Frank  Creation
//

using concurrent
using proto

**
** Add meta data tags to protos from AST
**
internal class AddMeta : Step
{
  override Void run()
  {
    addMeta(root)
  }

  private Void addMeta(CProto p)
  {
    if (p.doc != null && p.child("_doc") == null) add(p, "_doc", sys.objDoc, p.doc)
    p.each |kid| { addMeta(kid) }
  }

  private Void add(CProto x, Str name, CProto type, Str val)
  {
    addSlot(x, CProto(x.loc, name, null, CName(x.loc, type), val))
  }
}