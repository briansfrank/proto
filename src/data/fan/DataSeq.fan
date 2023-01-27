//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using util

**
** Sequence is base type for all collections.  All sequences
** maybe iterated, but do not guarantee an iteration order.
** Use `DataEnv.seq` to create instances.
**
@Js
const mixin DataSeq
{
  ** Data type for this collection
  abstract DataType type()

  ** Return true is collection is empty
  abstract Bool isEmpty()

  ** Start iteration or transformation of this sequence
  abstract DataSeqX x()
}

**************************************************************************
** DataSeqTransform
**************************************************************************

**
** Streaming iteration or transformation of a sequence
**
@Js
mixin DataSeqX
{
  ** Pretty print sequence to the output stream.
  ** Options may be anything accepted by `DataEnv.dict`.
  Void print(OutStream out := Env.cur.out, Obj? opts := null) { DataEnv.cur.print(this, out, opts) }

  ** Iterate items to an in-memory list
  abstract Obj?[] toList()

  ** Iterate the sequency items.  Order is not guaranteed.
  abstract Void seqEach(|Obj?| f)

  ** Iterate the sequency items until function returns non-null.
  abstract Obj? seqEachWhile(|Obj?->Obj?| f)

  ** Map the items from the sequence
  abstract This seqMap(|Obj?->Obj?| f)

  ** Filter the items from the sequence
  abstract This seqFindAll(|Obj?->Bool| f)

  ** Collect the transformation into a new sequence of same type as the source
  abstract DataSeq collect()
}