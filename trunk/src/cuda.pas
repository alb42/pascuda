unit cuda;

(* DRIVER API CUDA *)
(* created 2012-04-01
   author: Mariusz max@olo.com.pl
*)

interface

uses Windows, SysUtils;

var
  CU_LAUNCH_PARAM_END : pointer;
  CU_LAUNCH_PARAM_BUFFER_POINTER :pointer;
  CU_LAUNCH_PARAM_BUFFER_SIZE :pointer;

type
 CUresult = (
     (*
     * The API call returned with no errors. In the case of query calls, this
     * can also mean that the operation being queried is complete (see
     * ::cuEventQuery() and ::cuStreamQuery()).
     *)
    CUDA_SUCCESS                              = 0,

    (*
     * This indicates that one or more of the parameters passed to the API call
     * is not within an acceptable range of values.
     *)
    CUDA_ERROR_INVALID_VALUE                  = 1,

    (*
     * The API call failed because it was unable to allocate enough memory to
     * perform the requested operation.
     *)
    CUDA_ERROR_OUT_OF_MEMORY                  = 2,

    (*
     * This indicates that the CUDA driver has not been initialized with
     * ::cuInit() or that initialization has failed.
     *)
    CUDA_ERROR_NOT_INITIALIZED                = 3,

    (*
     * This indicates that the CUDA driver is in the process of shutting down.
     *)
    CUDA_ERROR_DEINITIALIZED                  = 4,

    (*
     * This indicates profiling APIs are called while application is running
     * in visual profiler mode.
    *)
    CUDA_ERROR_PROFILER_DISABLED           = 5,
    (*
     * This indicates profiling has not been initialized for this context.
     * Call cuProfilerInitialize() to resolve this.
    *)
    CUDA_ERROR_PROFILER_NOT_INITIALIZED       = 6,
    (*
     * This indicates profiler has already been started and probably
     * cuProfilerStart() is incorrectly called.
    *)
    CUDA_ERROR_PROFILER_ALREADY_STARTED       = 7,
    (*
     * This indicates profiler has already been stopped and probably
     * cuProfilerStop() is incorrectly called.
    *)
    CUDA_ERROR_PROFILER_ALREADY_STOPPED       = 8,
    (*
     * This indicates that no CUDA-capable devices were detected by the installed
     * CUDA driver.
     *)
    CUDA_ERROR_NO_DEVICE                      = 100,

    (*
     * This indicates that the device ordinal supplied by the user does not
     * correspond to a valid CUDA device.
     *)
    CUDA_ERROR_INVALID_DEVICE                 = 101,


    (*
     * This indicates that the device kernel image is invalid. This can also
     * indicate an invalid CUDA module.
     *)
    CUDA_ERROR_INVALID_IMAGE                  = 200,

    (*
     * This most frequently indicates that there is no context bound to the
     * current thread. This can also be returned if the context passed to an
     * API call is not a valid handle (such as a context that has had
     * ::cuCtxDestroy() invoked on it). This can also be returned if a user
     * mixes different API versions (i.e. 3010 context with 3020 API calls).
     * See ::cuCtxGetApiVersion() for more details.
     *)
    CUDA_ERROR_INVALID_CONTEXT                = 201,

    (*
     * This indicated that the context being supplied as a parameter to the
     * API call was already the active context.
     * \deprecated
     * This error return is deprecated as of CUDA 3.2. It is no longer an
     * error to attempt to push the active context via ::cuCtxPushCurrent().
     *)
    CUDA_ERROR_CONTEXT_ALREADY_CURRENT        = 202,

    (*
     * This indicates that a map or register operation has failed.
     *)
    CUDA_ERROR_MAP_FAILED                     = 205,

    (*
     * This indicates that an unmap or unregister operation has failed.
     *)
    CUDA_ERROR_UNMAP_FAILED                   = 206,

    (*
     * This indicates that the specified array is currently mapped and thus
     * cannot be destroyed.
     *)
    CUDA_ERROR_ARRAY_IS_MAPPED                = 207,

    (*
     * This indicates that the resource is already mapped.
     *)
    CUDA_ERROR_ALREADY_MAPPED                 = 208,

    (*
     * This indicates that there is no kernel image available that is suitable
     * for the device. This can occur when a user specifies code generation
     * options for a particular CUDA source file that do not include the
     * corresponding device configuration.
     *)
    CUDA_ERROR_NO_BINARY_FOR_GPU              = 209,

    (*
     * This indicates that a resource has already been acquired.
     *)
    CUDA_ERROR_ALREADY_ACQUIRED               = 210,

    (*
     * This indicates that a resource is not mapped.
     *)
    CUDA_ERROR_NOT_MAPPED                     = 211,

    (*
     * This indicates that a mapped resource is not available for access as an
     * array.
     *)
    CUDA_ERROR_NOT_MAPPED_AS_ARRAY            = 212,

    (*
     * This indicates that a mapped resource is not available for access as a
     * pointer.
     *)
    CUDA_ERROR_NOT_MAPPED_AS_POINTER          = 213,

    (*
     * This indicates that an uncorrectable ECC error was detected during
     * execution.
     *)
    CUDA_ERROR_ECC_UNCORRECTABLE              = 214,

    (*
     * This indicates that the ::CUlimit passed to the API call is not
     * supported by the active device.
     *)
    CUDA_ERROR_UNSUPPORTED_LIMIT              = 215,

    (*
     * This indicates that the ::CUcontext passed to the API call can
     * only be bound to a single CPU thread at a time but is already
     * bound to a CPU thread.
     *)
    CUDA_ERROR_CONTEXT_ALREADY_IN_USE         = 216,

    (*
     * This indicates that the device kernel source is invalid.
     *)
    CUDA_ERROR_INVALID_SOURCE                 = 300,

    (*
     * This indicates that the file specified was not found.
     *)
    CUDA_ERROR_FILE_NOT_FOUND                 = 301,

    (*
     * This indicates that a link to a shared object failed to resolve.
     *)
    CUDA_ERROR_SHARED_OBJECT_SYMBOL_NOT_FOUND = 302,

    (*
     * This indicates that initialization of a shared object failed.
     *)
    CUDA_ERROR_SHARED_OBJECT_INIT_FAILED      = 303,

    (*
     * This indicates that an OS call failed.
     *)
    CUDA_ERROR_OPERATING_SYSTEM               = 304,


    (*
     * This indicates that a resource handle passed to the API call was not
     * valid. Resource handles are opaque types like ::CUstream and ::CUevent.
     *)
    CUDA_ERROR_INVALID_HANDLE                 = 400,


    (*
     * This indicates that a named symbol was not found. Examples of symbols
     * are global/constant variable names, texture names, and surface names.
     *)
    CUDA_ERROR_NOT_FOUND                      = 500,


    (*
     * This indicates that asynchronous operations issued previously have not
     * completed yet. This result is not actually an error, but must be indicated
     * differently than ::CUDA_SUCCESS (which indicates completion). Calls that
     * may return this value include ::cuEventQuery() and ::cuStreamQuery().
     *)
    CUDA_ERROR_NOT_READY                      = 600,


    (*
     * An exception occurred on the device while executing a kernel. Common
     * causes include dereferencing an invalid device pointer and accessing
     * out of bounds shared memory. The context cannot be used, so it must
     * be destroyed (and a new one should be created). All existing device
     * memory allocations from this context are invalid and must be
     * reconstructed if the program is to continue using CUDA.
     *)
    CUDA_ERROR_LAUNCH_FAILED                  = 700,

    (*
     * This indicates that a launch did not occur because it did not have
     * appropriate resources. This error usually indicates that the user has
     * attempted to pass too many arguments to the device kernel, or the
     * kernel launch specifies too many threads for the kernel's register
     * count. Passing arguments of the wrong size (i.e. a 64-bit pointer
     * when a 32-bit int is expected) is equivalent to passing too many
     * arguments and can also result in this error.
     *)
    CUDA_ERROR_LAUNCH_OUT_OF_RESOURCES        = 701,

    (*
     * This indicates that the device kernel took too long to execute. This can
     * only occur if timeouts are enabled - see the device attribute
     * ::CU_DEVICE_ATTRIBUTE_KERNEL_EXEC_TIMEOUT for more information. The
     * context cannot be used (and must be destroyed similar to
     * ::CUDA_ERROR_LAUNCH_FAILED). All existing device memory allocations from
     * this context are invalid and must be reconstructed if the program is to
     * continue using CUDA.
     *)
    CUDA_ERROR_LAUNCH_TIMEOUT                 = 702,

    (*
     * This error indicates a kernel launch that uses an incompatible texturing
     * mode.
     *)
    CUDA_ERROR_LAUNCH_INCOMPATIBLE_TEXTURING  = 703,

    (*
     * This error indicates that a call to ::cuCtxEnablePeerAccess() is
     * trying to re-enable peer access to a context which has already
     * had peer access to it enabled.
     *)
    CUDA_ERROR_PEER_ACCESS_ALREADY_ENABLED    = 704,

    (*
     * This error indicates that ::cuCtxDisablePeerAccess() is
     * trying to disable peer access which has not been enabled yet
     * via ::cuCtxEnablePeerAccess().
     *)
    CUDA_ERROR_PEER_ACCESS_NOT_ENABLED        = 705,

    (*
     * This error indicates that the primary context for the specified device
     * has already been initialized.
     *)
    CUDA_ERROR_PRIMARY_CONTEXT_ACTIVE         = 708,

    (*
     * This error indicates that the context current to the calling thread
     * has been destroyed using ::cuCtxDestroy, or is a primary context which
     * has not yet been initialized.
     *)
    CUDA_ERROR_CONTEXT_IS_DESTROYED           = 709,

    (*
     * A device-side assert triggered during kernel execution. The context
     * cannot be used anymore, and must be destroyed. All existing device
     * memory allocations from this context are invalid and must be
     * reconstructed if the program is to continue using CUDA.
     *)
    CUDA_ERROR_ASSERT                         = 710,

    (*
     * This error indicates that the hardware resources required to enable
     * peer access have been exhausted for one or more of the devices
     * passed to ::cuCtxEnablePeerAccess().
     *)
    CUDA_ERROR_TOO_MANY_PEERS                 = 711,

    (*
     * This error indicates that the memory range passed to ::cuMemHostRegister()
     * has already been registered.
     *)
    CUDA_ERROR_HOST_MEMORY_ALREADY_REGISTERED = 712,

    (*
     * This error indicates that the pointer passed to ::cuMemHostUnregister()
     * does not correspond to any currently registered memory region.
     *)
    CUDA_ERROR_HOST_MEMORY_NOT_REGISTERED     = 713,

    (*
     * This indicates that an unknown internal error has occurred.
     *)
    CUDA_ERROR_UNKNOWN                        = 999
);


  pCUjit_option = ^CUjit_option;
  CUjit_option = (

    (*
     * Max number of registers that a thread may use.\n
     * Option type: unsigned int
     *)
    CU_JIT_MAX_REGISTERS = 0,

    (*
     * IN: Specifies minimum number of threads per block to target compilation
     * for\n
     * OUT: Returns the number of threads the compiler actually targeted.
     * This restricts the resource utilization fo the compiler (e.g. max
     * registers) such that a block with the given number of threads should be
     * able to launch based on register limitations. Note, this option does not
     * currently take into account any other resource limitations, such as
     * shared memory utilization.\n
     * Option type: unsigned int
     *)
    CU_JIT_THREADS_PER_BLOCK,

    (*
     * Returns a float value in the option of the wall clock time, in
     * milliseconds, spent creating the cubin\n
     * Option type: float
     *)
    CU_JIT_WALL_TIME,

    (*
     * Pointer to a buffer in which to print any log messsages from PTXAS
     * that are informational in nature (the buffer size is specified via
     * option ::CU_JIT_INFO_LOG_BUFFER_SIZE_BYTES) \n
     * Option type: char*
     *)
    CU_JIT_INFO_LOG_BUFFER,

    (*
     * IN: Log buffer size in bytes.  Log messages will be capped at this size
     * (including null terminator)\n
     * OUT: Amount of log buffer filled with messages\n
     * Option type: unsigned int
     *)
    CU_JIT_INFO_LOG_BUFFER_SIZE_BYTES,

    (*
     * Pointer to a buffer in which to print any log messages from PTXAS that
     * reflect errors (the buffer size is specified via option
     * ::CU_JIT_ERROR_LOG_BUFFER_SIZE_BYTES)\n
     * Option type: char*
     *)
    CU_JIT_ERROR_LOG_BUFFER,

    (*
     * IN: Log buffer size in bytes.  Log messages will be capped at this size
     * (including null terminator)\n
     * OUT: Amount of log buffer filled with messages\n
     * Option type: unsigned int
     *)
    CU_JIT_ERROR_LOG_BUFFER_SIZE_BYTES,

    (*
     * Level of optimizations to apply to generated code (0 - 4), with 4
     * being the default and highest level of optimizations.\n
     * Option type: unsigned int
     *)
    CU_JIT_OPTIMIZATION_LEVEL,

    (*
     * No option value required. Determines the target based on the current
     * attached context (default)\n
     * Option type: No option value needed
     *)
    CU_JIT_TARGET_FROM_CUCONTEXT,

    (*
     * Target is chosen based on supplied ::CUjit_target_enum.\n
     * Option type: unsigned int for enumerated type ::CUjit_target_enum
     *)
    CU_JIT_TARGET,

    (*
     * Specifies choice of fallback strategy if matching cubin is not found.
     * Choice is based on supplied ::CUjit_fallback_enum.\n
     * Option type: unsigned int for enumerated type ::CUjit_fallback_enum
     *)
    CU_JIT_FALLBACK_STRATEGY


  );

