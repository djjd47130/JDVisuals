unit JD.TessellationVisual;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.SyncObjs,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls,
  JD.Graphics, JD.Common;

type
  TTessellationVisual = class;

  TPatternType = (ptCopilot, ptTriangles, ptHexagons, ptSquares, ptOctagons);

  TShapeInfo = record
    Color: TJDColor;
    ColorIndex: Integer;
    ColorDir: Integer;
    Polygon: TArray<TGPPointF>;
    CenterPos: TJDPoint;
    function IsInRect(R: TJDRect): Boolean;
  end;

  TShapeInfoArray = TArray<TShapeInfo>;

  TTessellationVisual = class(TJDVisual)
  private
    FShapes: TShapeInfoArray;
    FShapesLock: TCriticalSection;
    FShapeSize: Single;
    FPatternType: TPatternType;
    FBackground: TBitmap;
    FBackGradStart: TJDAlphaColorRef;
    FBackGradEnd: TJDAlphaColorRef;
    FLineGradStart: TJDAlphaColorRef;
    FLineGradEnd: TJDAlphaColorRef;
    FLineWidth: Single;
    FGradRange: Integer;
    FColorGrad: TArray<TJDColor>;
    procedure ColorsChanged(Sender: TObject);
    procedure SetPatternType(const Value: TPatternType);
    procedure SetShapeSize(const Value: Single);
    procedure Regenerate;
    procedure CreateCopilotMosaicMesh;
    procedure CreateTriangleMesh;
    procedure CreateHexagonMesh;
    procedure CreateSquareMesh;
    function MakeGradBrush: TGPLinearGradientBrush;
    function MakeGradPen(Brush: TGPLinearGradientBrush;
      const Width: Single): TGPPen;
    function MakeShape: TShapeInfo;
    procedure AddShape(AShape: TShapeInfo);
    function MakeCopilotTriangle(Size: Single;
      Rotate: Boolean): TArray<TGPPointF>;
    function MakeHexagon(Size: Single): TArray<TGPPointF>;
    function MakeSquare(Size: Single): TArray<TGPPointF>;
    function MakeTriangle(Size: Single; Rotate: Boolean): TArray<TGPPointF>;
    procedure CreateOctagonMesh;
    function MakeOctagon(Size: Single): TArray<TGPPointF>;
    function MakeDiamond(Size: Single): TArray<TGPPointF>;
    procedure SetGradRange(const Value: Integer);
    procedure SetBackGradEnd(const Value: TJDAlphaColorRef);
    procedure SetBackGradStart(const Value: TJDAlphaColorRef);
    procedure SetLineGradEnd(const Value: TJDAlphaColorRef);
    procedure SetLineGradStart(const Value: TJDAlphaColorRef);
    procedure SetLineWidth(const Value: Single);
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ShapeExistsAt(Shapes: TArray<TShapeInfo>; X, Y: Single): Boolean;

  published
    property PatternType: TPatternType read FPatternType write SetPatternType;
    property ShapeSize: Single read FShapeSize write SetShapeSize;
    property LineWidth: Single read FLineWidth write SetLineWidth;

    property BackGradStart: TJDAlphaColorRef read FBackGradStart write SetBackGradStart;
    property BackGradEnd: TJDAlphaColorRef read FBackGradEnd write SetBackGradEnd;
    property LineGradStart: TJDAlphaColorRef read FLineGradStart write SetLineGradStart;
    property LineGradEnd: TJDAlphaColorRef read FLineGradEnd write SetLineGradEnd;

    property GradRange: Integer read FGradRange write SetGradRange;
  end;

implementation

uses
  System.Math;

function RandomSign: Integer;
begin
  if Random(2) = 0 then
    Result := -1
  else
    Result := 1;
end;

{ TTessellationVisual }

procedure TTessellationVisual.ColorsChanged(Sender: TObject);
begin
  Regenerate;
end;

