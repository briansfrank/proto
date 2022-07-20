//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto

**
** Built-in system prototypes
**
internal class CSys
{
  new make(|This| f) { f(this) }
  CProto obj
  CProto str
}