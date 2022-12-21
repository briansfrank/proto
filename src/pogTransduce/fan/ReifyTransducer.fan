//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//

using util
using pog

**
** Reify transducer
**
@Js
const class ReifyTransducer : Transducer
{
  new make(PogEnv env) : super(env, "reify") {}

  override Str summary()
  {
    "Construct a Proto tree from an AST object tree"
  }

  override Str usage()
  {
    """Summary:
         Construct a Proto tree from an AST object tree.  All
         qualified and relative names are resolved to their protos.
       Usage:
         reify ast:obj                Transform AST to Protos
       Arguments:
         obj                          AST object tree
       """
  }

  override Transduction transduce(Str:Obj? args)
  {
    throw Err("TODO")
  }

}