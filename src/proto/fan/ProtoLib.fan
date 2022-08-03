//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 May 2022  Brian Frank  Creation
//

**
** Proto library is a root object of versioned prototypes
**
@Js
const mixin ProtoLib : Proto
{
  ** Version of the library
  abstract Version version()

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  override abstract Proto? trap(Str name, Obj?[]? args := null)
}



