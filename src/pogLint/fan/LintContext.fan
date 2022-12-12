//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Dec 2022  Brian Frank  Creation
//

using pog

**
** LintContext is the public API for a LintRule to process and given
** proto and report items.
**
@Js
mixin LintContext
{
  ** Current graph
  abstract Graph graph()

  ** Parent of the current proto (or null if root)
  abstract Proto? parent()

  ** Current proto object
  abstract Proto proto()

  ** Log error against current proto
  abstract Void err(Str msg)

  ** Log warning against current proto
  abstract Void warn(Str msg)

  ** Log info against current proto
  abstract Void info(Str msg)
}