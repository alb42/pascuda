unit cufft;

(* CUFFT API  *)
(* created 2012-04-01
   author: Mariusz mariusz.maximus@gmail.com
*)


interface

uses WIndows, sysutils;

type
// CUFFT API function return values
cufftResult = (
  CUFFT_SUCCESS        = $0,
  CUFFT_INVALID_PLAN   = $1,
  CUFFT_ALLOC_FAILED   = $2,
  CUFFT_INVALID_TYPE   = $3,
  CUFFT_INVALID_VALUE  = $4,
  CUFFT_INTERNAL_ERROR = $5,
  CUFFT_EXEC_FAILED    = $6,
  CUFFT_SETUP_FAILED   = $7,
  CUFFT_INVALID_SIZE   = $8,
  CUFFT_UNALIGNED_DATA = $9);


// CUFFT defines and supports the following data types

// cufftHandle is a handle type used to store and access CUFFT plans.
cufftHandle = cardinal;

// cufftReal is a single-precision, floating-point real data type.
// cufftDoubleReal is a double-precision, real data type.
cufftReal = single;
cufftDoubleReal = double;

PcufftReal = ^cufftReal;
PcufftDoubleReal = ^cufftDoubleReal;

// cufftComplex is a single-precision, floating-point complex data type that
// consists of interleaved real and imaginary components.
// cufftDoubleComplex is the double-precision equivalent.
//??typedef cuComplex cufftComplex;
cufftComplex = packed record
  x,y: single;
end;
//??typedef cuDoubleComplex cufftDoubleComplex;
cufftDoubleComplex = packed record
  x,y: double;
end;

PcufftComplex = ^cufftComplex;
PcufftDoubleComplex= ^cufftDoubleComplex;

// CUFFT transform directions
const CUFFT_FORWARD = -1; // Forward FFT
const CUFFT_INVERSE = 1; // Inverse FFT



type

cufftType = (
  CUFFT_R2C = $2a,     // Real to Complex (interleaved)
  CUFFT_C2R = $2c,     // Complex (interleaved) to Real
  CUFFT_C2C = $29,     // Complex to Complex, interleaved
  CUFFT_D2Z = $6a,     // Double to Double-Complex
  CUFFT_Z2D = $6c,     // Double-Complex to Double
  CUFFT_Z2Z = $69      // Double-Complex to Double-Complex
);

cudaStream_t = integer; // ??????????????????


// Certain R2C and C2R transforms go much more slowly when FFTW memory
// layout and behaviour is required. The default is "best performance",
// which means not-compatible-with-fftw. Use the cufftSetCompatibilityMode
// API to enable exact FFTW-like behaviour.
//
// These flags can be ORed together to select precise FFTW compatibility
// behaviour. The two levels presently supported are:
//
//  CUFFT_COMPATIBILITY_FFTW_PADDING
//      Inserts extra padding between packed in-place transforms for
//      batched transforms with power-of-2 size.
//
//  CUFFT_COMPATIBILITY_FFTW_C2R_ASYMMETRIC
//      Guarantees FFTW-compatible output for non-symmetric complex inputs
//      for transforms with power-of-2 size. This is only useful for
//      artificial (i.e. random) datasets as actual data will always be
//      symmetric if it has come from the real plane. If you don't
//      understand what this means, you probably don't have to use it.
//
//  CUFFT_COMPATIBILITY_FFTW
//      For convenience, enables all FFTW compatibility modes at once.
//
cufftCompatibility = (
    CUFFT_COMPATIBILITY_NATIVE          = $00,
    CUFFT_COMPATIBILITY_FFTW_PADDING    = $01,    // The default value
    CUFFT_COMPATIBILITY_FFTW_ASYMMETRIC = $02,
    CUFFT_COMPATIBILITY_FFTW_ALL        = $03
);

const CUFFT_COMPATIBILITY_DEFAULT =  CUFFT_COMPATIBILITY_FFTW_PADDING;


