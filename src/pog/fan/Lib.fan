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
const class Lib : Proto
{
  ** Version of the library
  Version version() { Version.fromStr(getOwn("_version").val) }
}



