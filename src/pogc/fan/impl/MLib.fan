//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Lib implementation
**
/* TODO
@Js
internal const class MLib : MProto, Lib
{
  new make(FileLoc loc, Path path, AtomicRef baseRef, Str? val, Str:MProto children)
    : super(loc, path, baseRef, val, children)
  {
    // TODO: should be Version already once we reach here
    version = Version(get("_version").val)
  }

  override const Version version
}
*/