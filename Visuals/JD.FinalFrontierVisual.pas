unit JD.FinalFrontierVisual;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls,
  JD.FinalFrontierVisual.AvgCalc, JD.FinalFrontierVisual.CpuUsage;

const
  SPEED_UP = 0.00046; //Speed up time
  SPEED_CHANGE_FACTOR = 0.7; //+ or - Amount
  DEF_STAR_COUNT = 2500; //Default star count
  DEF_ACCEL = 1.2; //Default acceleration
  DEF_TAIL_LEN = 2.2; //Default tail length
  BOUND_BUFF = 700; //Off-screen area allowed
  SIZE_MULTIPLIER = 0.0035; //Initial size of newly spawned stars

type
  TStar = class;
  TFinalFrontierVisual = class;

  TPoint = TGPPointF;

  TRect = record
    Left: Single;
    Top: Single;
    Right: Single;
    Bottom: Single;
  end;

  TStarClass = (scM, scK, scG, scF, scA, scB, scO);

  TStarCounts = record
    M: Integer;
    K: Integer;
    G: Integer;
    F: Integer;
    A: Integer;
    B: Integer;
    O: Integer;
    procedure Reset;
    procedure Add(AClass: TStarClass);
  end;

  TStar = class(TObject)
  private
    FOwner: TFinalFrontierVisual;
    FPos: TPoint;
    FTailPos: TPoint;
    FStarClass: TStarClass;
    FDegree: Single;
    FDistance: Single;
    FColor: Cardinal;
    FSize: Single;
    FRelDistance: Single;
    FTailLength: Single;
    FRadians: Real;
    procedure CalcPos;
    function IsInBounds: Boolean;
    function AroundPoint(Center: TPoint; Distance, Degrees: Currency): TPoint;
  public
    constructor Create(AOwner: TFinalFrontierVisual);
    destructor Destroy; override;
    procedure Respawn;
    procedure Move(ASizeFactor, ASpeedFactor, ADistanceFactor: Single);
  end;

  TFinalFrontierVisual = class(TJDVisual)
  private
    FStars: TObjectList<TStar>;
    FBrush: TGPBrush;
    FStarPen: TGPPen;
    FTailPen: TGPPen;
    FFont: TGPFont;
    FTextBrush: TGPBrush;
    FSpeed: Single;
    FSpeedChange: Single;
    FMinSpeed: Single;
    FMaxSpeed: Single;
    FStarCounts: TStarCounts;
    FCpuAverage: TAverageCalculator;
    procedure SetSpeed(const Value: Single);
    procedure DrawStar(AStar: TStar);
    procedure EnsureStarCount;
    procedure DoDrawStats;
    procedure SetMaxSpeed(const Value: Single);
    procedure SetMinSpeed(const Value: Single);
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
    procedure SetThread(const Value: TJDVisualsThread); override;
  public
    constructor Create; override;
    destructor Destroy; override;
  public
    function StarCount: Integer;
    function Acceleration: Currency;
    function TailLength: Currency;
    function RealStars: Boolean;
    function ShowStats: Boolean;

    property Speed: Single read FSpeed write SetSpeed;
    property MinSpeed: Single read FMinSpeed write SetMinSpeed;
    property MaxSpeed: Single read FMaxSpeed write SetMaxSpeed;
  end;

function Rect(const ALeft, ATop, ARight, ABottom: Single): TRect;
function Point(X, Y: Single): TPoint;

implementation

function Rect(const ALeft, ATop, ARight, ABottom: Single): TRect;
begin
  Result.Left:= ALeft;
  Result.Top:= ATop;
  Result.Right:= ARight;
  Result.Bottom:= ABottom;
end;

function Point(X, Y: Single): TPoint;
begin
  Result.X:= X;
  Result.Y:= Y;
end;

{ TStarCounts }

procedure TStarCounts.Add(AClass: TStarClass);
begin
  case AClass of
    scM: Inc(M);
    scK: Inc(K);
    scG: Inc(G);
    scF: Inc(F);
    scA: Inc(A);
    scB: Inc(B);
    scO: Inc(O);
  end;
end;

procedure TStarCounts.Reset;
begin
  M:= 0;
  K:= 0;
  G:= 0;
  F:= 0;
  A:= 0;
  B:= 0;
  O:= 0;
end;

