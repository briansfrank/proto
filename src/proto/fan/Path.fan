//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Mar 2022  Brian Frank  Creation
//

using concurrent

**
** Prototype tree path as list of dotted names
**
@Js
const mixin Path
{
  ** Special root path is the empty string
  static const Path root := RootPath()

  ** Parse from dotted path.
  static new fromStr(Str s, Bool checked := true)
  {
    if (s.isEmpty) return root
    x := s.split('.', false)
    switch (x.size)
    {
      case 1:  if (isName(x[0])) return make1(x[0])
      case 2:  if (isName(x[0]) && isName(x[1])) return make2(x[0], x[1])
      case 3:  if (isName(x[0]) && isName(x[1]) && isName(x[2])) return make3(x[0], x[1], x[2])
      case 4:  if (isName(x[0]) && isName(x[1]) && isName(x[2]) && isName(x[3])) return make4(x[0], x[1], x[2], x[3])
      default: if (x.all { isName(it) }) return make(x)
    }
    if (checked) throw ParseErr("Invalid Path: $s.toCode")
    return null
  }

  ** Is the given string a valid path name.  Valid names must start
  ** with an ASCII lower case letter and contain only ASCII letters,
  ** digits, or underbar.
  static Bool isName(Str n)
  {
    if (n.isEmpty) return false
    if (!n[0].isAlpha && n[0] != '_') return false
    return n.all |c| { c.isAlphaNum || c == '_'}
  }

  ** Construct path with depth of 1.
  ** Name is not validated.
  static Path make1(Str name) { Path1(name) }

  ** Construct path with depth of 2.
  ** Names are not validated.
  static new make2(Str n0, Str n1) { Path2(n0, n1) }

  ** Construct path with depth of 3.
  ** Names are not validated.
  static new make3(Str n0, Str n1, Str n2) { Path3(n0, n1, n2) }

  ** Construct path with depth of 4.
  ** Names are not validated.
  static new make4(Str n0, Str n1, Str n2, Str n3) { Path4(n0, n1, n2, n3) }

  ** Construct path from list of names.
  ** Names are not validated.
  static new make(Str[] names)
  {
    if (names.size == 1) return Path1(names[0])
    if (names.size == 2) return Path2(names[0], names[1])
    if (names.size == 3) return Path3(names[0], names[1], names[2])
    if (names.size == 4) return Path4(names[0], names[1], names[2], names[3])
    return PathList(names)
  }

  ** Simple name is the last name in the path
  abstract Str name()

  ** Depth of the path
  abstract Int size()

  ** Is this the root path
  abstract Bool isRoot()

  ** Get a segment of the path
  @Operator abstract Str get(Int i)

  ** Slice this path
  @Operator Path getRange(Range range)
  {
    names := Str[,]
    names.capacity = size
    for (i := 0; i<size; ++i) names.add(get(i))
    return make(names.getRange(range))
  }

  ** Iterate each name in the path
  Void each(|Str name, Int i| f)
  {
    for (i := 0; i<size; ++i) f(get(i), i)
  }

  ** Hash code is based on toStr
  override Int hash() { toStr.hash }

  ** Equality is based on toStr
  override Bool equals(Obj? that)
  {
    toStr == that?.toStr && typeof === that.typeof
  }

  ** Add a new segemnt to this path
  abstract Path add(Str name)

}

**************************************************************************
** RootPath
**************************************************************************

@Js
internal const class RootPath : Path
{
  override Str name() { "" }
  override Bool isRoot() { true }
  override Int size() { 0 }
  override Str get(Int i) { throw IndexErr(i.toStr) }
  override Path add(Str n) { Path1(n) }
  override Str toStr() { "" }
}

**************************************************************************
** Path1
**************************************************************************

@Js
internal const class Path1 : Path
{
  new make(Str name) { this.name = name }
  const override Str name
  override Bool isRoot() { false }
  override Int size() { 1 }
  override Str get(Int i)
  {
    if (i == 0) return name
    throw IndexErr(i.toStr)
  }
  override Path add(Str n) { Path2(name, n) }
  override Str toStr() { name }
}

**************************************************************************
** Path2
**************************************************************************

@Js
internal const class Path2 : Path
{
  new make(Str n0, Str n1) { this.n0 = n0; this.n1 = n1 }
  override Str name() { n1 }
  override Bool isRoot() { false }
  override Int size() { 2 }
  override Str get(Int i)
  {
    if (i == 0) return n0
    if (i == 1) return n1
    throw IndexErr(i.toStr)
  }
  override Path add(Str n) { Path3(n0, n1, n) }
  private const Str n0
  private const Str n1
  override once Str toStr() { n0 + "." + n1 }
}

**************************************************************************
** Path3
**************************************************************************

@Js
internal const class Path3 : Path
{
  new make(Str n0, Str n1, Str n2) { this.n0 = n0; this.n1 = n1; this.n2 = n2 }
  override Str name() { n2 }
  override Bool isRoot() { false }
  override Int size() { 3 }
  override Str get(Int i)
  {
    if (i == 0) return n0
    if (i == 1) return n1
    if (i == 2) return n2
    throw IndexErr(i.toStr)
  }
  override Path add(Str n) { Path4(n0, n1, n2, n) }
  private const Str n0
  private const Str n1
  private const Str n2
  override once Str toStr() { n0 + "." + n1 + "." + n2 }
}

**************************************************************************
** Path4
**************************************************************************

@Js
internal const class Path4 : Path
{
  new make(Str n0, Str n1, Str n2, Str n3) { this.n0 = n0; this.n1 = n1; this.n2 = n2; this.n3 = n3 }
  override Str name() { n3 }
  override Bool isRoot() { false }
  override Int size() { 4 }
  override Str get(Int i)
  {
    if (i == 0) return n0
    if (i == 1) return n1
    if (i == 2) return n2
    if (i == 3) return n3
    throw IndexErr(i.toStr)
  }
  override Path add(Str n) { PathList([n0, n1, n2, n3, n]) }
  private const Str n0
  private const Str n1
  private const Str n2
  private const Str n3
  override once Str toStr() { n0 + "." + n1 + "." + n2 + "." + n3 }
}

**************************************************************************
** PathList
**************************************************************************

@Js
internal const class PathList : Path
{
  new make(Str[] names) { if (names.isEmpty) throw ArgErr("Names is empty"); this.names = names }
  override Str name() { names.last }
  override Bool isRoot() { false }
  override Int size() { names.size }
  override Str get(Int i) { names.get(i) }
  override once Str toStr() { names.join(".") }
  override Path add(Str n) { PathList(names.dup.add(n)) }
  private const Str[] names
}

