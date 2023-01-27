//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//  26 Jan 2023  Brian Frank  Repurpose ProtoCompiler
//

using util
using data

**
** Base class for XetoCompiler steps
**
@Js
abstract internal class Step
{
  XetoCompiler? compiler

  abstract Void run()

  DataEnv env() { compiler.env }

  Bool isLib() { compiler.isLib }

  Str qname() { compiler.qname }

  Bool isSys() { compiler.qname == "sys" }

  SysTypes sys() { compiler.sys }

  XetoObj ast() { compiler.ast }

  XetoObj? pragma() { compiler.pragma }

  Void info(Str msg) { compiler.info(msg) }

  XetoCompilerErr err(Str msg, FileLoc loc, Err? err := null) { compiler.err(msg, loc, err) }

  XetoCompilerErr err2(Str msg, FileLoc loc1, FileLoc loc2, Err? err := null) { compiler.err2(msg, loc1, loc2, err) }

  Void bombIfErr() { if (!compiler.errs.isEmpty) throw compiler.errs.first }
}