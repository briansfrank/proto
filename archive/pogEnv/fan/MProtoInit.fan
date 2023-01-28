//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Dec 2022  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Data used to instantiate an Proto implementation
**
@Js
const class MProtoInit
{
  new make(FileLoc loc, QName qname, AtomicRef isa, Obj? val, [Str:Proto]? children)
  {
    this.loc      = loc
    this.qname    = qname
    this.isa      = isa
    this.val      = val
    this.children = children ?: noChildren
  }

  const FileLoc loc
  const QName qname
  const AtomicRef isa
  const Obj? val
  const Str:Proto children

  static const Str:Proto noChildren := [:] { ordered = true }
}

