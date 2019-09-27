unit uVisual;

(*
  JD Visuals - Visualization engine
  by Jerry Dodge

  NOTE: This project makes use of the JEDI Code Library for Delphi.

  OpenSource on GitHub: https://github.com/djjd47130/JDVisuals

  This application displays various different visuals based on customized
  visual code. There's a primary thread which is used to encapsulate the
  animation of any given visual, and then inherited objects which actually
  implement each possible visualization.

  Each visual is implemented in its own unit - for example JD.SpiralOutVisual.
  Each visual also automatically registers itself in a global list which can
  be used to populate a menu for the user to pick from. Each visual object
  is also automatically created within this global list, so you don't need
  to create your own instance.

  Create just one instance of the thread. At this time you also instruct it
  to which canvas it is to draw to. Assign a visual by an instance of any
  TJDVisual, as found in the global visual list, to the `Visual` property.

  Create your own visualization by creating a new unit and inheriting
  `TJDVisual` from `JD.Visuals`. Observe the code of existing visuals
  as a base for making your own. The main important things are:
  - You must override DoStep to make actual movements and advancements in animation
  - You must override DoPaint to draw the visual to the canvas as one frame
  - You can optionally override CreateControls if you wish to add user control
  - You must register this class via unit initialization

  Note that I use the "Currency" type often for floats, due to its rounding.

*)

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  JD.Visuals, JD.Visuals.Controls, JD.Visuals.Utils,
  Vcl.StdCtrls, Vcl.Mask, JvExMask, JvSpin, Vcl.WinXCtrls;

type
  TfrmVisual = class(TForm)
    tmrMain: TTimer;
    pTop: TPanel;
    Panel1: TPanel;
    cboVisual: TComboBox;
    Label1: TLabel;
    btnFullScreen: TButton;
    View: TJDVisualView;
    procedure tmrMainTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pTopExit(Sender: TObject);
    procedure cboVisualClick(Sender: TObject);
    procedure btnFullScreenClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    function CreateNumberControl(AControl: TJDVNumberControl; const Index: Integer): TPanel;
    function CreateButtonControl(AControl: TJDVButtonControl; const Index: Integer): TPanel;
    function CreateTopPanel: TPanel;
    procedure NumberControlChanged(Sender: TObject);
    procedure CheckControlClicked(Sender: TObject);
    procedure PopulateVisualizations;
    function CreateCheckControl(AControl: TJDVCheckControl;
      const Index: Integer): TPanel;
  public
    procedure DestroyControls;
    procedure CreateControls;
    procedure ShowControls(const AShow: Boolean = True);
  end;

var
  frmVisual: TfrmVisual;

implementation

{$R *.dfm}

procedure TfrmVisual.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:= True;
  {$ENDIF}
  WindowState:= wsMaximized;
  Show;
  BringToFront;
  Application.ProcessMessages;
  Randomize;
  ShowControls(False);
  PopulateVisualizations;
end;

function TfrmVisual.CreateTopPanel: TPanel;
begin
  Result:= TPanel.Create(pTop);
  Result.Parent:= pTop;
  Result.Align:= alLeft;
  Result.Left:= pTop.Width;
  Result.BevelOuter:= bvNone;
  Result.Width:= 80;
end;

function TfrmVisual.CreateNumberControl(AControl: TJDVNumberControl; const Index: Integer): TPanel;
var
  Lbl: TLabel;
  Edt: TJvSpinEdit;
begin
  Result:= CreateTopPanel;
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
  Edt.OnChange:= NumberControlChanged;

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

function TfrmVisual.CreateButtonControl(AControl: TJDVButtonControl;
  const Index: Integer): TPanel;
var
  Btn: TButton;
begin
  Result:= CreateTopPanel;
  Result.Tag:= Index;

  Btn:= TButton.Create(Result);
  Btn.Parent:= Result;
  Btn.Align:= alClient;
  Btn.AlignWithMargins:= True;
  Btn.Caption:= AControl.Caption;
  Btn.OnClick:= AControl.OnClick;
  Btn.Tag:= Index;

end;

function TfrmVisual.CreateCheckControl(AControl: TJDVCheckControl; const Index: Integer): TPanel;
var
  Chk: TToggleSwitch;
  Lbl: TLabel;