constructor TTessellationVisual.Create(AOwner: TComponent);
begin
  inherited;
  VisualName := 'Tessellations';
  FPatternType:= TPatternType.ptHexagons;

  FShapesLock:= TCriticalSection.Create;
  FBackground:= TBitmap.Create;

  FLineGradStart:= TJDAlphaColorRef.Create;
  FLineGradEnd:= TJDAlphaColorRef.Create;
  FBackGradStart:= TJDAlphaColorRef.Create;
  FBackGradEnd:= TJDAlphaColorRef.Create;

  FShapeSize:= 42;
  FLineWidth:= 0.2;
  FGradRange:= 200;

  FLineGradStart.Color:= clLime;
  FLineGradStart.Alpha:= 150;

  FLineGradEnd.Color:= clBlack; // $003C0600;
  FLineGradEnd.Alpha:= 0;

  FBackGradStart.Color:= clNavy;

  FBackGradEnd.Color:= clBlack;

  FLineGradStart.OnChange:= ColorsChanged;
  FLineGradEnd.OnChange:= ColorsChanged;
  FBackGradStart.OnChange:= ColorsChanged;
  FBackGradEnd.OnChange:= ColorsChanged;

end;

destructor TTessellationVisual.Destroy;
begin

  FreeAndNil(FBackGradEnd);
  FreeAndNil(FBackGradStart);
  FreeAndNil(FLineGradEnd);
  FreeAndNil(FLineGradStart);
  FreeAndNil(FBackground);
  FreeAndNil(FShapesLock);
  inherited;
end;

procedure TTessellationVisual.CreateControls;
begin
  inherited;

end;

procedure TTessellationVisual.DoPaint;
var
  Graphics: TGPGraphics;
  Brush: TGPBrush;
  GradBrush: TGPLinearGradientBrush;
  Pen: TGPPen;

  procedure DrawBackground;
  begin
    Brush := TGPSolidBrush.Create(MakeColor(255, 0, 0, 0)); // Black background
    try
      var R: TJDRect := TJDRect.Create(0, 0, Thread.Width, Thread.Height);
      Graphics.FillRectangle(Brush, R);
    finally
      Brush.Free;
    end;
  end;

  procedure DrawShapes;
  var
    Shape: TShapeInfo;
    TranslatedPolygon: TArray<TGPPointF>;
    i: Integer;
  begin
    FShapesLock.Enter;
    try
      for Shape in FShapes do
      begin
        // Translate the static polygon based on CenterPos
        SetLength(TranslatedPolygon, Length(Shape.Polygon));
        for i := 0 to High(Shape.Polygon) do
        begin
          TranslatedPolygon[i].X := Shape.Polygon[i].X + Shape.CenterPos.X;
          TranslatedPolygon[i].Y := Shape.Polygon[i].Y + Shape.CenterPos.Y;
        end;

        // Set the color for the shape
        var C: TJDColor := FColorGrad[Shape.ColorIndex];
        Brush := TGPSolidBrush.Create(C.GDIPColor);
        try
          // Fill and draw the translated polygon
          Graphics.FillPolygon(Brush, PGPPointF(@TranslatedPolygon[0]), Length(TranslatedPolygon));
          Graphics.DrawPolygon(Pen, PGPPointF(@TranslatedPolygon[0]), Length(TranslatedPolygon));
        finally
          Brush.Free;
        end;
      end;
    finally
      FShapesLock.Leave;
    end;
  end;

begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    GradBrush := MakeGradBrush;
    try
      Pen := MakeGradPen(GradBrush, FLineWidth);
      try
        DrawBackground;
        DrawShapes;
      finally
        Pen.Free;
      end;
    finally
      GradBrush.Free;
    end;
  finally
    Graphics.Free;
  end;
end;

procedure TTessellationVisual.DoStep;
var
  Shape: TShapeInfo;
begin
  if Length(FShapes) = 0 then
    Regenerate;

  FShapesLock.Enter;
  try
    for var X := 0 to Length(FShapes) - 1 do begin
      Shape := FShapes[X];
      Shape.ColorIndex := Shape.ColorIndex + Shape.ColorDir;
      if (Shape.ColorIndex <= 0) or (Shape.ColorIndex >= High(FColorGrad)) then
        Shape.ColorDir := -Shape.ColorDir;
      Shape.ColorIndex := Max(0, Min(High(FColorGrad), Shape.ColorIndex));
      FShapes[X] := Shape;
    end;
  finally
    FShapesLock.Leave;
  end;
