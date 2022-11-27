//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 May 2022  Brian Frank  Creation
//

**
** Graph models a self contained namespaced graph of protos.
**
@Js
const mixin Graph : Proto
{
  ** The core system library
  abstract Lib sys()

  ** Libraries used by this namespace
  abstract Lib[] libs()

  ** Lookup a library by its dotted qualified name
  abstract Lib? lib(Str name, Bool checked := true)

  ** Encode the entire space to a JSON file.  Also see `PogEnv.decodeJson`.
  abstract Void encodeJson(OutStream out)

  ** Get the proto with the fully qualified name
  abstract Proto? getq(Str qname, Bool checked := true)

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  override abstract Proto? trap(Str name, Obj?[]? args := null)
}



