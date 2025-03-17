unit JD.Visuals.Install;

interface

uses
  System.Classes, System.SysUtils,
  JD.Visuals,
  JD.FibonacciVisual,
  JD.FinalFrontierVisual,
  JD.MatrixVisual,
  JD.RaindropsVisual,
  JD.SpiralOutVisual,
  JD.TessellationVisual;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JD Visuals Engine', [TJDVisualView]);
  RegisterComponents('JD Visuals', [
    TRaindropVisual,
    TMatrixVisual,
    TFinalFrontierVisual,
    TFibonacciVisual,
    TSpiralOutVisual,
    TTessellationVisual
    ]);
end;

end.
