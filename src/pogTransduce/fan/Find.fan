//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Find transducer
**
@Js
const class FindTransducer : Transducer
{
  new make(PogEnv env) : super(env, "find") {}

  override Str summary()
  {
    "Filter a data set to find matching data"
  }

  override Str usage()
  {
    """find fits:<type>           Find children of last value that fit type
       find <data> fits:<type>    Find children of data that fit given type
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    data := cx.argIt
    type := cx.argToProto("fits")

    result := find(cx, data.getProto, type)
    return cx.toResult(result, ["proto"], result.loc)
  }

  private Proto find(TransduceContext cx, Proto data, Proto type)
  {
    qname := cx.base
    isa := AtomicRef(data.isa)
    acc := Str:Proto[:]

    data.each |kid|
    {
      if (kid.isMeta) return
      if (!kid.fits(type)) return
      name := PogUtil.isOrdinalName(kid.name) ? "_${acc.size}" : kid.name
      acc[name] = kid
    }

    return cx.instantiate(data.loc, qname, isa, null, acc)
  }

}

