//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

using util
using concurrent
using pog

@Js
internal class MUpdate : Update
{
  new make(MGraph graph)
  {
    this.env     = graph.env
    this.factory = env.factory
    this.graph   = graph
    this.libsMap = graph.libsMap
    this.ts      = DateTime.now(null)
    this.ticks   = Duration.nowTicks
    this.tx      = graph.tx + 1
  }

  override const MGraph graph
  override const DateTime ts
  override const Int ticks
  override const Int tx

  override ProtoSpi init(Proto proto)
  {
    r := this.spi ?: throw Err("spi not ready")
    this.spi = null
    return r
  }

  override This load(Str libName)
  {
    if (graph.lib(libName, false) != null) return this
    echo("::: TODO: load($libName)")
    return this
  }

  override This unload(Str libName)
  {
    if (graph.lib(libName, false) == null) return this
    echo("::: TODO: unload($libName)")
    return this
  }

  override ProtoStub clone(ProtoStub type)
  {
    MProtoStub.makeClone(type)
  }

  override This set(ProtoStub parent, Str name, Obj val)
  {
    stubPath(parent).doSet(name, coerce("set", val))
    return this
  }

  override This add(ProtoStub parent, Obj val, Str? name := null)
  {
    stubPath(parent).doAdd(name, coerce("add", val))
    return this
  }

  override This remove(ProtoStub parent, Str name)
  {
    throw Err("TODO")
  }

  override This clear(ProtoStub parent)
  {
    throw Err("TODO")
  }

//////////////////////////////////////////////////////////////////////////
// Coerce
//////////////////////////////////////////////////////////////////////////

  private MProtoStub coerce(Str action, Obj val)
  {
    // if its already a stub, just use it
    if (val is MProtoStub) return val

    // try to map a scalar to a proto type
    scalarType := factory.fromFantomScalar[val.typeof.qname]
    if (scalarType != null)
    {
      scalarProto := getq(scalarType, false)
      if (scalarProto != null) return coerceScalar(val, scalarProto)
    }

    if (val is Proto) throw Err("Cannot $action Proto directly, clone it first")
    throw Err("Unsupported value type for $action: $val.typeof")
  }

  private MProtoStub coerceScalar(Obj val, Proto type)
  {
    MProtoStub.makeClone(type, val)
  }

//////////////////////////////////////////////////////////////////////////
// Stub Modifications Tracking
//////////////////////////////////////////////////////////////////////////

  ** Stub the given proto up the root
  private MProtoStub stubPath(ProtoStub obj)
  {
    if (obj is MProtoStub) return obj
    spi := (MProtoSpi)((Proto)obj).spi
    if (root == null) root = MProtoStub.makeStub(graph.spi)
    cur := root
    spi.path.each |name, i|
    {
      parent := cur
      kid := parent.get(name)
      if (kid == null) throw Err("Proto not in graph: $spi.path")

      if (kid is Proto)
      {
        kidProto := (Proto)kid
        kidStub := MProtoStub.makeStub(kidProto.spi)
        cur.doSet(name, kidStub)
        cur = kidStub
      }
      else
      {
        cur = kid
      }
    }
    return cur
  }

  ** Commit stubs back to new immutable graph
  MGraph commit()
  {
    if (root == null) return graph
    return commitStub(Path.root, root)
  }

  private Proto commitStub(Path path, MProtoStub stub)
  {
    children := stub.children.map |kid, name->Proto|
    {
      kid as Proto ?: commitStub(path.add(name), kid)
    }

    // TODO: this needs some work....
    type := stub.type as Proto ?: throw Err("no type?")
    baseRef := AtomicRef(MSingleBase(type))

    this.spi = MProtoSpi(stub.loc, path, tx, baseRef, stub.val, children)
    return path.isRoot ? MGraph(env, libsMap) : factory.instantiate(type.qname)
  }

  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("--- MUpdate [tx $tx] ---")
    dumpStub(out, "root", root, 0)
  }

  private Void dumpStub(OutStream out, Str name, ProtoStub? x, Int indent)
  {
    out.print(Str.spaces(indent))
    if (x == null) return out.printLine(" null")
    stub := x as MProtoStub
    if (stub != null)
    {
      out.print("M ").print(name).print(": ").printLine(stub.type)
      stub.children.each |kid, kidName|
      {
        dumpStub(out, kidName, kid, indent+2)
      }
    }
    else
    {
      proto := (Proto)x
      out.print("~ ").print(name).print(": ").printLine(proto.type)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private MPogEnv env
  private MFactory factory
  private Str:Lib libsMap
  private MProtoStub? root
  private MProtoSpi? spi
}


