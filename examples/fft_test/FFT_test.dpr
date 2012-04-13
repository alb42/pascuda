program FFT_test;

uses
  ExceptionLog,
  Forms,
  Unit65 in 'Unit65.pas' {Form65},
  cufft in '..\..\src\cufft.pas',
  cuda in '..\..\src\cuda.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm65, Form65);
  Application.Run;
end.
