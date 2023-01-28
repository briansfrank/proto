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

    result := Fitter(cx).fits(data, type)
    return cx.toResult(result, Str[,], data.loc)
  }
}

**************************************************************************
** Fitter
**************************************************************************

@Js
internal class Fitter
{
  new make(TransduceContext cx)
  {
    this.cx   = cx
    this.isExplain = true // cx.hasArg("explain")
  }

  Void validate(Proto x, Proto type)
  {
    if (!fits(x, type))
      cx.err("No fit: $x | $type", x)
  }

  Bool fits(Proto? x, Proto type)
  {
    if (type.isa != null && type.isa.info.isMaybe)
    {
      if (x == null) return true
      of := type.getOwn("_of", false)
      if (of == null) return true
      return fits(x, of)
    }

    if (x == null) return false

    if (type.info.isObj) return true

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

  private Proto toNominalType(Proto type)
  {
    if (type.isType) return type
    return type.isa
  }

  private Bool fitsSame(Proto x, Proto type)
  {
    x === type
  }

  private Bool fitsNominal(Proto x, Proto type)
  {
    if (type.info.isObj) return true
    if (x.info.isObj || x.info.isDict) return false
    if (fitsSame(x, type)) return true
    return fitsNominal(x.isa, type)
  }

  private Bool fitsEquals(Proto x, Proto type)
  {
    if (type.missing("_equals")) return true

    expect := type.valOwn(false)
    if (expect == null) return true

    actual := x.val(false)
    if (actual == null) return false

    return actual == expect || actual.toStr == expect.toStr
  }

  private Bool fitsStructural(Proto x, Proto type)
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

  TransduceContext cx       // make
  const Bool isExplain      // make
}

