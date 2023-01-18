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
    if (recs is Map) return make(env, recs)
    if (recs is List) return make(env, listToMap(recs))
    if (recs is Proto) return makePog(env, recs)
    throw ArgErr("Invalid set recs: $recs.typeof")
  }

  static MDataSet makePog(MDataEnv env, Proto pog)
  {
    map := Str:DataDict[:]
    pog.eachOwn |kid|
    {
      map[kid.name] = MDataDict.fromPog(env, kid)
    }
    return make(env, map)
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

  new make(MDataEnv env, Obj:DataDict map)
  {
    this.envRef = env
    this.map = map
  }

  override MDataEnv env() { envRef }
  const MDataEnv envRef

  const Obj:DataDict map

  override Int size()
  {
    map.size
  }

  override DataDict? get(Obj id, Bool checked := true)
  {
    rec := map[id]
    if (rec != null) return rec
    if (checked) throw UnknownDataErr(id.toStr)
    return null
  }

  override Void each(|DataDict rec, Obj id| f)
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
    MDataSet(env, map.findAll(f))
  }

  override DataSet findAllFits(DataType type)
  {
    findAll |rec| { rec.type.fits(type) }
  }

  override DataEventSet validate()
  {
    MDataEventSet(this, MDataEvent[,])
  }

  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("--- DataSet [$size] ---")
    each |rec, id| { out.printLine("$id: $rec") }
  }

}