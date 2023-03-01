//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Mar 2023  Brian Frank  Creation
//

using concurrent
using util

**
** AST spec - type and meta
**
@Js
internal class ASpec
{
  ARef? type
  AMap meta := AMap()
}