//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Jan 2023  Brian Frank  Creation
//

using concurrent
using pog
using util

**
** Or implementation
**
@Js
internal const class MOr : MProto
{
  new make(MProtoInit init) : super(init) {}

  override Bool isOr() { true }
}