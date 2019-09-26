unit JD.RaindropsVisual;

(*
  IMPORTANT NOTE:
  This visual is in raw beginning stages, and is far from ready. This visual
  will simulate raindrops falling from the top, in a "3D" view, and will
  create a ripple effect when reaching the "water" at the bottom.
*)

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

const
  DROP_COUNT = 300;
  MAX_DEPTH = 30;

type
  TDrop = record
    HorzPos: Currency;
    VertPos: Currency;
    Spread: Currency;
    Depth: Currency;
    Color: TColor;
  end;

  TDrops = array of TDrop;

  TRaindropVisual = class(TJDVisual)
  private
    FPen: TGPPen;
    FDrops: TDrops;
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

uses
  System.Math;

function RandomDrop(const AWidth: Currency): TDrop;
begin
  Result.HorzPos:= RandomRange(0, Trunc(AWidth));
  Result.VertPos:= -RandomRange(0, 2000);
  Result.Spread:= 0;
  Result.Depth:= RandomRange(1, MAX_DEPTH);
  Result.Color:= clSkyBlue;
end;

{ TRaindropVisual }

constructor TRaindropVisual.Create;
var
  X: Integer;
begin
  inherited;
  VisualName:= 'Raindrops';
  FPen:= TGPPen.Create(MakeColor(clSkyBlue));
  FPen.SetWidth(7.0);
  FPen.SetStartCap(LineCap.LineCapRound);
  FPen.SetEndCap(LineCap.LineCapRound);
  SetLength(FDrops, DROP_COUNT);
  for X := 0 to Length(FDrops)-1 do begin
    FDrops[X].Spread:= 10000;
  end;
end;

destructor TRaindropVisual.Destroy;
begin

  SetLength(FDrops, 0);
  FreeAndNil(FPen);
  inherited;
end;

procedure TRaindropVisual.CreateControls;
begin

end;

procedure TRaindropVisual.DoStep;
var
  X: Integer;
begin
  for X := 0 to Length(FDrops)-1 do begin

    if FDrops[X].VertPos >= (Thread.Height - (FDrops[X].Depth*12)) then begin
      //Rippling out
      FDrops[X].Spread:= FDrops[X].Spread + 2.2;
    end else begin
      //Falling down
      FDrops[X].VertPos:= FDrops[X].VertPos + ((MAX_DEPTH - FDrops[X].Depth) / 2);
    end;

    if FDrops[X].Spread > 100 then begin
      FDrops[X]:= RandomDrop(Thread.Width);
    end;

  end;
end;

procedure TRaindropVisual.DoPaint;
var
  X: Integer;
  R: TGPRectF;
begin
  for X := 0 to Length(FDrops)-1 do begin
    if FDrops[X].Spread = 0 then begin
      //Drop falling...
      FPen.SetColor(MakeColor(FDrops[X].Color));
      FPen.SetWidth((MAX_DEPTH - FDrops[X].Depth)*0.3);
      Thread.GPCanvas.DrawLine(FPen, FDrops[X].HorzPos, FDrops[X].VertPos, FDrops[X].HorzPos+1, FDrops[X].VertPos+1);
    end else begin
      //Drop ripples through "water"...
      R.Width:= FDrops[X].Spread * 2;
      R.Height:= FDrops[X].Spread * 0.8;
      R.X:= FDrops[X].HorzPos - (R.Width / 2);
      R.Y:= FDrops[X].VertPos - (R.Height / 2);
      FPen.SetWidth((MAX_DEPTH - FDrops[X].Depth)*0.2); //TODO: Make thinner as spread grows
      FPen.SetColor(MakeColor(ColorFade(FDrops[X].Color, -Round(FDrops[X].Spread * 1.5))));
      Thread.GPCanvas.DrawEllipse(FPen, R);
    end;
  end;
end;

initialization
  Visuals.RegisterVisualClass(TRaindropVisual);
end.