{ TStar }

constructor TStar.Create(AOwner: TFinalFrontierVisual);
begin
  FOwner:= AOwner;
  Respawn;
end;

destructor TStar.Destroy;
begin

  inherited;
end;

function TStar.AroundPoint(Center: TGPPointF; Distance: Currency; Degrees: Currency): TGPPointF;
begin
  FRadians:= (Degrees - 135) * Pi / 180;
  Result.X:= (Distance*Cos(FRadians)-Distance*Sin(FRadians))+Center.X;
  Result.Y:= (Distance*Sin(FRadians)+Distance*Cos(FRadians))+Center.Y;
end;

function TStar.IsInBounds: Boolean;
begin
  Result:= (FPos.X >= -BOUND_BUFF) and (FPos.X <= FOwner.Thread.Width+BOUND_BUFF)
    and    (FPos.Y >= -BOUND_BUFF) and (FPos.Y <= FOwner.Thread.Height+BOUND_BUFF);
end;

procedure TStar.CalcPos;
begin
  FPos:= AroundPoint(FOwner.Thread.CenterPoint, FDistance, FDegree);
  FTailLength:= FDistance * (FOwner.TailLength * FOwner.FSpeed);
  FTailLength:= FTailLength * ((FRelDistance * (FSize * 0.08)) * 0.0065);
  if FTailLength < 0.5 then
    FTailLength:= 0.5;
  if FTailLength > (BOUND_BUFF) then
    FTailLength:= (BOUND_BUFF);
  FTailPos:= AroundPoint(FOwner.Thread.CenterPoint, (FDistance-FTailLength), FDegree);
end;

procedure TStar.Move(ASizeFactor, ASpeedFactor, ADistanceFactor: Single);
begin
  FSize:= FSize + (((FRelDistance * 0.002) * ASizeFactor) * FOwner.FSpeed);
  FRelDistance:= FRelDistance + ASpeedFactor;
  FDistance:= FDistance + ((FRelDistance * FOwner.FSpeed) * ADistanceFactor);
  if not IsInBounds then begin
    Respawn;
  end;
  CalcPos;
end;

procedure TStar.Respawn;
var
  R: Integer;
  procedure DoRealStar;
  begin
    R:= Random(10001);
    case R of
      0..7500: begin
        //M Class - Light Orange Red <0.70
        FStarClass:= scM;
        FColor:= MakeColor(255, 200, 220);
        FSize:= (Random(70) * SIZE_MULTIPLIER);
      end;
      7501..8500: begin
        //K Class - Pale Yellow Orange 0.70-0.96 (0.26)
        FStarClass:= scK;
        FColor:= MakeColor(255, 230, 210);
        FSize:= (Random(26) * SIZE_MULTIPLIER) + 0.7;
      end;
      8501..9400: begin
        //G Class - Yellowish White 0.96-1.15 (0.19)
        FStarClass:= scG;
        FColor:= MakeColor(255, 255, 230);
        FSize:= (Random(19) * SIZE_MULTIPLIER) + 0.96;
      end;
      9401..9760: begin
        //F Class - White 1.15-1.4 (0.25)
        FStarClass:= scF;
        FColor:= MakeColor(255, 255, 255);
        FSize:= (Random(25) * SIZE_MULTIPLIER) + 1.15;
      end;
      9761..9860: begin
        //A Class - Blue White 1.4-1.8 (0.40)
        FStarClass:= scA;
        FColor:= MakeColor(220, 225, 255);
        FSize:= (Random(40) * SIZE_MULTIPLIER) + 1.4;
      end;
      9861..9999: begin
        //B Class - Deep Blue White 1.8-6.6 (4.8)
        FStarClass:= scB;
        FColor:= MakeColor(200, 200, 255);
        FSize:= (Random(480) * SIZE_MULTIPLIER) + 1.8;
      end;
      10000: begin
        //O Class - Blue >6.6
        FStarClass:= scO;
        FColor:= MakeColor(170, 170, 255);
        FSize:= (Random(500) * SIZE_MULTIPLIER) + 6.6;
      end;
    end;
  end;
  procedure DoGenericStar;
  begin
    FColor:= MakeColor(255, 255, 255);
    FSize:= (Random(20) * SIZE_MULTIPLIER) + 1.0;
  end;
