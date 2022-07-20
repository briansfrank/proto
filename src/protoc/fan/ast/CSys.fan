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

  CProto obj        // sys.Obj
  CProto str        // sys.Str
  CProto objDoc     // sys.Obj._doc
}