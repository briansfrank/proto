//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 2023  Brian Frank  Creation
//

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
    filter := cx.arg("filter")

    echo("FILTER $data |>  $filter")

    return data
  }

}

