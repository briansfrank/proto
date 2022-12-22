//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using util

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
  abstract Transduction transduce(Str:Obj? args)
}

**************************************************************************
** Transduction
**************************************************************************

**
** Transduction models the result and events from `Transducer.transduce`
**
@Js
const mixin Transduction
{
  ** Get the result.  If the transduction had errors and checked flag
  ** is true then raise an exception instead of returning the result.
  abstract Obj? get(Bool checked := true)

  ** Return if there was zero error events (might be other events)
  abstract Bool isOk()

  ** Return if there was one or more error events
  abstract Bool isErr()

  ** All events from the transduction
  abstract TransduceEvent[] events()

  ** Error events from the transduction
  abstract TransduceEvent[] errs()
}

**************************************************************************
** TransductionEvent
**************************************************************************

**
** TransduceEvent models an event from `Transducer.transduce`.
** Typically events are warnings and errors.
**
@Js
const mixin TransduceEvent
{
  ** Severity level of the event
  abstract TransduceEventLevel level()

  ** Message for the event
  abstract Str msg()

  ** File location or unknown if not applicable
  abstract FileLoc loc()

  ** Cause exception if applicable
  abstract Err? err()
}

**************************************************************************
** TransduceEventLevel
**************************************************************************

**
** Severity level of a transduction event
**
@Js
enum class TransduceEventLevel
{
  info,
  warn,
  err
}




