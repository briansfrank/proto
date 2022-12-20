//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

**
** Transducer performs a transform from one or more graphs
** into one or more graphs.
**
@Js
abstract const class Transducer
{
  ** Constructor
  @NoDoc protected new make(PogEnv env, Str name)
  {
    this.envRef = env
    this.nameRef = name
  }

  ** Environment
  PogEnv env() { envRef }
  private const PogEnv envRef

  ** Name key for this format type
  Str name() { nameRef }
  private const Str nameRef

  ** Return name
  override final Str toStr() { name }

  ** Short one sentence summary
  abstract Str summary()

  ** Multi-line usage help for command line
  abstract Str usage()

  ** Transduce the given arguments
  abstract Obj? transduce(Str:Obj? args)
}



