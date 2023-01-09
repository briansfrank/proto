//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

**
** Proto object graph utilities
**
@Js
const class PogUtil
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
  ** Does name start with an underbar followed by letter
  **
  static Bool isMetaName(Str name) { name.size >= 2 && name[0] == '_' && name[1].isAlpha }

  **
  ** Does name start with an underbar followed by digits
  **
  static Bool isOrdinalName(Str name) { name.size >= 2 && name[0] == '_' && name[1].isDigit }

  **
  ** Does name start with an upper case name
  **
  static Bool isTypeName(Str name) { name.size >= 1 && name[0].isUpper }

  **
  ** Does name start with a lower case
  **
  static Bool isFieldName(Str name) { name.size >= 1 && name[0].isLower }

  **
  ** Parse qname into its dotted path segments
  **
  static Str[] qnamePath(Str qname) { qname.split('.') }

  **
  ** Join two qnames together
  **
  static Str qnameJoin(Str parent, Str child)
  {
    if (parent.isEmpty) return child
    return StrBuf(parent.size+1+child.size).add(parent).addChar('.').add(child).toStr
  }

  **
  ** Map proto dotted qualified name to camel case name
  **
  @NoDoc static Str qnameToCamelCase(Str qname)
  {
    qname.split('.').map |n,i| { i == 0 ? n : n.capitalize }.join("")
  }

  **
  ** Get effective child object by name.
  **
  @NoDoc static Proto? getq(Proto base, QName qname, Bool checked := true)
  {
    Proto? x := base
    for (i := 0; i<qname.size; ++i)
    {
      x = x.get(qname[i], false)
      if (x == null) break
    }
    if (x != null) return x
    if (checked) throw UnknownProtoErr(qname.toStr)
    return null
  }

  **
  ** Utility for print transducer
  **
  @NoDoc static Void print(Obj? val, OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    args := Str:Obj?[:]
    if (opts != null) args.setAll(opts)
    args["it"] = val ?: "null"
    args["to"] = out
    args = args.map |v| { PogEnv.cur.data(v) }
    PogEnv.cur.transduce("print", args)
  }
}



