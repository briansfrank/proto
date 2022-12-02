//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Aug 2022  Brian Frank  Creation
//

using pog

**
** TypeSrc models the source file of a Fantom type with protos
**
internal class TypeSrc
{
  new make(Proto proto, PodSrc pod, File file, Bool isAbstract, Str base, Range lines)
  {
    this.proto      = proto
    this.pod        = pod
    this.name       = proto.name
    this.file       = file
    this.isAbstract = isAbstract
    this.base       = base
    this.lines      = lines
  }

  const Proto proto     // Proto for the type
  PodSrc pod            // Pod source directory
  const Str name        // Proto and Fantom type name
  const File file       // Fantom source file
  const Str base        // Fantom base type name
  const Bool isAbstract // Is the class abstract (non-indexed)
  const Range lines     // pog-start .. pog-end lines (zero based line numbers)
  Str[]? gen            // GenSlots source code

  override Str toStr() { proto.qname }
}