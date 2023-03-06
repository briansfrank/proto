//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2023  Brian Frank  Creation
//

using util
using data2

**
** Implementation of DataType wrapped by XetoType
**
@Js
internal const class MType : MSpec
{
  new make(FileLoc loc, XetoLib lib, Str qname, Str name, XetoType self, XetoType? supertype, DataDict own, MSlots declared, Obj? val)
    : super(loc, lib, name, self, own, declared, val)
  {
    this.lib       = lib
    this.qname     = qname
    this.supertype = supertype
  }

  const XetoLib lib

  const override Str qname

  override DataSpec spec() { env.sys.type }

  const override XetoType? supertype

  override Str toStr() { qname }

  Bool isaX(XetoType that)
  {
    if (this === that.mt) return true
    if (supertype == null) return false
    return supertype.mt.isaX(that)
  }
}

**************************************************************************
** XetoType
**************************************************************************

**
** XetoType is the referential proxy for MType
**
@Js
internal const class XetoType : XetoSpec, DataType
{
  new make() : super() {}

  override DataLib lib() { mt.lib }

  override Str qname() { mt.qname }

  override Str name() { mt.name }

  override Bool isaScalar() { mt.isaX(mt.env.sys.scalar) }

  override Bool isaMarker() { mt.isaX(mt.env.sys.marker) }

  override Bool isaSeq()    { mt.isaX(mt.env.sys.seq) }

  override Bool isaDict()   { mt.isaX(mt.env.sys.dict) }

  override Bool isaList()   { mt.isaX(mt.env.sys.list) }

  override Bool isaMaybe()  { mt.isaX(mt.env.sys.maybe) }

  override Bool isaAnd()    { mt.isaX(mt.env.sys.and) }

  override Bool isaOr()     { mt.isaX(mt.env.sys.or) }

  override Bool isaQuery()  { mt.isaX(mt.env.sys.query) }

  const MType? mt
}