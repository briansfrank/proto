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
internal const class MDataLib : MDataDef, DataLib
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
    this.meta     = MProtoDict.fromMeta(env, pog)

    this.libTypes = MDataType.fromPog(this, pog)
    this.map = Str:DataType[:].addList(libTypes) { it.name }
  }

  const override MDataEnv env
  override MDataLib lib() { this }
  override DataType type() { env.sys.libType }

  const override FileLoc loc
  const override Str qname
  const override DataDict meta
  const override Version version
  const override DataType[] libTypes := [,]
  const override Str:DataType map

  override DataType? libType(Str name, Bool checked := true)
  {
    lib := map[name]
    if (lib != null) return lib
    if (checked) throw UnknownTypeErr("${qname}.${name}")
    return null
  }
}