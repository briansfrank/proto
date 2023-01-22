//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jan 2023  Brian Frank  Creation
//

using data

**
** Funcs for 'sys.lint'
**
@Js
const class Funcs
{
  static Obj findAllFits(DataDict args)
  {
    set := argSet(args, "set")
    type := argType(args, "type")
    return set.findAllFits(type)
  }

  static DataSet argSet(DataDict args, Str name)
  {
    x := args.get(name, null) ?: throw Err("Missing argument '$name'")
    return x as DataSet ?: throw Err("Expecting argument '$name' to be DataSet, not $x.typeof")
  }

  static DataType argType(DataDict args, Str name)
  {
    x := args.get(name, null) ?: throw Err("Missing argument '$name'")
    return x as DataType ?: throw Err("Expecting argument '$name' to be Type, not $x.typeof")
  }
}


