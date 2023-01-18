//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Jan 2023  Brian Frank  Creation
//

using util

**
** Logical set of DataDict records.  Each record in a data set is keyed
** by a primary id which is unique within this data set.  The 'id' slot
** is used for this key if available, otherwise a synthetic key is generated.
**
@Js
const mixin DataSet
{
  ** Number of records in the data
  abstract Int size()

  ** Lookup a record by its id.
  abstract DataDict? get(Obj id, Bool checked := true)

  ** Iterate the records in the data set
  abstract Void each(|DataDict rec, Obj id| f)

  ** Transform set into a map keyed by id
  abstract Obj:DataDict toMap()

  ** Transform set into list of records
  abstract DataDict[] toList()

  ** Find the first record that matches given predicate function
  abstract DataDict? find(|DataDict rec, Obj id->Bool| f)

  ** Find the all records that match given predicate function
  abstract DataSet findAll(|DataDict rec, Obj id->Bool| f)

  ** Return a new data set filtered by each rec that fits given type
  abstract DataSet findAllFits(DataType type)

  ** Validate the records using their nominally declared types
  abstract DataEventSet validate()

  ** Debug dump
  @NoDoc abstract Void dump(OutStream out := Env.cur.out)
}