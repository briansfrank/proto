//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Jan 2023  Brian Frank  Creation
//

using util

**
** Logical set of Dict records.
**
@Js
const mixin DataSet : DataSeq
{
  ** Environment
  abstract DataEnv env()

  ** Number of items in the data set
  abstract Int size()

  ** Start iteration or transformation of this data set
  abstract override DataSetX x()

  ** Debug dump
  @NoDoc abstract Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
}

**************************************************************************
** DataSetTransform
**************************************************************************

**
** Streaming iteration or transformation of a data set
**
@Js
mixin DataSetX : DataSeqX
{
  ** Transform set into list of records
  abstract override Dict[] toList()

  ** Iterate the dict records
  abstract Void each(|Dict rec| f)

  ** Iterate the dict records until callback returns non-null
  abstract Obj? eachWhile(|Dict rec->Obj?| f)

  ** Map the records by the given transformation function.
  ** If the function returns null, then the record is excluded.
  abstract This map(|Dict rec->Dict?| f)

  ** Find the all records that match given predicate function
  abstract This findAll(|Dict rec->Bool| f)

  ** Collect into new data set
  abstract override DataSet collect()
}