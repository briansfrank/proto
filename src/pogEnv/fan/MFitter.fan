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
    // echo("~~ fits $x: $x.isa ${x.val(false)} FITS $type: $type.isa ${type.valOwn(false)} ===> $r")

    if (fitsNominal(x, toNominalType(type)))
    {
      return fitsEquals(x, type)
    }

    if (fitsStructural(x, type))
    {
      return true
    }

    return false
  }

  private static Proto toNominalType(Proto type)
  {
    if (type.isType) return type
    return type.isa
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

  private static Bool fitsEquals(Proto x, Proto type)
  {
    if (type.missing("_equals")) return true

    expect := type.valOwn(false)
    if (expect == null) return true

    actual := x.val(false)
    if (actual == null) return false

    return actual == expect || actual.toStr == expect.toStr
  }

  private static Bool fitsStructural(Proto x, Proto type)
  {
    if (!x.info.fitsDict) return false
    if (!type.info.fitsDict) return false

    result := type.eachWhile |expect|
    {
      if (expect.isMeta) return null

      actual := x.get(expect.name, false)
      if (actual != null && fits(actual, expect)) return null

      return "non-fit"
    }

    return result == null
  }

}

