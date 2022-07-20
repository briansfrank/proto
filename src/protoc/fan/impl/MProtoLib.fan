//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent
using proto

**
** ProtoLib implementation
**
internal const class MProtoLib : MProto, ProtoLib
{
  new make(Path path, AtomicRef typeRef, Str? val, Str:MProto children)
    : super(path, typeRef, val, children)
  {
    // TODO: should be Version already once we reach here
    version = Version(get("_version").val)
  }

  override const Version version
}