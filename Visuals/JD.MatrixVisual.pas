unit JD.MatrixVisual;

(*
  IMPORTANT NOTE:
  This visual is in raw beginning stages, and is far from ready. This visual
  will simulate the "Matrix" green characters falling down the screen and
  leaving a trail of other characters...

  BUG: Frequently freezing and forcing me to kill the process...

*)

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.Types,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

type
  TStringArray = array of String;

  TMatrixChar = record
    Char: String;
    XPos: Currency;
    YPos: Currency;
    SubChars: TStringArray;
  end;

  TMatrixChars = array of TMatrixChar;

  TMatrixVisual = class(TJDVisual)
  private
    FFontWidth: Integer;
    FFontHeight: Integer;
    FTextBrush: TGPSolidBrush;
    FChars: TMatrixChars;
    function FontFilename: String;
    function SpawnChar: TMatrixChar;
    function ColWidth: Integer;
    function RowHeight: Integer;
    function ColCount: Integer;
    function RowCount: Integer;
    procedure EnsureCharCount;
    function RandomChar: String;
    procedure EnsureFontSize;
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
    procedure SetThread(const Value: TJDVisualsThread); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function CharCount: Integer;
    function TrailSize: Integer;
    function FontSize: Integer;
  end;

implementation

uses
  System.IOUtils, System.Math;

{ TMatrixVisual }

constructor TMatrixVisual.Create;
var
  X: Integer;
begin
  inherited;
  VisualName:= 'Matrix';

  FTextBrush := TGPSolidBrush.Create(MakeColor(50, 255, 50));

  AddFontResource(PChar(FontFilename)) ;
  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

  for X := 0 to Length(FChars)-1 do begin
    FChars[X].YPos:= 10000; //Forces it to respawn on next step
  end;

  EnsureFontSize;

end;

destructor TMatrixVisual.Destroy;
begin
  SetLength(FChars, 0);

  RemoveFontResource(PChar(FontFilename)) ;
  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

  FreeAndNil(FTextBrush);

  inherited;
end;

procedure TMatrixVisual.CreateControls;
begin
  Controls.NewNumberControl('Char Count', ntInteger, 170, 10, 1000, 0, 10);
  Controls.NewNumberControl('Trail Size', ntInteger, 27, 0, 50, 0, 1);
  Controls.NewNumberControl('Font Size',  ntInteger, 27, 2, 100, 0, 1);

end;

function TMatrixVisual.CharCount: Integer;
begin
  Result:= TJDVNumberControl(Controls['Char Count']).ValueInt;
end;

function TMatrixVisual.TrailSize: Integer;
begin
  Result:= TJDVNumberControl(Controls['Trail Size']).ValueInt;
end;

function TMatrixVisual.FontSize: Integer;
begin
  Result:= TJDVNumberControl(Controls['Font Size']).ValueInt;
end;

function TMatrixVisual.RandomChar: String;
begin
  if RandomRange(1, 2) = 1 then begin
    Result:= Chr(RandomRange(33,63));
  end else begin
    Result:= Chr(RandomRange(91,126));
  end;
end;

procedure TMatrixVisual.EnsureCharCount;
var
  X: Integer;
begin
  for X := 1 to 10 do begin
    if CharCount = Length(FChars) then Break;
    if CharCount > Length(FChars) then begin
      SetLength(FChars, Length(FChars)+1);
      FChars[Length(FChars)-1]:= SpawnChar;
    end else
    if CharCount < Length(FChars) then begin
      SetLength(FChars, Length(FChars)-1);
    end;
  end;
  for X := 0 to Length(FChars)-1 do begin
    if Length(FChars[X].SubChars) <> TrailSize then
      SetLength(FChars[X].SubChars, TrailSize);
  end;
end;

procedure TMatrixVisual.EnsureFontSize;
var
  R: TRect;
