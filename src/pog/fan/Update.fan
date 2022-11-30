//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   6 Aug 2022  Brian Frank  Creation
//

using concurrent

**
** Graph update context
**
@Js
abstract class Update
{

//////////////////////////////////////////////////////////////////////////
// Execution Context
//////////////////////////////////////////////////////////////////////////

  ** Get the current update
  static Update? cur(Bool checked := true)
  {
    u := curStack?.peek
    if (u != null) return u
    if (checked) throw NotInUpdateErr("Not currently in an update")
    return null
  }

  ** Get the current update stack
  @NoDoc static Update[]? curStack()
  {
    Actor.locals[actorKey] as Update[]
  }

  ** Push this update on to the stack, perform callback, then pop
  @NoDoc Graph execute(|This->Graph| f)
  {
    stack := curStack
    if (stack == null)
    {
      Actor.locals[actorKey] = stack = Update[this]
      try
        return f(this)
      finally
        Actor.locals.remove(actorKey)
    }
    else
    {
      stack.push(this)
      try
        return f(this)
      finally
        stack.pop
    }
  }

  private static const Str actorKey := "pog.update"

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** Associated original instance of the graph
  abstract Graph graph()

  ** Timestamp for this update
  abstract DateTime ts()

  ** Duration ticks for this update
  abstract Int ticks()

  ** Transaction id for this update
  abstract Int tx()

  ** Convenience for 'graph.get'
  Proto? getq(Str qname, Bool checked := true) { graph.getq(qname, checked) }

//////////////////////////////////////////////////////////////////////////
// Updates
//////////////////////////////////////////////////////////////////////////

  ** Proto initialization
  @NoDoc abstract ProtoSpi init(Proto proto)

  ** Load the given library name into the graph.  If the library is already
  ** loaded then this a no-op.  Dependencies must already be loaded.
  abstract This load(Str libName)

  ** Remove the given library name into the graph.  If library is not already
  ** loaded then this no-op.  Raise exception if other loaded libraries
  ** depend on the given library.
  abstract This unload(Str libName)

  ** Clone a new proto from the given type
  abstract ProtoStub clone(ProtoStub type)

  ** Add or update the effective child within the parent.  If the given
  ** name does not exist or is inherited, then this method always ensures
  ** that parent has its own child slot for the name.   The value may be a
  ** Proto or a scalar value.  If the parent's type has a slot with the same
  ** name, then value must be type compatible with the parent's definition.
  abstract This set(ProtoStub parent, Str name, Obj val)

  ** Add the given slot name within the parent.  This method has the
  ** exact same semantics as `set` except it raises a 'DupProtoNameErr'
  ** if name is already bound to slot (own or inherited).  If name is null,
  ** then a name is auto-generated.
  abstract This add(ProtoStub parent, Obj val, Str? name := null)

  ** Remove given slot from the parent proto.  Note this removes the slot
  ** only if the parent has its own slot with the given name; the name
  ** may still be inherited from the parent's prototype.  If the parent
  ** does not have its own slot with the given name, then this method is
  ** a silent no-op.
  abstract This remove(ProtoStub parent, Str name)

  ** Remove all children protos from the given proto.  This method only
  ** removes slots which owned by the given parent, not inherited slots.
  abstract This clear(ProtoStub parent)
}

**************************************************************************
** ProtoStub
**************************************************************************

** ProtoStub is an actual Proto instance or a place holder
** used during the update proecess.
@Js
mixin ProtoStub {}

