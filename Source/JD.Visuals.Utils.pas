unit JD.Visuals.Utils;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ;

type
  TColorArray = array of TColor;

  TColorRec = record
    R, G, B: Integer;
    function Value: TColor;
  end;

function PointAroundCircle(Center: TGPPointF; Distance: Currency; Degrees: Currency): TGPPointF;
function IntRange(const Value, Min, Max: Integer): Integer;
function ColorFade(const ASource: TColor; const ACount: Integer; const Shift: Integer): TColorArray; overload;
function ColorFade(const ASource: TColor; const Shift: Integer): TColor; overload;
function MakeColor(const AColor: TColor): Cardinal; overload;
function PosOf(const AValue: Integer): Integer;
function NegOf(const AValue: Integer): Integer;

function SetThreadDescription(hThread: THandle; lpThreadDescription: WideString): HRESULT; stdcall;
  external kernel32 name 'SetThreadDescription';


implementation

//Calculates an absolute pixel point based on a center point, distance (radius), and degrees.
//This is perhaps the most complicated part of the whole thing. Someone wrote this
//  function for me many years ago and I've used it in many projects, and tweak it for each.
function PointAroundCircle(Center: TGPPointF; Distance: Currency; Degrees: Currency): TGPPointF;
var
  Radians: Real;
begin
  //TODO: Change input from "Degrees" to "Radians" to eliminate the need for
  //  a variable, this reducing heap allocation and increasing performance.

  //Convert angle from degrees to radians; Subtract 135 to bring position to 0 Degrees
  Radians:= (Degrees - 135) * Pi / 180;
  Result.X:= Trunc(Distance*Cos(Radians)-Distance*Sin(Radians))+Center.X;
  Result.Y:= Trunc(Distance*Sin(Radians)+Distance*Cos(Radians))+Center.Y;
end;

function IntRange(const Value, Min, Max: Integer): Integer;
begin
  Result:= Value;
  if Result < Min then Result:= Min;
  if Result > Max then Result:= Max;
end;

function ColorFade(const ASource: TColor; const ACount: Integer; const Shift: Integer): TColorArray;
var
  X: Integer;
  R, G, B: Byte;
begin
  SetLength(Result, ACount);
  for X := 0 to ACount-1 do begin
    R:= IntRange(GetRValue(ASource), 1, 254) + (Shift * X);
    G:= IntRange(GetGValue(ASource), 1, 254) + (Shift * X);
    B:= IntRange(GetBValue(ASource), 1, 254) + (Shift * X);
    Result[X]:= RGB(R, G, B);
  end;
end;

function ColorFade(const ASource: TColor; const Shift: Integer): TColor;
var
  R, G, B: Byte;
begin
  R:= IntRange(GetRValue(ASource), 1, 254) + (Shift);
  G:= IntRange(GetGValue(ASource), 1, 254) + (Shift);
  B:= IntRange(GetBValue(ASource), 1, 254) + (Shift);
  Result:= RGB(R, G, B);
end;

function MakeColor(const AColor: TColor): Cardinal;
begin
  Result:= MakeColor(GetRValue(AColor), GetGValue(AColor), GetBValue(AColor));
end;

function PosOf(const AValue: Integer): Integer;
begin
  Result:= AValue;
  if Result < 0 then
    Result:= -Result;
end;

function NegOf(const AValue: Integer): Integer;
begin
  Result:= AValue;
  if Result > 0 then
    Result:= -Result;
end;

{ TColorRec }

function TColorRec.Value: TColor;
begin
  Result:= RGB(R, G, B);
end;

end.
