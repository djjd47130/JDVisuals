unit JD.Visuals;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.SyncObjs,
  Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls,
  GDIPAPI, GDIPOBJ,
  JD.Visuals.Controls, JD.Visuals.Utils,
  JD.Common, JD.Graphics;

type
  TJDVisual = class;
  TJDVisualsThread = class;
  TJDVisualView = class;
  TJDVisualEngine = class;

  TJDVisualClass = class of TJDVisual;

  TJDVisual = class(TComponent)
  private
    FThread: TJDVisualsThread;
    FControls: TJDVisualControls;
    FVisualName: String;
    function GetCanvas: TCanvas;
    function GetGPCanvas: TGPGraphics;
  protected
    procedure SetThread(const Value: TJDVisualsThread); virtual;
    procedure DoStep; virtual; abstract;
    procedure DoPaint; virtual; abstract;
    procedure CreateControls; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Thread: TJDVisualsThread read FThread write SetThread;
    property Controls: TJDVisualControls read FControls;
    property VisualName: String read FVisualName write FVisualName;
    property Canvas: TCanvas read GetCanvas;
    property GPCanvas: TGPGraphics read GetGPCanvas;
  end;

  TJDVOnGetDims = procedure(Sender: TJDVisualsThread; var Width, Height: Integer) of object;

  TJDVisualsThread = class(TThread)
  private
    FLock: TCriticalSection;
    FCanvas: TCanvas;
    FGPCanvas: TGPGraphics;
    FStepDelay: Integer;
    FVisual: TJDVisual;
    FWidth: Integer;
    FHeight: Integer;
    FOnGetDimensions: TJDVOnGetDims;
    function CreateCanvas: TGPGraphics;
    procedure SetDelay(const Value: Integer);
    procedure SetVisual(const Value: TJDVisual);
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  protected
    procedure Execute; override;
    procedure DoGetDimensions(var Width, Height: Integer); virtual;
  public
    constructor Create(ACanvas: TCanvas); reintroduce;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    function CenterPoint: TGPPointF;
    procedure PaintToCanvas;
  public
    property Canvas: TCanvas read FCanvas;
    property GPCanvas: TGPGraphics read FGPCanvas;
    property StepDelay: Integer read FStepDelay write SetDelay;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Visual: TJDVisual read FVisual write SetVisual;

    property OnGetDimensions: TJDVOnGetDims read FOnGetDimensions write FOnGetDimensions;
  end;

  TJDVisualView = class(TCustomControl)
  private
    FThread: TJDVisualsThread;
    FTimer: TTimer;
    FVisual: TJDVisual;
    FOnMouseMove: TMouseMoveEvent;
    procedure TimerExec(Sender: TObject);
    procedure ThreadGetDimensions(Sender: TJDVisualsThread; var Width, Height: Integer);
    procedure SetVisual(const Value: TJDVisual);
    function GetInterval: Integer;
    procedure SetInterval(const Value: Integer);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property AlignWithMargins;
    property Anchors;
    property Color;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Interval: Integer read GetInterval write SetInterval;
    property ParentColor;
    property ParentDoubleBuffered;
    property Touch;
    property UseDockManager;
    property Visual: TJDVisual read FVisual write SetVisual;

    property OnClick;
    property OnDblClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnUnDock;
  end;

  //New alternative option than just TJDVisualView - a non-visual component
  //  with events to render to third-party canvas via OnPaint event.
  TJDVisualEngine = class(TJDComponent)
  private
    FBitmap: TBitmap;
    FVisual: TJDVisual;
    FThread: TJDVisualsThread;
    FTimer: TTimer;
    procedure TimerExec(Sender: TObject);
    procedure ThreadGetDimensions(Sender: TJDVisualsThread; var Width, Height: Integer);
    procedure SetVisual(const Value: TJDVisual);
    function GetInterval: Integer;
    procedure SetInterval(const Value: Integer);
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; virtual;
    procedure DrawTo(const X, Y: Integer; Canvas: TCanvas); overload;
    procedure DrawTo(const X, Y: Integer; DC: HDC); overload;
  published
    property Height: Integer read GetHeight write SetHeight;
    property Interval: Integer read GetInterval write SetInterval;
    property Visual: TJDVisual read FVisual write SetVisual;
    property Width: Integer read GetWidth write SetWidth;
    //property OnPaint
    //property OnStep
  end;