begin
  FDistance:= Random(2200);
  FDegree:= (Random(3600) * 0.1);
  FRelDistance:= (Random(15)+1) * 0.05;
  if FOwner.RealStars then begin
    DoRealStar;
  end else begin
    DoGenericStar;
  end;
  CalcPos;
end;

{ TFinalFrontierVisual }

constructor TFinalFrontierVisual.Create;
begin
  inherited;
  Randomize;
  VisualName:= 'Final Frontier';
  FCpuAverage:= TAverageCalculator.Create;
  FStars:= TObjectList<TStar>.Create(True);
  FBrush := TGPSolidBrush.Create(MakeColor(0, 0, 0));
  FTailPen:= TGPPen.Create(MakeColor(255, 255, 255));
  FTailPen.SetLineCap(LineCap.LineCapRound, LineCap.LineCapRound, DashCap.DashCapRound);
  FStarPen:= TGPPen.Create(MakeColor(255, 255, 255));
  FTextBrush := TGPSolidBrush.Create(MakeColor(100, 255, 100));
  FSpeed:= FMinSpeed;
  FSpeedChange:= 1.0;
  FMinSpeed:= 0.0002;
  FMaxSpeed:= 1.0;
end;

destructor TFinalFrontierVisual.Destroy;
begin
  FStars.Clear;
  FStars.Free;
  FTextBrush.Free;
  FStarPen.Free;
  FTailPen.Free;
  FBrush.Free;
  FCpuAverage.Free;
  if Assigned(FFont) then
    FreeAndNil(FFont);
  inherited;
end;

procedure TFinalFrontierVisual.CreateControls;
begin
  Controls.NewNumberControl('Star Count', ntInteger, DEF_STAR_COUNT, 10, 5000, 0, 10);
  Controls.NewNumberControl('Acceleration', ntFloat, DEF_ACCEL, 0.1, 10.0, 2, 0.1);
  Controls.NewNumberControl('Tail Length', ntFloat, DEF_TAIL_LEN, 0.1, 10.0, 2, 0.1);
  Controls.NewCheckControl('Real Stars', True);
  Controls.NewCheckControl('Show Stats', False);
end;

function TFinalFrontierVisual.StarCount: Integer;
begin
  Result:= TJDVNumberControl(Controls['Star Count']).ValueInt;
end;

function TFinalFrontierVisual.TailLength: Currency;
begin
  Result:= TJDVNumberControl(Controls['Tail Length']).Value;
end;

function TFinalFrontierVisual.Acceleration: Currency;
begin
  Result:= TJDVNumberControl(Controls['Acceleration']).Value;
end;

function TFinalFrontierVisual.RealStars: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Real Stars']).Checked;
end;

function TFinalFrontierVisual.ShowStats: Boolean;
begin
  Result:= TJDVCheckControl(Controls['Show Stats']).Checked;
end;

procedure TFinalFrontierVisual.SetSpeed(const Value: Single);
begin
  FSpeed := Value;
end;

procedure TFinalFrontierVisual.SetThread(const Value: TJDVisualsThread);
var
  lf: LOGFONT;
begin
  inherited;
  if FFont <> nil then
    FreeAndNil(FFont);
  if Thread <> nil then begin
    lf:= Default(LOGFONT);
    lf.lfHeight:= 22;
    lf.lfCharSet:= DEFAULT_CHARSET;
    lf.lfFaceName:= 'Consolas';
    FFont:= TGPFont.Create(Canvas.Handle, PLogFont(@lf));
  end;
end;

procedure TFinalFrontierVisual.SetMaxSpeed(const Value: Single);
begin
  FMaxSpeed := Value;
end;

procedure TFinalFrontierVisual.SetMinSpeed(const Value: Single);
begin
  FMinSpeed := Value;
end;

procedure TFinalFrontierVisual.DrawStar(AStar: TStar);
begin
  FTailPen.SetColor(AStar.FColor);
  FTailPen.SetWidth(AStar.FSize);
  GPCanvas.DrawLine(FTailPen, AStar.FPos, AStar.FTailPos);
end;

procedure TFinalFrontierVisual.EnsureStarCount;
var
  X: Integer;
  S: TStar;
