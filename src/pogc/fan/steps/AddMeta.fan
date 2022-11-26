//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jul 2022  Brian Frank  Creation
//

using concurrent
using pog

**
** Add meta data tags to protos from AST
**
internal class AddMeta : Step
{

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    addMeta(root)
  }

  private Void addMeta(CProto p)
  {
    addOf(p)
    addDoc(p)
    p.each |kid| { addMeta(kid) }
  }

//////////////////////////////////////////////////////////////////////////
// Of
//////////////////////////////////////////////////////////////////////////

  private Void addOf(CProto p)
  {
    // check if proto type was parsed with of list
    ofTypes := p.type?.of
    if (ofTypes == null) return

    // Maybe wrapper type - type if the _of slot directly
    if (p.type.deref.isMaybe)
    {
      ofType := ofTypes[0]
      addSlot(p, CProto(ofType.loc, "_of", null, ofType, null))
    }

    // And/Or compound type - types are children of a _of list object
    else
    {
      ofObj := add(p, "_of", sys.list, null)
      ofTypes.each |t, i|
      {
        add(ofObj, "_${i}", t.deref, t.val)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  private Void addDoc(CProto p)
  {
    if (p.doc == null) return
    if (p.getOwn("_doc", false) != null) return
    type := p === sys.objDoc ? sys.str : sys.objDoc
    add(p, "_doc", type, p.doc)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private CProto add(CProto x, Str name, CProto type, Str? val)
  {
    kid := CProto(x.loc, name, null, CType(x.loc, type), val)
    addSlot(x, kid)
    return kid
  }
}