(**
 * Function cache configurations
 *)

  CUfunc_cache=(
    CU_FUNC_CACHE_PREFER_NONE    = $00, (**< no preference for shared memory or L1 (default) *)
    CU_FUNC_CACHE_PREFER_SHARED  = $01, (**< prefer larger shared memory and smaller L1 cache *)
    CU_FUNC_CACHE_PREFER_L1      = $02, (**< prefer larger L1 cache and smaller shared memory *)
    CU_FUNC_CACHE_PREFER_EQUAL   = $03  (**< prefer equal sized L1 cache and shared memory *)
  );

  CUdevice = integer;
  CUcontext = pointer;
  CUmodule= pointer;
  CUfunction= pointer;
  CUarray= pointer;
  CUtexref= pointer;
  CUsurfref= pointer;
  CUevent= pointer;
  CUstream= pointer;
  CUgraphicsResource = pointer;

type
  //  CUresult = integer;
  __TcuModuleLoadDataEx = function(var module: CUmodule; image: pAnsiCHar; numOptions: cardinal; options: pCUjit_option; optionValues: pointer   ):CUresult;stdcall;
  __TcuInit = function(Flags: cardinal): CUresult; stdcall;
  __TcuDeviceGetCount = function(var count: integer): CUresult;  stdcall;
  __TcuDeviceGet= function(var device: CUdevice; ordinal: integer): CUresult;  stdcall;
  __TcuDeviceGetName = function(name: PAnsiChar; len: integer; dev: CUdevice): CUresult;  stdcall;

  __TcuCtxCreate = function(var pctx: CUcontext; flags: cardinal; dev: CUdevice): CUresult;  stdcall;
  __cuCtxDestroy= function(pctx: CUcontext): CUresult;  stdcall;
  __cuCtxPopCurrent= function(pctx: CUcontext): CUresult;  stdcall;
  __cuCtxGetApiVersion= function(pctx: CUcontext;var version: cardinal): CUresult;  stdcall;
  __cuCtxGetCacheConfig= function(var config: CUfunc_cache): CUresult;  stdcall;


  __TcuModuleGetFunction = function(var hfunc:CUfunction;hmod: CUmodule; name: PAnsiChar): CUresult;  stdcall;
  __TcuMemAlloc = function(var dptr: pointer; bytesize: cardinal): CUresult;  stdcall;
  __TcuMemFree = function(dptr: pointer): CUresult;  stdcall;
  __TcuFuncSetBlockShape  = function(hfunc: CUfunction; x,y,z: integer): CUresult;  stdcall;
  __TcuParamSetv = function(hfunc: CUfunction; offset: integer;var ptr: pointer; numbytes: cardinal ): CUresult;  stdcall;
  __TcuParamSetSize = function(hfunc: CUfunction; numbytes: cardinal ): CUresult;  stdcall;
  __TcuLaunchGrid= function(hfunc: CUfunction; grid_width, grid_height: integer): CUresult;  stdcall;
  __TcuMemcpyDtoH = function(dstHost:pointer; srcDevice: pointer; ByteCount: integer): CUresult;  stdcall;
  __TcuMemcpyHtoD = function(dstDevice:pointer; srcHost: pointer; ByteCount: integer): CUresult;  stdcall;
  __TcuLaunchKernel= function(f:CUfunction;
                             gridDimX,gridDimY,gridDimZ:cardinal;
                             blockDimX,blockDimY,blockDimz:cardinal;
                             sharedMemBytes: cardinal;
                             hStream: CUstream;
                             kernelParams, extra: pointer  ): CUresult;  stdcall;

  __T= function(): CUresult;  stdcall;
