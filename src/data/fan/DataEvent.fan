//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jan 2023  Brian Frank  Creation
//

using util

**
** Event item for info and errors within data sets.
**
/* TODO
@Js
const mixin DataEvent : DataDict
{
  ** Id for subject record in the dataset or null if not applicable
  abstract Obj? subjectId()

  ** Severity level of the event
  abstract DataEventLevel level()

  ** Message for the event
  abstract Str msg()

  ** File location or unknown if not applicable
  abstract FileLoc loc()

  ** Cause exception if applicable
  abstract Err? err()
}

**************************************************************************
** DataEventSet
**************************************************************************

**
** Data set of events
**
@Js
const mixin DataEventSet : DataSet
{
  ** Subject data set of the events
  abstract DataSet subjectSet()

  ** List of all events
  abstract DataEvent[] events()
}

*****************************************************************
** DataEventLevel
**************************************************************************

**
** Severity level of a data event
**
@Js
enum class DataEventLevel
{
  info,
  warn,
  err
}

*/