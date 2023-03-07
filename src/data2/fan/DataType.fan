//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** DataType is a named DataSpec in a DataLib.
**
@Js
const mixin DataType : DataSpec
{

  ** Parent library for type
  abstract DataLib lib()

}