end;

procedure TTessellationVisual.SetGradRange(const Value: Integer);
begin
  FGradRange := Value;
  Regenerate;
end;

procedure TTessellationVisual.SetBackGradEnd(const Value: TJDAlphaColorRef);
begin
  FBackGradEnd.Assign(Value);
  Regenerate;
end;

procedure TTessellationVisual.SetBackGradStart(const Value: TJDAlphaColorRef);
begin
  FBackGradStart.Assign(Value);
  Regenerate;
end;

procedure TTessellationVisual.SetLineGradEnd(const Value: TJDAlphaColorRef);
begin
  FLineGradEnd.Assign(Value);
  Regenerate;
end;

procedure TTessellationVisual.SetLineGradStart(const Value: TJDAlphaColorRef);
begin
  FLineGradStart.Assign(Value);
  Regenerate;
end;

procedure TTessellationVisual.SetLineWidth(const Value: Single);
begin
  FLineWidth := Value;
  Regenerate;
end;

procedure TTessellationVisual.SetPatternType(const Value: TPatternType);
begin
  FPatternType := Value;
  Regenerate;
end;

procedure TTessellationVisual.SetShapeSize(const Value: Single);
begin
  FShapeSize := Value;
  Regenerate;
end;

function TTessellationVisual.MakeGradBrush: TGPLinearGradientBrush;
begin
  Result:= TGPLinearGradientBrush.Create(
    MakePoint(0.0, 0.0),
    MakePoint(Single(Thread.Width), Single(Thread.Height)),
    FLineGradStart.GetJDColor.GDIPColor,
    FLineGradEnd.GetJDColor.GDIPColor
  );
end;

function TTessellationVisual.MakeGradPen(Brush: TGPLinearGradientBrush; const Width: Single): TGPPen;
begin
  Result:= TGPPen.Create(Brush, Width);
end;

procedure TTessellationVisual.Regenerate;
begin
  if not Assigned(Thread) then
    Exit;

  if csLoading in Self.ComponentState then
    Exit;


  FColorGrad:= GenerateColorGradient(FBackGradStart.GetJDColor, FBackGradEnd.GetJDColor, FGradRange);
  //FColorGrad:= GenerateMultiColorGradient([clBlack, clNavy, $00003500], FGradRange);
  //FColorGrad:= GenerateMultiColorGradient([clBlack, clBlack, $00420000, clBlack, clBlack, $00002B00, clBlack, clBlack], FGradRange);
  //FColorGrad:= GenerateMultiColorGradient([clRed, clWhite, clBlue], FGradRange);
  //FColorGrad:= GenerateMultiColorGradient([clRed, clBlack, clWhite, clBlack, clBlue], FGradRange);
  //FColorGrad:= GenerateMultiColorGradient([clBlack, clBlack, clRed, clBlack, clBlack, clWhite, clBlack, clBlack, clBlue, clBlack, clBlack], FGradRange);
  //FColorGrad:= [clRed, clWhite, clBlue];

  FShapesLock.Enter;
  try
    SetLength(FShapes, 0);
    case FPatternType of
      ptCopilot: CreateCopilotMosaicMesh;
      ptTriangles: CreateTriangleMesh;
      ptHexagons: CreateHexagonMesh;
      ptSquares: CreateSquareMesh;
      ptOctagons: CreateOctagonMesh;
    end;
  finally
    FShapesLock.Leave;
  end;
end;

function TTessellationVisual.MakeTriangle(Size: Single; Rotate: Boolean): TArray<TGPPointF>;
begin
  SetLength(Result, 3);
  if Rotate then begin
    Result[0].X := 0;
    Result[0].Y := Size / 2; // Bottom point
    Result[1].X := -Size / 2;
    Result[1].Y := -Size / 2; // Top-left point
    Result[2].X := Size / 2;
    Result[2].Y := -Size / 2; // Top-right point
  end else begin
    Result[0].X := 0;
    Result[0].Y := -Size / 2; // Top point
    Result[1].X := Size / 2;
    Result[1].Y := Size / 2; // Bottom-right point
    Result[2].X := -Size / 2;
    Result[2].Y := Size / 2; // Bottom-left point
  end;
