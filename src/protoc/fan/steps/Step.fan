//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using util
using proto

**
** Base class for ProtoCompiler steps
**
abstract internal class Step
{
  ProtoCompiler? compiler

  abstract Void run()

  ProtoEnv env() { compiler.env }

  Str[] libNames() { compiler.libNames }

  CLib[] libs() { compiler.libs }

  CProto root() { compiler.root }

  CSys sys() { compiler.sys }

  MProtoSpace ps() { compiler.ps }

  internal Void addSlot(CProto parent, CProto child)
  {
    if (child.parent != null) throw Err()
    child.parent = parent
    if (parent.children.isRO)
    {
      parent.children = Str:CProto[:]
      parent.children.ordered = true
    }
    else
    {
      if (parent.children[child.name] != null)
      {
        err("Duplicate slot name $child.name", child.loc)
        return
      }
    }
    parent.children.add(child.name, child)
  }

  Void info(Str msg) { compiler.info(msg) }

  CompilerErr err(Str msg, FileLoc loc, Err? err := null) { compiler.err(msg, loc, err) }

  CompilerErr err2(Str msg, FileLoc loc1, FileLoc loc2, Err? err := null) { compiler.err2(msg, loc1, loc2, err) }

  Void bombIfErr() { if (!compiler.errs.isEmpty) throw compiler.errs.first }
}