//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Base type for static library definitions
**
@Js
const mixin DataDef
{
  ** Environment
  abstract DataEnv env()

  ** Source code location for this definition
  abstract FileLoc loc()

  ** Documentation for this definition or empty string if unknown
  abstract Str doc()

  ** Meta data for this definition
  abstract DataDict meta()
}