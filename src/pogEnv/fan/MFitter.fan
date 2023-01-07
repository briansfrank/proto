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
  /*
  static const AtomicBool debug := AtomicBool(true)

  static Bool explain(Proto x, Proto type)
  {
    debug.val = true
    echo("~~ fits")
    echo("~~   $x: $x.isa ${x.val(false)}")
    echo("~~   $type: $type.isa ${type.valOwn(false)}")
    result := fits(x, type)
    echo("~~   ==> $result")
    debug.val = false
    return result
  }
  */

  static Bool fits(Proto? x, Proto type)
  {
    if (type.isa != null && type.isa.info.isMaybe)
    {
      if (x == null) return true
      of := type.getOwn("_of", false)
      if (of == null) return true
      return fits(x, of)
    }

    if (x == null) return false

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
    if (type.info.isObj) return true
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
      if (fits(actual, expect)) return null
      return "non-fit"
    }

    return result == null
  }

}

