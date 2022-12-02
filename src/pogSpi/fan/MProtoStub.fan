//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

using util
using concurrent
using pog

**
** Proto stub implementation used update process
**
@Js
internal class MProtoStub : ProtoStub
{
  new makeClone(ProtoStub type, Obj? val := null)
  {
    this.loc = FileLoc.unknown
    this.type = type
    this.children = MProtoSpi.noChildren
    this.val = val
  }

  new makeStub(MProtoSpi spi)
  {
    this.loc = spi.loc
    this.old = spi
    this.type = spi.type
    this.children = spi.children
  }

  ProtoStub? get(Str name) { children[name] }

  Void doSet(Str name, MProtoStub kid)
  {
    if (kid.parent != null) throw ProtoAlreadyParentedErr(name)
    if (children.isImmutable) children = children.dup
    kid.parent = this
    children[name] = kid
  }

  Void doAdd(Str? name, MProtoStub kid)
  {
    if (name == null) name = autoName
    else if (children[name] != null) throw DupProtoNameErr(name)
    doSet(name, kid)
  }

  private Str autoName()
  {
    for (i := 0; i<10_000; ++i)
    {
      name := "_" + i.toStr
      if (children[name] == null) return name
    }
    throw Err("Cannot autoName")
  }

  static const Str:ProtoStub noChildren := [:]

  ProtoStub? parent
  FileLoc loc
  Obj? val
  MProtoSpi? old
  ProtoStub? type
  Str:ProtoStub children
}