var
 cuModuleLoadDataEx: __TcuModuleLoadDataEx;
 cuInit: __TcuInit;
 cuDeviceGetCount: __TcuDeviceGetCount;
 cuDeviceGet: __TcuDeviceGet;
 cuDeviceGetName: __TcuDeviceGetName;
 // Context Management
 cuCtxCreate: __TcuCtxCreate;
 cuCtxDestroy: __cuCtxDestroy;
 cuCtxPopCurrent:__cuCtxPopCurrent;
 // END Context Management

 cuModuleGetFunction:__TcuModuleGetFunction;
 cuMemAlloc: __TcuMemAlloc;
 cuMemFree: __TcuMemFree;
 cuFuncSetBlockShape: __TcuFuncSetBlockShape;
 cuParamSetv: __TcuParamSetv;
 cuParamSetSize: __TcuParamSetSize;
 cuLaunchGrid: __TcuLaunchGrid;
 cuMemcpyDtoH: __TcuMemcpyDtoH;
 cuMemcpyHtoD: __TcuMemcpyHtoD;
 cuLaunchKernel: __TcuLaunchKernel;

 cuDeviceTotalMem: __T;
 cuModuleGetGlobal: __T;
 cuMemGetInfo: __T;
 cuMemAllocPitch  : __T;
 cuMemGetAddressRange: __T;
 cuMemAllocHost: __T;
 cuMemHostGetDevicePointer: __T;
 cuMemcpyDtoD: __T;
 cuMemcpyDtoA: __T;
 cuMemcpyAtoD: __T;
 cuMemcpyHtoA: __T;
 cuMemcpyAtoH: __T;
 cuMemcpyAtoA: __T;
 cuMemcpyHtoAAsync: __T;
 cuMemcpyAtoHAsync: __T;
 cuMemcpy2D: __T;
 cuMemcpy2DUnaligned: __T;
 cuMemcpy3D: __T;
 cuMemcpyHtoDAsync: __T;
 cuMemcpyDtoHAsync: __T;
 cuMemcpyDtoDAsync: __T;
 cuMemcpy2DAsync  : __T;
 cuMemcpy3DAsync  : __T;
 cuMemsetD8       : __T;
 cuMemsetD16      : __T;
 cuMemsetD32      : __T;
 cuMemsetD2D8     : __T;
 cuMemsetD2D16    : __T;
 cuMemsetD2D32    : __T;
 cuArrayCreate    : __T;
 cuArrayGetDescriptor: __T;
 cuArray3DCreate     : __T;
 cuArray3DGetDescriptor: __T;
 cuTexRefSetAddress    : __T;
 cuTexRefGetAddress    : __T;
 cuGraphicsResourceGetMappedPointer: __T;

