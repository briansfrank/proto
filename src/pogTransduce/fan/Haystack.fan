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
** Haystack transducer
**
@Js
const class HaystackTransducer : Transducer
{
  new make(PogEnv env) : super(env, "haystack") {}

  override Str summary()
  {
    "Convert between Haystack and Proto data models"
  }

  override Str usage()
  {
    """Summary:
         Read or write objects as Haystack data.
       Usage:
         haystack read:dicts      Convert haystack dicts to protos
         haystack write:proto     Convert protos to haystack dicts
       Arguments:
         read                     List of dicts
         write                    Proto graph
       """
  }

  override Transduction transduce(Str:Obj? args)
  {
    cx := TransduceContext(this, args)
    if (args.containsKey("read")) return readHaystack(cx)
    if (args.containsKey("write")) return writeHaystack(cx)
    throw ArgErr("Missing read or write argument")
  }

  private Transduction readHaystack(TransduceContext cx)
  {
    cx.toResult(HaystackReader(cx).read)
  }

  private Transduction writeHaystack(TransduceContext cx)
  {
    throw Err("TODO")
  }
}

**************************************************************************
** HaystackReader
**************************************************************************

@Js
internal class HaystackReader
{
  new make(TransduceContext cx)
  {
    this.cx   = cx
    this.arg  = cx.arg("read", true)
    this.base = QName.fromStr(cx.arg("base", false, Str#) ?: "")
    this.loc  = cx.toLoc(arg)
  }

  Proto read()
  {
    initKinds
    dicts := initDicts

    protos := Str:Proto[:]
    protos.ordered = true
    dicts.each |dict, i|
    {
      name := "_$i"
      protos[name] = dictToProto(base.add(name), dict)
    }

    return MProto(loc, base, isList, null, protos)
  }

  private Void initKinds()
  {
    // TODO
    depends := cx.env.create(["sys", "ph"])
    sys := depends.lib("sys")
    ph  := depends.lib("ph")

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

  private Dict[] initDicts()
  {
    if (arg is Dict) return Dict[arg]
    if (arg is List) return Dict[,].addAll(arg)
    if (arg is Grid) return ((Grid)arg).toRows
    if (arg is File) return fileToDicts(arg)
    throw ArgErr("Read arg not supported: $arg [$arg.typeof]")
  }

  private Dict[] fileToDicts(File f)
  {
    if (f.ext == "zinc") return ZincReader(f.in).readGrid.toRows
    if (f.ext == "json") return JsonReader(f.in).readGrid.toRows
    if (f.ext == "trio") return TrioReader(f.in).readAllDicts
    throw ArgErr("Unsupported haystack file type: $f.name")
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
    return MProto(loc, qname, isDict, null, kids)
  }

  private Proto scalarToProto(QName qname, Obj? val, Kind kind)
  {
    isa := kinds.getChecked(kind.name)
    if (kind.isSingleton) val = null
    else if (kind.isXStr) val = kind.valToZinc(val)
    return MProto(loc, qname, isa, val, MProto.noChildren)
  }

  private TransduceContext cx       // make
  private Obj arg                   // make
  private QName base                // make
  private FileLoc loc               // make
  private AtomicRef? isDict         // initKinds
  private AtomicRef? isList         // initKinds
  private [Str:AtomicRef]? kinds    // initKinds
}

