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
    validateLib(p)
    validateVal(p)
    validateFit(p)
    p.eachOwn |kid| { validate(kid) }
    stack.pop
    return p
  }

//////////////////////////////////////////////////////////////////////////
// Libs
//////////////////////////////////////////////////////////////////////////

  Void validateLib(Proto p)
  {
    if (!p.info.isLib) return
    validateLibName(p)
    p.eachOwn |kid| { validateLibChild(p, kid) }
  }

  Void validateLibName(Proto lib)
  {
    if (lib.qname !== lib.qname.lib)
      err("Invalid qname for lib, each name must be start with lower case", lib)
  }

  Void validateLibChild(Proto lib, Proto proto)
  {
    if (!proto.qname.isUpperName && !proto.isMeta)
      err("Invalid name for lib child, name must start with upper case", proto)
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

  Void validateFit(Proto p)
  {
    parentType := parent?.isa
    if (parentType == null) return

    slotType := parentType.get(p.name, false)?.isa
    if (slotType == null) return

    if (!p.fits(slotType))
      cx.err("Invalid type for '${parentType}.${p.name}': '${p.isa}' does not fit '$slotType'", p)

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


