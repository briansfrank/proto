//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Jan 2023  Brian Frank  New Year!
//

using concurrent
using util
using pog
using pogEnv
using haystack

**
** Read transducer
**
@Js
const class ReadTransducer : Transducer
{
  new make(PogEnv env) : super(env, "read")
  {
    methods := Str:Method[:]
    typeof.methods.each |m|
    {
      if (!m.name.startsWith("read")) return
      name := m.name[4..-1].decapitalize
      methods[name] = m
    }
    this.methods = methods
  }

  const Str:Method methods

  override Str summary()
  {
    "Read file into memory"
  }

  override Str usage()
  {
    """read <file>            Read file type based on file name extension
       read pog:<file>        Read pog file as unvalidated Proto
       read json:<file>       Read JSON file as json object
       read zinc:<file>       Read Zinc file as haystack grid
       read hayson:<file>     Read Hayson JSON file as haystack grid
       read trio:<file>       Read Trio file as haystack grid
       read csv:<file>        Read CSV file as haystack grid
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)

    // lookup reader method by argument name
    result := methods.eachWhile |method, name|
    {
      from := args[name]
      if (from == null) return null
      return readMethod(cx, from, method)
    }
    if (result != null) return result

    // check by extension
    file := cx.argIt(false)?.getFile(false)
    if (file != null && file.ext != null)
    {
      method := methods[file.ext]
      if (method == null) throw ArgErr("No reader for file extension: $file.name")
      return readMethod(cx, cx.argIt, method)
    }

    throw Err("Unknown read file type: $args.keys.sort")
  }

  private TransduceData readMethod(TransduceContext cx, TransduceData from, Method method)
  {
    if (method.params.size == 2)
      return method.callOn(this, [cx, from])
    else
      return from.withInStream |in| { method.callOn(this, [cx, from, in]) }
  }

  private TransduceData readPog(TransduceContext cx, TransduceData from)
  {
    args := cx.args.dup
    args["it"] = from

    x := env.transduce("parse", args)
    if (x.isErr) return x

    x = env.transduce("resolve", args.dup.set("it", x))
    if (x.isErr) return x

    x = env.transduce("reify", args.dup.set("it", x))
    if (x.isErr) return x

    return x
  }

  private TransduceData readJson(TransduceContext cx, TransduceData from, InStream in)
  {
    json := JsonInStream(in).readJson
    return cx.toResult(json, ["json"], from.loc)
  }

  private TransduceData readZinc(TransduceContext cx, TransduceData from, InStream in)
  {
    grid := ZincReader(in).readGrid
    return cx.toResult(grid, ["grid", "zinc"], from.loc)
  }

  private TransduceData readHayson(TransduceContext cx, TransduceData from, InStream in)
  {
    grid := JsonReader(in).readGrid
    return cx.toResult(grid, ["grid", "hayson"], from.loc)
  }

  private TransduceData readTrio(TransduceContext cx, TransduceData from, InStream in)
  {
    grid := TrioReader(in).readGrid
    return cx.toResult(grid,  ["grid", "trio"], from.loc)
  }

  private TransduceData readCsv(TransduceContext cx, TransduceData from, InStream in)
  {
    grid := CsvReader(in).readGrid
    return cx.toResult(grid,  ["grid", "csv"], from.loc)
  }
}

