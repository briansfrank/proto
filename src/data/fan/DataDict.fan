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

  ** Start iteration or transformation of this dict
  abstract override DataDictX x()
}

**************************************************************************
** DataDictTransform
**************************************************************************

**
** Streaming iteration or transformation of a dict
**
@Js
mixin DataDictX : DataSeqX
{
  ** Iterate the name/value pairs
  abstract Void each(|Obj,Str| f)

  ** Iterate the name/value pairs  until callback returns non-null
  abstract Obj? eachWhile(|Obj,Str->Obj?| f)

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

**************************************************************************
** AbstractDataDictX
**************************************************************************

@NoDoc @Js
abstract class AbstractDataDictX : DataDictX
{
  new make(DataDict source)
  {
    this.source = source
  }

  override Obj?[] toList()
  {
    acc := Obj?[,]
    each |v| { acc.add(v) }
    return acc
  }

  override Void seqEach(|Obj?| f)
  {
    each(f)
  }

  override Obj? seqEachWhile(|Obj?->Obj?| f)
  {
    eachWhile(f)
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

  override DataDict collect()
  {
    if (acc == null) return source
    return source.type.env.dict(acc)
  }

  override This add(Str name, Obj val)
  {
    init
    acc.add(name, val)
    return this
  }

  override This set(Str name, Obj val)
  {
    init
    acc.set(name, val)
    return this
  }

  override This rename(Str oldName, Str newName)
  {
    if (acc == null && source.missing(oldName)) return this
    init
    old := acc.remove(oldName)
    if (old != null) acc[newName] = old
    return this
  }

  override This remove(Str name)
  {
    if (acc == null && source.missing(name)) return this
    init
    acc.remove(name)
    return this
  }

  private This init()
  {
    if (acc != null) return this
    acc = Str:Obj?[:]
    each |v, n| { acc[n] = v }
    return this
  }

  const DataDict source
  private [Str:Obj]? acc
}

