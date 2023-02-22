//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Feb 2023  Brian Frank  Creation
//

**
** AST relative or qualified name
**
@Js
internal const class AName
{
  new make(Str s)
  {
    colon := s.index("::")
    if (colon == null)
    {
      lib = null
      name = s
    }
    else
    {
      lib = s[0..<colon]
      name = s[colon+2..-1]
    }
    this.toStr = s
  }

  new makeQualified(Str lib, Str name)
  {
    this.lib = lib
    this.name = name
    this.toStr = StrBuf(lib.size+2+name.size).add(lib).add("::").add(name).toStr
  }

  const Str? lib
  const Str name
  Bool isQualified() { lib != null }
  const override Str toStr
}