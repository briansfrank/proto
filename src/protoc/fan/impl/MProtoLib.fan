//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto

**
** ProtoLib implementation
**
internal const class MProtoLib : MProto, ProtoLib
{
  new make(Path path, MProto? type, Str? val, Str:MProto children)
    : super(path, type, val, children)
  {
  }

  override Version version() { throw Err("TODO") }
}