end;

function TTessellationVisual.MakeSquare(Size: Single): TArray<TGPPointF>;
begin
  SetLength(Result, 4);
  Result[0].X := -Size / 2;
  Result[0].Y := -Size / 2; // Top-left
  Result[1].X := Size / 2;
  Result[1].Y := -Size / 2; // Top-right
  Result[2].X := Size / 2;
  Result[2].Y := Size / 2; // Bottom-right
  Result[3].X := -Size / 2;
  Result[3].Y := Size / 2; // Bottom-left
end;

function TTessellationVisual.MakeHexagon(Size: Single): TArray<TGPPointF>;
var
  i: Integer;
  Angle: Double;
begin
  SetLength(Result, 6);
  for i := 0 to 5 do begin
    Angle := DegToRad(60 * i); // Hexagonal angles
    Result[i].X := Size * Cos(Angle);
    Result[i].Y := Size * Sin(Angle);
  end;
end;

function TTessellationVisual.MakeCopilotTriangle(Size: Single; Rotate: Boolean): TArray<TGPPointF>;
begin
  SetLength(Result, 3);
  if Rotate then begin
    Result[0].X := -Size / 2;
    Result[0].Y := -Size / 2; // Top-left
    Result[1].X := Size / 2;
    Result[1].Y := -Size / 2; // Top-right
    Result[2].X := 0;
    Result[2].Y := Size / 2; // Bottom
  end else begin
    Result[0].X := -Size / 2;
    Result[0].Y := Size / 2; // Bottom-left
    Result[1].X := Size / 2;
    Result[1].Y := Size / 2; // Bottom-right
    Result[2].X := 0;
    Result[2].Y := -Size / 2; // Top
  end;
end;

function TTessellationVisual.MakeOctagon(Size: Single): TArray<TGPPointF>;
var
  SideLength, Radius, HalfSize: Single;
begin
  // Calculate the side length and radius based on the total size
  HalfSize := Size / 2;                       // Half the full width/height of the octagon
  SideLength := Size / (1 + Sqrt(2));         // Length of each side
  Radius := HalfSize;                         // Distance from center to any flat edge midpoint

  SetLength(Result, 8);

  // Define the octagon vertices clockwise, starting from the top flat edge
  Result[0].X := -SideLength / 2; Result[0].Y := -Radius;        // Top-left flat edge
  Result[1].X :=  SideLength / 2; Result[1].Y := -Radius;        // Top-right flat edge
  Result[2].X :=  Radius;        Result[2].Y := -SideLength / 2; // Top-right diagonal corner
  Result[3].X :=  Radius;        Result[3].Y :=  SideLength / 2; // Bottom-right diagonal corner
  Result[4].X :=  SideLength / 2; Result[4].Y :=  Radius;        // Bottom-right flat edge
  Result[5].X := -SideLength / 2; Result[5].Y :=  Radius;        // Bottom-left flat edge
  Result[6].X := -Radius;        Result[6].Y :=  SideLength / 2; // Bottom-left diagonal corner
  Result[7].X := -Radius;        Result[7].Y := -SideLength / 2; // Top-left diagonal corner
end;

function TTessellationVisual.MakeDiamond(Size: Single): TArray<TGPPointF>;
var
  HalfSize, AdjustedLength: Single;
begin
  SetLength(Result, 4);

  // NOTE: The reduction by 15% size is a DIRTY HACK because Copilot
  // failed to provide an accurate calculation.

  // Reduce the diamond size by 15%
  HalfSize := Size / 2;
  AdjustedLength := (HalfSize / Sqrt(2)) * 0.85; // Reduce by 15%

  // Define the diamond vertices relative to its center
  Result[0].X := 0;                   Result[0].Y := -AdjustedLength; // Top vertex
  Result[1].X := AdjustedLength;      Result[1].Y := 0;              // Right vertex
  Result[2].X := 0;                   Result[2].Y := AdjustedLength; // Bottom vertex
  Result[3].X := -AdjustedLength;     Result[3].Y := 0;              // Left vertex
