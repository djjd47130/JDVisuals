program JDVisuals;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uVisual in 'uVisual.pas' {frmVisual},
  JD.Visuals in 'JD.Visuals.pas',
  JD.SpiralOutVisual in 'JD.SpiralOutVisual.pas',
  JD.Visuals.Utils in 'JD.Visuals.Utils.pas',
  JD.Visuals.Controls in 'JD.Visuals.Controls.pas',
  JD.FibonacciVisual in 'JD.FibonacciVisual.pas',
  JD.FinalFrontierVisual in 'JD.FinalFrontierVisual.pas',
  JD.FinalFrontierVisual.AvgCalc in 'JD.FinalFrontierVisual.AvgCalc.pas',
  JD.FinalFrontierVisual.CpuUsage in 'JD.FinalFrontierVisual.CpuUsage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.Title := 'JD Visuals';
  Application.CreateForm(TfrmVisual, frmVisual);
  Application.Run;
end.
