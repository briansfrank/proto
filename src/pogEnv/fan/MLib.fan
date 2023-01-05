//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Dec 2022  Brian Frank  Creation
//

using concurrent
using pog
using util

**
** Lib implementation
**
@Js
internal const class MLib : MProto, Lib
{
  new make(MProtoInit init) : super(init) {}

  once override Version version() { Version.fromStr(getOwn("_version").val.toStr) }

  override Bool isLib() { true }
}