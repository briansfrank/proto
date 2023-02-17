//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data
using xeto

**
** DataLib implementation
**
@Js
internal const class MDataLib : MDataDef, DataLib
{
  new make(MDataEnv env, Str qname, XetoObj ast)
  {
    this.env      = env
    this.loc      = ast.loc
    this.qname    = qname
    this.meta     = env.astMeta(ast.meta)
    this.version  = Version(this.meta["version"] as Str ?: "0")
    this.libTypes = MDataType.reify(this, ast)
    this.map      = Str:DataType[:].addList(libTypes) { it.name }
  }

  const override MDataEnv env
  override MDataLib lib() { this }
  override DataType type() { env.sys.libType }

  const override FileLoc loc
  const override Str qname
  const override Dict meta
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