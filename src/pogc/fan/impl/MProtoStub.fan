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
  new makeClone(ProtoStub type)
  {
    this.loc = FileLoc.unknown
    this.type = type
    this.children = MProtoSpi.noChildren
  }

  new makeStub(MProtoSpi spi)
  {
    this.loc = spi.loc
    this.old = spi
    this.type = spi.type
    this.children = spi.children
  }

  ProtoStub? get(Str name) { children[name] }

  Void set(Str name, ProtoStub kid)
  {
    if (children.isImmutable) children = children.dup
    children[name] = kid
  }

  Void add(Str name, ProtoStub kid)
  {
    if (children[name] != null) throw DupProtoNameErr(name)
    set(name, kid)
  }

  static const Str:ProtoStub noChildren := [:]

  FileLoc loc
  Obj? val
  MProtoSpi? old
  ProtoStub? type
  Str:ProtoStub children
}