begin
  if Assigned(Canvas) then begin
    Canvas.Font.Name:= 'Matrix Code NFI';
    Canvas.Font.Size:= FontSize;
    R:= Rect(0, 0, 10, 10);
    DrawText(Canvas.Handle, 'o', 1, R, DT_SINGLELINE or DT_CALCRECT);
    FFontWidth:= R.Width;
    FFontHeight:= R.Height;
  end;
  if FFontWidth = 0 then FFontWidth:= 1;
  if FFontHeight = 0 then FFontHeight:= 1;
end;

function TMatrixVisual.FontFilename: String;
begin
  Result:= ExtractFilePath(ParamStr(0));
  Result:= TPath.Combine(Result, 'matrix code nfi.ttf');
end;

function TMatrixVisual.ColWidth: Integer;
begin
  Result:= FFontWidth;
  if Result = 0 then
    Result:= 1;
end;

function TMatrixVisual.RowHeight: Integer;
begin
  Result:= FFontHeight div 2;
  if Result = 0 then
    Result:= 1;
end;

function TMatrixVisual.ColCount: Integer;
begin
  Result:= Thread.Width div ColWidth;
end;

function TMatrixVisual.RowCount: Integer;
begin
  Result:= Thread.Height div RowHeight;
end;

procedure TMatrixVisual.SetThread(const Value: TJDVisualsThread);
begin
  inherited;
  EnsureCharCount;
  EnsureFontSize;
end;

function TMatrixVisual.SpawnChar: TMatrixChar;
var
  X: Integer;
begin
  Result.Char:= RandomChar;
  Result.XPos:= Random(ColCount);
  Result.YPos:= -Random(RowCount+20);
  SetLength(Result.SubChars, TrailSize);
  for X := 0 to Length(Result.SubChars)-1 do begin
    Result.SubChars[X]:= ' ';
  end;
end;

procedure TMatrixVisual.DoStep;
var
  X: Integer;
  Y: Integer;
begin
  EnsureCharCount;
  EnsureFontSize;
  for X := 0 to Length(FChars)-1 do begin
    FChars[X].YPos:= FChars[X].YPos + 1;
    if FChars[X].YPos > RowCount+TrailSize+1 then begin
      FChars[X]:= SpawnChar;
    end else begin
      if Length(FChars[X].SubChars) > 0 then begin
        for Y := Length(FChars[X].SubChars)-1 downto 1 do begin
          FChars[X].SubChars[Y]:= FChars[X].SubChars[Y-1];
        end;
        FChars[X].SubChars[0]:= FChars[X].Char;
        FChars[X].Char:= RandomChar;
      end;
    end;
  end;
  Sleep(70);
end;

procedure TMatrixVisual.DoPaint;
var
  X, Y: Integer;
  MC: TMatrixChar;
  Pt: TGPPointF;
  lf: LOGFONT;
  Fnt: TGPFont;
begin
  lf:= Default(LOGFONT);
  lf.lfHeight:= FontSize;
  lf.lfCharSet:= DEFAULT_CHARSET;
  lf.lfFaceName:= 'Matrix Code NFI';
  Fnt:= TGPFont.Create(Canvas.Handle, PLogFont(@lf));
  try
    EnsureFontSize;
    for X := 0 to Length(FChars)-1 do begin
      MC:= FChars[X];
      Pt.X:= MC.XPos * ColWidth;
      Pt.Y:= MC.YPos * RowHeight;
      FTextBrush.SetColor(MakeColor(200, 200, 200));
      GPCanvas.DrawString(MC.Char, Length(MC.Char), Fnt, Pt, nil, FTextBrush);
      for Y := 0 to Length(MC.SubChars)-1 do begin
        //TODO: Draw trailing chars with darker color and fade...
        Pt.Y:= Pt.Y - RowHeight;
        FTextBrush.SetColor(MakeColor(0, 255-(Y*(255 div TrailSize)), 0));
        GPCanvas.DrawString(MC.SubChars[Y], Length(MC.SubChars[Y]), Fnt, Pt, nil, FTextBrush);
      end;
    end;
  finally
    FreeAndNil(Fnt);
  end;
end;

initialization
  Visuals.RegisterVisualClass(TMatrixVisual);
end.
