//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Dec 2022  Brian Frank  Creation
//

using concurrent
using util
using pog
using pogEnv
using haystack

**
** Import transducer
**
@Js
const class ImportTransducer : Transducer
{
  new make(PogEnv env) : super(env, "import") {}

  override Str summary()
  {
    "Import a foreign data model into protos"
  }

  override Str usage()
  {
    """import <data>         Import inferred on data type"
       import grid:<data>    Import a Haystack grid to protos
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)

    // named arguments
    if (cx.hasArg("grid")) return importGrid(cx, cx.arg("grid"))

    // infer from it
    data := cx.arg("it", false)
    if (data != null)
    {
      if (data.get is Grid) return importGrid(cx, data)
    }

    throw Err("Unknown import type: $args")
  }

  private TransduceData importGrid(TransduceContext cx, TransduceData data)
  {
    grid := data.get as Grid ?: throw Err("Not a grid [$data.get.typeof]")
    proto := HaystackImporter(cx, data).import(grid.toRows)
    return cx.toResult(proto, ["proto", "unvalidated"], data.loc)
  }
}

**************************************************************************
** HaystackImporter
**************************************************************************

@Js
internal class HaystackImporter
{
  new make(TransduceContext cx, TransduceData data)
  {
    this.cx   = cx
    this.base = cx.base
    this.loc  = data.loc
  }

  Proto import(Dict[] dicts)
  {
    initKinds

    protos := Str:Proto[:]
    protos.ordered = true
    dicts.each |dict, i|
    {
      name := "_$i"
      protos[name] = dictToProto(base.add(name), dict)
    }

    return cx.instantiate(loc, base, isList, null, protos)
  }

  private Void initKinds()
  {
    sys := cx.env.load("sys")
    ph  := cx.env.load("ph")

    acc := Str:AtomicRef[:]
    Kind.listing.each |kind|
    {
      proto := sys.getOwn(kind.name, false) ?: ph.getOwn(kind.name, false)
      if (proto == null) return
      acc[kind.name] = AtomicRef(proto)
    }

    xstr := acc.getChecked("XStr")
    acc["Span"] = xstr
    acc["Bin"] = xstr

    this.kinds = acc
    this.isDict = acc.getChecked("Dict")
    this.isList = acc.getChecked("List")
  }

  private Proto valToProto(QName qname, Obj val)
  {
    kind := Kind.fromVal(val)
    if (kind === Kind.dict) return dictToProto(qname, val)
    if (kind.isScalar) return scalarToProto(qname, val, kind)
    throw Err("TODO: valToProto $kind")
  }

  private Proto dictToProto(QName qname, Dict d)
  {
    kids := Str:Proto[:]
    kids.ordered = true
    d.each |v, n|
    {
      kids[n] = valToProto(qname.add(n), v)
    }
    return cx.instantiate(loc, qname, isDict, null, kids)
  }

  private Proto scalarToProto(QName qname, Obj? val, Kind kind)
  {
    isa := kinds.getChecked(kind.name)
    if (kind.isSingleton) val = null
    else if (kind.isXStr) val = kind.valToZinc(val)
    return cx.instantiate(loc, qname, isa, val, null)
  }

  private TransduceContext cx       // make
  private QName base                // make
  private FileLoc loc               // make
  private AtomicRef? isDict         // initKinds
  private AtomicRef? isList         // initKinds
  private [Str:AtomicRef]? kinds    // initKinds
}

