unit JD.Visuals.Controls;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TJDVisualControls = class;
  TJDVisualControlBase = class;
  TJDVNumberControl = class;
  TJDVButtonControl = class;
  TJDVCheckControl = class;

  TJDVNumberType = (ntInteger, ntFloat);

  TJDVisualControls = class(TObject)
  private
    FItems: TObjectList<TJDVisualControlBase>;
    function GetItem(const Index: Integer): TJDVisualControlBase;
    function GetItemByCaption(const Caption: String): TJDVisualControlBase;
  public
    constructor Create;
    destructor Destroy; override;

    function NewNumberControl(const ACaption: String; const ANumberType: TJDVNumberType = ntInteger;
      const AValue: Currency = 0.0; const AMin: Currency = 0.0; const AMax: Currency = 0.0;
      const ADigits: Integer = 3; const AInterval: Currency = 0.1): TJDVNumberControl;
    function NewButtonControl(const ACaption: String; const AOnClick: TNotifyEvent): TJDVButtonControl;
    function NewCheckControl(const ACaption: String; const AChecked: Boolean): TJDVCheckControl;

    function Count: Integer;
    property Items[const Index: Integer]: TJDVisualControlBase read GetItem;
    property ItemsByCaption[const Caption: String]: TJDVisualControlBase read GetItemByCaption; default;
  end;

  TJDVisualControlBase = class(TObject)
  private
    FOwner: TJDVisualControls;
    FCaption: String;
    procedure SetCaption(const Value: String);
  public
    constructor Create(AOwner: TJDVisualControls); virtual;
    destructor Destroy; override;
    property Caption: String read FCaption write SetCaption;
  end;

  TJDVNumberControl = class(TJDVisualControlBase)
  private
    FNumberType: TJDVNumberType;
    FValue: Currency;
    FMax: Currency;
    FMin: Currency;
    FDigits: Integer;
    FInterval: Currency;
    procedure SetNumberType(const Value: TJDVNumberType);
    procedure SetValue(const Value: Currency);
    procedure SetDigits(const Value: Integer);
    procedure SetMax(const Value: Currency);
    procedure SetMin(const Value: Currency);
    function GetValueInt: Integer;
    procedure SetValueInt(const Value: Integer);
    procedure SetInterval(const Value: Currency);
  public
    constructor Create(AOwner: TJDVisualControls); override;
    destructor Destroy; override;
    property Digits: Integer read FDigits write SetDigits;
    property Interval: Currency read FInterval write SetInterval;
    property NumberType: TJDVNumberType read FNumberType write SetNumberType;
    property Min: Currency read FMin write SetMin;
    property Max: Currency read FMax write SetMax;
    property Value: Currency read FValue write SetValue;
    property ValueInt: Integer read GetValueInt write SetValueInt;
  end;

  TJDVButtonControl = class(TJDVisualControlBase)
  private
    FOnClick: TNotifyEvent;
  public
    constructor Create(AOwner: TJDVisualControls); override;
    destructor Destroy; override;
    procedure Click;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TJDVCheckControl = class(TJDVisualControlBase)
  private
    FChecked: Boolean;
    procedure SetChecked(const Value: Boolean);
  public
    constructor Create(AOwner: TJDVisualControls); override;
    destructor Destroy; override;
    property Checked: Boolean read FChecked write SetChecked;
  end;

implementation

{ TJDVisualControls }

constructor TJDVisualControls.Create;
begin
  FItems:= TObjectList<TJDVisualControlBase>.Create(False);

end;

destructor TJDVisualControls.Destroy;
var
  X: Integer;
begin
  for X := 0 to FItems.Count-1 do
    FItems[X].Free;
  FreeAndNil(FItems);
  inherited;
end;

function TJDVisualControls.Count: Integer;
begin
  Result:= FItems.Count;
end;

function TJDVisualControls.GetItem(const Index: Integer): TJDVisualControlBase;
begin
  Result:= FItems[Index];
end;

function TJDVisualControls.GetItemByCaption(
  const Caption: String): TJDVisualControlBase;
var
  X: Integer;
begin
  Result:= nil;
  for X := 0 to FItems.Count-1 do begin
    if FItems[X].Caption = Caption then begin
      Result:= FItems[X];
      Break;
    end;
  end;
end;

function TJDVisualControls.NewButtonControl(const ACaption: String;
  const AOnClick: TNotifyEvent): TJDVButtonControl;
begin
  Result:= TJDVButtonControl.Create(Self);
  Result.FCaption:= ACaption;
  Result.FOnClick:= AOnClick;
end;

function TJDVisualControls.NewCheckControl(const ACaption: String;
  const AChecked: Boolean): TJDVCheckControl;
begin
  Result:= TJDVCheckControl.Create(Self);
  Result.FCaption:= ACaption;
  Result.FChecked:= AChecked;
end;

function TJDVisualControls.NewNumberControl(const ACaption: String;
  const ANumberType: TJDVNumberType; const AValue, AMin, AMax: Currency;
  const ADigits: Integer; const AInterval: Currency): TJDVNumberControl;
begin
  Result:= TJDVNumberControl.Create(Self);
  Result.FCaption:= ACaption;
  Result.FNumberType:= ANumberType;
  Result.FValue:= AValue;
  Result.FMin:= AMin;
  Result.FMax:= AMax;
  Result.FDigits:= ADigits;
  Result.FInterval:= AInterval;
end;

{ TJDVisualControlBase }

constructor TJDVisualControlBase.Create(AOwner: TJDVisualControls);
begin
  FOwner:= AOwner;
  FOwner.FItems.Add(Self);
end;

destructor TJDVisualControlBase.Destroy;
begin
  inherited;
end;

procedure TJDVisualControlBase.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

{ TJDVNumberControl }

constructor TJDVNumberControl.Create(AOwner: TJDVisualControls);
begin
  inherited;

end;

destructor TJDVNumberControl.Destroy;
begin

  inherited;
end;

function TJDVNumberControl.GetValueInt: Integer;
begin
  Result:= Trunc(FValue);
end;

procedure TJDVNumberControl.SetDigits(const Value: Integer);
begin
  FDigits := Value;
end;

procedure TJDVNumberControl.SetInterval(const Value: Currency);
begin
  FInterval := Value;
end;

procedure TJDVNumberControl.SetMax(const Value: Currency);
begin
  FMax := Value;
end;

procedure TJDVNumberControl.SetMin(const Value: Currency);
begin
  FMin := Value;
end;

procedure TJDVNumberControl.SetNumberType(const Value: TJDVNumberType);
begin
  FNumberType := Value;
end;

procedure TJDVNumberControl.SetValue(const Value: Currency);
begin
  FValue := Value;
end;

procedure TJDVNumberControl.SetValueInt(const Value: Integer);
begin
  FValue:= Value;
end;

{ TJDVButtonControl }

constructor TJDVButtonControl.Create(AOwner: TJDVisualControls);
begin
  inherited;

end;

destructor TJDVButtonControl.Destroy;
begin

  inherited;
end;

procedure TJDVButtonControl.Click;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

{ TJDVCheckControl }

constructor TJDVCheckControl.Create(AOwner: TJDVisualControls);
begin
  inherited;

end;

destructor TJDVCheckControl.Destroy;
begin

  inherited;
end;

procedure TJDVCheckControl.SetChecked(const Value: Boolean);
begin
  FChecked := Value;
end;

end.
