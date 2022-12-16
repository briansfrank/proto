//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

using pog

**
** Parse transducer
**
@Js
const class ParseTransducer : ReadTransducer
{
  new make(PogEnv env) : super(env, "parse") {}

  override Str summary()
  {
    "Parse pog source into AST"
  }

  override Obj read(InStream in)
  {
    str := in.readAllStr
    return "parse input $str.size chars"
  }
}


