//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Jan 2023  Brian Frank  Creation
//

using data
using axonx

**
** Experimental functions to eventually push back into core
**
class XFuncs
{
  **
  ** Test if the given value fits the type.
  **
  ** Examples:
  **    fits("foo", Str)    // returns true
  **    fits(123, Str)      // returns false
  **
  @Axon static Bool fits(Obj? val, DataType type)
  {
    cx.data.fits(val, type)
  }

  ** Explain why value does not fit given type.
  ** If it does fit return the empty data set.
  @Axon static DataSet fitsExplain(Obj? val, DataType type)
  {
    cx.data.fitsExplain(val, type)
  }

  private static Context cx() { AxonContext.curAxon }
}