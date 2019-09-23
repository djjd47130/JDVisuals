unit JD.SpiralOutVisual;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

const
  POINT_COUNT = 130;
  COLOR_TIMER_DELAY = 150;
  COLOR_FADE = -1; //Recommended to keep at -1
  COLOR_MAX = 253;
  COLOR_MIN = COLOR_MAX - POINT_COUNT + 10;

type
  TSpiralPoint = record
    Degrees: Currency;
    Distance: Currency;
    Speed: Currency;
  end;

  TSpiralPoints = array of TSpiralPoint;

  TSpiralOutVisual = class(TJDVisual)
  private
    FPoints: TSpiralPoints;
    FPen: TGPPen;
    FBaseColor: TColorRec;
    FDirR: Integer;
    FDirG: Integer;
    FDirB: Integer;
    FCurPoint: TGPPointF;
    FLast: TGPPointF;
    FCols: TColorArray;
    FColorFrequency: Integer;
    FColorTrack: Integer;
    procedure ShiftColors;
    procedure SetColorFrequency(const Value: Integer);
    procedure ResetButtonClick(Sender: TObject);
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ColorFrequency: Integer read FColorFrequency write SetColorFrequency;
    function Spacing: Currency;
    function SpeedFactor: Currency;
    function Thickness: Currency;
  end;

implementation

uses
  System.Math;

{ TSpiralOutVisual }

constructor TSpiralOutVisual.Create;
var
  X: Integer;
begin
  inherited;
  VisualName:= 'Spiral Out';
  FColorFrequency:= 15;
  FBaseColor.R:= RandomRange(COLOR_MIN, COLOR_MAX);
  FBaseColor.G:= RandomRange(COLOR_MIN, COLOR_MAX);
  FBaseColor.B:= RandomRange(COLOR_MIN, COLOR_MAX);
  FDirR:= 2;
  FDirG:= 3;
  FDirB:= 1;
  FPen:= TGPPen.Create(MakeColor(FBaseColor.R, FBaseColor.G, FBaseColor.B));
  FPen.SetWidth(Thickness);
  FPen.SetStartCap(LineCap.LineCapRound);
  FPen.SetEndCap(LineCap.LineCapRound);
  SetLength(FPoints, POINT_COUNT);
  for X := 0 to Length(FPoints)-1 do begin
    FPoints[X].Degrees:= 0;
    FPoints[X].Distance:= (X+1) * Spacing;
    FPoints[X].Speed:= (X+1) * SpeedFactor;
  end;
end;

destructor TSpiralOutVisual.Destroy;
begin
  SetLength(FPoints, 0);
  FreeAndNil(FPen);
  inherited;
end;

procedure TSpiralOutVisual.CreateControls;
begin
  Controls.NewButtonControl('Reset', ResetButtonClick);
  Controls.NewNumberControl('Thickness', ntFloat, 17.0, 0.1, 1000.0, 2, 0.1);
  Controls.NewNumberControl('Spacing', ntFloat, 2.7, 0.001, 1000.0, 3, 0.1);
  Controls.NewNumberControl('Speed', ntFloat, 0.05, 0.025, 5.0, 3, 0.025);
end;

procedure TSpiralOutVisual.ResetButtonClick(Sender: TObject);
var
  X: Integer;
begin
  for X := 0 to Length(FPoints)-1 do begin
    FPoints[X].Degrees:= 0;
  end;
end;

function TSpiralOutVisual.Spacing: Currency;
begin
  Result:= TJDVNumberControl(Controls['Spacing']).Value;
end;

function TSpiralOutVisual.SpeedFactor: Currency;
begin
  Result:= TJDVNumberControl(Controls['Speed']).Value;
end;

function TSpiralOutVisual.Thickness: Currency;
begin
  Result:= TJDVNumberControl(Controls['Thickness']).Value;
end;

procedure TSpiralOutVisual.SetColorFrequency(const Value: Integer);
begin
  FColorFrequency := Value;
end;

procedure TSpiralOutVisual.DoStep;
var
  X: Integer;
begin
  for X := 0 to Length(FPoints)-1 do begin
    FPoints[X].Distance:= (X+1) * Spacing;
    FPoints[X].Speed:= (X+1) * SpeedFactor;
    FPoints[X].Degrees:= FPoints[X].Degrees + FPoints[X].Speed;
  end;
  Inc(FColorTrack);
  if FColorTrack >= FColorFrequency then begin
    FColorTrack:= 0;
    ShiftColors;
  end;
end;

procedure TSpiralOutVisual.ShiftColors;
begin
  if FBaseColor.R >= COLOR_MAX then FDirR:= NegOf(FDirR);
  if FBaseColor.R <= COLOR_MIN then FDirR:= PosOf(FDirR);
  if FBaseColor.G >= COLOR_MAX then FDirG:= NegOf(FDirG);
  if FBaseColor.G <= COLOR_MIN then FDirG:= PosOf(FDirG);
  if FBaseColor.B >= COLOR_MAX then FDirB:= NegOf(FDirB);
  if FBaseColor.B <= COLOR_MIN then FDirB:= PosOf(FDirB);
  FBaseColor.R:= FBaseColor.R + FDirR;
  FBaseColor.G:= FBaseColor.G + FDirG;
  FBaseColor.B:= FBaseColor.B + FDirB;
end;

procedure TSpiralOutVisual.DoPaint;
var
  X: Integer;
begin
  FCols:= ColorFade(FBaseColor.Value, Length(FPoints), COLOR_FADE);
  FPen.SetWidth(Thickness);
  for X := 0 to Length(FPoints)-1 do begin
    FCurPoint:= PointAroundCircle(Thread.CenterPoint, FPoints[X].Distance, FPoints[X].Degrees);
    if X > 0 then begin
      FPen.SetColor(MakeColor(FCols[X]));
      Thread.GPCanvas.DrawLine(FPen, FLast.X, FLast.Y, FCurPoint.X, FCurPoint.Y);
    end;
    FLast:= FCurPoint;
  end;
end;

initialization
  Visuals.RegisterVisualClass(TSpiralOutVisual);
end.