implementation

{ TJDVisual }

constructor TJDVisual.Create(AOwner: TComponent);
begin
  inherited;
  FVisualName:= 'Unnamed Visual';
  FControls:= TJDVisualControls.Create;
  CreateControls;
end;

destructor TJDVisual.Destroy;
begin
  FreeAndNil(FControls);
  inherited;
end;

procedure TJDVisual.CreateControls;
begin

end;

function TJDVisual.GetCanvas: TCanvas;
begin
  if FThread <> nil then
    Result:= FThread.Canvas
  else
    Result:= nil;
end;

function TJDVisual.GetGPCanvas: TGPGraphics;
begin
  if FThread <> nil then
    Result:= FThread.GPCanvas
  else
    Result:= nil;
end;

procedure TJDVisual.SetThread(const Value: TJDVisualsThread);
begin
  FThread := Value;
end;

{ TJDVisualsThread }

constructor TJDVisualsThread.Create(ACanvas: TCanvas);
begin
  inherited Create(True);
  NameThreadForDebugging('JDVisualsThread', Self.ThreadID);
  FCanvas:= ACanvas;
  FLock:= TCriticalSection.Create;
  FStepDelay:= 15;
  Self.Priority:= TThreadPriority.tpHighest;
end;

destructor TJDVisualsThread.Destroy;
begin
  FreeAndNil(FLock);
  inherited;
end;

function TJDVisualsThread.CenterPoint: TGPPointF;
begin
  Result.X:= FWidth / 2;
  Result.Y:= FHeight / 2;
end;

procedure TJDVisualsThread.DoGetDimensions(var Width, Height: Integer);
begin
  if Assigned(FOnGetDimensions) then
    FOnGetDimensions(Self, Width, Height);
end;

procedure TJDVisualsThread.Lock;
begin
  FLock.Enter;
end;

procedure TJDVisualsThread.Unlock;
begin
  FLock.Leave;
end;

procedure TJDVisualsThread.SetDelay(const Value: Integer);
begin
  Lock;
  try
    FStepDelay := Value;
  finally
    Unlock;
  end;
end;

procedure TJDVisualsThread.SetHeight(const Value: Integer);
begin
  Lock;
  try
    FHeight := Value;
  finally
    Unlock;
  end;
end;

procedure TJDVisualsThread.SetVisual(const Value: TJDVisual);
begin
  Lock;
  try
    FVisual := Value;
    if FVisual <> nil then
      FVisual.Thread:= Self;
  finally
    Unlock;
  end;
end;

procedure TJDVisualsThread.SetWidth(const Value: Integer);
begin
  Lock;
  try
    FWidth := Value;
  finally
    Unlock;
  end;
end;

procedure TJDVisualsThread.Execute;
begin
  while not Terminated do begin
    Lock;
    try
      try
        if Assigned(FVisual) then begin
          FVisual.DoStep;
        end;
      except
        on E: Exception do begin
          //TODO
        end;
      end;
    finally
      Unlock;
    end;
    Sleep(FStepDelay);
  end;
end;

function TJDVisualsThread.CreateCanvas: TGPGraphics;
begin
  Result:= CreateGPCanvas(FCanvas.Handle);
end;

procedure TJDVisualsThread.PaintToCanvas;
var
  W, H: Integer;
begin
  W:= FWidth;
  H:= FHeight;
  DoGetDimensions(W, H);
  FWidth:= W;
  FHeight:= H;
  Lock;
  try
    if Assigned(FVisual) then begin
      FGPCanvas:= CreateCanvas;
      try
        FCanvas.Lock;
        try
          //TODO: Implement a sort of "flowfield" to "remember" background
          //  and make pixels "move" to create some sort of effect

          //Paint the foreground
          FVisual.DoPaint;

        finally
          FCanvas.Unlock;
        end;
      finally
        FGPCanvas.Free;
      end;
    end;
  finally
    Unlock;
  end;
