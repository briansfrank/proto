//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** JSON transducer
**
@Js
const class JsonTransducer : Transducer
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

  override Transduction transduce(Str:Obj? args)
  {

    if (args.containsKey("read")) return readJson(args)
    if (args.containsKey("write")) return writeJson(args)
    throw ArgErr("Missing read or write argument")
  }

  Transduction readJson(Str:Obj? args)
  {
    TransduceContext(this, args).read |in, loc|
    {
      JsonInStream(in).readJson
    }
  }

  Transduction writeJson(Str:Obj? args)
  {
    cx := TransduceContext(this, args)
    val := cx.arg("val")
    return cx.write |out|
    {
      JsonPrinter(out).printVal(val)
      return val
    }
  }
}

**************************************************************************
** JsonPrinter
**************************************************************************

@Js
internal class JsonPrinter
{
  new make(OutStream out) { this.out = JsonOutStream(out) }

  Void printVal(Obj? val)
  {
    if (val is Map)
      printMap(val)
    else
      out.writeJson(val.toStr)
  }

  Void printMap(Str:Obj? map)
  {
    keys := map.keys
    if (keys.size == 0)
      out.print("{}")
    else if (keys.size <= 1 || map["_val"] != null)
      printCompact(map)
    else
      printComplex(map)
  }

  Void printCompact(Str:Obj? map)
  {
    first := true
    out.print("{")
    if (map.containsKey("_is"))  first = printPair("_is", map["_is"], -1, first)
    if (map.containsKey("_val")) first = printPair("_val", map["_val"], -1, first)
    map.each |v, n|
    {
      if (n == "_is" || n == "_val") return
      first = printPair(n, v, -1, first)
    }
    out.print("}")
  }

  Void printComplex(Str:Obj? map)
  {
    out.printLine("{")
    indention++
    first := true
    map.each |v, n|
    {
      first = printPair(n, v, indention, first)
    }
    out.printLine.print(Str.spaces(indention*2)).print("}")
    indention--
  }

  Bool printPair(Str n, Obj? v, Int indent, Bool first)
  {
    if (first)
    {
      if (indent > 0) out.print(Str.spaces(indent*2))
    }
    else
    {
      if (indent > 0)
         out.printLine(",").print(Str.spaces(indent*2))
      else
        out.print(", ")
    }
    out.writeJson(n)
    out.writeChar(':')
    printVal(v)
    return false
  }

  JsonOutStream out
  Int indention
}



