//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Dec 2022  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Validate transducer
**
@Js
const class ValidateTransducer : Transducer
{
  new make(PogEnv env) : super(env, "validate") {}

  override Str summary()
  {
    "Validate a proto graph"
  }

  override Str usage()
  {
    """validate <proto>    Validate proto
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx    := TransduceContext(this, args)
    data  := cx.argIt
    proto := Validator(cx).validate(data.getProto)
    return cx.toResult(proto, ["proto", "validated"], data.loc)
  }

}

**************************************************************************
** Validator
**************************************************************************

@Js
internal class Validator
{
  new make(TransduceContext cx) { this.cx = cx }

  Proto validate(Proto p)
  {
    stack.push(p)
    validateIs(p)
    validateLib(p)
    validateVal(p)
    validateDict(p)
    p.eachOwn |kid| { validate(kid) }
    stack.pop
    return p
  }

//////////////////////////////////////////////////////////////////////////
// Isa
//////////////////////////////////////////////////////////////////////////

  Void validateIs(Proto p)
  {
    if (p.isa == null)
    {
      if (p.qname.toStr != "sys.Obj") err("Missing is base object", p)
      return
    }

    if (p.isType)
    {
      validateIsSealed(p)
      validateIsFits(p)
    }
  }

  private Void validateIsSealed(Proto p)
  {
    if (p.isa.missingOwn("_sealed")) return
    if (p.qname.lib == p.isa.qname.lib) return
    err("Cannot extend sealed type '$p.isa'", p)
  }

  private Void validateIsFits(Proto p)
  {
    Fitter(cx).validate(p, p.isa)
  }

//////////////////////////////////////////////////////////////////////////
// Libs
//////////////////////////////////////////////////////////////////////////

  Void validateLib(Proto p)
  {
    if (!p.info.isLibRoot) return
    validateLibName(p)
    p.eachOwn |kid| { validateLibChild(p, kid) }
  }

  Void validateLibName(Proto lib)
  {
    if (lib.qname !== lib.qname.lib)
      err("Invalid qname for lib, each name must be start with lower case", lib)
  }

  Void validateLibChild(Proto lib, Proto p)
  {
    if (!p.isType && !p.isMeta)
      err("Invalid name for lib child - must be capitalized type name", p)
  }

//////////////////////////////////////////////////////////////////////////
// Vals
//////////////////////////////////////////////////////////////////////////

  Void validateVal(Proto p)
  {
    val := p.valOwn(false)
    if (val == null) return

    pattern := p.get("_pattern", false)
    if (pattern == null || !pattern.hasVal) return

    valStr := val.toStr
    if (!Regex(pattern.val.toStr).matches(valStr))
      cx.err("Scalar does not match ${pattern.qname.parent} pattern: ${valStr.toCode}", p)
  }

//////////////////////////////////////////////////////////////////////////
// Dict
//////////////////////////////////////////////////////////////////////////

  Void validateDict(Proto p)
  {
    if (!p.info.fitsDict || p.info.isDict) return

    type := p.isa
    type.each |slot|
    {
      if (!slot.isField) return

      slotObj := p.get(slot.name)

      if (slot === slotObj)
      {
        // if we have have inherited the field, then check for default value
        if (slot.info.fitsScalar && !slot.hasValOwn && !slotObj.hasValOwn && !slot.isa.info.isMarker)
          err("Missing scalar value for '${type}.${slot.name}'", p)
      }
      else
      {
        // check that slot object fits the slot type
        if (!slotObj.fits(slot))
          cx.err("Invalid type for '${type}.${slot.name}': '${slotObj.isa}' does not fit '$slot.isa'", slotObj)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Proto? parent()
  {
    stack.size <= 1 ? null : stack[-2]
  }

  Void err(Str msg, Proto proto)
  {
    cx.err(msg, proto)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  TransduceContext cx
  Proto[] stack := [,]
}


