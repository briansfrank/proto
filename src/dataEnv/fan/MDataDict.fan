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

**************************************************************************
** MAbstractDict
**************************************************************************

@Js
internal const abstract class MAbstractDict : DataDict
{
  override Bool has(Str name) { get(name, null) != null }
  override Bool missing(Str name) { get(name, null) == null }
  override Void seqEach(|Obj?| f) { each(f) }
  override Obj? seqEachWhile(|Obj?->Obj?| f) { eachWhile(f) }
  override DataDictTransform x() { MDataDictTransform(this) }
}

**************************************************************************
** MEmptyDict
**************************************************************************

@Js
internal const class MEmptyDict : MAbstractDict
{
  new make(DataType type) { this.type = type }
  const override DataType type
  override Bool has(Str name) { false }
  override Bool missing(Str name) { true }
  override Bool isEmpty() { true }
  override Obj? get(Str name, Obj? def := null) { def }
  override Obj? trap(Str n, Obj?[]? a := null) { throw UnknownSlotErr(n) }
  override Void each(|Obj?, Str| f) {}
  override Obj? eachWhile(|Obj?, Str->Obj?| f) { null }
  override Str toStr() { "{}" }
}

**************************************************************************
** MMapDict
**************************************************************************

@Js
internal const class MMapDict : MAbstractDict
{
  new make(DataType type, Str:Obj? map) { this.type = type; this.map = map }
  const override DataType type
  override Bool isEmpty() { map.isEmpty }
  override Obj? get(Str name, Obj? def := null) { map.get(name, def) }
  override Obj? trap(Str n, Obj?[]? a := null) { MDataUtil.dictTrap(this, n) }
  override Void each(|Obj?,Str| f) { map.each(f) }
  override Obj? eachWhile(|Obj?,Str->Obj?| f) { map.eachWhile(f) }
  override Str toStr() { MDataUtil.dictToStr(this) }
  const Str:Obj? map
}

**************************************************************************
** MProtoDict (TODO)
**************************************************************************

@Js
internal const class MProtoDict : MAbstractDict
{
  static DataDict fromMeta(MDataEnv env, Proto p)
  {
    acc := Str:Obj?[:]
    p.eachOwn |kid|
    {
      if (kid.isMeta && kid.hasVal)
        acc[kid.name[1..-1]] = kid.val
    }
    return make(env, acc)
  }

  static DataDict fromOwn(MDataEnv env, Proto p)
  {
    acc := Str:Obj?[:]
    p.eachOwn |kid|
    {
      if (kid.hasVal)
        acc[kid.name] = kid.val
      else
        acc[kid.name] = fromOwn(env, kid)
    }
    return make(env, acc)
  }

  new make(MDataEnv env, Str:Obj map) { this.env = env; this.map = map }
  const MDataEnv env
  override DataType type() { env.sys.dict }
  override Bool has(Str name) { map[name] != null }
  override Bool missing(Str name) { map[name] == null }
  override Bool isEmpty() { map.isEmpty }
  override Obj? get(Str name, Obj? def := null) { map.get(name, def) }
  override Obj? trap(Str n, Obj?[]? a := null) { MDataUtil.dictTrap(this, n) }
  override Void each(|Obj?,Str| f) { map.each(f) }
  override Obj? eachWhile(|Obj?,Str->Obj?| f) { map.eachWhile(f) }
  override Str toStr() { MDataUtil.dictToStr(this) }
  const Str:Obj? map
}

**************************************************************************
** MDataDictTransform
**************************************************************************

@Js
class MDataDictTransform : DataDictTransform
{
  new make(DataDict source) { this.source = source }

  override This map(|Obj?->Obj?| f)
  {
    init
    acc = acc.map(f)
    return this
  }

  override This findAll(|Obj?->Bool| f)
  {
    init
    acc = acc.findAll(f)
    return this
  }

  override DataDict collect()
  {
    if (acc == null) return source
    return source.type.env.dict(acc)
  }

  This init()
  {
    if (acc != null) return this
    acc = Str:Obj?[:]
    source.each |v, n| { acc[n] = v }
    return this
  }

  private const DataDict source
  private [Str:Obj]? acc
}

