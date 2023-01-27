//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//  26 Jan 2023  Brian Frank  Repurpose ProtoCompiler
//

using util
using data

**
** Xeto compiler
**
@Js
class XetoCompiler
{

//////////////////////////////////////////////////////////////////////////
// Inputs
//////////////////////////////////////////////////////////////////////////

  ** Install environment
  DataEnv? env

  ** Logging
  XetoLog log := XetoLog.makeOutStream

  ** Input file or directory
  File? input

  ** Qualified name of library to compile
  Str? qname

//////////////////////////////////////////////////////////////////////////
// Pipelines
//////////////////////////////////////////////////////////////////////////

  ** Compile input directory to library
  XetoObj compileLib()
  {
    run([
      InitLib(),
      Parse(),
      Infer(),
      Resolve(),
    ])
    return ast
  }

  ** Run the pipeline with the given steps
  internal This run(Step[] steps)
  {
    try
    {
      t1 := Duration.now
      steps.each |step|
      {
        step.compiler = this
        step.run
      }
      t2 := Duration.now
      duration = t2 - t1
      info("Compile data lib $qname.toCode [$duration.toLocale]")
      return this
    }
    catch (XetoCompilerErr e)
    {
      throw e
    }
    catch (Err e)
    {
      throw err("Internal compiler error", FileLoc.unknown, e)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  ** Log info message
  Void info(Str msg)
  {
    log.info(msg)
  }

  ** Log warning message
  Void warn(Str msg, FileLoc loc, Err? cause := null)
  {
    log.warn(msg, loc, cause)
  }

  ** Log err message
  XetoCompilerErr err(Str msg, FileLoc loc, Err? cause := null)
  {
    err := XetoCompilerErr(msg, loc, cause)
    errs.add(err)
    log.err(msg, loc, cause)
    return err
  }

  ** Log err message with two locations of duplicate identifiers
  XetoCompilerErr err2(Str msg, FileLoc loc1, FileLoc loc2, Err? cause := null)
  {
    err := XetoCompilerErr(msg, loc1, cause)
    errs.add(err)
    log.err("$msg [$loc2]", loc1, cause)
    return err
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  XetoCompilerErr[] errs := [,]        // err
  internal SysTypes sys := SysTypes()  // make
  internal Duration? duration          // run
  internal Bool isLib                  // compileLib
  internal XetoObj? ast                // Parse
  internal XetoObj? pragma             // Parse
  internal DataLib? lib                // Assmble
}

**************************************************************************
** SysTypes
**************************************************************************

@Js
internal class SysTypes
{
  XetoType obj    := init("sys.Obj")
  XetoType marker := init("sys.Marker")
  XetoType str    := init("sys.Str")
  XetoType dict   := init("sys.Dict")
  XetoType list   := init("sys.List")

  private static XetoType init(Str qname) { XetoType(FileLoc.synthetic, qname) }
}

**************************************************************************
** XetoCompilerErr
**************************************************************************

@Js
const class XetoCompilerErr : FileLocErr
{
  new make(Str msg, FileLoc loc, Err? cause := null) : super(msg, loc, cause) {}
}


