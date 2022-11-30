//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

**
** Proto object graph environment for the current VM.
**
@Js
abstract const class PogEnv
{
  ** Current default environment for the VM
  static PogEnv cur() { curRef ?: throw Err("PogEnv not initialized") }

  // init env instance using reflection
  private static const PogEnv? curRef
  static
  {
    try
    {
      if (Env.cur.runtime == "js")
        curRef = JsPogEnv()
      else
        curRef = Type.find("pogc::MPogEnv").make
    }
    catch (Err e)
    {
      echo("ERROR: cannot init PogEnv.cur")
      e.trace
    }
  }

  ** Search path of directories from lowest to highest priority.  Standard
  ** behavior is to map 'pog/' directory of the Fantom `sys::Env` path.
  abstract File[] path()

  ** List the library qnames installed by this environment
  abstract Str[] installed()

  ** Return root directory for the given library qname.  The result
  ** might be on the local file system or a directory within a pod file.
  abstract File? libDir(Str qname, Bool checked := true)

  ** I/O adaptor and file format registry
  abstract PogEnvIO io()

  ** Compile a new graph from a list of library qnames.
  ** Raise exception if there are any compiler errors.
  abstract Graph compile(Str[] libNames)

  ** Debug dump
  @NoDoc virtual Void dump(OutStream out := Env.cur.out) {}
}

**************************************************************************
** JsPogEnv
**************************************************************************

**
** JsPogEnv is stub implementation for browser environments
**
@Js
internal const class JsPogEnv : PogEnv
{
  override File[] path() { File[,] }

  override Str[] installed() { Str[,] }

  override File? libDir(Str name, Bool checked := true) { throw UnsupportedErr() }

  override PogEnvIO io() { throw UnsupportedErr() }

  override Graph compile(Str[] libNames) { throw UnsupportedErr() }
}


