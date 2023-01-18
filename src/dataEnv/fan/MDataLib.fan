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
** DataLib implementation
**
@Js
internal const class MDataLib : DataLib
{
  new make(MDataEnv env, Str qname)
  {
    // TODO: load from existing pog engine
    pog := PogEnv.cur.load(qname)
    sys := qname == "sys" ? pog : PogEnv.cur.load("sys")

    this.env      = env
    this.loc      = pog.loc
    this.qname    = qname
    this.version  = pog.version
    this.meta     = MDataDict.fromPogMeta(pog)

    this.types = MDataType.fromPog(this, pog)
    this.typesMap = Str:DataType[:].addList(types) { it.name }
  }

  const override MDataEnv env
  const override FileLoc loc
  const override Str qname
  const override DataDict meta
  const override Version version
  const override DataType[] types := [,]
  const Str:DataType typesMap

  override Str doc() { meta.getData("doc", false) as Str ?: "" }
  override Str toStr() { qname }

  override DataType? type(Str name, Bool checked := true)
  {
    lib := typesMap[name]
    if (lib != null) return lib
    if (checked) throw UnknownTypeErr("${qname}.${name}")
    return null
  }
}