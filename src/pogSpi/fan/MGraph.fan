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
const class MGraph : Graph
{
  new make(MPogEnv env, Str:Lib libsMap)
  {
    this.env     = env
    this.libs    = libsMap.vals.sort |a, b| { a.qname <=> b.qname }
    this.libsMap = libsMap
    this.sys     = libsMap.getChecked("sys")
  }

  override const PogEnv env
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

  override Proto? getq(Obj qnameArg, Bool checked := true)
  {
    qname := qnameArg as QName ?: QName.fromStr(qnameArg)
    Proto? p := this
    for (i := 0; p != null && i<qname.size; ++i)
      p = p.get(qname[i], checked)
    return p
  }

  override Proto? getById(Str id, Bool checked := true)
  {
    // TODO: just full scan for now
    if (!id.startsWith("@")) throw ArgErr("Id must be prefixed with @: $id")
    p := doGetById(this, id)
    if (p != null) return p
    if (checked) throw UnknownProtoErr(id)
    return null
  }

  private Proto? doGetById(Proto p, Str id)
  {
    v := p.getOwn("id", false)
    if (v != null && v.val(false)?.toStr == id) return p
    return p.eachOwnWhile |kid| { doGetById(kid, id) }
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