implementation


var
  CudaDLL: HMODULE;
  CudaLoaded:boolean;

const
  CudaDLLName = 'nvcuda.dll';

procedure InitializeLibrary;
begin
  CudaDLL := LoadLibraryEx(CudaDLLName, 0, 0);
  if CudaDLL = 0 then
    raise Exception.CreateFmt('File: %s could not be found',
      [CudaDLLName])
  else
  begin
    CudaLoaded := True;

    @cuModuleLoadDataEx := GetProcAddress(CudaDLL, 'cuModuleLoadDataEx');  Assert ( @cuModuleLoadDataEx <> nil);

    @cuInit := GetProcAddress(CudaDLL, 'cuInit');  Assert ( @cuInit <> nil);
    @cuDeviceGetCount := GetProcAddress(CudaDLL, 'cuDeviceGetCount');  Assert ( @cuDeviceGetCount <> nil);
    @cuDeviceGet := GetProcAddress(CudaDLL, 'cuDeviceGet');  Assert ( @cuDeviceGet <> nil);
    @cuDeviceGetName := GetProcAddress(CudaDLL, 'cuDeviceGetName');  Assert ( @cuDeviceGetName <> nil);

    @cuCtxCreate:= GetProcAddress(CudaDLL, 'cuCtxCreate_v2');  Assert ( @cuCtxCreate <> nil);
    @cuCtxDestroy:= GetProcAddress(CudaDLL, 'cuCtxDestroy');  Assert ( @cuCtxDestroy <> nil);

    @cuModuleGetFunction:= GetProcAddress(CudaDLL, 'cuModuleGetFunction');  Assert ( @cuModuleGetFunction <> nil);
    @cuMemAlloc:= GetProcAddress(CudaDLL, 'cuMemAlloc_v2');  Assert ( @cuMemAlloc <> nil);
    @cuMemFree := GetProcAddress(CudaDLL, 'cuMemFree_v2');  Assert ( @cuMemFree <> nil);
    @cuFuncSetBlockShape := GetProcAddress(CudaDLL, 'cuFuncSetBlockShape');  Assert ( @cuFuncSetBlockShape <> nil);
    @cuParamSetv:= GetProcAddress(CudaDLL, 'cuParamSetv');  Assert ( @cuParamSetv <> nil);
    @cuParamSetSize:= GetProcAddress(CudaDLL, 'cuParamSetSize');  Assert ( @cuParamSetSize <> nil);
    @cuLaunchGrid:= GetProcAddress(CudaDLL, 'cuLaunchGrid');  Assert ( @cuLaunchGrid <> nil);
    @cuMemcpyDtoH:= GetProcAddress(CudaDLL, 'cuMemcpyDtoH_v2');  Assert ( @cuMemcpyDtoH <> nil);
    @cuMemcpyHtoD:= GetProcAddress(CudaDLL, 'cuMemcpyHtoD_v2');  Assert ( @cuMemcpyHtoD <> nil);
    @cuLaunchKernel:= GetProcAddress(CudaDLL, 'cuLaunchKernel');  Assert ( @cuLaunchKernel <> nil);

    @cuDeviceTotalMem := GetProcAddress(CudaDLL, 'cuDeviceTotalMem_v2');  Assert ( @cuDeviceTotalMem <> nil);
    @cuModuleGetGlobal:= GetProcAddress(CudaDLL, 'cuModuleGetGlobal_v2');  Assert ( @cuModuleGetGlobal <> nil);
    @cuMemGetInfo:= GetProcAddress(CudaDLL, 'cuMemGetInfo_v2');  Assert ( @cuMemGetInfo <> nil);
    @cuMemAllocPitch := GetProcAddress(CudaDLL, 'cuMemAllocPitch_v2');  Assert ( @cuMemAllocPitch <> nil);
    @cuMemGetAddressRange:= GetProcAddress(CudaDLL, 'cuMemGetAddressRange_v2');  Assert ( @cuMemGetAddressRange <> nil);
    @cuMemAllocHost:= GetProcAddress(CudaDLL, 'cuMemAllocHost_v2');  Assert ( @cuMemAllocHost <> nil);
    @cuMemHostGetDevicePointer:= GetProcAddress(CudaDLL, 'cuMemHostGetDevicePointer_v2');  Assert ( @cuMemHostGetDevicePointer <> nil);
    @cuMemcpyDtoD:= GetProcAddress(CudaDLL, 'cuMemcpyDtoD_v2');  Assert ( @cuMemcpyDtoD <> nil);
    @cuMemcpyDtoA:= GetProcAddress(CudaDLL, 'cuMemcpyDtoA_v2');  Assert ( @cuMemcpyDtoA <> nil);
    @cuMemcpyAtoD:= GetProcAddress(CudaDLL, 'cuMemcpyAtoD_v2');  Assert ( @cuMemcpyAtoD <> nil);
    @cuMemcpyHtoA:= GetProcAddress(CudaDLL, 'cuMemcpyHtoA_v2');  Assert ( @cuMemcpyHtoA <> nil);
    @cuMemcpyAtoH:= GetProcAddress(CudaDLL, 'cuMemcpyAtoH_v2');  Assert ( @cuMemcpyAtoH <> nil);
    @cuMemcpyAtoA:= GetProcAddress(CudaDLL, 'cuMemcpyAtoA_v2');  Assert ( @cuMemcpyAtoA <> nil);
    @cuMemcpyHtoAAsync:= GetProcAddress(CudaDLL, 'cuMemcpyHtoAAsync_v2');  Assert ( @cuMemcpyHtoAAsync <> nil);
    @cuMemcpyAtoHAsync:= GetProcAddress(CudaDLL, 'cuMemcpyAtoHAsync_v2');  Assert ( @cuMemcpyAtoHAsync <> nil);
    @cuMemcpy2D:= GetProcAddress(CudaDLL, 'cuMemcpy2D_v2');  Assert ( @cuMemcpy2D <> nil);
    @cuMemcpy2DUnaligned:= GetProcAddress(CudaDLL, 'cuMemcpy2DUnaligned_v2');  Assert ( @cuMemcpy2DUnaligned <> nil);
    @cuMemcpy3D:= GetProcAddress(CudaDLL, 'cuMemcpy3D_v2');  Assert ( @cuMemcpy3D <> nil);
    @cuMemcpyHtoDAsync:= GetProcAddress(CudaDLL, 'cuMemcpyHtoDAsync_v2');  Assert ( @cuMemcpyHtoDAsync <> nil);
    @cuMemcpyDtoHAsync:= GetProcAddress(CudaDLL, 'cuMemcpyDtoHAsync_v2');  Assert ( @cuMemcpyDtoHAsync <> nil);
    @cuMemcpyDtoDAsync:= GetProcAddress(CudaDLL, 'cuMemcpyDtoDAsync_v2');  Assert ( @cuMemcpyDtoDAsync <> nil);
    @cuMemcpy2DAsync  := GetProcAddress(CudaDLL, 'cuMemcpy2DAsync_v2');  Assert ( @cuMemcpy2DAsync <> nil);
    @cuMemcpy3DAsync  := GetProcAddress(CudaDLL, 'cuMemcpy3DAsync_v2');  Assert ( @cuMemcpy3DAsync <> nil);
    @cuMemsetD8       := GetProcAddress(CudaDLL, 'cuMemsetD8_v2');  Assert ( @cuMemsetD8 <> nil);
    @cuMemsetD16      := GetProcAddress(CudaDLL, 'cuMemsetD16_v2');  Assert ( @cuMemsetD16 <> nil);
    @cuMemsetD32      := GetProcAddress(CudaDLL, 'cuMemsetD32_v2');  Assert ( @cuMemsetD32 <> nil);
    @cuMemsetD2D8     := GetProcAddress(CudaDLL, 'cuMemsetD2D8_v2');  Assert ( @cuMemsetD2D8 <> nil);
    @cuMemsetD2D16    := GetProcAddress(CudaDLL, 'cuMemsetD2D16_v2');  Assert ( @cuMemsetD2D16 <> nil);
    @cuMemsetD2D32    := GetProcAddress(CudaDLL, 'cuMemsetD2D32_v2');  Assert ( @cuMemsetD2D32 <> nil);
    @cuArrayCreate    := GetProcAddress(CudaDLL, 'cuArrayCreate_v2');  Assert ( @cuArrayCreate <> nil);
    @cuArrayGetDescriptor:= GetProcAddress(CudaDLL, 'cuArrayGetDescriptor_v2');  Assert ( @cuArrayGetDescriptor <> nil);
    @cuArray3DCreate     := GetProcAddress(CudaDLL, 'cuArray3DCreate_v2');  Assert ( @cuArray3DCreate <> nil);
    @cuArray3DGetDescriptor:= GetProcAddress(CudaDLL, 'cuArray3DGetDescriptor_v2');  Assert ( @cuArray3DGetDescriptor <> nil);
    @cuTexRefSetAddress    := GetProcAddress(CudaDLL, 'cuTexRefSetAddress_v2');  Assert ( @cuTexRefSetAddress <> nil);
    @cuTexRefGetAddress    := GetProcAddress(CudaDLL, 'cuTexRefGetAddress_v2');  Assert ( @cuTexRefGetAddress <> nil);
    @cuGraphicsResourceGetMappedPointer:= GetProcAddress(CudaDLL, 'cuGraphicsResourceGetMappedPointer_v2');  Assert ( @cuGraphicsResourceGetMappedPointer <> nil);

  end;

end;

procedure FinalizeCudaLibrary;
begin
  FreeLibrary(CudaDLL);
  CudaLoaded := False;
end;

var
  _tmpPARAM_END,_tmpBUFFER_POINTER,_tmpBUFFER_SIZE: integer;
initialization
  _tmpPARAM_END := 0;
  _tmpBUFFER_POINTER := 1;
  _tmpBUFFER_SIZE := 2;
  CU_LAUNCH_PARAM_END := @_tmpPARAM_END;
  CU_LAUNCH_PARAM_BUFFER_POINTER :=  @_tmpBUFFER_POINTER;
  CU_LAUNCH_PARAM_BUFFER_SIZE :=  @_tmpBUFFER_SIZE;

  InitializeLibrary;


finalization
  FinalizeCudaLibrary;


end.