end;

{ TJDVisualView }

constructor TJDVisualView.Create(AOwner: TComponent);
begin
  inherited;
  Color:= clBlack;
  FVisual:= nil;

  FTimer:= TTimer.Create(nil);
  FTimer.Interval:= 25;
  FTimer.OnTimer:= TimerExec;

  FThread:= TJDVisualsThread.Create(Canvas);
  FThread.OnGetDimensions:= ThreadGetDimensions;
  FThread.Start;
end;

destructor TJDVisualView.Destroy;
begin
  FThread.Terminate;
  FThread.WaitFor;
  FreeAndNil(FThread);
  FreeAndNil(FTimer);
  inherited;
end;

function TJDVisualView.GetInterval: Integer;
begin
  Result:= FTimer.Interval;
end;

procedure TJDVisualView.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TJDVisualView.Paint;
begin
  inherited;
  FThread.PaintToCanvas;
end;

procedure TJDVisualView.Resize;
begin
  inherited;
  FThread.Width:= ClientWidth;
  FThread.Height:= ClientHeight;
end;

procedure TJDVisualView.SetInterval(const Value: Integer);
begin
  FTimer.Interval:= Value;
end;

procedure TJDVisualView.SetVisual(const Value: TJDVisual);
begin
  FVisual := Value;
  FThread.Visual:= Value;
  Invalidate;
end;

procedure TJDVisualView.ThreadGetDimensions(Sender: TJDVisualsThread; var Width,
  Height: Integer);
begin
  Width:= Self.ClientWidth;
  Height:= Self.ClientHeight;
end;

procedure TJDVisualView.TimerExec(Sender: TObject);
begin
  Invalidate;
end;

{ TJDVisualEngine }

constructor TJDVisualEngine.Create(AOwner: TComponent);
begin
  inherited;
  //Color:= clBlack;
  FVisual:= nil;

  FBitmap:= TBitmap.Create;
  FBitmap.PixelFormat:= pf32bit;

  FTimer:= TTimer.Create(nil);
  FTimer.Interval:= 25;
  FTimer.OnTimer:= TimerExec;

  FThread:= TJDVisualsThread.Create(FBitmap.Canvas);
  FThread.OnGetDimensions:= ThreadGetDimensions;
  FThread.Start;

end;

destructor TJDVisualEngine.Destroy;
begin

  FThread.Terminate;
  FThread.WaitFor;
  FreeAndNil(FThread);
  FreeAndNil(FTimer);
  FreeAndNil(FBitmap);
  inherited;
end;

procedure TJDVisualEngine.DrawTo(const X, Y: Integer; DC: HDC);
begin
  //TODO

end;

procedure TJDVisualEngine.DrawTo(const X, Y: Integer; Canvas: TCanvas);
begin
  DrawTo(X, Y, Canvas.Handle);
end;

function TJDVisualEngine.GetHeight: Integer;
begin
  Result:= FBitmap.Height;
end;

function TJDVisualEngine.GetInterval: Integer;
begin
  Result:= FTimer.Interval;
end;

function TJDVisualEngine.GetWidth: Integer;
begin
  Result:= FBitmap.Width
end;

procedure TJDVisualEngine.Invalidate;
begin
  //TODO: Call OnPaint event...
end;

procedure TJDVisualEngine.SetHeight(const Value: Integer);
begin
  FBitmap.Height := Value;
  Invalidate;
end;

procedure TJDVisualEngine.SetInterval(const Value: Integer);
begin
  FTimer.Interval:= Value;
  Invalidate;
end;

procedure TJDVisualEngine.SetVisual(const Value: TJDVisual);
begin
  FVisual := Value;
  Invalidate;
end;

procedure TJDVisualEngine.SetWidth(const Value: Integer);
begin
  FBitmap.Width := Value;
  Invalidate;
end;

procedure TJDVisualEngine.ThreadGetDimensions(Sender: TJDVisualsThread;
  var Width, Height: Integer);
begin
  Width:= Self.Width;
  Height:= Self.Height;
end;

procedure TJDVisualEngine.TimerExec(Sender: TObject);
begin
  Invalidate;
end;

end.
