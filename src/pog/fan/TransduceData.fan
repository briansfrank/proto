//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Jan 2023  Brian Frank  Creation
//

using util

**
** TransduceData wraps the arguments and results for `Transducer.transduce`.
** It wraps up the value object itself, tags used for type hinting,
** and error events.  Create instances via `PogEnv.data`.
**
@Js
mixin TransduceData
{
  ** Get the wrapped data object.  If the transduce had errors and checked
  ** flag is true then raise an exception instead of returning the result.
  abstract Obj? get(Bool checked := true)

  ** Type hinting for type of data wrapped.  Standard values:
  **   - json
  **   - json, ast, unresolved
  **   - json, ast, resolved
  **   - proto, unvalidated
  **   - proto, validated
  **   - grid
  abstract Str[] tags()

  ** File location of data if applicable
  abstract FileLoc loc()

  ** Return if there was zero error events (might be other events)
  abstract Bool isOk()

  ** Return if there was one or more error events
  abstract Bool isErr()

  ** All events from the transduction
  abstract TransduceEvent[] events()

  ** Error events from the transduction
  abstract TransduceEvent[] errs()
}

