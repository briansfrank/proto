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
mixin ProtoSpace
{
  ** The core language library
  abstract Proto lang()

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

  ** Libraries used by this namespace
  abstract ProtoLib[] libs()

  ** Lookup a library by its root name
  abstract ProtoLib? lib(Str name, Bool checked := true)

  ** Current point in time transaction id.
  abstract Int tx()
}



