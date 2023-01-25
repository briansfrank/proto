//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Jan 2023  Brian Frank  Creation
//

using axonx

**
** Axon shell specific functions
**
internal class ShellFuncs
{
  @Axon
  static Obj? quit()
  {
    cx.session.isDone = true
    return noEcho
  }

  @Axon
  static Obj? help(Obj? func := null)
  {
    session := cx.session
    out := session.out

    if (func == null)
    {
      out.printLine
      out.printLine("?, help            Print this help summary")
      out.printLine("quit, exit, bye    Exit the shell")
      out.printLine("help(func)         Help on a specific function")
      out.printLine
      return noEcho
    }

    f := func as TopFn
    if (f == null)
    {
      out.printLine("Not a top level function: $func [$func.typeof]")
      return noEcho
    }

    s := StrBuf()
    s.add(f.name).add("(")
    f.params.each |p, i|
    {
      if (i > 0) s.add(", ")
      s.add(p.name)
      if (p.def != null) s.add(":").add(p.def)
    }
    s.add(")")

    sig := s.toStr
    doc := funcDoc(f)

    out.printLine
    out.printLine(sig)
    if (doc != null) out.printLine.printLine(doc)
    out.printLine
    return noEcho
  }

  private static Str? funcDoc(TopFn f)
  {
    doc := f.meta["doc"] as Str
    if (doc != null) return doc.trimToNull
    if (f is FantomFn) return ((FantomFn)f).method.doc
    return null
  }

  @Axon
  static Obj? print(Obj? val := null)
  {
    echo(val)
    return noEcho
  }

  static Str noEcho() {  Session.noEcho }

  static Context cx() { AxonContext.curAxon }
}