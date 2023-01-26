//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Jan 2023  Brian Frank  Creation
//

using util
using data

**
** DataSet implementation
**
@Js
internal const class MDataSet : DataSet
{
  new make(MDataType type, DataDict[] list)
  {
    this.type = type
    this.list = list
  }

  override DataEnv env() { type.env }

  const override DataType type

  override Bool isEmpty() { list.isEmpty }

  override Int size() { list.size }

  const DataDict[] list

  override DataSetX x() { MDataSetX(this) }

  override Str toStr() { "DataSet size=$size" }

  override Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    out.printLine("--- DataSet [$size] ---")
    x.each |rec| { out.printLine(rec) }
  }
}

**************************************************************************
** MDataSetX
**************************************************************************

@Js
internal class MDataSetX: DataSetX
{
  new make(MDataSet source) { this.source = source }

  override Void seqEach(|Obj?| f) { source.list.each(f) }

  override Obj? seqEachWhile(|Obj?->Obj?| f) { source.list.eachWhile(f) }

  override This seqMap(|Obj?->Obj?| f) { map(f) }

  override This seqFindAll(|Obj?->Bool| f) { findAll(f) }

  override DataSet collect()
  {
    if (acc == null) return source
    return MDataSet(source.type, acc)
  }

  override Void each(|DataDict| f) { source.list.each(f) }

  override Obj? eachWhile(|DataDict->Obj?| f) { source.list.eachWhile(f) }

  override DataDict[] toList() { source.list }

  override This findAll(|DataDict rec->Bool| f)
  {
    init
    acc = acc.findAll(f)
    return this
  }

  override This map(|DataDict rec->DataDict?| f)
  {
    init
    acc = acc.map(f)
    return this
  }

  This init()
  {
    if (acc != null) return this
    acc = source.list.dup
    return this
  }

  const MDataSet source
  private DataDict[]? acc
}