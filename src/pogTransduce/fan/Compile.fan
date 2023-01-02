//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Jan 2023  Brian Frank  New Year!
//

using concurrent
using util
using pog
using pogEnv

**
** Compile transducer
**
@Js
const class CompileTransducer : Transducer
{
  new make(PogEnv env) : super(env, "compile") {}

  override Str summary()
  {
    "Convenience to parse, resolve, reify, and validate"
  }

  override Str usage()
  {
    """compile file            Convenience for read:file
       compile read:           Compile from prompt
       compile read:file       Compile file
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    x := env.transduce("parse", args)
    if (x.isErr) return x

    x = env.transduce("resolve", args.dup.set("it", x))
    if (x.isErr) return x

    x = env.transduce("reify", args.dup.set("it", x))
    if (x.isErr) return x

    x = env.transduce("validate", args.dup.set("it", x))
    if (x.isErr) return x

    return x
  }
}

