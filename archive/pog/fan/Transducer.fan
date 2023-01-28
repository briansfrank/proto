//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using util

**
** Transducer performs a transformation on one or more input objects.
** There is always at least one output object and zero more events
** used to report warnings, errors, and other side channel data.
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
  abstract TransduceData transduce(Str:TransduceData args)
}

