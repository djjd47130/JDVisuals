program JDVisuals;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uVisual in 'uVisual.pas' {frmVisual},
  JD.SpiralOutVisual in '..\Visuals\JD.SpiralOutVisual.pas',
  JD.FinalFrontierVisual in '..\Visuals\JD.FinalFrontierVisual.pas',
  JD.FinalFrontierVisual.AvgCalc in '..\Visuals\JD.FinalFrontierVisual.AvgCalc.pas',
  JD.FinalFrontierVisual.CpuUsage in '..\Visuals\JD.FinalFrontierVisual.CpuUsage.pas',
  JD.RaindropsVisual in '..\Visuals\JD.RaindropsVisual.pas',
  JD.FibonacciVisual in '..\Visuals\JD.FibonacciVisual.pas',
  JD.MatrixVisual in '..\Visuals\JD.MatrixVisual.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Cobalt XEMedia');
  Application.Title := 'JD Visuals';
  Application.CreateForm(TfrmVisual, frmVisual);
  Application.Run;
end.
