unit JD.Visuals;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.SyncObjs,
  Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls,
  GDIPAPI, GDIPOBJ,
  JD.Visuals.Controls, JD.Visuals.Utils;

type
  TJDVisual = class;
  TJDVisualsThread = class;
  TJDVisualView = class;

  TJDVisualClass = class of TJDVisual;

  TJDVisual = class(TObject)
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
    constructor Create; virtual;
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

  TJDVisualList = class(TObject)
  private
    FItems: TObjectList<TJDVisual>;
    function GetVisual(const Index: Integer): TJDVisual;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    procedure RegisterVisualClass(const AClass: TJDVisualClass);
    property Visuals[const Index: Integer]: TJDVisual read GetVisual; default;
  end;

  TJDVisualView = class(TCustomControl)
  private
    FThread: TJDVisualsThread;
    FTimer: TTimer;
    FVisualIndex: Integer;
    procedure TimerExec(Sender: TObject);
    procedure SetVisualIndex(const Value: Integer);
    procedure ThreadGetDimensions(Sender: TJDVisualsThread; var Width, Height: Integer);
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Visual: TJDVisual;
  published
    property Align;
    property AlignWithMargins;
    property Anchors;
    property Color;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property ParentColor;
    property ParentDoubleBuffered;
    property Touch;
    property UseDockManager;
    property VisualIndex: Integer read FVisualIndex write SetVisualIndex;

    property OnClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnUnDock;
  end;

function Visuals: TJDVisualList;

implementation

var
  _Visuals: TJDVisualList;

function Visuals: TJDVisualList;
begin
  if _Visuals = nil then
    _Visuals:= TJDVisualList.Create;
  Result:= _Visuals;
end;

{ TJDVisual }

constructor TJDVisual.Create;
begin
  FVisualName:= 'Unnamed Visual';
  FControls:= TJDVisualControls.Create;
  CreateControls;
end;

procedure TJDVisual.CreateControls;
begin

end;

destructor TJDVisual.Destroy;
begin
  FreeAndNil(FControls);
  inherited;
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
  Result:= TGPGraphics.Create(FCanvas.Handle);
  Result.SetInterpolationMode(InterpolationMode.InterpolationModeHighQuality);
  Result.SetSmoothingMode(SmoothingMode.SmoothingModeHighQuality);
  Result.SetCompositingQuality(CompositingQuality.CompositingQualityHighQuality);
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

{ TJDVisualList }

constructor TJDVisualList.Create;
begin
  FItems:= TObjectList<TJDVisual>.Create(True);
end;

destructor TJDVisualList.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

function TJDVisualList.GetVisual(const Index: Integer): TJDVisual;
begin
  Result:= FItems[Index];
end;

function TJDVisualList.Count: Integer;
begin
  Result:= FItems.Count;
end;

procedure TJDVisualList.RegisterVisualClass(const AClass: TJDVisualClass);
var
  V: TJDVisual;
begin
  V:= AClass.Create;
  FItems.Add(V);
end;

{ TJDVisualView }

constructor TJDVisualView.Create(AOwner: TComponent);
begin
  inherited;
  Color:= clBlack;
  FVisualIndex:= -1;

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

procedure TJDVisualView.SetVisualIndex(const Value: Integer);
begin
  if Value < -1 then
    raise Exception.Create('Index out of range');
  if Value > Visuals.Count-1 then
    raise Exception.Create('Index out of range');
  FVisualIndex:= Value;
  if Value = -1 then
    FThread.Visual:= nil
  else
    FThread.Visual:= Visuals[Value];
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

function TJDVisualView.Visual: TJDVisual;
begin
  Result:= FThread.Visual;
end;

initialization
  _Visuals:= nil;
finalization
  FreeAndNil(_Visuals);
end.
