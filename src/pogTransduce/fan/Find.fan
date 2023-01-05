//
// Copyright (c) 2022, Brian Frank
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
    """find filter:<filter>           Filter last value with given filter
       find <data> filter:<filter>    Filter proto data with given filter
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    data := cx.argIt
    filter := cx.argToProto("filter")

    // not sure about how this should work, but if the filter
    // is auto-named, then use it's actual type
    if (filter.isOrdinal) filter = filter.isa

    result := find(cx, data.getProto, filter)
    return cx.toResult(result, ["proto"], result.loc)
  }

  private Proto find(TransduceContext cx, Proto set, Proto filter)
  {
    qname := cx.base
    isa := AtomicRef(set.isa)
    acc := Str:Proto[:]

    set.each |kid|
    {
      if (kid.isMeta) return
      if (!kid.fits(filter)) return
      name := PogUtil.isOrdinalName(kid.name) ? "_${acc.size}" : kid.name
      acc[name] = kid
    }

    return cx.instantiate(set.loc, qname, isa, null, acc)
  }

}

