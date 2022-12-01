//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

**
** Proto object graph I/O adaptor and file format registry
**
@Js
abstract const class PogEnvIO
{
  ** List the I/O formats supported by this environment
  abstract PogIO[] list()

  ** Lookup an I/O format by its name
  abstract PogIO? get(Str name, Bool checked := true)

  ** Convenience for 'get(name).read(input)'
  Graph read(Str name, Obj input) { get(name).read(input) }

  ** Convenience for 'get(name).write(graph, output)'
  Obj? write(Str name, Graph graph, Obj output) { get(name).write(graph, output) }
}

**************************************************************************
** PogIO
**************************************************************************

**
** Proto object graph I/O adatpor or file format
**
@Js
abstract const class PogIO
{
  ** Constructor
  @NoDoc protected new make(PogEnv env, Str name)
  {
    this.envRef = env
    this.nameRef = name
  }

  ** Environment
  PogEnv env() { envRef }
  private const PogEnv envRef

  ** Name key for this format type
  Str name() { nameRef }
  private const Str nameRef

  ** Short one sentence of this format
  abstract Str summary()

  ** Return if this instance can read the given input type
  abstract Bool canRead(Obj input)

  ** Read input value into an in-memory graph.  For file based I/O input
  ** is File or InStream and is guaranteed to be closed upon exit.
  abstract Graph read(Obj input)

  ** Return if this instance can write to the given output type
  abstract Bool canWrite(Obj? output)

  ** Write graph to the output value.  For file based I/O output
  ** is File or OutStream and is guaranteed to be closed upon exit.
  abstract Obj? write(Graph graph, Obj? output := null)
}

**************************************************************************
** FilePogIO
**************************************************************************

**
** File based PogIO that supports input/output streams
**
@NoDoc @Js
abstract const class FilePogIO : PogIO
{
  protected new make(PogEnv env, Str name) : super(env, name) {}

  override Bool canRead(Obj input)
  {
    input is InStream || input is File
  }

  override Graph read(Obj input)
  {
    if (input is File) return read(((File)input).in)
    in := input as InStream ?: throw Err("Unsupported input type: $input [$input.typeof]")
    try
      return readStream(in)
    finally
      in.close
  }

  abstract Graph readStream(InStream in)

  override Bool canWrite(Obj? output)
  {
    output is OutStream || output is File
  }

  override Obj? write(Graph graph, Obj? output := null)
  {
    if (output is File) { f := (File)output; write(graph, f.out); return f  }
    out := output as OutStream ?: throw Err("Unsupported output type: $output [${output?.typeof}]")
    try
      writeStream(graph, out)
    finally
      out.close
    return out
  }

  abstract Void writeStream(Graph graph, OutStream out)
}


