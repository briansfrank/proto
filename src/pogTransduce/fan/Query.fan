//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Query transducer
**
@Js
const class QueryTransducer : Transducer
{
  new make(PogEnv env) : super(env, "query") {}

  override Str summary()
  {
    "Execute a named query"
  }

  override Str usage()
  {
    """query qname:<qname>           Execute query by qname in last value
       query <data> qname:<qname>    Execute query by qname in given data set
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    data := cx.argIt.getProto

    qname := QName(cx.arg("qname").getStr.trim)
    parent := data.getq(qname.parent)
    query := parent.get(qname.name)

    // TODO: need to decide to select dataset root
    if (data.getOwn("Data", false) != null)
      data = data->Data

    result := Querier(cx, data, query).run(parent)
    return cx.toResult(result, ["proto"], result.loc)
  }
}

**************************************************************************
** Querier
**************************************************************************

@Js
internal class Querier
{
  new make(TransduceContext cx, Proto data, Proto query)
  {
    if (!query.info.fitsQuery) throw ArgErr("Proto is not a Query: $query")

    this.cx     = cx
    this.data   = data
    this.query  = query
  }

  Proto run(Proto parent)
  {
    acc := Str:Proto[:] { ordered = true }
    isa := AtomicRef(data.isa)
    of := getOf(query)
    doRun(parent) |item|
    {
      if (of != null && !item.fits(of)) return
      name := PogUtil.isOrdinalName(item.name) ? "_${acc.size}" : item.name
      acc[name] = item
    }
    return cx.instantiate(data.loc, cx.base, isa, null, acc)
  }

  private Void doRun(Proto parent, |Proto| f)
  {
    // check for via
    via := (query.get("_via", false)?.val(false) as Str)?.trimToNull
    if (via != null) return runVia(parent, via, f)

    // check for inverse
    inverse := getInverse(query)
    if (inverse != null) return runInverse(parent, inverse, f)

    // unknown query type
    cx.err("Query is missing via or inverse", query)
  }

  private Void runVia(Proto parent, Str via, |Proto| f)
  {
    multiHop := false
    if (via.endsWith("+"))
    {
      multiHop = true
      via = via[0..-2]
    }

    dataEach |item|
    {
      if (matchVia(parent, via, multiHop, item)) f(item)
    }
  }

  private Bool matchVia(Proto parent, Str via, Bool multiHop, Proto item)
  {
    x := parent.get(via, false)?.isa
    if (x === item) return true

    if (multiHop)
    {
      while (x != null)
      {
        x = x.get(via, false)?.isa
        if (x === item) return true
      }
    }

    return false
  }

  private Void runInverse(Proto parent, Proto inverse, |Proto| f)
  {
    // must be query
    if (!inverse.info.fitsQuery) return cx.err("Inverse is not query type: $inverse", query)

    // check inverse doesn't reference another inverse
    cyclic := getInverse(inverse)
    if (cyclic != null) return cx.err("Cyclic inverse query: $query / $inverse", query)

    // first find all the items in the inverse set
    inverseQuerier := Querier(cx, data, inverse)
    dataEach |x|
    {
      inverseQuerier.doRun(x) |item|
      {
        if (item === parent) f(x)
      }
    }
  }

  private Void dataEach(|Proto| f)
  {
    // iterate items in from our potential data set:
    //  - skip meta children
    //  - skip children which don't of parameter
    data.each |item|
    {
      if (item.isMeta) return
      f(item)
    }
  }

  private Proto? getOf(Proto q)
  {
    q.get("_of", false)?.isa
  }

  private Proto? getInverse(Proto q)
  {
    x := q.get("_inverse", false)?.isa
    if (x == null || x.qname.toStr == "sys.Query") return null
    return x
  }

  TransduceContext cx       // make
  const Proto data          // make
  const Proto query         // make
}

