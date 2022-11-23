//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent
using util
using proto

**
** ProtoLib implementation
**
@Js
internal const class MProtoLib : MProto, ProtoLib
{
  new make(FileLoc loc, Path path, AtomicRef baseRef, Str? val, Str:MProto children)
    : super(loc, path, baseRef, val, children)
  {
    // TODO: should be Version already once we reach here
    version = Version(get("_version").val)
  }

  override const Version version
}