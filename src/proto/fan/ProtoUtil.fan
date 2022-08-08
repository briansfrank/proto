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
@Js
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

  **
  ** Parse qname into its dotted path segments
  **
  static Str[] qnamePath(Str qname) { qname.split('.') }

  **
  ** Map proto dotted qualified name to camel case name
  **
  @NoDoc static Str qnameToCamelCase(Str qname)
  {
    qname.split('.').map |n,i| { i == 0 ? n : n.capitalize }.join("")
  }
}



