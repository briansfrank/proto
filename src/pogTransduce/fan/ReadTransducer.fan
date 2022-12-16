//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

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

  override final Obj transduce(Obj arg)
  {
    in := toInStream(arg)
    try
      return read(in)
    finally
      in.close
  }

  abstract Obj read(InStream in)
}


