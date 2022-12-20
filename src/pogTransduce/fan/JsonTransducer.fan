//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** JSON transducer
**
@Js
const class JsonTransducer : MTransducer
{
  new make(PogEnv env) : super(env, "json") {}

  override Str summary()
  {
    "Parse pog source into AST"
  }

  override Str usage()
  {
    """Summary:
         Read or write objects in JSON format.
       Usage:
         json read:input              Read given input stream
         json val:obj write:output    Write object to output stream
       Arguments:
         read                         Input file, string, or 'stdin'
         write                        Output file or 'stdout'
         obj                          Object tree or proto graph
       """
  }

  override Obj? transduce(Str:Obj? args)
  {
    if (args.containsKey("read")) return readJson(args)
    if (args.containsKey("write")) return writeJson(args)
    throw ArgErr("Missing read or write argument")
  }

  Obj? readJson(Str:Obj? args)
  {
    read(args) |in, loc|
    {
      JsonInStream(in).readJson
    }

  }

  Obj? writeJson(Str:Obj? args)
  {
    val := arg(args, "val")
    return write(args) |out|
    {
      JsonOutStream(out).writeJson(val)
    }
  }
}