type
 __cufftPlan1d = function(var plan: cufftHandle;
                                 nx: integer;
                                 type_:cufftType;
                                 batch:integer (* deprecated - use cufftPlanMany *)):cufftResult;  stdcall;

 __cufftPlan2d = function(var plan:cufftHandle;
                                 nx:integer; ny:integer;
                                  type_:cufftType):cufftResult; stdcall;

 __cufftPlan3d = function(var plan: cufftHandle;
                                 nx:integer; ny:integer; nz:integer;
                                 type_:cufftType):cufftResult; stdcall;

 __cufftPlanMany = function(var plan: cufftHandle;
                                   rank:integer;
                                   n:Pinteger;
                                   inembed:Pinteger; istride:integer;  idist:integer;
                                   onembed:Pinteger; ostride:integer; odist:integer;
                                   type_:cufftType;
                                   batch:integer):cufftResult; stdcall;

 __cufftDestroy = function(plan: cufftHandle):cufftResult; stdcall;

 __cufftExecC2C = function(plan: cufftHandle;
                                  idata: PcufftComplex;
                                  odata: PcufftComplex;
                                  direction:integer):cufftResult; stdcall;

 __cufftExecR2C = function(plan: cufftHandle;
                                  idata: PcufftReal;
                                  odata: PcufftComplex):cufftResult; stdcall;

 __cufftExecC2R = function(plan: cufftHandle;
                                   idata: PcufftComplex;
                                   odata: cufftReal):cufftResult; stdcall;

 __cufftExecZ2Z = function(plan: cufftHandle;
                                  idata: PcufftDoubleComplex;
                                  odata: PcufftDoubleComplex;
                                  direction:integer):cufftResult; stdcall;

 __cufftExecD2Z = function(plan: cufftHandle;
                                   idata:PcufftDoubleReal;
                                   odata:PcufftDoubleComplex):cufftResult; stdcall;

 __cufftExecZ2D = function(plan: cufftHandle;
                                  idata: PcufftDoubleComplex;
                                  odata: PcufftDoubleReal):cufftResult; stdcall;

 __cufftSetStream = function(plan: cufftHandle;
                                    stream: cudaStream_t):cufftResult; stdcall;

 __cufftSetCompatibilityMode = function( plan: cufftHandle;
                                                mode: cufftCompatibility):cufftResult; stdcall;

 __cufftGetVersion = function(var version:integer):cufftResult; stdcall;


var
  cufftPlan1d: __cufftPlan1d;
  cufftPlan2d:__cufftPlan2d ;
  cufftPlan3d:__cufftPlan3d ;
  cufftPlanMany:__cufftPlanMany ;
  cufftDestroy:__cufftDestroy ;
  cufftExecC2C:__cufftExecC2C ;
  cufftExecR2C:__cufftExecR2C ;
  cufftExecC2R:__cufftExecC2R ;
  cufftExecZ2Z:__cufftExecZ2Z ;
  cufftExecD2Z:__cufftExecD2Z ;
  cufftExecZ2D:__cufftExecZ2D ;
  cufftSetStream:__cufftSetStream ;
  cufftSetCompatibilityMode:__cufftSetCompatibilityMode ;
  cufftGetVersion:__cufftGetVersion ;
implementation

const
  cufftDLLName = 'cufft32_41_28.dll';


var
  cufftLoaded: boolean;
  cufftDLL:HMODULE;


procedure InitializeLibrary;
begin
  cufftDLL := LoadLibraryEx(cufftDLLName, 0, 0);
  if cufftDLL = 0 then
    raise Exception.CreateFmt('File: %s could not be found',
      [cufftDLLName])
  else
  begin
    @cufftPlan1d := GetProcAddress(cufftDLL, 'cufftPlan1d');  Assert ( @cufftPlan1d <> nil);
    @cufftPlan2d := GetProcAddress(cufftDLL, 'cufftPlan2d');  Assert ( @cufftPlan2d <> nil);
    @cufftPlan3d := GetProcAddress(cufftDLL, 'cufftPlan3d');  Assert ( @cufftPlan3d <> nil);
    @cufftPlanMany := GetProcAddress(cufftDLL, 'cufftPlanMany');  Assert ( @cufftPlanMany <> nil);
    @cufftDestroy := GetProcAddress(cufftDLL, 'cufftDestroy');  Assert ( @cufftDestroy <> nil);
    @cufftExecC2C := GetProcAddress(cufftDLL, 'cufftExecC2C');  Assert ( @cufftExecC2C <> nil);
    @cufftExecR2C := GetProcAddress(cufftDLL, 'cufftExecR2C');  Assert ( @cufftExecR2C <> nil);
    @cufftExecC2R := GetProcAddress(cufftDLL, 'cufftExecC2R');  Assert ( @cufftExecC2R <> nil);
    @cufftExecZ2Z := GetProcAddress(cufftDLL, 'cufftExecZ2Z');  Assert ( @cufftExecZ2Z <> nil);
    @cufftExecD2Z := GetProcAddress(cufftDLL, 'cufftExecD2Z');  Assert ( @cufftExecD2Z <> nil);
    @cufftExecZ2D := GetProcAddress(cufftDLL, 'cufftExecZ2D');  Assert ( @cufftExecZ2D <> nil);
    @cufftSetStream := GetProcAddress(cufftDLL, 'cufftSetStream');  Assert ( @cufftSetStream <> nil);
    @cufftSetCompatibilityMode := GetProcAddress(cufftDLL, 'cufftSetCompatibilityMode');  Assert ( @cufftSetCompatibilityMode <> nil);
    @cufftGetVersion := GetProcAddress(cufftDLL, 'cufftGetVersion');  Assert ( @cufftGetVersion <> nil);
    cufftLoaded := True;
  end;
end;

procedure FinalizeLibrary;
begin
  FreeLibrary(cufftDLL);
  cufftLoaded := False;
end;

initialization
  InitializeLibrary;
finalization
  FinalizeLibrary;
end.

