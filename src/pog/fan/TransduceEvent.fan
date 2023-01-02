//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using util

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

  ** Qualified name of target proto or null if not applicable
  abstract QName? qname()

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




