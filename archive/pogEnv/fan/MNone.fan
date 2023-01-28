//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Jan 2022  Brian Frank  Creation
//

using concurrent
using pog
using util

**
** Implementation for bottom None type
**
@Js
internal const final class MNone : MProto
{
  new make(MProtoInit init) : super(init) {}

  override Bool isNone() { true }
}