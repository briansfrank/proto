//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using pog

**
** Graph implementation
**
@Js
internal const class MGraph : Graph
{
  new make(Str:Lib libsMap)
  {
    this.libs    = libsMap.vals.sort |a, b| { a.qname <=> b.qname }
    this.libsMap = libsMap
    this.sys     = libsMap.getChecked("sys")
  }

  override const Lib[] libs
  override const Lib sys
  const Str:Lib libsMap

  override Lib? lib(Str name, Bool checked := true)
  {
    lib := libsMap[name]
    if (lib != null) return lib
    if (checked) throw UnknownLibErr(name)
    return null
  }

  override Proto? getq(Str qname, Bool checked := true)
  {
    path := Path(qname)
    Proto? p := this
    for (i := 0; p != null && i<path.size; ++i)
      p = p.get(path[i], checked)
    return p
  }

  override Graph update(|Update| f)
  {
    MUpdate(this).execute |MUpdate u->Graph|
    {
      f(u)
      return u.commit
    }
  }

}