begin
  Result:= CreateTopPanel;
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
  Chk.OnClick:= CheckControlClicked;
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

procedure TfrmVisual.CreateControls;
var
  X: Integer;
  Ctrls: TJDVisualControls;
begin
  DestroyControls;
  if View.Visual <> nil then begin
    Ctrls:= View.Visual.Controls;
    for X := 0 to Ctrls.Count-1 do begin

      if Ctrls.Items[X] is TJDVNumberControl then begin
        CreateNumberControl(TJDVNumberControl(Ctrls.Items[X]), X);
      end;

      if Ctrls.Items[X] is TJDVButtonControl then begin
        CreateButtonControl(TJDVButtonControl(Ctrls.Items[X]), X);
      end;

      if Ctrls.Items[X] is TJDVCheckControl then begin
        CreateCheckControl(TJDVCheckControl(Ctrls.Items[X]), X);
      end;

    end;
  end;
end;

procedure TfrmVisual.DestroyControls;
var
  X: Integer;
begin
  for X := pTop.ControlCount-1 downto 0 do begin
    if pTop.Controls[X].Tag >= 0 then
      pTop.Controls[X].Free;
  end;
end;

procedure TfrmVisual.NumberControlChanged(Sender: TObject);
var
  NC: TJDVNumberControl;
  Edt: TJvSpinEdit;
begin
  if View.Visual <> nil then begin
    Edt:= TJvSpinEdit(Sender);
    NC:= TJDVNumberControl(View.Visual.Controls.Items[Edt.Tag]);
    NC.Value:= Edt.Value;
  end;
end;

procedure TfrmVisual.CheckControlClicked(Sender: TObject);
var
  CC: TJDVCheckControl;
  Chk: TToggleSwitch;
begin
  if View.Visual <> nil then begin
    Chk:= TToggleSwitch(Sender);
    CC:= TJDVCheckControl(View.Visual.Controls.Items[Chk.Tag]);
    CC.Checked:= Chk.State = tssOn;
  end;
end;

procedure TfrmVisual.btnFullScreenClick(Sender: TObject);
begin
  case Self.BorderStyle of
    bsNone: begin
      Self.BorderStyle:= bsSizeable;
      Self.FormStyle:= TFormStyle.fsNormal;
      Self.WindowState:= wsNormal;
      Self.WindowState:= wsMaximized;
      btnFullScreen.Caption:= 'Enter Full Screen';
    end;
    bsSizeable: begin
      Self.BorderStyle:= bsNone;
      Self.FormStyle:= TFormStyle.fsStayOnTop;
      Self.Left:= 0;
      Self.Width:= Screen.Width;
      Self.Top:= 0;
      Self.Height:= Screen.Height;
      btnFullScreen.Caption:= 'Exit Full Screen';
    end;
  end;
end;

procedure TfrmVisual.cboVisualClick(Sender: TObject);
begin
  try
    if cboVisual.CanFocus then
      cboVisual.SetFocus;
    View.VisualIndex:= cboVisual.ItemIndex;
    Self.CreateControls;
  except
    //Swallow exception - TODO
  end;
end;

procedure TfrmVisual.tmrMainTimer(Sender: TObject);
begin
  Invalidate;
end;

procedure TfrmVisual.ViewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Y < pTop.Height then
    ShowControls
  else
    ShowControls(False);
end;

procedure TfrmVisual.FormResize(Sender: TObject);
begin
  pTop.Left:= 0;
  pTop.Width:= ClientWidth;
end;

procedure TfrmVisual.PopulateVisualizations;
var
  X: Integer;
begin
  cboVisual.Items.Clear;
  for X := 0 to Visuals.Count-1 do begin
    cboVisual.Items.Add(Visuals[X].VisualName);
  end;
  if cboVisual.Items.Count > 0 then begin
    cboVisual.ItemIndex:= 0;
    cboVisualClick(nil);
  end;
end;

procedure TfrmVisual.pTopExit(Sender: TObject);
begin
  ShowControls(False);
end;

procedure TfrmVisual.ShowControls(const AShow: Boolean);
begin
  if AShow then
    pTop.Top:= 0
  else begin
    pTop.Top:= -pTop.Height;
  end;
end;

end.
