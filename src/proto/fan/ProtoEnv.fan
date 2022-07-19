//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

**
** Prototype environment for the current VM.
**
@Js
abstract const class ProtoEnv
{
  ** Current default environment for the VM
  static ProtoEnv cur() { curRef ?: throw Err("ProtoEnv not initialized") }

  // init env instance using reflection
  private static const ProtoEnv? curRef
  static
  {
    try
    {
      curRef = Type.find("protoc::MProtoEnv").make
    }
    catch (Err e)
    {
      echo("ERROR: cannot init ProtoEnv.cur")
      e.trace
    }
  }

  ** List the library names installed by this environment
  abstract Str[] installed()

  ** Search path of directories from lowest to highest priority.  Standard
  ** behavior is to map 'pog/' directory of the Fantom `sys::Env` path.
  abstract File[] path()

  ** Return root directory for the given library name.  The result
  ** might be on the local file system or a directory within a pod file.
  ** Raise exception if library name is not installed.
  abstract File libDir(Str name)

  ** Debug dump
  @NoDoc abstract Void dump(OutStream out := Env.cur.out)
}

