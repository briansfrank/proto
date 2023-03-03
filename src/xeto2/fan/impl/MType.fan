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
  new make(XetoEnv env, FileLoc loc, XetoLib lib, Str qname, Str name, XetoType self, XetoType? base, DataDict own, MSlots declared, Obj? val)
    : super(env, loc, self, own, declared, val)
  {
    this.lib   = lib
    this.qname = qname
    this.name  = name
    this.base  = base
  }

  const XetoLib lib

  const Str qname

  const Str name

  override DataSpec spec() { env.sys.type }

  const XetoType? base

  override Str toStr() { qname }

  Bool isaX(XetoType that)
  {
    if (this === that.mt) return true
    base := this.base
    if (base == null) return false
    return base.mt.isaX(that)
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
  override DataLib lib() { mt.lib }

  override DataType? base() { mt.base }

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