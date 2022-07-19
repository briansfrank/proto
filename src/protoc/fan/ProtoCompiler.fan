//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto

**
** Proto compiler
**
internal class ProtoCompiler
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  ** It-block constructor
  new make(|This| f) { f(this) }

//////////////////////////////////////////////////////////////////////////
// Inputs
//////////////////////////////////////////////////////////////////////////

  ** Info, warning, and error logging
  const Log log := Log.get("protoc")

  ** Install environment
  const ProtoEnv env := ProtoEnv.cur

  ** Library names to compile
  const Str[] libNames

  ** Output directory for compiler/documentation results
  const File? outDir

//////////////////////////////////////////////////////////////////////////
// Pipelines
//////////////////////////////////////////////////////////////////////////

  ** Compile input libs to a ProtoSpace
  ProtoSpace compileSpace()
  {
    run([
       InitLibs(),
      ])
    log.info("compileSpace [$duration.toLocale]")
throw Err("TODO")
    return ps
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
      return this
    }
    catch (CompilerErr e)
    {
      throw e
    }
    catch (Err e)
    {
      throw err("Internal compiler error", Loc.none, e)
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
  Void warn(Str msg, Loc loc, Err? cause := null)
  {
    log.warn("$msg [$loc]", cause)
  }

  ** Log err message
  CompilerErr err(Str msg, Loc loc, Err? cause := null)
  {
    err := CompilerErr(msg, loc, cause)
    errs.add(err)
    log.err("$msg [$loc]", cause)
    return err
  }

  ** Log err message with two locations of duplicate identifiers
  CompilerErr err2(Str msg, Loc loc1, Loc loc2, Err? cause := null)
  {
    err := CompilerErr(msg, loc1, cause)
    errs.add(err)
    log.err("$msg [$loc1, $loc2]", cause)
    return err
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  internal CompilerErr[] errs := [,]     // err
  internal Duration? duration            // run
  internal CLib[]? libs                  // InitLibs
  internal MProtoSpace? ps               // Assemble
}


