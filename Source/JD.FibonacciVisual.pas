unit JD.FibonacciVisual;

(*
  IMPORTANT NOTE

  This particular visual is currently in active development, and is
  not fully functional / animated at the moment. However it does
  at least demonstrate the drawing of the Fibonacci spiral.

*)

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

type
  TFibDir = (fbUp, fbLeft, fbDown, fbRight);

  TIntArray = array of Integer;

  TFibonacciVisual = class(TJDVisual)
  private
    FPen: TGPPen;
    function ShowBoxes: Boolean;
    function ShowSpiral: Boolean;
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function Canvas: TGPGraphics;
    function Thickness: Currency;
    function Zoom: Currency;
  end;

implementation

uses
  System.Math;

function NextDir(const ADir: TFibDir): TFibDir;
begin
  case ADir of
    fbUp:     Result:= fbLeft;
    fbLeft:   Result:= fbDown;
    fbDown:   Result:= fbRight;
    fbRight:  Result:= fbUp;
    else      Result:= fbRight;
  end;
end;

function FibonacciNums(const ACount: Integer): TIntArray;
var
  X: Integer;
begin
  if ACount < 2 then
    raise Exception.Create('Input must be at least 2!');
  SetLength(Result, ACount);
  Result[0]:= 1;
  Result[1]:= 1;
  for X := 2 to ACount-1 do begin
    Result[X]:= Result[X-1] + Result[X-2]; //The golden rule...
  end;
end;

{ TFibonacciVisual }

function TFibonacciVisual.Canvas: TGPGraphics;
begin
  Result:= Thread.GPCanvas;
end;

constructor TFibonacciVisual.Create;
begin
  inherited;
  VisualName:= 'Fibonacci Spiral';

  FPen:= TGPPen.Create(MakeColor(255,255,255));
  FPen.SetWidth(2.0);
  FPen.SetStartCap(LineCap.LineCapRound);
  FPen.SetEndCap(LineCap.LineCapRound);

end;

destructor TFibonacciVisual.Destroy;
begin

  inherited;
end;

procedure TFibonacciVisual.CreateControls;
begin
  Controls.NewNumberControl('Thickness', ntFloat, 3.0, 0.1, 1000.0, 2, 1.0);
  Controls.NewNumberControl('Zoom', ntFloat, 2.7, 0.001, 1000.0, 3, 0.1);
  Controls.NewCheckControl('Show Boxes', True);
  Controls.NewCheckControl('Show Spiral', True);
end;

procedure TFibonacciVisual.DoStep;
begin

end;

function TFibonacciVisual.Thickness: Currency;
begin
  Result:= TJDVNumberControl(Controls['Thickness']).Value;
end;

function TFibonacciVisual.Zoom: Currency;
begin
  Result:= TJDVNumberControl(Controls['Zoom']).Value;
end;

function TFibonacciVisual.ShowBoxes: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Show Boxes']).Checked;
end;

function TFibonacciVisual.ShowSpiral: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Show Spiral']).Checked;
end;

function Rect(const Left, Top, Right, Bottom: Currency): TGPRectF;
begin
  Result.X:= Left;
  Result.Y:= Top;
  Result.Width:= Right - Left;
  Result.Height:= Bottom - Top;
end;

function Point(const X, Y: Currency): TGPPointF;
begin
  Result.X:= X;
  Result.Y:= Y;
end;


const
  //MULTIPLIER = 1;
  SQUARE_COUNT = 50;



procedure TFibonacciVisual.DoPaint;
var
  Arr: TIntArray;
  Num: Integer;
  X: Integer;
  R, LR, CR: TGPRectF;
  CP: TGPPointF;
  Dir: TFibDir;
  procedure DoDrawRect;
  var
    S: String;
  begin
    LR:= R;
    FPen.SetColor(MakeColor(clDkGray));
    FPen.SetWidth(1.0);
    if Self.ShowBoxes then
      Canvas.DrawRectangle(FPen, R);
    S:= IntToStr(X);
  end;
  procedure DoDrawCurve;
  begin
    CP:= Point(R.X + (R.Width / 2), R.Y + (R.Height / 2));
    FPen.SetColor(MakeColor(clSkyBlue));
    FPen.SetWidth(Thickness);

    case Dir of
      fbUp: begin
        //Top-right
        CR.X:= R.X - R.Width;
        CR.Y:= R.Y;
        CR.Width:= (R.Width * 2);
        CR.Height:= (R.Height * 2);
        Canvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (90*3),  (90));
      end;
      fbLeft: begin
        //Top-left
        CR.X:= R.X;
        CR.Y:= R.Y;
        CR.Width:= (R.Width * 2);
        CR.Height:= (R.Height * 2);
        Canvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (90*2),  (90));
      end;
      fbDown: begin
        //Bottom-left
        CR.X:= R.X;
        CR.Y:= (R.Y - R.Height);
        CR.Width:= (R.Width * 2);
        CR.Height:= (R.Height * 2);
        Canvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (90),   (90));
      end;
      fbRight: begin
        //Bottom-right
        CR.X:= (R.X - R.Width);
        CR.Y:= (R.Y - R.Height);
        CR.Width:= (R.Width * 2);
        CR.Height:= (R.Height * 2);
        Canvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (0),    (90));
      end;
    end;
  end;
begin
  Dir:= fbRight;
  Arr:= FibonacciNums(SQUARE_COUNT);
  LR:= Rect(Thread.CenterPoint.X, Thread.CenterPoint.Y, Thread.CenterPoint.X+Zoom, Thread.CenterPoint.Y+Zoom);

  for X := 0 to Length(Arr)-1 do begin
    Num:= Arr[X];
    Dir:= NextDir(Dir);
    R.Width:= (Num*Zoom);
    R.Height:= (Num*Zoom);
    case Dir of
      fbUp: begin
        //Next square on top - right to left
        R.Y:= LR.Y - (Num*Zoom);
        R.X:= (LR.X+LR.Height) - (Num*Zoom);
      end;
      fbLeft: begin
        //Next square on left - top to bottom
        R.Y:= LR.Y;
        R.X:= LR.X - (Num*Zoom);
      end;
      fbDown: begin
        //Next square on bottom - left to right
        R.Y:= LR.Y + LR.Height;
        R.X:= LR.X;
      end;
      fbRight: begin
        //Next square on right - bottom to top
        R.Y:= (LR.Y+LR.Height) - (Num*Zoom);
        R.X:= LR.X + LR.Width;
      end;
    end;
    DoDrawRect;
    if Self.ShowSpiral then
      DoDrawCurve;
  end;

  //Canvas.DrawArc(FPen, 100, 100, 200, 200, 90, 90);

end;

initialization
  Visuals.RegisterVisualClass(TFibonacciVisual);
end.
