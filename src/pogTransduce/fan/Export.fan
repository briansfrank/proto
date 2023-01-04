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
      // for now just assume proto is list
      if (PogUtil.isAuto(kid.name))
        dicts.add(exportToDict(kid))
    }
    return Etc.makeDictsGrid(null, dicts)
  }

  Obj?[] exportToList(Proto proto)
  {
    acc := Obj?[,]
    proto.each |kid|
    {
      if (PogUtil.isAuto(kid.name)) acc.add(export(kid))
    }
    return acc.toImmutable
  }

  Dict exportToDict(Proto proto)
  {
    if (proto.hasVal) return Etc.makeDict1("val", export(proto))
    acc := Str:Obj[:]
    acc.ordered = true
    proto.each |kid|
    {
      if (kid.isMeta) return
      acc[kid.name] = export(kid)
    }
    return Etc.makeDict(acc)
  }


  Obj? export(Proto proto)
  {
    kind := toKind(proto)

    // singletons
    if (kind.isSingleton) return kind.defVal

    // collections
    if (kind.isDict) return exportToDict(proto)
    if (kind.isList) return exportToList(proto)
    if (kind.isGrid) return exportToGrid(proto)

    // scalars
    val := proto.val(false)
    if (val == null) return null
    switch (kind)
    {
      case Kind.str:      return val.toStr
      case Kind.number:   return val as Number ?: Number.fromStr(val.toStr)
      case Kind.ref:      return val as Ref ?: Ref.fromStr(val.toStr)
      case Kind.date:     return val as Date ?: Date.fromStr(val.toStr)
      case Kind.time:     return val as Time ?: Time.fromStr(val.toStr)
      case Kind.dateTime: return val as DateTime ?: DateTime.fromStr(val.toStr)
      case Kind.symbol:   return val as Symbol ?: Symbol.fromStr(val.toStr)
      case Kind.coord:    return val as Coord  ?: Coord.fromStr(val.toStr)
      case Kind.xstr:     return val as XStr ?: ZincReader(val.toStr.in).readVal
      default: throw Err("Unhandled haystack kind $kind: $val ($val.typeof)")
    }
  }

  Kind toKind(Proto proto)
  {
    Kind.fromStr(proto.isa?.name ?: "", false) ?: Kind.dict
  }
}


