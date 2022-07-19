//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 May 2022  Brian Frank  Creation
//

**
** ProtoSpace models a namespace tree of protos.
**
@Js
const mixin ProtoSpace
{
  ** The core system library
  abstract ProtoLib sys()

  ** Libraries used by this namespace
  abstract ProtoLib[] libs()

  ** Lookup a library by its root name
  abstract ProtoLib? lib(Str name, Bool checked := true)

  ** The object type from which all other objects inherit
  abstract Proto obj()

  ** The str type object
  abstract Proto str()

  ** The marker type object
  abstract Proto marker()

  ** Root object for this space
  abstract Proto root()

  ** Get the proto at the given path
  @Operator abstract Proto? get(Path path, Bool checked := true)
}



