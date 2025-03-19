unit JD.SpiralOutVisual;

(*
 Spiral Out
 Visual by Jerry Dodge

 CONCEPT
 Everything starts from a central point, and an array of points along
 different radius around this point. It starts with a vertical line, then each
 point rotates around the center - each point slightly faster than the prior.
 The result is a spectacular display of different shapes and star effects.
*)

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Common, JD.Graphics,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

const
  POINT_COUNT = 130; //TODO: Make dynamic
  COLOR_TIMER_DELAY = 150; //TODO: Make dynamic
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
    FBaseColor: TJDColor;
    FDirR: Integer;
    FDirG: Integer;
    FDirB: Integer;
    FCurPoint: TGPPointF;
    FLast: TGPPointF;
    FCols: TJDColorArray;
    FColorTrack: Integer;
    FReset: Boolean;
    procedure ShiftColors;
    procedure SetColorFrequency(const Value: Integer);
    procedure ResetButtonClick(Sender: TObject);
    procedure SetSpacing(const Value: Currency);
    procedure SetSpeedFactor(const Value: Currency);
    procedure SetThickness(const Value: Currency);
    procedure SetReset(const Value: Boolean);
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetColorFrequency: Integer;
    function GetSpacing: Currency;
    function GetSpeedFactor: Currency;
    function GetThickness: Currency;

  published
    property Reset: Boolean read FReset write SetReset;
    property ColorFrequency: Integer read GetColorFrequency write SetColorFrequency;
    property Spacing: Currency read GetSpacing write SetSpacing;
    property SpeedFactor: Currency read GetSpeedFactor write SetSpeedFactor;
    property Thickness: Currency read GetThickness write SetThickness;
  end;

implementation

uses
  System.Math;

{ TSpiralOutVisual }

constructor TSpiralOutVisual.Create(AOwner: TComponent);
var
  X: Integer;
begin
  inherited;
  VisualName:= 'Spiral Out';
  FBaseColor.Red:= RandomRange(COLOR_MIN, COLOR_MAX);
  FBaseColor.Green:= RandomRange(COLOR_MIN, COLOR_MAX);
  FBaseColor.Blue:= RandomRange(COLOR_MIN, COLOR_MAX);
  FDirR:= 2;
  FDirG:= 3;
  FDirB:= 1;
  FPen:= TGPPen.Create(MakeColor(FBaseColor.Red, FBaseColor.Green, FBaseColor.Blue));
  FPen.SetWidth(GetThickness);
  FPen.SetStartCap(LineCap.LineCapRound);
  FPen.SetEndCap(LineCap.LineCapRound);
  SetLength(FPoints, POINT_COUNT);
  for X := 0 to Length(FPoints)-1 do begin
    FPoints[X].Degrees:= 0;
    FPoints[X].Distance:= (X+1) * GetSpacing;
    FPoints[X].Speed:= (X+1) * GetSpeedFactor;
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
  Controls.NewButtonControl('Reset',            ResetButtonClick);
  Controls.NewNumberControl('Color Frequency',  ntInteger,  15,   1,      100,    0,  1);
  Controls.NewNumberControl('Thickness',        ntFloat,    17.0, 0.1,    1000.0, 2,  0.1);
  Controls.NewNumberControl('Spacing',          ntFloat,    2.7,  0.001,  1000.0, 3,  0.1);
  Controls.NewNumberControl('Speed',            ntFloat,    0.05, 0.005,  5.0,    3,  0.01);
end;

procedure TSpiralOutVisual.ResetButtonClick(Sender: TObject);
var
  X: Integer;
begin
  for X := 0 to Length(FPoints)-1 do begin
    FPoints[X].Degrees:= 0;
  end;
end;

function TSpiralOutVisual.GetColorFrequency: Integer;
begin
  Result:= TJDVNumberControl(Controls['Color Frequency']).ValueInt;
end;

function TSpiralOutVisual.GetSpacing: Currency;
begin
  Result:= TJDVNumberControl(Controls['Spacing']).Value;
end;

function TSpiralOutVisual.GetSpeedFactor: Currency;
begin
  Result:= TJDVNumberControl(Controls['Speed']).Value;
end;

function TSpiralOutVisual.GetThickness: Currency;
begin
  Result:= TJDVNumberControl(Controls['Thickness']).Value;
end;

procedure TSpiralOutVisual.SetColorFrequency(const Value: Integer);
begin
  TJDVNumberControl(Controls['Color Frequency']).ValueInt:= Value;
end;

procedure TSpiralOutVisual.SetReset(const Value: Boolean);
begin
  if Value then begin
    FReset:= False;
    ResetButtonClick(nil);
  end;
end;

procedure TSpiralOutVisual.SetSpacing(const Value: Currency);
begin
  TJDVNumberControl(Controls['Spacing']).Value:= Value;
end;

procedure TSpiralOutVisual.SetSpeedFactor(const Value: Currency);
begin
  TJDVNumberControl(Controls['Speed']).Value:= Value;
end;

procedure TSpiralOutVisual.SetThickness(const Value: Currency);
begin
  TJDVNumberControl(Controls['Thickness']).Value:= Value;
end;

procedure TSpiralOutVisual.DoStep;
var
  X: Integer;
begin
  for X := 0 to Length(FPoints)-1 do begin
    FPoints[X].Distance:= (X+1) * GetSpacing;
    FPoints[X].Speed:= (X+1) * GetSpeedFactor;
    FPoints[X].Degrees:= FPoints[X].Degrees + FPoints[X].Speed;
  end;
  Inc(FColorTrack);
  if FColorTrack >= ColorFrequency then begin
    FColorTrack:= 0;
    ShiftColors;
  end;
end;

procedure TSpiralOutVisual.ShiftColors;
begin
  if FBaseColor.Red >= COLOR_MAX then FDirR:= NegOf(FDirR);
  if FBaseColor.Red <= COLOR_MIN then FDirR:= PosOf(FDirR);
  if FBaseColor.Green >= COLOR_MAX then FDirG:= NegOf(FDirG);
  if FBaseColor.Green <= COLOR_MIN then FDirG:= PosOf(FDirG);
  if FBaseColor.Blue >= COLOR_MAX then FDirB:= NegOf(FDirB);
  if FBaseColor.Blue <= COLOR_MIN then FDirB:= PosOf(FDirB);
  FBaseColor.Red:= FBaseColor.Red + FDirR;
  FBaseColor.Green:= FBaseColor.Green + FDirG;
  FBaseColor.Blue:= FBaseColor.Blue + FDirB;
end;

procedure TSpiralOutVisual.DoPaint;
var
  X: Integer;
begin
  FCols:= ColorFade(FBaseColor, Length(FPoints), COLOR_FADE);
  FPen.SetWidth(GetThickness);
  for X := 0 to Length(FPoints)-1 do begin
    FCurPoint:= PointAroundCircle(Thread.CenterPoint, FPoints[X].Distance, FPoints[X].Degrees);
    if X > 0 then begin
      FPen.SetColor(TJDColor(FCols[X]).GDIPColor);
      GPCanvas.DrawLine(FPen, FLast.X, FLast.Y, FCurPoint.X, FCurPoint.Y);
    end;
    FLast:= FCurPoint;
  end;
end;

initialization
  //Visuals.RegisterVisualClass(TSpiralOutVisual);
end.
