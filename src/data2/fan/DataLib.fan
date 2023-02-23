//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Versioned library module of data specifications.
** Use `DataEnv.lib` to load libraries.
**
@Js
const mixin DataLib : DataSpec
{

  ** Full qualified name of this library
  abstract Str qname()

  ** Version of this library
  abstract Version version()

}