end;

function TTessellationVisual.MakeShape: TShapeInfo;
begin
  case FPatternType of
    ptCopilot:    SetLength(Result.Polygon, 3);
    ptTriangles:  SetLength(Result.Polygon, 3);
    ptHexagons:   SetLength(Result.Polygon, 6);
    ptSquares:    SetLength(Result.Polygon, 4);
    ptOctagons:   SetLength(Result.Polygon, 8);
  end;
  Result.ColorDir:= RandomSign;
  Result.ColorIndex:= Random(Length(FColorGrad));
end;

procedure TTessellationVisual.AddShape(AShape: TShapeInfo);
begin
  SetLength(FShapes, Length(FShapes) + 1);
  FShapes[High(FShapes)] := AShape;
end;

procedure TTessellationVisual.CreateCopilotMosaicMesh;
var
  X, Y: Integer;
  Offset: Single;
  Shape: TShapeInfo;
  //Upward: Boolean;
  StaticUpwardTriangle, StaticDownwardTriangle: TArray<TGPPointF>;
begin
  StaticUpwardTriangle := MakeCopilotTriangle(FShapeSize, True);   // Upward triangle
  StaticDownwardTriangle := MakeCopilotTriangle(FShapeSize, False); // Downward triangle

  for Y := 0 to Trunc(Thread.Height / FShapeSize) do begin
    for X := 0 to Trunc(Thread.Width / FShapeSize) do begin
      if (Y mod 2) = 0 then
        Offset := 0
      else
        Offset := FShapeSize / 2;

      Shape := MakeShape;
      if (X + Y) mod 2 = 0 then
        Shape.Polygon := StaticUpwardTriangle
      else
        Shape.Polygon := StaticDownwardTriangle;

      Shape.CenterPos.X := X * FShapeSize + Offset;
      Shape.CenterPos.Y := Y * FShapeSize;

      AddShape(Shape);
    end;
  end;
end;

function TTessellationVisual.ShapeExistsAt(Shapes: TArray<TShapeInfo>; X, Y: Single): Boolean;
var
  Shape: TShapeInfo;
begin
  Result := False;

  // Iterate through the existing shapes
  for Shape in Shapes do
  begin
    // Check if the center position matches the given X and Y coordinates
    if (Shape.CenterPos.X = X) and (Shape.CenterPos.Y = Y) then
    begin
      Result := True; // Shape found at this position
      Exit;
    end;
  end;
end;

procedure TTessellationVisual.CreateHexagonMesh;
var
  X, Y: Integer;
  CenterX, CenterY, HexHeight, HorizontalSpacing{, VerticalSpacing}: Single;
  Shape: TShapeInfo;
  StaticHexagon: TArray<TGPPointF>;
begin
  StaticHexagon := MakeHexagon(FShapeSize);
  HexHeight := FShapeSize * Sqrt(3);        // Height of a hexagon (distance between two flat sides)
  HorizontalSpacing := FShapeSize * 1.5;    // Horizontal center-to-center distance
  //VerticalSpacing := HexHeight * 0.5;       // Vertical spacing for row alignment
  for Y := 0 to Trunc(Thread.Height / HexHeight) + 1 do begin
    for X := 0 to Trunc(Thread.Width / HorizontalSpacing) + 1 do begin
      CenterX := X * HorizontalSpacing;
      CenterY := Y * HexHeight + (X mod 2) * (HexHeight / 2);
      if (CenterX > Thread.Width + FShapeSize) or (CenterY > Thread.Height + FShapeSize) then
        Continue;
      Shape := MakeShape;
      Shape.Polygon := StaticHexagon;
      Shape.CenterPos.X := CenterX;
      Shape.CenterPos.Y := CenterY;
      AddShape(Shape);
    end;
  end;
end;

