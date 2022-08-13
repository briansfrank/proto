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

  ** Search path of directories from lowest to highest priority.  Standard
  ** behavior is to map 'pog/' directory of the Fantom `sys::Env` path.
  abstract File[] path()

  ** List the library dotted path names installed by this environment
  abstract Str[] installed()

  ** Return root directory for the given library dotted path name.  The result
  ** might be on the local file system or a directory within a pod file.
  abstract File? libDir(Str name, Bool checked := true)

  ** Compile a new namespace from a list of library dotted path names.
  ** Raise exception if there are any compiler errors.
  abstract ProtoSpace compile(Str[] libNames)

  ** Decode space from pre-compiled JSON.  Also see `ProtoSpace.decodeJson`.
  ** Stream is guaranteed to be closed.
  abstract ProtoSpace decodeJson(InStream in)

  ** Debug dump
  @NoDoc abstract Void dump(OutStream out := Env.cur.out)
}

