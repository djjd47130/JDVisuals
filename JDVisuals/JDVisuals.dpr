program JDVisuals;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  JD.Visuals,
  uVisual in 'uVisual.pas' {frmVisual},
  VisualControls in 'VisualControls.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Cobalt XEMedia');
  Application.Title := 'JD Visuals';
  Application.CreateForm(TfrmVisual, frmVisual);
  Application.Run;
end.
