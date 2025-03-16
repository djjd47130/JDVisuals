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
    procedure SetThickness(const Value: Currency);
    procedure SetZoom(const Value: Currency);
    procedure SetCount(const Value: Integer);
    procedure SetShowBoxes(const Value: Boolean);
    procedure SetShowSpiral(const Value: Boolean);
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetThickness: Currency;
    function GetZoom: Currency;
    function GetCount: Integer;
    function GetShowBoxes: Boolean;
    function GetShowSpiral: Boolean;

  published
    property Thickness: Currency read GetThickness write SetThickness;
    property Zoom: Currency read GetZoom write SetZoom;
    property Count: Integer read GetCount write SetCount;
    property ShowBoxes: Boolean read GetShowBoxes write SetShowBoxes;
    property ShowSpiral: Boolean read GetShowSpiral write SetShowSpiral;
  end;

implementation

uses
  System.Math;

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

function NextDir(const ADir: TFibDir): TFibDir;
begin
  //Used to alternate direction to move each next box
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
  //Main function for generating Fibonacci sequence
  if ACount < 2 then
    raise Exception.Create('Input must be at least 2!');
  SetLength(Result, ACount);
  Result[0]:= 1;
  Result[1]:= 1;
  for X := 2 to ACount-1 do begin
    //The golden rule - each value is a sum of prior two values
    Result[X]:= Result[X-1] + Result[X-2];
  end;
end;

{ TFibonacciVisual }

constructor TFibonacciVisual.Create(AOwner: TComponent);
begin
  inherited;
  VisualName:= 'Fibonacci Spiral';
  FPen:= TGPPen.Create(MakeColor(clSkyBlue));
  FPen.SetWidth(2.0);
  FPen.SetStartCap(LineCap.LineCapRound);
  FPen.SetEndCap(LineCap.LineCapRound);
end;

destructor TFibonacciVisual.Destroy;
begin
  FreeAndNil(FPen);
  inherited;
end;

procedure TFibonacciVisual.CreateControls;
begin
  Controls.NewNumberControl('Thickness', ntFloat, 3.0, 0.1, 1000.0, 2, 1.0);
  Controls.NewNumberControl('Zoom', ntFloat, 2.7, 0.001, 1000.0, 3, 0.1);
  Controls.NewNumberControl('Count', ntInteger, 30, 2, 500, 0, 1);
  Controls.NewCheckControl('Show Boxes', True);
  Controls.NewCheckControl('Show Spiral', True);
end;

function TFibonacciVisual.GetThickness: Currency;
begin
  Result:= TJDVNumberControl(Controls['Thickness']).Value;
end;

function TFibonacciVisual.GetZoom: Currency;
begin
  Result:= TJDVNumberControl(Controls['Zoom']).Value;
end;

procedure TFibonacciVisual.SetCount(const Value: Integer);
begin
  TJDVNumberControl(Controls['Count']).ValueInt:= Value;
end;

procedure TFibonacciVisual.SetShowBoxes(const Value: Boolean);
begin
  TJDVCheckControl(Controls['Show Boxes']).Checked:= Value;
end;

procedure TFibonacciVisual.SetShowSpiral(const Value: Boolean);
begin
  TJDVCheckControl(Controls['Show Spiral']).Checked:= Value;
end;

procedure TFibonacciVisual.SetThickness(const Value: Currency);
begin
  TJDVNumberControl(Controls['Thickness']).Value:= Value;
end;

procedure TFibonacciVisual.SetZoom(const Value: Currency);
begin
  TJDVNumberControl(Controls['Zoom']).Value:= Value;
end;

function TFibonacciVisual.GetCount: Integer;
begin
  Result:= TJDVNumberControl(Controls['Count']).ValueInt;
end;

function TFibonacciVisual.GetShowBoxes: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Show Boxes']).Checked;
end;

function TFibonacciVisual.GetShowSpiral: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Show Spiral']).Checked;
end;

procedure TFibonacciVisual.DoStep;
begin
  //TODO: An actual animation of some kind...

end;

procedure TFibonacciVisual.DoPaint;
var
  Arr: TIntArray;
  Num: Integer;
  X: Integer;
  R, LR, CR: TGPRectF;
  CP: TGPPointF;
  Dir: TFibDir;
  procedure DoDrawRect;
  begin
    LR:= R; //Keep track of prior rectangle
    FPen.SetColor(MakeColor(clDkGray));
    FPen.SetWidth(1.0);
    if GetShowBoxes then
      GPCanvas.DrawRectangle(FPen, R);
  end;
  procedure DoDrawCurve;
  begin
    CP:= Point(R.X + (R.Width / 2), R.Y + (R.Height / 2));
    FPen.SetColor(MakeColor(clSkyBlue));
    FPen.SetWidth(GetThickness);

    //Here we need to assume that width/height of each box is doubled.
    //CR is used to define a virtual space for a circle, but then
    //we only draw an arc consuming 1/4 of that circle.

    CR.Width:= (R.Width * 2);
    CR.Height:= (R.Height * 2);

    case Dir of
      fbUp: begin
        //Top-right
        CR.X:= R.X - R.Width;
        CR.Y:= R.Y;
        GPCanvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (90*3),  (90));
      end;
      fbLeft: begin
        //Top-left
        CR.X:= R.X;
        CR.Y:= R.Y;
        GPCanvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (90*2),  (90));
      end;
      fbDown: begin
        //Bottom-left
        CR.X:= R.X;
        CR.Y:= (R.Y - R.Height);
        GPCanvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (90),   (90));
      end;
      fbRight: begin
        //Bottom-right
        CR.X:= (R.X - R.Width);
        CR.Y:= (R.Y - R.Height);
        GPCanvas.DrawArc(FPen, CR.X,  CR.Y, CR.Width,   CR.Height,  (0),    (90));
      end;
    end;
  end;
begin
  Dir:= fbRight;
  Arr:= FibonacciNums(GetCount);
  LR:= Rect(Thread.CenterPoint.X, Thread.CenterPoint.Y, Thread.CenterPoint.X+GetZoom, Thread.CenterPoint.Y+GetZoom);

  for X := 0 to Length(Arr)-1 do begin
    Num:= Arr[X];
    Dir:= NextDir(Dir);

    //Here we set the box size based on current sequence number,
    //then decide how to position it relative to the prior one(s).

    R.Width:= (Num*GetZoom);
    R.Height:= (Num*GetZoom);
    case Dir of
      fbUp: begin
        //Next square on top - right to left
        R.Y:= LR.Y - (Num*GetZoom);
        R.X:= (LR.X+LR.Height) - (Num*GetZoom);
      end;
      fbLeft: begin
        //Next square on left - top to bottom
        R.Y:= LR.Y;
        R.X:= LR.X - (Num*GetZoom);
      end;
      fbDown: begin
        //Next square on bottom - left to right
        R.Y:= LR.Y + LR.Height;
        R.X:= LR.X;
      end;
      fbRight: begin
        //Next square on right - bottom to top
        R.Y:= (LR.Y+LR.Height) - (Num*GetZoom);
        R.X:= LR.X + LR.Width;
      end;
    end;
    DoDrawRect;
    if GetShowSpiral then
      DoDrawCurve;
  end;
end;

initialization
  //Visuals.RegisterVisualClass(TFibonacciVisual);
end.
