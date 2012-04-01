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

  d_a: pointer;
  d_b: pointer;
  d_c: pointer;
  d_n: pointer;

  buf,buf_out: array of integer;

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

  mKernelParameterConfig[0] := @d_a;
  mKernelParameterConfig[1] := @d_b;
  mKernelParameterConfig[2] := @d_c;
  mKernelParameterConfig[3] := @d_n;

  for I := 0 to 2 - 1 do
   checkCudaErrors( cuLaunchKernel( hKernel , SIZE,1,1,1,1,1,0, nil,@mKernelParameterConfig[0],nil ));

  cuMemcpyDtoH(@buf_out[0],d_c, sizeof(integer)*SIZE);


  for I := 0 to SIZE - 1 do
  begin
    writeln(format('[%d] host:%d device:%d  ', [i, buf[i], buf_out[I] ] ));
  end;

//  showmessage(format('%d %d %d',[buf[1], buf[2], buf[3] ]));



  readln;
end.
