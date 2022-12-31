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
    """json data                 Write data as JSON to stdout
       json data write:output    Write data as JSON to file
       json read:file            Read JSON from file
       """
  }

  override Transduction transduce(Str:Obj? args)
  {
    if (args.containsKey("read")) return readJson(args)
    if (args.containsKey("it")) return writeJson(args)
    throw ArgErr("Missing read or write argument")
  }

  Transduction readJson(Str:Obj? args)
  {
    TransduceContext(this, args).read("read") |in, loc|
    {
      JsonInStream(in).readJson
    }
  }

  Transduction writeJson(Str:Obj? args)
  {
    cx := TransduceContext(this, args)
    val := cx.arg("it")
    output := cx.arg("write", false) ?: Env.cur.out
    return cx.write(output) |out|
    {
      JsonPrinter(out).print(val)
      return val
    }
  }
}

**************************************************************************
** JsonPrinter
**************************************************************************

@Js
internal class JsonPrinter : Printer
{
  new make(OutStream out, [Str:Obj?]? opts := null) : super(out, opts) {}

  Void print(Obj? val)
  {
    if (val is Proto)
      printProto(val)
    else if (val is Map)
      printMap(val)
    else if (val is List)
      printList(val)
    else
      wquoted(val.toStr)
  }

  Void printProto(Proto proto)
  {
    map := Str:Obj[:]
    map.ordered = true
    map.addNotNull("_is", proto.isa?.qname)
    map.addNotNull("_val", proto.valOwn(false))
    proto.eachOwn |kid|
    {
      map[kid.name] = kid
    }
    printMap(map)
  }

  Void printMap(Str:Obj? map)
  {
    keys := map.keys
    if (keys.size == 0)
      wsymbol("{}")
    else if (keys.size <= 1 || map["_val"] != null)
      printCompact(map)
    else
      printComplex(map)
  }

  Void printCompact(Str:Obj? map)
  {
    first := true
    wsymbol("{")
    if (map.containsKey("_is"))  first = printPair("_is", map["_is"], false, first)
    if (map.containsKey("_val")) first = printPair("_val", map["_val"], false, first)
    map.each |v, n|
    {
      if (n == "_is" || n == "_val") return
      first = printPair(n, v, false, first)
    }
    wsymbol("}")
  }

  Void printComplex(Str:Obj? map)
  {
    wsymbol("{").nl
    indention++
    first := true
    map.each |v, n|
    {
      first = printPair(n, v, true, first)
    }
    indention--
    nl.windent.wsymbol("}")
  }

  Bool printPair(Str n, Obj? v, Bool indenting, Bool first)
  {
    if (first)
    {
      if (indenting) windent
    }
    else
    {
      if (indenting)
         wsymbol(",").nl.windent
      else
        wsymbol(",").sp
    }
    wquoted(n)
    wsymbol(":")
    print(v)
    return false
  }

  Void printList(Obj?[] list)
  {
    // TODO
    throw Err("TODO")
  }

}



