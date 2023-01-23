//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using util

**
** Sequence is base type for all collections.  All sequences may
** be iterated, but do not guarantee an iteration order.  Use `DataEnv.seq`
** to create a sequence instance from arbitrary Fantom data.
**
@Js
const mixin DataSeq
{
  ** Data type for this collection
  abstract DataType type()

  ** Return true is collection is empty
  abstract Bool isEmpty()

  ** Iterate the sequency items.  Order is not guaranteed.
  abstract Void seqEach(|Obj?| f)

  ** Iterate the sequency items until function returns non-null.
  abstract Obj? seqEachWhile(|Obj?->Obj?| f)

  ** Begin streaming transformation of this sequence
  abstract DataSeqTransform x()

}

**************************************************************************
** DataSeqTransform
**************************************************************************

**
** Streaming transformation of a sequence
**
@Js
mixin DataSeqTransform
{
  ** Map the items from the sequence
  abstract This map(|Obj?->Obj?| f)

  ** Filter the items from the sequence
  abstract This findAll(|Obj?->Bool| f)

  ** Collect the transformation into a new sequence of same type as the source
  abstract DataSeq collect()
}