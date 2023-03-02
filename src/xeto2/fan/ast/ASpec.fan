//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Mar 2023  Brian Frank  Creation
//

using concurrent
using util

**
** AST DataType
**
@Js
internal class ASpec : AVal
{
  ** Constructor
  new make(FileLoc loc, ARef? type, XetoSpec asm)
  {
    this.loc    = loc
    this.type   = type
    this.asmRef = asm
  }

  ** Source code location
  const override FileLoc loc

  ** Return 'asm' XetoSpec as the assembled value
  override Obj? asmVal() { asm }

  ** Reference to the DataSpec - we backpatch the "m" field in Assemble step
  virtual XetoSpec asm() { asmRef }
  const XetoSpec asmRef

  ** Type ref for this spec.  Null if this is Obj or we need to infer type
  ARef? type

  ** Additional meta-data fields for DataSpec.own
  AMap meta := AMap()

  ** Map of ASpecs for slot specs
  AMap slots := AMap()

  ** Default value for a scalar spec
  AVal? val

  ** Debug string
  override Str toStr() { "$type <$meta>" }
}

**************************************************************************
** TODO
**************************************************************************

**
** AST spec - type and meta
**
@Js
internal class ASpecX
{
  ARef? type
  AMap meta := AMap()

  FileLoc loc() { type?.loc ?: FileLoc.unknown }

  Bool isTypeOnly() { meta.isEmpty }

  override Str toStr()
  {
    if (isTypeOnly && type != null)
      return type.toStr
    else
      return "$type <$meta>"
  }
}