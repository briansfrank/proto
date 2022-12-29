//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Aug 2022  Brian Frank  Creation
//

using util
using pog
using pogEnv

**
** PogStubCompiler: pog -> sections of Fantom code
**
class PogStubCompiler
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  ** It-block constructor
  new make(|This| f) { f(this) }

//////////////////////////////////////////////////////////////////////////
// Inputs
//////////////////////////////////////////////////////////////////////////

  ** Environment
  MPogEnv env := PogEnv.cur

  ** Info, warning, and error logging
  Logger logger := Logger.makeOutStream

//////////////////////////////////////////////////////////////////////////
// Pipelines
//////////////////////////////////////////////////////////////////////////

  ** Compile input libs to a ProtoSpace
  Void compile()
  {
    run([
      FindPods(),
      FindTypes(),
      GenSlots(),
      RewriteIndex(),
      RewriteTypes(),
    ])
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
      info("Done [$duration.toLocale]")
      return this
    }
    catch (CompilerErr e)
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
    logger.info(msg)
  }

  ** Log warning message
  Void warn(Str msg, FileLoc loc, Err? cause := null)
  {
    logger.warn(msg, loc, cause)
  }

  ** Log err message
  CompilerErr err(Str msg, FileLoc loc, Err? cause := null)
  {
    err := CompilerErr(msg, loc, cause)
    errs.add(err)
    logger.err(msg, loc, cause)
    return err
  }

  ** Log err message with two locations of duplicate identifiers
  CompilerErr err2(Str msg, FileLoc loc1, FileLoc loc2, Err? cause := null)
  {
    err := CompilerErr(msg, loc1, cause)
    errs.add(err)
    logger.err("$msg [$loc2]", loc1, cause)
    return err
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  internal CompilerErr[] errs := [,]     // err
  internal Duration? duration            // run
  internal Lib[]? libs                   // CompileLibs
  internal PodSrc[]? pods                // FindPods
}



