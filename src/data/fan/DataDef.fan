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
const mixin DataDef : DataDict
{
  ** Environment
  abstract DataEnv env()

  ** Library module which contains this definition
  abstract DataLib lib()

  ** Qualified name which uniquely identifies this definition
  abstract Str qname()

  ** Source code location for this definition
  abstract FileLoc loc()

  ** Documentation for this definition or empty string if unknown
  abstract Str doc()

  ** Meta data for this definition
  abstract DataDict meta()

  ** Return qname for string representation.  Some special types
  ** like Maybe, And, and Or will return signature
  abstract override Str toStr()
}