unit JD.CircleTraceVisual;

//Inspiration: https://giphy.com/gifs/satisfying-oddlysatisfying-oddly-LXfS9EGAqBI2PIo9la?fbclid=IwAR3dTKKsx-SXri-RdUkz5-iVMEQVQgqPfo7WJqYsnYv615UyCfctDx0mpzU


interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

type

  TCircle = record
    Angle: Currency;
    Speed: Currency;
    Color: TColor;
  end;

  TCircleTraceVisualVisual = class(TJDVisual)
  private
    FCircles: Array of TCircle;
    FDiameter: Currency;
    FCirclePen: TGPPen;
    FDotPen: TGPPen;
    FTracePen: TGPPen;
    FBitmap: TBitmap;
    FBitmapCanvas: TGPGraphics;
    function CircleRect(const ACol, ARow: Integer; const Centered: Boolean = True): TGPRectF;
    function RectCenter(const R: TGPRectF): TGPPointF;
    function AreaSize: Currency;
    function AreaRect(const Centered: Boolean = True): TGPRectF;
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function ShowDots: Boolean;
    function ShowGrid: Boolean;
  end;

implementation

uses
  System.Math;

{ TCircleTraceVisualVisual }

constructor TCircleTraceVisualVisual.Create;
var
  X: Integer;
begin
  inherited;
  VisualName:= 'Circle Trace';

  FBitmap:= TBitmap.Create;
  FBitmap.Canvas.Brush.Style:= bsSolid;
  FBitmap.Canvas.Brush.Color:= clBlack;
  FBitmap.Canvas.FillRect(FBitmap.Canvas.ClipRect);

  FCirclePen:= TGPPen.Create(MakeColor(clBlue));
  FCirclePen.SetWidth(2.0);
  FCirclePen.SetStartCap(LineCap.LineCapRound);
  FCirclePen.SetEndCap(LineCap.LineCapRound);

  FDotPen:= TGPPen.Create(MakeColor(clRed));
  FDotPen.SetWidth(7.0);
  FDotPen.SetStartCap(LineCap.LineCapRound);
  FDotPen.SetEndCap(LineCap.LineCapRound);

  FTracePen:= TGPPen.Create(MakeColor(clDkGray));
  FTracePen.SetWidth(0.75);
  FTracePen.SetStartCap(LineCap.LineCapRound);
  FTracePen.SetEndCap(LineCap.LineCapRound);
  FTracePen.SetDashStyle(DashStyle.DashStyleDash);

  FDiameter:= 110;
  SetLength(FCircles, 7);
  for X := 0 to Length(FCircles)-1 do begin
    FCircles[X].Angle:= 0;
    FCircles[X].Speed:= X * 0.1;
    FCircles[X].Color:= clDkGray;
  end;
end;

destructor TCircleTraceVisualVisual.Destroy;
begin
  FreeAndNil(FTracePen);
  FreeAndNil(FDotPen);
  FreeAndNil(FCirclePen);
  FreeAndNil(FBitmap);
  inherited;
end;

procedure TCircleTraceVisualVisual.CreateControls;
begin
  Controls.NewCheckControl('Show Grid', False);
  Controls.NewCheckControl('Show Dots', True);
end;

function TCircleTraceVisualVisual.ShowGrid: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Show Grid']).Checked;
end;

function TCircleTraceVisualVisual.ShowDots: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Show Dots']).Checked;
end;

function TCircleTraceVisualVisual.AreaSize: Currency;
begin
  Result:= Length(FCircles) * FDiameter; //Overall size of full visual view
end;

function TCircleTraceVisualVisual.AreaRect(const Centered: Boolean = True): TGPRectF;
begin
  Result.Width:= AreaSize;
  Result.Height:= Result.Width;
  if Centered then begin
    Result.X:= (Thread.Width / 2) - (Result.Width / 2);
    Result.Y:= (Thread.Height / 2) - (Result.Height / 2);
  end else begin
    Result.X:= 0;
    Result.Y:= 0;
  end;
end;

function TCircleTraceVisualVisual.CircleRect(const ACol,
  ARow: Integer; const Centered: Boolean = True): TGPRectF;
var
  R: TGPRectF;
begin
  R:= AreaRect(Centered);
  Result.X:= R.X + (FDiameter * (ACol-1)) + 5;
  Result.Y:= R.Y + (FDiameter * (ARow-1)) + 5;
  Result.Width:= FDiameter - 10;
  Result.Height:= FDiameter - 10;
