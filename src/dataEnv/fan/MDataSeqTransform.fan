//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
using data
using pog

**
** DataSeqTransform implementations
**
/*
@Js
internal const class MDataSeqTransform : DataSeqTransform
{
  new make(DataSeq source)
  {
    this.sourceRef = source
  }

  override This map(|Obj?->Obj?| f)
  {
    this
  }

  override This findAll(|Obj?->Bool| f)
  {
    this
  }

  override DataSeq collect()
  {
    source
  }

  virtual DataSeq source() { sourceRef }
  const DataSeq sourceRef
}
*/

**************************************************************************
** MDataDictTransform
**************************************************************************

@Js
class MDataDictTransform : DataDictTransform
{
  new make(DataDict source) { this.source = source }

  override This map(|Obj?->Obj?| f)
  {
    init
    acc = acc.map(f)
    return this
  }

  override This findAll(|Obj?->Bool| f)
  {
    init
    acc = acc.findAll(f)
    return this
  }

  override DataDict collect()
  {
    if (acc == null) return source
    return source.type.env.dict(acc)
  }

  This init()
  {
    if (acc != null) return this
    acc = Str:Obj?[:]
    source.each |v, n| { acc[n] = v }
    return this
  }

  private const DataDict source
  private [Str:Obj]? acc
}


