//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using data

**
** MFitter implements DataEnv.fits
**
@Js
const class MFitter
{
  new make(DataEnv env)
  {
    this.env = env
    this.sys = this.env.sys
  }

  Bool fits(Obj? val, DataType type)
  {
    // get type for value
    valType := env.typeOf(val, false)
    if (valType == null) return false

    // check nominal typing
    if (valType.inherits(type)) return true

    // check structurally typing
    return false
  }

  private const MDataEnv env
  private const MSys sys
}