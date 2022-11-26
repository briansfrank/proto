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
const mixin Graph
{
  ** The core system library
  abstract Lib sys()

  ** Libraries used by this namespace
  abstract Lib[] libs()

  ** Lookup a library by its dotted qualified name
  abstract Lib? lib(Str name, Bool checked := true)

  ** The object type from which all other objects inherit
  abstract Proto obj()

  ** The str type object
  abstract Proto str()

  ** The marker type object
  abstract Proto marker()

  ** The dict type object
  abstract Proto dict()

  ** Root object for this space
  abstract Proto root()

  ** Encode the entire space to a JSON file.  Also see `ProtoEnv.decodeJson`.
  abstract Void encodeJson(OutStream out)

  ** Get the proto with the fully qualified name
  @Operator abstract Proto? get(Str qname, Bool checked := true)
}



