//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jan 2023  Brian Frank  Creation
//

using data

**
** Data implementation utilities
**
@Js
const class MDataUtil
{
  static Obj dictTrap(DataDict dict, Str name)
  {
    val := dict.get(name, null)
    if (val != null) return val
    throw UnknownSlotErr(name)
  }

  static Str dictToStr(DataDict dict)
  {
    s := StrBuf()
    dict.x.each |v, n|
    {
      s.join(n, ", ")
      if (v.toStr != "marker")
      {
        s.add(":").add(v.toStr.toCode)
      }
    }
    return s.toStr
  }

  /* TODO
  static DataObj? dictGetData(DataDict dict, Str name, Bool checked)
  {
    val := dict.get(name, null)
    if (val != null) return dict.type.env.obj(val)
    if (checked) throw UnknownSlotErr(name)
    return null
  }

  static Void dictEachData(DataDict dict, |DataObj, Str| f)
  {
    env := dict.type.env
    dict.each |v, n| { f(env.obj(v), n) }
  }
  */
}