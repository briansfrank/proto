//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 May 2022  Brian Frank  Creation
//

**
** Library is the root object for a module of versioned prototypes
**
@Js
const mixin Lib : Proto
{
  ** Version of the library
  abstract Version version()

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  abstract override Proto? trap(Str name, Obj?[]? args := null)
}



