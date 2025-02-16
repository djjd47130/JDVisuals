unit VisualControls;

(*
  Visual Controls - Encapsulates UI panel for user to modify visual controls
*)

interface

uses
  System.Classes,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.StdCtrls, Vcl.Mask,
  JvExMask, JvSpin, Vcl.WinXCtrls,
  JD.Visuals,
  JD.Visuals.Controls;

type
  TVisualControlPanel = class(TCustomPanel)
  private
    FVisuals: TJDVisualView;
    procedure NumberControlChanged(Sender: TObject);
    procedure CheckControlClicked(Sender: TObject);
    procedure SetVisuals(const Value: TJDVisualView);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DestroyControls;
    procedure CreateControls;
  published
    property Align;
    property AlignWithMargins;
    property Anchors;
    property Visuals: TJDVisualView read FVisuals write SetVisuals;
  end;

function CreateTopPanel(AOwner: TWinControl): TPanel;
function CreateNumberControl(AOwner: TWinControl; AControl: TJDVNumberControl; OnChanged: TNotifyEvent; const Index: Integer): TPanel;
function CreateButtonControl(AOwner: TWinControl; AControl: TJDVButtonControl; const Index: Integer): TPanel;
function CreateCheckControl(AOwner: TWinControl; AControl: TJDVCheckControl; OnChanged: TNotifyEvent; const Index: Integer): TPanel;

implementation

function CreateTopPanel(AOwner: TWinControl): TPanel;
begin
  Result:= TPanel.Create(AOwner);
  Result.Parent:= AOwner;
  Result.Align:= alLeft;
  Result.Left:= AOwner.Width;
  Result.BevelOuter:= bvNone;
  Result.Width:= 80;
end;

function CreateNumberControl(AOwner: TWinControl; AControl: TJDVNumberControl; OnChanged: TNotifyEvent; const Index: Integer): TPanel;
var
  Lbl: TLabel;
  Edt: TJvSpinEdit;
begin
  Result:= CreateTopPanel(AOwner);
  Result.Tag:= Index;

  Edt:= TJvSpinEdit.Create(Result);
  Edt.Parent:= Result;
  Edt.Align:= alBottom;
  Edt.AlignWithMargins:= True;
  Edt.Font.Size:= 10;
  Edt.ButtonKind:= bkStandard;
  Edt.Height:= 24;
  case AControl.NumberType of
    ntInteger: Edt.ValueType:= TValueType.vtInteger;
    ntFloat: Edt.ValueType:= TValueType.vtFloat;
  end;
  Edt.MinValue:= AControl.Min;
  Edt.MaxValue:= AControl.Max;
  Edt.Decimal:= AControl.Digits;
  Edt.Increment:= AControl.Interval;
  Edt.Value:= AControl.Value;
  Edt.Tag:= Index;
  Edt.OnChange:= OnChanged;

  Lbl:= TLabel.Create(Result);
  Lbl.Parent:= Result;
  Lbl.Align:= alClient;
  Lbl.AlignWithMargins:= True;
  Lbl.Font.Style:= [fsBold];
  Lbl.Font.Color:= clWhite;
  Lbl.Caption:= AControl.Caption;
  Lbl.Margins.Top:= 0;
  Lbl.Tag:= Index;

end;

function CreateButtonControl(AOwner: TWinControl; AControl: TJDVButtonControl;
  const Index: Integer): TPanel;
var
  Btn: TButton;
begin
  Result:= CreateTopPanel(AOwner);
  Result.Tag:= Index;

  Btn:= TButton.Create(Result);
  Btn.Parent:= Result;
  Btn.Align:= alClient;
  Btn.AlignWithMargins:= True;
  Btn.Caption:= AControl.Caption;
  Btn.OnClick:= AControl.OnClick;
  Btn.Tag:= Index;

end;

function CreateCheckControl(AOwner: TWinControl; AControl: TJDVCheckControl; OnChanged: TNotifyEvent;  const Index: Integer): TPanel;
var
  Chk: TToggleSwitch;
  Lbl: TLabel;
begin
  Result:= CreateTopPanel(AOwner);
  Result.Tag:= Index;
  Result.Width:= 120;
  Result.Font.Color:= clWhite;

  Chk:= TToggleSwitch.Create(Result);
  Chk.Parent:= Result;
  Chk.Align:= alBottom;
  Chk.Font.Color:= clWhite;
  Chk.Font.Style:= [fsBold];
  Chk.AlignWithMargins:= True;
  if AControl.Checked then
    Chk.State:= tssOn
  else
    Chk.State:= tssOff;
  Chk.OnClick:= OnChanged;
  Chk.Tag:= Index;

  Lbl:= TLabel.Create(Result);
  Lbl.Parent:= Result;
  Lbl.Align:= alClient;
  Lbl.AlignWithMargins:= True;
  Lbl.Font.Style:= [fsBold];
  Lbl.Font.Color:= clWhite;
  Lbl.Caption:= AControl.Caption;
  Lbl.Margins.Top:= 0;
  Lbl.Tag:= Index;

end;

{ TVisualControlPanel }

constructor TVisualControlPanel.Create(AOwner: TComponent);
begin
  inherited;
  Self.BevelOuter:= bvNone;
  Self.ParentColor:= True;
end;

destructor TVisualControlPanel.Destroy;
begin
  DestroyControls;
  inherited;
end;

procedure TVisualControlPanel.CreateControls;
var
  X: Integer;
  Ctrls: TJDVisualControls;
begin
  DestroyControls;
  if FVisuals.Visual <> nil then begin
    Ctrls:= FVisuals.Visual.Controls;
    for X := 0 to Ctrls.Count-1 do begin

      if Ctrls.Items[X] is TJDVNumberControl then begin
        CreateNumberControl(Self, TJDVNumberControl(Ctrls.Items[X]), NumberControlChanged, X);
      end;

      if Ctrls.Items[X] is TJDVButtonControl then begin
        CreateButtonControl(Self, TJDVButtonControl(Ctrls.Items[X]), X);
      end;

      if Ctrls.Items[X] is TJDVCheckControl then begin
        CreateCheckControl(Self, TJDVCheckControl(Ctrls.Items[X]), CheckControlClicked, X);
      end;

    end;
  end;
end;

procedure TVisualControlPanel.DestroyControls;
var
  X: Integer;
begin
  for X := Self.ControlCount-1 downto 0 do begin
    if Self.Controls[X].Tag >= 0 then
      Self.Controls[X].Free;
  end;
end;

procedure TVisualControlPanel.CheckControlClicked(Sender: TObject);
var
  CC: TJDVCheckControl;
  Chk: TToggleSwitch;
begin
  if FVisuals.Visual <> nil then begin
    Chk:= TToggleSwitch(Sender);
    CC:= TJDVCheckControl(FVisuals.Visual.Controls.Items[Chk.Tag]);
    CC.Checked:= Chk.State = tssOn;
  end;
end;

procedure TVisualControlPanel.NumberControlChanged(Sender: TObject);
var
  NC: TJDVNumberControl;
  Edt: TJvSpinEdit;
begin
  if FVisuals.Visual <> nil then begin
    Edt:= TJvSpinEdit(Sender);
    NC:= TJDVNumberControl(FVisuals.Visual.Controls.Items[Edt.Tag]);
    NC.Value:= Edt.Value;
  end;
end;

procedure TVisualControlPanel.SetVisuals(const Value: TJDVisualView);
begin
  FVisuals := Value;
end;

end.
