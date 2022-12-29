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
      curRef = Type.find("pogEnv::MPogEnv").make
      //curRef = Type.find("pogSpi::LocalPogEnv").make
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

  ** Is given library qname installed
  abstract Bool isInstalled(Str qname)

  ** Return root directory for the given library qname.  The result
  ** might be on the local file system or a directory within a pod file.
  abstract File? libDir(Str qname, Bool checked := true)

  ** Load the given library into memory.  If previously loaded then
  ** return cached version.  If library is not installed or has errors
  ** then raise an exception.  This call automatically loads and cached
  ** the given lib dependent libs.
  abstract Lib? load(Str qname, Bool checked := true)

  ** List the installed transducers
  abstract Transducer[] transducers()

  ** Lookup a transducer by name
  abstract Transducer? transducer(Str name, Bool checked := true)

  ** Convenience for 'transducer(name).transduce(args)'
  Transduction transduce(Str name, Str:Obj? args) { transducer(name).transduce(args) }

  ** Debug dump
  @NoDoc virtual Void dump(OutStream out := Env.cur.out) {}
}


