//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Jan 2023  Brian Frank  Creation
//

using util
using data
using pog

**
** DataSet implementation
**
@Js
internal const class MDataSet : DataSet
{
  static MDataSet factory(MDataEnv env, Obj recs)
  {
    if (recs is DataSet) return recs
    type := env.type("sys.DictSeq")
    if (recs is Map) return make(type, recs)
    if (recs is List) return make(type, listToMap(recs))
    if (recs is Proto) return makePog(type, recs)
    throw ArgErr("Invalid set recs: $recs.typeof")
  }

  static MDataSet makePog(MDataType type, Proto pog)
  {
    map := Str:DataDict[:]
    pog.eachOwn |kid|
    {
      map[kid.name] = MProtoDict.fromOwn(type.env, kid)
    }
    return make(type, map)
  }

  static Obj:DataDict listToMap(DataDict[] recs)
  {
    map := Obj:DataDict[:]
    Str? autoPrefix
    auto := 0
    recs.each |rec|
    {
      id := rec.get("id", null)
      if (id == null)
      {
        if (autoPrefix == null) autoPrefix = Int.random.and(0xFFFF_FFFF).toHex(8)
        id = "_" + autoPrefix + "-" + (auto++)
      }
      if (id != null)
      {
        map[id] = rec
      }
      map[id] = rec
    }
    return map
  }

  new make(MDataType type, Obj:DataDict map)
  {
    this.type = type
    this.map = map
  }

  override DataEnv env() { type.env }

  const override DataType type

  const Obj:DataDict map

  override Bool has(Str name) { map[name] != null }

  override Bool missing(Str name) { map[name] == null }

  override Bool isEmpty() { map.isEmpty }

// TODO
  override Obj? get(Str name, Obj? def := null) { map.get(name, def) }

  override Obj? trap(Str n, Obj?[]? a := null) { MDataUtil.dictTrap(this, n) }

  override Void seqEach(|Obj?| f) { map.each(f) }

  override Obj? seqEachWhile(|Obj?->Obj?| f) { map.eachWhile(f) }

  override Void each(|Obj?,Str| f) { map.each(f) }

  override Obj? eachWhile(|Obj?,Str->Obj?| f) { map.eachWhile(f) }

  override Int size()
  {
    map.size
  }

  override DataDict? getById(Obj id, Bool checked := true)
  {
    rec := map[id]
    if (rec != null) return rec
    if (checked) throw UnknownDataErr(id.toStr)
    return null
  }

  override Void eachById(|DataDict rec, Obj id| f)
  {
    map.each(f)
  }

  override Obj:DataDict toMap()
  {
    map
  }

  override DataDict[] toList()
  {
    map.vals
  }

  override DataDict? find(|DataDict rec, Obj id->Bool| f)
  {
    map.find(f)
  }

  override DataSet findAll(|DataDict rec, Obj id->Bool| f)
  {
    MDataSet(type, map.findAll(f))
  }

  override DataSet findAllFits(DataType type)
  {
    findAll |rec| { fits(rec, type) }
  }

  private Bool fits(DataDict rec, DataType type)
  {
    // nominal typing
    if (rec.type.inherits(type)) return true

    // TODO: just stub out very simple structural typing
    return type.slots.all |slot|
    {
      if (slot.slotType.qname == "sys.Maybe") return true
      if (slot.name == "points") return true
      val := rec.get(slot.name, null)
      if (val == null) return false
      return true
    }
  }

  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("--- DataSet [$size] ---")
    each |rec, id| { out.printLine("$id: $rec") }
  }

}