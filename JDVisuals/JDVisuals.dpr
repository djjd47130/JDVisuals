program JDVisuals;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  JD.Visuals,
  uVisual in 'uVisual.pas' {frmVisual},
  JD.SpiralOutVisual in '..\Visuals\JD.SpiralOutVisual.pas',
  JD.FinalFrontierVisual in '..\Visuals\JD.FinalFrontierVisual.pas',
  JD.FinalFrontierVisual.AvgCalc in '..\Visuals\JD.FinalFrontierVisual.AvgCalc.pas',
  JD.FinalFrontierVisual.CpuUsage in '..\Visuals\JD.FinalFrontierVisual.CpuUsage.pas',
  JD.RaindropsVisual in '..\Visuals\JD.RaindropsVisual.pas',
  JD.FibonacciVisual in '..\Visuals\JD.FibonacciVisual.pas',
  JD.MatrixVisual in '..\Visuals\JD.MatrixVisual.pas',
  VisualControls in 'VisualControls.pas',
  JD.ChessboardVisual in '..\Visuals\JD.ChessboardVisual.pas',
  JD.CircleTraceVisual in '..\Visuals\JD.CircleTraceVisual.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Cobalt XEMedia');
  Application.Title := 'JD Visuals';
  Application.CreateForm(TfrmVisual, frmVisual);
  Application.Run;
end.
