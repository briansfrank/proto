//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Single unit of immutable data and its data type.
**
@Js
const mixin DataObj
{
  ** Data type for this object
  abstract DataType type()
}