program forward_inverse;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  cuda, cufft;

procedure checkCudaErrors(p_id: CUresult);
var
  s: string;
begin
  if(p_id<>CUDA_SUCCESS) then
  begin
    s := format('Error CUDA ID=%d',[integer(p_id)]);
    writeln(s);
  end;
end;

procedure checkCuFFTErrors(p_id: cufftResult);
var
  s: string;
begin
  if(p_id<>CUFFT_SUCCESS) then
  begin
    s := format('Error CUFFT ID=%d',[integer(p_id)]);
    writeln(s);
  end;
end;



function LoadFile(const FileName: TFileName): AnsiString;
begin
  with TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite) do
  begin
    try
      SetLength(Result, Size);
      Read(Pointer(Result)^, Size);
    except
      Result := '';  // Deallocates memory
      Free;
      raise;
    end;
    Free;
  end;
end;

const
  SIZE =1024;
type
  TmyArray = array [0..3] of pointer;

var
  n, i: integer;
  hModule: CUmodule;
  hDevice: CUdevice;
  hContext: CUcontext;
  hKernel: CUfunction;
  str: ansiString;
  mKernelParameterConfig: TmyArray;

  device_a: pointer;
  device_b: pointer;
  device_c: pointer;
  // d_n: pointer;

  host_a,host_b,host_c: array of cufftComplex;


  v_fft: cufftHandle;
begin
  n := SIZE;
  SetLength(host_a,SIZE);
  SetLength(host_b,SIZE);
  SetLength(host_c,SIZE);
  for I := 0 to SIZE - 1 do
  begin
    host_a[i].x := I;
    host_a[i].y := I;
  end;

  checkCudaErrors( cuInit(0) );
  checkCudaErrors( cuDeviceGet( hDevice ,0));
  checkCudaErrors( cuCtxCreate( hContext, 0,hDevice));

  checkCudaErrors( cuMemAlloc(device_a,sizeof(cufftComplex)*SIZE));
  checkCudaErrors( cuMemAlloc(device_b,sizeof(cufftComplex)*SIZE));
  checkCudaErrors( cuMemAlloc(device_c,sizeof(cufftComplex)*SIZE));
  checkCudaErrors( cuMemcpyHtoD(device_a,@host_a[0], sizeof(cufftComplex)*SIZE));


  checkCuFFTErrors( cufftPlan1d(v_fft,SIZE,CUFFT_C2C,1));  // create PLAIN

  checkCuFftErrors( cufftExecC2C(v_fft, device_a, device_b,CUFFT_FORWARD)); //  FFT FORWARD
  cuMemcpyDtoH(@host_b[0],device_b, sizeof(cufftComplex)*SIZE);

  checkCuFftErrors( cufftExecC2C(v_fft, device_b, device_c,CUFFT_INVERSE)); //  FFT INVERSE
  cuMemcpyDtoH(@host_c[0],device_c, sizeof(cufftComplex)*SIZE);

{  for I := 0 to SIZE - 1 do
  begin
    writeln(format('[%d] A(%f;%f) B(%f;%f) C(%f;%f) ', [i,
                                                       host_a[i].x, host_a[i].y,
                                                       host_b[i].x, host_b[i].y,
                                                       host_c[i].x / SIZE , host_c[i].y / SIZE
                                                        ]
                                                        ));
  end;}

//  readln;



  str := LoadFile( 'kernel_add_vector.ptx');
  checkCudaErrors( cuModuleLoadDataEx( hModule, pansichar(str),0,nil,nil));
  str := '_Z3addP6float2S0_S0_';
  checkCudaErrors( cuModuleGetFunction( hKernel , hModule,  pansichar(str)));

  mKernelParameterConfig[0] := @device_c;
  mKernelParameterConfig[1] := @device_b;
  mKernelParameterConfig[2] := @device_b;

  checkCudaErrors( cuLaunchKernel( hKernel , SIZE,1,1,1,1,1,0, nil,@mKernelParameterConfig[0],nil ));


  cuMemcpyDtoH(@host_b[0],device_b, sizeof(cufftComplex)*SIZE);


  //writeln (host_b[7].x);

 // readln;
end.
