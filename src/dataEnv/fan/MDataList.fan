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

@Js
const class MDataList : DataSeq
{
  new make(DataType type, Obj?[] list)
  {
    this.type = type
    this.list = list
  }

  const override DataType type

  override Bool isEmpty() { list.isEmpty }

  override DataSeqX x() { MDataListX(this) }

  override Str toStr() { list.toStr }

  internal const Obj?[] list
}


**************************************************************************
** MDataListX
**************************************************************************

@Js
class MDataListX : DataSeqX
{
  new make(MDataList source)
  {
    this.source = source
  }

  override Void seqEach(|Obj?| f)
  {
    source.list.each(f)
  }

  override Obj? seqEachWhile(|Obj?->Obj?| f)
  {
    source.list.eachWhile(f)
  }

  override This seqMap(|Obj?->Obj?| f)
  {
    init
    acc = acc.map(f)
    return this
  }

  override This seqFindAll(|Obj?->Bool| f)
  {
    init
    acc = acc.findAll(f)
    return this
  }

  override DataSeq collect()
  {
    if (acc == null) return source
    return MDataList(source.type, acc)
  }

  This init()
  {
    if (acc != null) return this
    acc = source.list.dup
    return this
  }

  private const MDataList source
  private Obj?[]? acc
}

