//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

**
** Proto utilities
**
const class ProtoUtil
{
  **
  ** Return if the given string is a legal proto name:
  **   - first char must be ASCII letter
  **   - rest of chars must be ASCII letter, digit, or underbar
  **
  static Bool isName(Str n)
  {
    if (n.isEmpty || !n[0].isAlpha) return false
    return n.all |c| { c.isAlphaNum || c == '_' }
  }
}



