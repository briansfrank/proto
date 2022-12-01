//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

using pog
using haystack

**
** Prototype tree path as list of dotted names
**
@Js
const class HaystackPogIO : PogIO
{
  new make(PogEnv env) : super(env, "haystack") {}

  override Str summary()
  {
    "Adaptor for Haystack dict instances"
  }

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  override Bool canRead(Obj input)
  {
    input is Grid || input is Dict
  }

  override Graph read(Obj input)
  {
    if (input is Dict) return read(Etc.makeDictGrid(null, input))
    grid := input as Grid ?: throw UnsupportedErr("Input not supported: $input [$input.typeof]")

    return env.create(["sys", "ph"]).update |u|
    {
      data := readDict(u, Etc.emptyDict)
      u.add(u.graph, data, "data")
      grid.each |row|
      {
        data.add(readDict(u, row))
      }
    }
  }

  private ProtoStub readDict(Update u, Dict d)
  {
    stub := u.clone(u.graph.sys->Dict)
    d.each |val, name|
    {
      kind := Kind.fromVal(val)
      if (kind.isScalar)
      {
        u.add(stub, val, name)
      }
      else if (kind.isDict)
      {
        u.add(stub, readDict(u, val), name)
      }
      else
      {
        throw Err("Dict kind not supported: $kind")
      }
    }
    return stub
  }

//////////////////////////////////////////////////////////////////////////
// Write
//////////////////////////////////////////////////////////////////////////

  override Bool canWrite(Obj? output)
  {
    output == null
  }

  override Obj? write(Graph graph, Obj? output := null)
  {
    if (output != null) throw UnsupportedErr("Output type must be null")
    throw Err("TODO")
  }
}

