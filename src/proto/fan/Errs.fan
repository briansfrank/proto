//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

@NoDoc
const class UnknownProtoErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

@NoDoc
const class ProtoMissingValErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

@NoDoc
const class UnknownLibErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

