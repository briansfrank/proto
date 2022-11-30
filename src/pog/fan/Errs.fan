//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

@Js @NoDoc
const class UnknownProtoErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

@Js @NoDoc
const class ProtoMissingValErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

@Js @NoDoc
const class UnknownLibErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

@Js @NoDoc
const class NotInUpdateErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

@NoDoc @Js
const class DupProtoNameErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

@NoDoc @Js
const class ProtoAlreadyParentedErr : Err
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}