begin
  for X := 1 to 10 do begin
    if StarCount = FStars.Count then Break;
    if StarCount > FStars.Count then begin
      S:= TStar.Create(Self);
      FStars.Add(S);
    end else
    if StarCount < FStars.Count then begin
      FStars.Delete(FStars.Count-1);
    end;
  end;
end;

procedure PadString(var AStr: String; AWidth: Integer; AChar: Char = ' '; APadLeft: Boolean = False);
begin
  while Length(AStr) < AWidth do begin
    if APadLeft then
      AStr:= AChar + AStr
    else
      AStr:= AStr + AChar;
  end;
end;

procedure TFinalFrontierVisual.DoDrawStats;
var
  S, T: String;
  Cpu: Double;
  R, R2: TGPRectF;
  Pt: TGPPointF;
  procedure A(const AName, AValue: String); overload;
  begin
    T:= AName+':';
    PadString(T, 13);
    S:= S + T+AValue+sLineBreak;
  end;
  procedure A(const AName: String; AValue: Integer); overload;
  begin
    A(AName, IntToStr(AValue));
  end;
  procedure A(const AName: String; AValue: Single); overload;
  begin
    A(AName, FormatFloat('#,###,##0.0000', AValue));
  end;
begin
  if ShowStats then begin
    A('Speed', FSpeed);
    A('Speed Chg', Self.FSpeedChange);
    A('Accel', Acceleration);
    A('Min Speed', Self.FMinSpeed);
    A('Max Speed', Self.FMaxSpeed);
    A('Tail Len', TailLength);
    S:= S + sLineBreak;
    if RealStars then begin
      A('Star Classes', '');
      A('  M', FStarCounts.M);
      A('  K', FStarCounts.K);
      A('  G', FStarCounts.G);
      A('  F', FStarCounts.F);
      A('  A', FStarCounts.A);
      A('  B', FStarCounts.B);
      A('  O', FStarCounts.O);
      S:= S + sLineBreak;
    end;
    A('Total Stars', FStars.Count);
    S:= S + sLineBreak;
    Cpu:= GetTotalCpuUsagePct;
    FCpuAverage.Add(Cpu);
    A('Cpu Usage', Cpu);
    A('Cpu Average', FCpuAverage.Value);
    R.X:= 0;
    R.Y:= 0;
    R.Width:= Thread.Width;
    R.Height:= Thread.Height;
    GPCanvas.MeasureString(S, Length(S), FFont, R, nil, R2);

    Pt.X:= 5;
    Pt.Y:= Thread.Height - R2.Height - 5;
    {
    case FStats of
      spNone: ;
      spTopLeft: begin
        Pt.X:= 5;
        Pt.Y:= 5;
      end;
      spTopRight: begin
        Pt.X:= Thread.Width-R2.Width-5;
        Pt.Y:= 5;
      end;
      spBottomLeft: begin
        Pt.X:= 5;
        Pt.Y:= Thread.Height - R2.Height - 5;
      end;
      spBottomRight: begin
        Pt.X:= Thread.Width-R2.Width-5;
        Pt.Y:= Thread.Height - R2.Height - 5;
      end;
    end;
    }
    GPCanvas.DrawString(S, Length(S), FFont, Pt, nil, FTextBrush);
  end;
end;

procedure TFinalFrontierVisual.DoStep;
var
  S: TStar;
  SzF: Single;
  SpF: Single;
  DsF: Single;
begin
  EnsureStarCount;
  SzF:= 1.0;
  SpF:= (Acceleration * FSpeed);
  DsF:= 1.0;
  if (FSpeed >= FMaxSpeed) and (FSpeedChange > 0) then begin
    FSpeedChange:= -SPEED_CHANGE_FACTOR;
  end else
  if (FSpeed <= FMinSpeed) and (FSpeedChange < 0) then begin
    FSpeedChange:= SPEED_CHANGE_FACTOR;
  end;
  FSpeed:= FSpeed + (SPEED_UP * FSpeedChange);
  FStarCounts.Reset;

  for S in FStars do begin
    S.Move(SzF, SpF, DsF);
    FStarCounts.Add(S.FStarClass);
  end;

end;

procedure TFinalFrontierVisual.DoPaint;
var
  S: TStar;
begin
  for S in FStars do begin
    DrawStar(S);
  end;
  DoDrawStats;
end;

initialization
  Visuals.RegisterVisualClass(TFinalFrontierVisual);
end.
