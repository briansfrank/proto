//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto

**
** ProtoSpace implementation
**
internal const class MProtoSpace : ProtoSpace
{
  new make(Proto root, Str:ProtoLib libsMap)
  {
    this.root    = root
    this.libs    = libsMap.vals.sort |a, b| { a.name <=> b.name }
    this.libsMap = libsMap
    this.sys     = libsMap.getChecked("sys")
    this.obj     = sys->Obj
    this.marker  = sys->Marker
    this.str     = sys->Str
    this.dict    = sys->Dict
  }

  override const Proto root
  override const ProtoLib[] libs
  override const ProtoLib sys
  override const Proto obj
  override const Proto marker
  override const Proto str
  override const Proto dict
  const Str:ProtoLib libsMap

  override ProtoLib? lib(Str name, Bool checked := true)
  {
    lib := libsMap[name]
    if (lib != null) return lib
    if (checked) throw UnknownLibErr(name)
    return null

  }

  @Operator override Proto? get(Path path, Bool checked := true)
  {
    Proto? p := root
    for (i := 0; p != null && i<path.size; ++i)
      p = p.get(path[i], checked)
    return p
  }

}

