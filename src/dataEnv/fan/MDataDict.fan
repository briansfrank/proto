//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data
using pog

**
** DataDict implementation
**
@Js
internal const class MDataDict : DataDict
{
  static MDataDict fromPogMeta(Proto p)
  {
    acc := Str:Obj?[:]
    p.each |kid|
    {
      if (kid.isMeta && kid.hasVal)
        acc[kid.name[1..-1]] = kid.val
    }
    return make(acc)
  }

  new make(Str:Obj? map, DataType? type := null) { this.map = map; typeRef = type }

  override DataType type() { typeRef ?: ((MDataEnv)DataEnv.cur).sys.dict }
  const DataType? typeRef

  override DataObj? getData(Str name, Bool checked := true) { throw Err("TODO") }

  override Void eachData(|DataObj,Str| f) { throw Err("TODO") }

  override Obj? get(Str name, Obj? def := null) { map.get(name, def) }

  override Str toStr()
  {
    s := StrBuf()
    map.each |v, n|
    {
      s.join(n, ", ")
      if (v.toStr != "marker")
      {
        s.add(":").add(v.toStr.toCode)
      }
    }
    return s.toStr
  }

  const Str:Obj? map
}

**************************************************************************
** MEmptyDict
**************************************************************************

@Js
internal const class MEmptyDict : DataDict
{
  new make(DataType type) { this.type = type }

  const override DataType type

  override DataObj? getData(Str name, Bool checked := true) { throw Err("TODO") }

  override Void eachData(|DataObj,Str| f) {}

  override Obj? get(Str name, Obj? def := null) { def }

  override Str toStr() { "{}" }
}

