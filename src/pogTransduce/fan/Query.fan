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
    q := parent.get(qname.name)

    // TODO: need to decide to select dataset root
    if (data.getOwn("Data", false) != null)
      data = data->Data

    /*
    echo(">>> Parent")
    parent.print
    echo(">>> Query")
    q.print
    echo(">>>> Data")
    data.print
    */

    result := query(cx, parent, q, data)
    return cx.toResult(result, ["proto"], result.loc)
  }

  private Proto query(TransduceContext cx, Proto parent, Proto query, Proto data)
  {
    if (!query.info.fitsQuery) throw ArgErr("Proto is not a Query: $query")

    acc := Str:Proto[:]
    isa := AtomicRef(data.isa)

    data.each |kid|
    {
      if (kid.isMeta) return
      if (!inQuery(parent, query, kid)) return
      name := PogUtil.isOrdinalName(kid.name) ? "_${acc.size}" : kid.name
      acc[name] = kid
    }

    return cx.instantiate(data.loc, cx.base, isa, null, acc)
  }

  private Bool inQuery(Proto parent, Proto query, Proto item)
  {
    // match of type
    of := query.get("_of", false)?.isa
    if (of != null && !item.fits(of)) return false

    // check for via
    via := query.get("_via", false)?.val(false) as Str
    if (via != null && !inQueryVia(parent, query, item, via)) return false

    return true
  }

  private Bool inQueryVia(Proto parent, Proto query, Proto item, Str via)
  {
    x := parent.get(via, false)?.isa
    return x === item
  }

}

