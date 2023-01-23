//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Collection of name/value slots.
** Use `DataEnv.dict` to create instances.
**
@Js
const mixin DataDict : DataSeq
{
  ** Does this dict contains the given slot name
  abstract Bool has(Str name)

  ** Does this dict not contain the given slot name
  abstract Bool missing(Str name)

  ** Get the data object value for the given name or 'def' is not mapped.
  @Operator abstract Obj? get(Str name, Obj? def := null)

  ** Get the value mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an exception.
  override abstract Obj? trap(Str name, Obj?[]? args := null)

  ** Iterate the data object values
  abstract Void each(|Obj?,Str| f)

  ** Iterate the data object values until callback returns non-null
  abstract Obj? eachWhile(|Obj?,Str->Obj?| f)

  ** Begin streaming transformation of this sequence
  abstract override DataDictTransform x()
}

**************************************************************************
** DataDictTransform
**************************************************************************

**
** Streaming transformation of a sequence
**
@Js
mixin DataDictTransform : DataSeqTransform
{
  ** Add name to dict.  If name already exists, raise an exception.
  abstract This add(Str name, Obj val)

  ** Add or overwrite name to given value.
  abstract This set(Str name, Obj val)

  ** Rename the given name or ignore if oldName not mapped.
  abstract This rename(Str oldName, Str newName)

  ** Remove name if it is mapped by dict, ignore if name not mapped.
  abstract This remove(Str name)

  ** Collect the transformation into a new sequence of same type as the source
  abstract override DataDict collect()
}

