//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   6 Jan 2022  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Fits transducer
**
@Js
const class FitsTransducer : Transducer
{
  new make(PogEnv env) : super(env, "fits") {}

  override Str summary()
  {
    "Return if proto fits a type"
  }

  override Str usage()
  {
    """fits type:<proto>           Does last value fit type
       fits <data> type:<proto>    Does given data fit type
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    data := cx.argIt.getProto
    type := cx.arg("type").getProto

    result := Fitter(cx, data, type).fits
    return cx.toResult(result, [,], data.loc)
  }
}

**************************************************************************
** Fitter
**************************************************************************

@Js
internal class Fitter
{
  new make(TransduceContext cx, Proto data, Proto type)
  {
    this.cx   = cx
    this.data = data
    this.type = type
  }

  Bool fits()
  {
    doFits(data, type)
  }

  static Bool doFits(Proto? x, Proto type)
  {
    if (type.isa != null && type.isa.info.isMaybe)
    {
      if (x == null) return true
      of := type.getOwn("_of", false)
      if (of == null) return true
      return doFits(x, of)
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
      if (doFits(actual, expect)) return null
      return "non-fit"
    }

    return result == null
  }

  TransduceContext cx       // make
  const Proto data          // make
  const Proto type          // make
}

