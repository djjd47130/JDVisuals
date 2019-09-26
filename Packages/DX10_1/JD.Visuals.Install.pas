unit JD.Visuals.Install;

interface

uses
  System.Classes, System.SysUtils,
  JD.Visuals;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JD Visuals', [TJDVisualView]);
end;

end.
