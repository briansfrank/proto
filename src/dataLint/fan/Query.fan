//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Jan 2023  Brian Frank  Creation
//

using data
using haystackx
using axonx

**
** Query
**
@Js
class Query
{

//////////////////////////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////////////////////////

  new make(AxonContext cx)
  {
    this.cx = cx
    this.fitter = Fitter(cx)
  }

  Dict[] query(Dict subject, DataSlot query)
  {
    // verify its a query
    if (!query.slotType.isaQuery) throw ArgErr("Slot is not Query type: $query.qname")

    // TODO get of type
    of := query.meta["of"] as DataType
    if (of == null)
    {
      if (query.name == "points") of = cx.data.type("ph.Point")
      else if (query.name == "equips") of = cx.data.type("ph.Equip")
      else throw Err("TODO: need to wire up 'of'")
    }

    // via
    via := query.meta["via"] as Str
    if (via != null) return queryVia(subject, of, query, via)

    // inverse
    inverse := query.meta["inverse"] as Str
    if (inverse != null) return queryInverse(subject, of, query, inverse)

    throw Err("Query missing via or inverse meta: $query.qname")
  }

//////////////////////////////////////////////////////////////////////////
// Query Via
//////////////////////////////////////////////////////////////////////////

  private Dict[] queryVia(Dict subject, DataType of, DataSlot query, Str via)
  {
    multiHop := false
    if (via.endsWith("+"))
    {
      multiHop = true
      via = via[0..-2]
    }

    acc := Dict[,]
    cur := subject as Dict
    while (true)
    {
      cur = matchVia(cur, of, via)
      if (cur == null) break
      acc.add(cur)
      if (!multiHop) break
    }
    return acc
  }

  private Dict? matchVia(Dict subject, DataType of, Str via)
  {
    ref := subject.get(via, null) as Ref
    if (ref == null) return null

    rec := cx.deref(ref)
    if (rec == null) return rec

    if (!fitter.fits(rec, of)) return null

    return rec
  }

//////////////////////////////////////////////////////////////////////////
// Query Inverse
//////////////////////////////////////////////////////////////////////////

  private Dict[] queryInverse(Dict subject, DataType of, DataSlot query, Str inverseName)
  {
    inverse := cx.data.slot(inverseName, false)
    if (inverse == null) throw Err("Inverse of query '$query.qname' not found: $inverseName")

    // require inverse query to be structured as via (which is all we support anyways)
    via := inverse.meta["via"] as Str
    if (via == null) throw Err("Inverse of query '$query.qname' must be via: '$inverse.qname'")
    multiHop := false
    if (via.endsWith("+"))
    {
      multiHop = true
      via = via[0..-2]
    }

    // TODO: this uses temp AxonContext.readAll hack
    potentialRecs := cx.readAll(Filter.has(via))

    // find all potentials that have via refs+ back to me
    subjectId := subject.id
    return potentialRecs.findAll |rec|
    {
      matchInverse(subjectId, rec, via, multiHop) && fitter.fits(rec, of)
    }
  }

  private Bool matchInverse(Ref subjectId, Dict rec, Str via, Bool multiHop)
  {
    ref := rec[via] as Ref
    if (ref == null) return false

    if (ref == subjectId) return true

    if (!multiHop) return false

    x := cx.deref(ref)
    if (x == null) return false

    // TODO: need some cyclic checks
    return matchInverse(subjectId, x, via, multiHop)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private AxonContext cx
  private Fitter fitter
}