//
// Copyright (c) 2009, SkyFoundry LLC
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Dec 2009  Brian Frank  Creation
//   17 Feb 2023  Brian Frank  Move from haystack to data
//

using util

**
** Dict is a map of name/value pairs.  It is used to model grid rows, grid
** meta-data, and name/value object literals.  Dict is characterized by:
**   - names must match `Etc.isTagName` rules
**   - values should be one valid Haystack kinds
**   - get '[]' access returns null if name not found
**   - trap '->' access throws exception if name not found
**
** Also see `Etc.emptyDict`, `Etc.makeDict`.
**
@Js
const mixin Dict : DataSeq
{
  **
  ** Return generic 'sys.Dict' type
  **
  override DataType type() { DataEnv.cur.emptyDict.type }

  **
  ** Start iteration or transformation of this dict
  **
  override DictX x() { MDictX(this) }

  **
  ** Return if the there are no name/value pairs
  **
  abstract override Bool isEmpty()

  **
  ** Get the value for the given name or 'def' if name not mapped
  **
  @Operator
  abstract Obj? get(Str name, Obj? def := null)

  **
  ** Return true if the given name is mapped to a non-null value.
  **
  abstract Bool has(Str name)

  **
  ** Return true if the given name is not mapped to a non-null value.
  **
  abstract Bool missing(Str name)

  **
  ** Iterate through the name/value pairs
  **
  abstract Void each(|Obj val, Str name| f)

  **
  ** Iterate through the name/value pairs until the given
  ** function returns non-null, then break the iteration and
  ** return resulting object.  Return null if function returns
  ** null for every name/value pair.
  **
  abstract Obj? eachWhile(|Obj val, Str name->Obj?| f)

  **
  ** Get the value mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownNameErr.
  **
  override abstract Obj? trap(Str name, Obj?[]? args := null)

  **
  ** Get the 'id' tag as a Ref or raise CastErr/UnknownNameErr
  **
  virtual Ref id()
  {
    get("id", null) ?: throw UnknownNameErr("id")
  }

  **
  ** Get display string for dict or the given tag.  If 'name'
  ** is null, then return display text for the entire dict
  ** using `Etc.dictToDis`.  If 'name' is non-null then format
  ** the tag value using its appropiate 'toLocale' method.  If
  ** 'name' is not defined by this dict, then return 'def'.
  **
  virtual Str? dis(Str? name := null, Str? def := "")
  {
    // TODO: combo of Etc.dictToDis and Kind.fromType(val.typeof).valToDis(val)
    if (name == null)
    {
      Obj? d
      d = get("dis", null);       if (d != null) return d.toStr
//      d = get("disMacro", null);  if (d != null) return macro(d.toStr, dict)
//      d = get("disKey", null);    if (d != null) return disKey(d)
      d = get("name", null);      if (d != null) return d.toStr
      d = get("def", null);       if (d != null) return d.toStr
      d = get("tag", null);       if (d != null) return d.toStr
//      id := dict.get("id", null) as Ref; if (id != null) return id.dis
      return def
    }
    else
    {
      val := get(name)
      if (val == null) return def
      return val.toStr
    }
  }

  ** Return string for debugging only
  override Str toStr()
  {
    buf := StrBuf()
    DataEnv.cur.print(this, buf.out)
    return buf.toStr
  }
}

**************************************************************************
** DictX
**************************************************************************

**
** Streaming iteration or transformation of a dict
**
@Js
mixin DictX : DataSeqX
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
  abstract override Dict collect()
}

**************************************************************************
** MDictX
**************************************************************************

@NoDoc @Js
class MDictX : DictX
{
  new make(Dict source)
  {
    this.source = source
  }

  override Obj?[] toList()
  {
    acc := Obj?[,]
    source.each |v| { acc.add(v) }
    return acc
  }

  override Void seqEach(|Obj?| f)
  {
    source.each(f)
  }

  override Obj? seqEachWhile(|Obj?->Obj?| f)
  {
    source.eachWhile(f)
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

  override Dict collect()
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
    source.each |v, n| { acc[n] = v }
    return this
  }

  const Dict source
  private [Str:Obj]? acc
}

