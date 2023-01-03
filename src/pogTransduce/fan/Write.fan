//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
using pog
using pogEnv
using haystack

**
** Write transducer
**
@Js
const class WriteTransducer : Transducer
{
  new make(PogEnv env) : super(env, "write")
  {
    methods := Str:Method[:]
    typeof.methods.each |m|
    {
      if (!m.name.startsWith("write")) return
      name := m.name[5..-1].decapitalize
      methods[name] = m
    }
    this.methods = methods
  }

  const Str:Method methods

  override Str summary()
  {
    "Write in-memory data to file or stdout"
  }

  override Str usage()
  {
    """write                     Write last value to stdout
       write <data>              Write data to stdout
       write <data> to:<file>    Write data to file based on file extension
       write pog:<file>          Write proto to pog file
       write json:<file>         Write JSON object to file
       write zinc:<file>         Write haystack grid to Zinc file
       write hayson:<file>       Write haystack grid to Hayson JSON file
       write trio:<file>         Write haystack grid to Trio file
       write csv:<file>          Write haystack grid to CSV file
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    data := cx.argIt

    // lookup writer method by argument name
    result := methods.eachWhile |method, name|
    {
      to := args[name]
      if (to == null) return null
      return writeMethod(cx, data, to, method)
    }
    if (result != null) return result

    // check by extension
    to := cx.argWriteTo
    file := to.getFile(false)
    if (file != null && file.ext != null)
    {
      method := methods[file.ext]
      if (method == null) throw ArgErr("No write for file extension: $file.name")
      return writeMethod(cx, data, to, method)
    }

    // try to get a method from data value
    return writeMethod(cx, data, to, valToMethod(data.get))
  }

  private Method valToMethod(Obj? val)
  {
    if (val is Proto) return #writePog
    if (val is Grid) return #writeZinc
    return #writeJson
  }

  private TransduceData writeMethod(TransduceContext cx, TransduceData data, TransduceData to, Method method)
  {
    to.withOutStream |out| { method.callOn(this, [cx, data, out]) }
    return data
  }

  private Void writePog(TransduceContext cx, TransduceData data, OutStream out)
  {
    PogPrinter(out, cx.args).print(data.getProto)
  }

  private Void writeJson(TransduceContext cx, TransduceData data, OutStream out)
  {
    JsonPrinter(out, cx.args).print(data.get)
  }

  private Void writeZinc(TransduceContext cx, TransduceData data, OutStream out)
  {
    ZincWriter(out).writeGrid(data.getAs(Grid#))
  }

  private Void writeTrio(TransduceContext cx, TransduceData data, OutStream out)
  {
    TrioWriter(out).writeGrid(data.getAs(Grid#))
  }

  private Void writeHayson(TransduceContext cx, TransduceData data, OutStream out)
  {
    JsonWriter(out).writeGrid(data.getAs(Grid#))
  }

  private Void writeCsv(TransduceContext cx, TransduceData data, OutStream out)
  {
    CsvWriter(out).writeGrid(data.getAs(Grid#))
  }

}

