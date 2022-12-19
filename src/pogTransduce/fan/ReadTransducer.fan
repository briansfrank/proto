//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** ReadTransducer is the base class to operate on an input stream
**
@Js
abstract const class ReadTransducer : Transducer
{
  new make(PogEnv env, Str name) : super(env, name) {}

  override final Bool canTransduce(Obj in)
  {
    in is InStream || in is Str || in is File
  }

  private InStream toInStream(Obj arg)
  {
    if (arg is InStream) return arg
    if (arg is Str) return ((Str)arg).in
    if (arg is File) return ((File)arg).in
    throw ArgErr("Invalid input for $name transducer")
  }

  private FileLoc toFileLoc(Obj arg)
  {
    if (arg is File) return FileLoc.makeFile(arg)
    return FileLoc.unknown
  }

  override final Obj transduce(Obj arg)
  {
    loc := toFileLoc(arg)
    in := toInStream(arg)
    try
      return read(loc, in)
    finally
      in.close
  }

  abstract Obj read(FileLoc loc, InStream in)
}


