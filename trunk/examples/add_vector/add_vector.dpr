program add_vector;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, cuda;



procedure checkCudaErrors(p_id: CUresult);
var
  s: string;
begin
  if(p_id<>CUDA_SUCCESS) then
  begin
    s := format('Error ID=%d',[integer(p_id)]);
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
  SIZE =1024*16;
type
  TKernelParams = array of pointer;

var
  n, i: integer;
  hModule: CUmodule;
  hDevice: CUdevice;
  hContext: CUcontext;
  hKernel: CUfunction;
  str: ansiString;
  v_KernelParams: TKernelParams;

  d_a: pointer;
  d_b: pointer;
  d_c: pointer;
  d_n: pointer;

  buf,buf_out: array of integer;

  event_start, event_stop:   CUevent;
  event_time: single;
begin
  n := SIZE;
  SetLength(buf,SIZE);
  SetLength(buf_out,SIZE);
  for I := 0 to SIZE - 1 do
    buf[i] := I;

  checkCudaErrors( cuInit(0) );
  checkCudaErrors( cuDeviceGet( hDevice ,0));
  checkCudaErrors( cuCtxCreate( hContext, 0,hDevice));
  str := LoadFile( 'kernel_add_vector.ptx');
  checkCudaErrors( cuModuleLoadDataEx( hModule, pansichar(str),0,nil,nil));
  str := '_Z3addPiS_S_S_';
  checkCudaErrors( cuModuleGetFunction( hKernel , hModule,  pansichar(str)));

  checkCudaErrors(  cuMemAlloc(d_a,sizeof(integer)*SIZE));
  checkCudaErrors(  cuMemAlloc(d_b,sizeof(integer)*SIZE));
  checkCudaErrors(  cuMemAlloc(d_c,sizeof(integer)*SIZE));
  checkCudaErrors(  cuMemAlloc(d_n,sizeof(integer)));

  checkCudaErrors( cuMemcpyHtoD(d_a,@buf[0], sizeof(integer)*SIZE));
  checkCudaErrors( cuMemcpyHtoD(d_b,@buf[0], sizeof(integer)*SIZE));
  checkCudaErrors( cuMemcpyHtoD(d_n,@n, sizeof(integer)));

  setlength(v_KernelParams,4);
  v_KernelParams[0] := @d_a;
  v_KernelParams[1] := @d_b;
  v_KernelParams[2] := @d_c;
  v_KernelParams[3] := @d_n;


  checkCudaErrors( cuEventCreate(event_start,0));

  checkCudaErrors( cuEventCreate(event_stop,0));

  checkCudaErrors( cuEventRecord(event_start,0));

  checkCudaErrors( cuLaunchKernel( hKernel , SIZE,1,1,1,1,1,0, nil,@v_KernelParams[0],nil ));

  checkCudaErrors( cuEventRecord(event_stop,0));

  checkCudaErrors( cuEventSynchronize(event_stop));

  checkCudaErrors( cuEventElapsedTime(event_time, event_start, event_stop));

  writeln(format('run time: %3.1f ms',[event_time]));

  cuMemcpyDtoH(@buf_out[0],d_c, sizeof(integer)*SIZE);

  (* display result
  for I := 0 to SIZE - 1 do
  begin
    writeln(format('[%d] host:%d device:%d  ', [i, buf[i], buf_out[I] ] ));
  end;*)

  readln;
end.
