//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

using util

@NoDoc const class CompilerErr : Err
{
  new make(Str msg, FileLoc loc, Err? cause) : super(msg, cause) { this.loc = loc }
  const FileLoc loc
}