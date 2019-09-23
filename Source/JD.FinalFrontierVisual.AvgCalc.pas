unit JD.FinalFrontierVisual.AvgCalc;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TAverageCalculator = class(TObject)
  private
    FItems: TList<Double>;
    FMaxCount: Integer;
    FValue: Double;
    procedure SetMaxCount(const Value: Integer);
    procedure EnsureMax;
    procedure CalcAverage;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AValue: Double);
    function Value: Double;
    property MaxCount: Integer read FMaxCount write SetMaxCount;
  end;

implementation

{ TAverageCalculator }

constructor TAverageCalculator.Create;
begin
  FMaxCount:= 200;
  FItems:= TList<Double>.Create;
  CalcAverage;
end;

destructor TAverageCalculator.Destroy;
begin
  FItems.Clear;
  FreeAndNil(FItems);
  inherited;
end;

procedure TAverageCalculator.Add(AValue: Double);
begin
  FItems.Add(AValue);
  EnsureMax;
  CalcAverage;
end;

procedure TAverageCalculator.SetMaxCount(const Value: Integer);
begin
  FMaxCount := Value;
  EnsureMax;
  CalcAverage;
end;

procedure TAverageCalculator.CalcAverage;
var
  X: Integer;
begin
  EnsureMax;
  FValue:= 0;
  if FItems.Count > 0 then begin
    for X := 0 to FItems.Count-1 do begin
      FValue:= FValue + FItems[X];
    end;
    FValue:= FValue / FItems.Count;
  end;
end;

function TAverageCalculator.Value: Double;
begin
  Result:= FValue;
end;

procedure TAverageCalculator.EnsureMax;
begin
  while FItems.Count > FMaxCount do begin
    FItems.Delete(0);
  end;
end;

end.
