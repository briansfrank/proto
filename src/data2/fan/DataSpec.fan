//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Data specification.
**
@Js
const mixin DataSpec : DataDict
{

  ** Environment for spec
  abstract DataEnv env()

  ** Type of this spec.   If this spec is a DataType itself then return self.
  abstract DataType type()

  ** Get the declared children slots
  abstract DataSlots declared()

  ** Get the effective children slots including inherited
  //abstract DataSlots slots()

  ** Scalar value or null
  abstract Obj? val()

  ** File location of definition or unknown
  @NoDoc abstract FileLoc loc()

}