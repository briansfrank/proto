//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 May 2022  Brian Frank  Creation
//

**
** Graph is the root a self contained namespaced graph of protos.
**
@Js
abstract const class Graph : AbstractProto
{
  ** Environment
  abstract PogEnv env()

  ** The core system library
  abstract Lib sys()

  ** Libraries used by this namespace
  abstract Lib[] libs()

  ** Lookup a library by its dotted qualified name
  abstract Lib? lib(Str name, Bool checked := true)

  ** Get the proto with the fully qualified name.
  ** The qname parameter may be a Str or a QName.
  abstract Proto? getq(Obj qname, Bool checked := true)

  ** Get the proto by its unique id key
  abstract Proto? getById(Str id, Bool checked := true)

  ** Perform an update to the graph and return new instance
  abstract Graph update(|Update| f)

}





