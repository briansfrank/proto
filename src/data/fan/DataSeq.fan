//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using util

**
** Sequence is base type for all collections
**
@Js
const mixin DataSeq
{
  ** Data type for this collection
  abstract DataType type()

  ** Return true is collection is empty
  abstract Bool isEmpty()

  ** Iterate the sequency items
  abstract Void seqEach(|Obj?| f)

  ** Iterate the sequency items until function returns non-null
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