procedure TTessellationVisual.CreateSquareMesh;
var
  X, Y: Integer;
  Shape: TShapeInfo;
  StaticSquare: TArray<TGPPointF>;
begin
  StaticSquare := MakeSquare(FShapeSize);
  for Y := 0 to Trunc(Thread.Height / FShapeSize) do begin
    for X := 0 to Trunc(Thread.Width / FShapeSize) do begin
      Shape := MakeShape;
      Shape.CenterPos.X := X * FShapeSize + (FShapeSize / 2);
      Shape.CenterPos.Y := Y * FShapeSize + (FShapeSize / 2);
      Shape.Polygon := StaticSquare;
      AddShape(Shape);
    end;
  end;
end;

//NOTE: Almost perfect, has slight Y offset / overlap issue.
procedure TTessellationVisual.CreateTriangleMesh;
var
  X, Y: Integer;
  OffsetX, TriangleHeight: Single;
  Shape: TShapeInfo;
begin
  TriangleHeight := (FShapeSize * Sqrt(3)) / 2;
  OffsetX := -FShapeSize / 2;
  for Y := 0 to Trunc(Thread.Height / TriangleHeight) + 1 do begin
    for X := 0 to Trunc(Thread.Width / (FShapeSize / 2)) + 1 do begin
      Shape := MakeShape;
      if (X + Y) mod 2 = 0 then begin
        // Downward triangle
        Shape.Polygon := MakeTriangle(FShapeSize, True);
        Shape.CenterPos.X := OffsetX + X * (FShapeSize / 2);
        Shape.CenterPos.Y := Y * TriangleHeight;
      end else begin
        // Upward triangle
        Shape.Polygon := MakeTriangle(FShapeSize, False);
        Shape.CenterPos.X := OffsetX + X * (FShapeSize / 2) - (FShapeSize / 2);
        Shape.CenterPos.Y := (Y + 1) * TriangleHeight;
      end;
      AddShape(Shape);
    end;
  end;
end;

procedure TTessellationVisual.CreateOctagonMesh;
var
  X, Y: Integer;
  Size, HalfSize: Single;
  CenterX, CenterY: Single;
  Shape: TShapeInfo;
  StaticOctagon, StaticDiamond: TArray<TGPPointF>;
begin
  // Clear the shape list
  SetLength(FShapes, 0);

  // Define the overall size of the octagon
  Size := FShapeSize; // Full width and height of the octagon
  HalfSize := Size / 2; // Half size of the octagon

  // Create reusable static shapes
  StaticOctagon := MakeOctagon(Size);  // Correct octagon shape
  StaticDiamond := MakeDiamond(Size); // Refined diamond size

  // Populate the octagon grid
  for Y := 0 to Trunc(Thread.Height / Size) + 1 do begin
    for X := 0 to Trunc(Thread.Width / Size) + 1 do begin

      // Calculate the center position of the current octagon
      CenterX := X * Size;
      CenterY := Y * Size;

      // Add the octagon
      Shape := MakeShape;
      Shape.Polygon := StaticOctagon;
      Shape.CenterPos.X := CenterX;
      Shape.CenterPos.Y := CenterY;
      AddShape(Shape);

      // Add the diamond to fill the gaps between octagons
      if (X > 0) and (Y > 0) then begin
        Shape := MakeShape;
        Shape.Polygon := StaticDiamond;
        Shape.CenterPos.X := CenterX - HalfSize;
        Shape.CenterPos.Y := CenterY - HalfSize;
        AddShape(Shape);
      end;

    end;
  end;
end;

{ TShapeInfo }

function TShapeInfo.IsInRect(R: TJDRect): Boolean;
var
  Point: TJDPoint;
begin
  // Default to not being in the rectangle
  Result := False;

  //TODO: Needs to account for CurrentPos!!!

  // Iterate through each vertex of the shape's polygon
  for Point in Polygon do begin
    // Check if any point is contained within the rectangle
    if R.ContainsPoint(Point) then begin
      Result := True; // If any point is inside, return True
      Exit;
    end;
  end;
end;

end.
