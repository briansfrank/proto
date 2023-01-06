//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   6 Jan 2022  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** MFitter is used to implement Proto.fits
**
@Js
class MFitter
{
  static Bool fits(Proto x, Proto type)
  {
    if (fitsNominal(x, type)) return true
    if (fitsStructural(x, type)) return true
    return false
  }

  private static Bool fitsSame(Proto x, Proto type)
  {
    x === type
  }

  private static Bool fitsNominal(Proto x, Proto type)
  {
    if (x.info.isObj || x.info.isDict) return false
    if (fitsSame(x, type)) return true
    return fitsNominal(x.isa, type)
  }

  private static Bool fitsStructural(Proto x, Proto type)
  {
    if (!x.info.fitsDict) return false
    if (!type.info.fitsDict) return false

    result := type.eachWhile |expect|
    {
      if (expect.isMeta) return null

      actual := x.get(expect.name, false)
      if (actual != null && fits(actual, expect.isa)) return null

      return "non-fit"
    }

    return result == null
  }

}

