//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Aug 2022  Brian Frank  Creation
//

using util
using pog
using pogEnv

**
** Base class for PogStubCompiler steps
**
abstract internal class Step
{
  PogStubCompiler? compiler

  abstract Void run()

  MPogEnv env() { compiler.env }

  Lib[] libs() { compiler.libs }

  Lib sys() { libs.find { it.qname.toStr == "sys" } ?: throw Err() }

  PodSrc[] pods() { compiler.pods }

  Void info(Str msg) { compiler.info(msg) }

  CompilerErr err(Str msg, FileLoc loc, Err? err := null) { compiler.err(msg, loc, err) }

  CompilerErr err2(Str msg, FileLoc loc1, FileLoc loc2, Err? err := null) { compiler.err2(msg, loc1, loc2, err) }

  Void bombIfErr() { if (!compiler.errs.isEmpty) throw compiler.errs.first }
}