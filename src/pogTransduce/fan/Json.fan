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
    """json <data>                 Write data as JSON to stdout
       json <data> write:output    Write data as JSON to file
       json showdoc:<bool>         Toggle doc meta in results
       json showloc:<bool>         Toggle file location meta in results
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    if (args.containsKey("it")) return writeJson(args)
    throw ArgErr("Missing read or write argument")
  }

  TransduceData writeJson(Str:Obj? args)
  {
    cx  := TransduceContext(this, args)
    data := cx.arg("it")
    return cx.argWrite.withOutStream |out|
    {
      JsonPrinter(out, args).print(data.get(false))
      return data
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
    if (!showloc) keys.remove("_loc")
    if (!showdoc) keys.remove("_doc")

    if (keys.size == 0)
      wsymbol("{}")
    else if (keys.size <= 1 || map["_val"] != null)
      printCompact(keys, map)
    else
      printComplex(keys, map)
  }

  Void printCompact(Str[] keys, Str:Obj? map)
  {
    first := true
    wsymbol("{")
    if (keys.contains("_is"))  first = printPair("_is", map["_is"], false, first)
    if (keys.contains("_val")) first = printPair("_val", map["_val"], false, first)
    keys.each |n|
    {
      if (n == "_is" || n == "_val") return
      v := map[n]
      first = printPair(n, v, false, first)
    }
    wsymbol("}")
  }

  Void printComplex(Str[] keys, Str:Obj? map)
  {
    wsymbol("{").nl
    indention++
    first := true
    keys.each |n|
    {
      v := map[n]
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



