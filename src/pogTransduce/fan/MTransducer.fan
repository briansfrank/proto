//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Dec 2022  Brian Frank  Creation
//

using util
using pog

**
** Base class for implementations
**
@Js
abstract const class MTransducer : Transducer
{
  ** Constructor
  new make(PogEnv env, Str name) : super(env, name) {}

  ** Get an argument by name
  Obj? arg(Str:Obj? args, Str name, Bool checked := true)
  {
    arg := args[name]
    if (arg != null) return arg
    if (checked) throw ArgErr("Missing argument: $name")
    return null
  }

  ** Convert arg into an input stream
  InStream toInStream(Obj arg)
  {
    if (arg is InStream) return arg
    if (arg is Str) return ((Str)arg).in
    if (arg is File) return ((File)arg).in
    throw ArgErr("Invalid read arg for $name transducer")
  }

  ** Convert an arg into a file location
  FileLoc toFileLoc(Obj arg)
  {
    if (arg is File) return FileLoc.makeFile(arg)
    return FileLoc.unknown
  }

  ** Standard read using 'read' arg as input stream and file location
  Obj? read(Str:Obj args, |InStream, FileLoc->Obj?| f)
  {
    arg := arg(args, "read")
    loc := toFileLoc(arg)
    in := toInStream(arg)
    try
      return f(in, loc)
    finally
      in.close
  }
}


