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
mixin ProtoLib : Proto
{
  ** Fantom pod which defines the library
  abstract Pod pod()

  ** Version of the library
  abstract Version version()
}



