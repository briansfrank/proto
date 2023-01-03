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
       read zinc:<file>       Read Zinc file as Haystack grid
       read hayson:<file>     Read Hayson JSON file as Haystack grid
       read trio:<file>       Read Trio file as Haystack grid
       read csv:<file>        Read CSV file as Haystack grid
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)

    // lookup reader method by argument name
    result := methods.eachWhile |method, name|
    {
      arg := args[name]
      if (arg == null) return null
      return method.callOn(this, [cx, arg])
    }
    if (result != null) return result

    // check by extension
    file := cx.arg("it", false)?.getFile(false)
    if (file != null && file.ext != null)
    {
      method := methods[file.ext]
      if (method == null) throw ArgErr("No reader for file extension: $file.name")
      return method.callOn(this, [cx, cx.arg("it")])
    }

    throw Err("Unknown read file type: $args")
  }

  private TransduceData readPog(TransduceContext cx, TransduceData data)
  {
    args := cx.args.dup
    args["it"] = data

    x := env.transduce("parse", args)
    if (x.isErr) return x

    x = env.transduce("resolve", args.dup.set("it", x))
    if (x.isErr) return x

    x = env.transduce("reify", args.dup.set("it", x))
    if (x.isErr) return x

    return x
  }

  private TransduceData readZinc(TransduceContext cx, TransduceData data)
  {
    data.withInStream |in|
    {
      grid := ZincReader(in).readGrid
      return cx.toResult(grid, ["grid", "zinc"], data.loc)
    }
  }

  private TransduceData readHayson(TransduceContext cx, TransduceData data)
  {
    data.withInStream  |in|
    {
      grid := JsonReader(in).readGrid
      return cx.toResult(grid, ["grid", "hayson"], data.loc)
    }
  }

  private TransduceData readTrio(TransduceContext cx, TransduceData data)
  {
    data.withInStream  |in|
    {
      grid := TrioReader(in).readGrid
      return cx.toResult(grid,  ["grid", "trio"], data.loc)
    }
  }

  private TransduceData readCsv(TransduceContext cx, TransduceData data)
  {
    data.withInStream  |in|
    {
      grid := CsvReader(in).readGrid
      return cx.toResult(grid,  ["grid", "csv"], data.loc)
    }
  }
}

