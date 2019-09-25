program FibonacciTest;

uses
  Vcl.Forms,
  uFibonacciTestMain in 'uFibonacciTestMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
