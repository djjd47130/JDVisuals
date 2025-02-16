unit JD.ChessboardVisual;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

type

  TNumArray = array of Currency;

  TChessboardVisual = class(TJDVisual)
  private
    FPen: TGPPen;
    FBrush: TGPSolidBrush;
    //FColWidths: TNumArray;
    //FRowHeights: TNumArray;
    FColShift: Currency;
    FRowShift: Currency;
    FColShiftDir: Currency;
    FRowShiftDir: Currency;
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function ColCount: Integer;
    function RowCount: Integer;
    function ColWidth: Currency;
    function RowHeight: Currency;
    function GetCellRect(const ACol, ARow: Integer): TGPRectF;
    function CellColor(const ACol, ARow: Integer): TColor;

  end;

implementation

{ TChessboardVisual }

constructor TChessboardVisual.Create;
begin
  inherited;
  VisualName:= 'Chessboard';
  FPen:= TGPPen.Create(MakeColor(clSkyBlue));
  FPen.SetWidth(7.0);
  FPen.SetStartCap(LineCap.LineCapRound);
  FPen.SetEndCap(LineCap.LineCapRound);
  FBrush:= TGPSolidBrush.Create(MakeColor(clWhite));
  FColShiftDir:= 0.27;
  FRowShiftDir:= 0.21;
end;

destructor TChessboardVisual.Destroy;
begin
  FreeAndNil(FBrush);
  FreeAndNil(FPen);
  inherited;
end;

procedure TChessboardVisual.CreateControls;
begin

end;

function TChessboardVisual.ColCount: Integer;
begin
  Result:= 8;
end;

function TChessboardVisual.RowCount: Integer;
begin
  Result:= 8;
end;

function TChessboardVisual.RowHeight: Currency;
begin
  Result:= Thread.Height / RowCount;
end;

function TChessboardVisual.ColWidth: Currency;
begin
  Result:= Thread.Width / ColCount;
end;

function TChessboardVisual.GetCellRect(const ACol, ARow: Integer): TGPRectF;
begin
  case ACol of
    0,2,4,6: begin
      Result.X:= (ACol*ColWidth)+FColShift;
      Result.Width:= ColWidth - (FColShift*2);
    end;
    else begin
      Result.X:= (ACol*ColWidth)-FColShift;
      Result.Width:= ColWidth + (FColShift*2);
    end;
  end;
  case ARow of
    0,2,4,6: begin
      Result.Y:= (ARow*RowHeight)+FRowShift;
      Result.Height:= RowHeight - (FRowShift*2);
    end;
    else begin
      Result.Y:= (ARow*RowHeight)-FRowShift;
      Result.Height:= RowHeight + (FRowShift*2);
    end;
  end;
end;

function TChessboardVisual.CellColor(const ACol, ARow: Integer): TColor;
begin
  case ACol of
    0,2,4,6: begin
      if (ARow mod 2) = 0 then begin
        Result:= clNavy;
      end else begin
        Result:= clBlue;
      end;
    end;
    else begin
      if (ARow mod 2) = 0 then begin
        Result:= clBlue;
      end else begin
        Result:= clNavy;
      end;
    end;
  end;
end;

procedure TChessboardVisual.DoStep;
const
  SHIFT_AMT = 12;
begin
  if FColShift <= -SHIFT_AMT then
    FColShiftDir:= PosOf(FColShiftDir);
  if FColShift >= SHIFT_AMT then
    FColShiftDir:= NegOf(FColShiftDir);

  if FRowShift <= -SHIFT_AMT then
    FRowShiftDir:= PosOf(FRowShiftDir);
  if FRowShift >= SHIFT_AMT then
    FRowShiftDir:= NegOf(FRowShiftDir);

  FColShift:= FColShift + FColShiftDir;
  FRowShift:= FRowShift + FRowShiftDir;

end;

procedure TChessboardVisual.DoPaint;
var
  X, Y: Integer;
  R: TGPRectF;
begin
  for X := 0 to ColCount-1 do begin
    for Y := 0 to RowCount-1 do begin
      FBrush.SetColor(MakeColor(CellColor(X, Y)));
      R:= GetCellRect(X, Y);
      GPCanvas.FillRectangle(FBrush, R);
    end;
  end;
end;

initialization
  Visuals.RegisterVisualClass(TChessboardVisual);
end.