end;

function TCircleTraceVisualVisual.RectCenter(const R: TGPRectF): TGPPointF;
begin
  Result.X:= R.X + (R.Width / 2);
  Result.Y:= R.Y + (R.Height / 2);
end;

procedure TCircleTraceVisualVisual.DoStep;
var
  X: Integer;
begin
  for X := 0 to Length(FCircles)-1 do begin
    FCircles[X].Angle:= FCircles[X].Angle + FCircles[X].Speed;
    if FCircles[X].Angle >= 360 then
      FCircles[X].Angle:= 0;
  end;
end;

procedure TCircleTraceVisualVisual.DoPaint;
const
  MARGIN = 20;
var
  X, Y: Integer;
  R: TGPRectF;
  CP, P, P2: TGPPointF;
  AR: TGPRectF;
  B: TGPBitmap;
begin
  AR:= AreaRect(False);

  //Fill in the center
  FBitmap.Width:= Trunc(AR.Width) + 100;
  FBitmap.Height:= Trunc(AR.Height) + 100;

  FBitmapCanvas:= CreateGPCanvas(FBitmap.Canvas.Handle);
  try
    for X := 1 to Length(FCircles)-1 do begin
      for Y := 1 to Length(FCircles)-1 do begin
        R:= CircleRect(X+1, Y+1, False);
        CP:= RectCenter(R);
        P:= PointAroundCircle(CP, (FDiameter / 2)-MARGIN, FCircles[X].Angle);
        P2:= PointAroundCircle(CP, (FDiameter / 2)-MARGIN, FCircles[Y].Angle);
        P.Y:= P2.Y;
        P2.X:= P.X + 0.1;
        P2.Y:= P.Y + 0.1;
        FBitmapCanvas.DrawLine(FCirclePen, P, P2);
      end;
    end;
  finally
    FreeAndNil(FBitmapCanvas);
  end;
  AR:= AreaRect(True);
  Canvas.Draw(Trunc(AR.X), Trunc(AR.Y), FBitmap);


  if ShowDots then begin
    for X := 1 to Length(FCircles)-1 do begin
      for Y := 1 to Length(FCircles)-1 do begin
        R:= CircleRect(X+1, Y+1, True);
        CP:= RectCenter(R);
        P:= PointAroundCircle(CP, (FDiameter / 2)-MARGIN, FCircles[X].Angle);
        P2:= PointAroundCircle(CP, (FDiameter / 2)-MARGIN, FCircles[Y].Angle);
        P.Y:= P2.Y;
        P2.X:= P.X + 0.1;
        P2.Y:= P.Y + 0.1;
        GPCanvas.DrawLine(FDotPen, P, P2);
      end;
    end;
  end;


  //Vertical along left
  for X := 1 to Length(FCircles)-1 do begin
    R:= CircleRect(1, X+1);
    GPCanvas.DrawEllipse(FCirclePen, R);
    CP:= RectCenter(R);
    P:= PointAroundCircle(CP, (FDiameter / 2)-MARGIN, FCircles[X].Angle);
    P2:= P;
    P2.X:= P2.X + 0.1;
    P2.Y:= P2.Y + 0.1;
    if ShowDots then begin
      GPCanvas.DrawLine(FDotPen, P, P2);
    end;
    if ShowGrid then begin
      P2.X:= AR.X;
      P2.Y:= P.Y;
      P.X:= AR.X + AR.Width;
      GPCanvas.DrawLine(FTracePen, P, P2);
    end;
  end;

  //Horizontal along top
  for X := 1 to Length(FCircles)-1 do begin
    R:= CircleRect(X+1, 1);
    GPCanvas.DrawEllipse(FCirclePen, R);
    CP:= RectCenter(R);
    P:= PointAroundCircle(CP, (FDiameter / 2)-MARGIN, FCircles[X].Angle);
    P2:= P;
    P2.X:= P2.X + 0.1;
    P2.Y:= P2.Y + 0.1;
    if ShowDots then begin
      GPCanvas.DrawLine(FDotPen, P, P2);
    end;
    if ShowGrid then begin
      P2.X:= P.X;
      P2.Y:= AR.Y;
      P.Y:= AR.Y + AR.Height;
      GPCanvas.DrawLine(FTracePen, P, P2);
    end;
  end;

end;

initialization
  Visuals.RegisterVisualClass(TCircleTraceVisualVisual);
end.
