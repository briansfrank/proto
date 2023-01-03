//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jan 2023  Brian Frank  Creation
//

using util
using pog
using haystack

**
** Export transducer
**
@Js
const class ExportTransducer : Transducer
{
  new make(PogEnv env) : super(env, "export") {}

  override Str summary()
  {
    "Export protos to a foreign data model"
  }

  override Str usage()
  {
    """export ast:<data>     Export proto to JSON AST
       export grid:<data>    Export proto to haystack grid
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)

    if (cx.hasArg("ast")) return exportAst(cx, cx.arg("ast"))
    if (cx.hasArg("grid")) return exportGrid(cx, cx.arg("grid"))

    throw Err("Unknown export type specified: $args.keys.sort")
  }

  private TransduceData exportAst(TransduceContext cx, TransduceData data)
  {
    proto := data.getProto
    ast := AstExporter().export(proto)
    return cx.toResult(ast, ["json", "ast", "resolved"], data.loc)
  }

  private TransduceData exportGrid(TransduceContext cx, TransduceData data)
  {
    proto := data.getProto
    grid := HaystackExporter().exportToGrid(proto)
    return cx.toResult(grid, ["grid"], data.loc)
  }
}

**************************************************************************
** AstExporter
**************************************************************************

@Js
internal class AstExporter
{
  Str:Obj? export(Proto proto)
  {
    map := Str:Obj[:]
    map.ordered = true
    map.addNotNull("_is", proto.isa?.qname)
    map.addNotNull("_val", proto.valOwn(false))
    proto.eachOwn |kid|
    {
      map[kid.name] = export(kid)
    }
    return map
  }
}

**************************************************************************
** HaystackExporter
**************************************************************************

@Js
internal class HaystackExporter
{
  Grid exportToGrid(Proto proto)
  {
    dicts := Dict[,]
    proto.each |kid|
    {
      dicts.add(exportToDict(kid))
    }
    return Etc.makeDictsGrid(null, dicts)
  }

  Dict exportToDict(Proto proto)
  {
    if (proto.hasVal) return Etc.makeDict1("val", exportToScalar(proto))
    acc := Str:Obj[:]
    acc.ordered = true
    proto.each |kid|
    {
      if (kid.isMeta) return
      acc[kid.name] = export(kid)
    }
    return Etc.makeDict(acc)
  }

  Obj exportToScalar(Proto proto)
  {
    // TODO
    proto.val
  }

  Obj? export(Proto proto)
  {
    if (proto.isa?.qname?.toStr == "sys.Marker") return Marker.val
    if (proto.hasVal) return exportToScalar(proto)
    return exportToDict(proto)
  }
}


