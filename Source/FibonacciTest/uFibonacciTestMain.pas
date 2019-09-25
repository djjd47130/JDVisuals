unit uFibonacciTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type

  TFibDir = (fbUp, fbLeft, fbDown, fbRight);

  TIntArray = array of Integer;

  TfrmMain = class(TForm)
    Timer1: TTimer;
    Log: TMemo;
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function NextDir(const ADir: TFibDir): TFibDir;
begin
  case ADir of
    fbUp:     Result:= fbLeft;
    fbLeft:   Result:= fbDown;
    fbDown:   Result:= fbRight;
    fbRight:  Result:= fbUp;
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
    Result[X]:= Result[X-1] + Result[X-2];
  end;
end;

procedure TfrmMain.FormPaint(Sender: TObject);
const
  MULTIPLIER = 5;
var
  CenterPoint: TPoint;
  Arr: TIntArray;
  Num: Integer;
  X: Integer;
  R, LR, CR: TRect;
  Dir: TFibDir;
  procedure DoDrawRect;
  var
    S: String;
  begin
    LR:= R;
    Canvas.Rectangle(R);
    S:= IntToStr(X);
    //DrawText(Canvas.Handle, PChar(S), Length(S), R, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
  end;
  procedure DoDrawCurve;
  begin
    case Dir of
      fbUp: begin
        //Top-right
        CR:= Rect(R.Left-R.Width, R.Top, R.Right, R.Bottom-R.Height);
        Canvas.Arc(CR.Left, CR.Top, CR.Right, CR.Bottom, CR.Right, CR.Bottom, CR.Left, CR.Top);
      end;
      fbLeft: begin
        //Top-left

      end;
      fbDown: begin
        //Bottom-left

      end;
      fbRight: begin
        //Bottom-right

      end;
    end;
  end;
begin
  Log.Lines.Clear;
  Canvas.Brush.Style:= bsClear;
  Canvas.Pen.Style:= psSolid;
  Canvas.Pen.Color:= clBlack;
  Canvas.Pen.Width:= 1;
  Canvas.Font.Size:= 10;
  CenterPoint:= Point((ClientWidth div 2), (ClientHeight div 2));
  Dir:= fbRight;
  Arr:= FibonacciNums(20);
  LR:= Rect(CenterPoint.X, CenterPoint.Y, CenterPoint.X+MULTIPLIER, CenterPoint.Y+MULTIPLIER);
  //LR:= Rect(CenterPoint.X, CenterPoint.Y, CenterPoint.X, CenterPoint.Y);

  for X := 0 to Length(Arr)-1 do begin
    Num:= Arr[X];
    Dir:= NextDir(Dir);
    case Dir of
      fbUp: begin
        //Next square on top - right to left
        R.Top:= LR.Top - (Num*MULTIPLIER);
        R.Bottom:= LR.Top;
        R.Left:= LR.Right - (Num*MULTIPLIER);
        R.Width:= (Num*Multiplier);
      end;
      fbLeft: begin
        //Next square on left - top to bottom
        R.Right:= LR.Left;
        R.Left:= LR.Left - (Num*MULTIPLIER);
        R.Top:= LR.Top;
        R.Bottom:= LR.Top + (Num*MULTIPLIER);
      end;
      fbDown: begin
        //Next square on bottom - left to right
        R.Top:= LR.Bottom;
        R.Bottom:= LR.Bottom + (Num*MULTIPLIER);
        R.Left:= LR.Left;
        R.Right:= LR.Left + (Num*MULTIPLIER);
      end;
      fbRight: begin
        //Next square on right - bottom to top
        R.Left:= LR.Right;
        R.Right:= LR.Right + (Num*MULTIPLIER);
        R.Bottom:= LR.Bottom;
        R.Top:= LR.Bottom - (Num*MULTIPLIER);
      end;
    end;
    DoDrawRect;
    DoDrawCurve;
    Log.Lines.Append(Format('%d = %d, %d, %d, %d', [X, R.Left, R.Top, R.Right, R.Bottom]));
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  Invalidate;
end;

end.
