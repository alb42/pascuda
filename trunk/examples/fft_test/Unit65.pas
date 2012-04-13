unit Unit65;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JclExprEval, StdCtrls, TeEngine, Series, ExtCtrls, TeeProcs, Chart,
  cufft, cuda , JclMath ;

type
  TForm65 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Edit_start: TEdit;
    Edit_stop: TEdit;
    Chart1: TChart;
    Series1: TFastLineSeries;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    a_ExpressionCompiler: TExpressionCompiler;
    a_CompiledExpression: TCompiledExpression;
    a_ExpressionParam1: Double;
    procedure Prepare_Expresion;
    function count_value(t: double): double;
  public
    { Public declarations }
  end;

var
  Form65: TForm65;

implementation

{$R *.dfm}


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

const
  N = 16*16*16;




function TForm65.count_value(t: double): double;
begin
  a_ExpressionParam1 := t;
  result := a_CompiledExpression  //  3*cos(2*3.14159*5*t)+10*sin(2*3.14159*12*t)
end;

procedure TForm65.FormCreate(Sender: TObject);
begin
  DecimalSeparator := '.';
end;

procedure TForm65.Prepare_Expresion;
begin
  a_ExpressionCompiler := TExpressionCompiler.Create;
  try
    // ExpressionCompiler stores the addresses of VarA, VarB, VarC.
    a_ExpressionCompiler.AddVar('t', a_ExpressionParam1);
    a_ExpressionCompiler.AddFunc('sin',sin);
    a_ExpressionCompiler.AddFunc('cos',cos);

    // ExpressionCompiler creates a compiled expression from a string.
    a_CompiledExpression := a_ExpressionCompiler.Compile(Edit1.Text);

  finally
  end;
end;

procedure TForm65.Button1Click(Sender: TObject);
var
  daneX: Array of double;
  daneYchart: Array of double;
  daneYchartSingle: Array of single;
  daneY: Array of cufftComplex;
  i: integer;
  v_start, v_stop: double;
  v_intervalTime: double;
  fftPlan: cufftHandle;
  fftPlan2: cufftHandle;
  hDevice: CUdevice;
  hContext: CUcontext;
  device_a: pointer;
  device_b: pointer;
  device_c: pointer;
  device_d: pointer;
  device_e: pointer;

  dane_a: Array of cufftComplex;
  dane_b: Array of cufftComplex;
  dane_c: Array of cufftComplex;
  dane_c_norm: Array of cufftComplex;


  invN: double;
  zf:Array of double;
  zfft:Array of double;
  Fs: double;
begin
  Prepare_Expresion;
  v_start := strtofloat( Edit_start.Text );
  v_stop := strtofloat( Edit_stop.Text );

//  v_intervalTime :=

  setlength(daneX,N);
  setlength(daneYchart,N);
  setlength(daneYchartSingle,N);
  setlength(daneY,N);
  setlength(dane_a,N);
  setlength(dane_b,N);
  setlength(dane_c,N);
  setlength(dane_c_norm,N);

  setlength(zf,1 + N div 2);
  setlength(zfft,1 + N div 2);

  for I := 0 to N  - 1 do
    begin
      daneX[i] := v_start + (v_stop - v_start) * i /(n-1);

      daneY[i].x :=  count_value( daneX[i] );
      daneY[i].y := 0;

      daneYchart[i] := count_value( daneX[i] );
      daneYchartSingle[i] := count_value( daneX[i] );
    end;


//  series1.Clear;
//  series1.AddArray(daneX,daneYchart);
//  series1.AddArray()


  checkCudaErrors( cuInit(0) );
  checkCudaErrors( cuDeviceGet( hDevice ,0));
  checkCudaErrors( cuCtxCreate( hContext, 0,hDevice));

  checkCudaErrors( cuMemAlloc(device_a, sizeof(cufftComplex)*N));
  checkCudaErrors( cuMemAlloc(device_b, sizeof(cufftComplex)*N));
  checkCudaErrors( cuMemAlloc(device_c, sizeof(cufftComplex)*N));
  checkCudaErrors( cuMemAlloc(device_d, sizeof(single)*N));
  checkCudaErrors( cuMemAlloc(device_c, sizeof(cufftComplex)*N));

  checkCudaErrors( cuMemcpyHtoD(device_a,@daneY[0], sizeof(cufftComplex)*N));
  checkCudaErrors( cuMemcpyHtoD(device_d,@daneYchartSingle[0], sizeof(single)*N));

  checkCuFFTErrors(cufftPlan1d( fftPlan, N, CUFFT_C2C,1));
  checkCuFFTErrors(  cufftExecC2C( fftPlan,device_a, device_b, CUFFT_FORWARD));
  checkCuFFTErrors(  cufftExecC2C( fftPlan,device_b, device_c, CUFFT_INVERSE));

  checkCuFFTErrors(cufftPlan1d( fftPlan2, N, CUFFT_R2C,1));
  checkCuFFTErrors(  cufftExecR2C( fftPlan2,device_d, device_e));


  checkCudaErrors(cuMemcpyDtoH(@dane_a[0],device_a, sizeof(cufftComplex)*N));
  checkCudaErrors(  cuMemcpyDtoH(@dane_b[0],device_b, sizeof(cufftComplex)*N));
  checkCudaErrors(  cuMemcpyDtoH(@dane_c[0],device_c, sizeof(cufftComplex)*N));


  //checkCudaErrors( cuMemcpyDtoH(@dane_b[0],device_e, sizeof(cufftComplex)*N div 2));


  allocconsole;
  for I := 0 to N  - 1 do
  begin
    dane_c_norm[i].x := dane_c[i].x / N;
    dane_c_norm[i].Y := dane_c[i].Y / N;

    writeln(format('%f %f',[dane_a[i].x, dane_c_norm[i].x  ]));
  end;

  Fs := (N - 1)/(v_stop-v_start);
  invN := 2/n;
  for I := 0 to ((N div 2) +1)  - 1 do
  begin
    zf[i] := 0.5 * Fs * i / (N shr 1);

    zfft[i] := Sqrt(dane_b[i].x * dane_b[i].x + dane_b[i].y * dane_b[i].y) * invN;
  end;


  series1.Clear;
  series1.AddArray(zf,zfft);

  a_ExpressionCompiler.Free;
end;

end.
