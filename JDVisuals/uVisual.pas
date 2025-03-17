unit uVisual;

(*
  JD Visuals - Visualization engine for Delphi
  by Jerry Dodge

  OpenSource on GitHub: https://github.com/djjd47130/JDVisuals

  NOTE: This project makes use of the JEDI Code Library for Delphi.

  This application displays various different visuals based on customized
  visual code. There's a primary component using a thread which is used to
  encapsulate the animation of any given visual, and then inherited objects
  which actually implement each possible visualization.

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
  When I was using Single or Double, accuracy was terrible, and leaving it
  running overnight caused it to go all out of whack. But since
  Currency is technically an integer with the decimal offset by 4 digits,
  it naturally has integer precision.

*)

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JD.Visuals, JD.Visuals.Controls, JD.Visuals.Utils,
  VisualControls, System.Actions, Vcl.ActnList,
  JD.RaindropsVisual,
  JD.FibonacciVisual,
  JD.FinalFrontierVisual,
  JD.SpiralOutVisual,
  RzButton,
  Vcl.Menus, Vcl.Mask, RzEdit, RzCmboBx, JD.TessellationVisual;
type

  TfrmVisual = class(TForm)
    tmrMain: TTimer;
    pTop: TPanel;
    Panel1: TPanel;
    cboVisual: TComboBox;
    Label1: TLabel;
    btnFullScreen: TButton;
    Acts: TActionList;
    actFullScreen: TAction;
    View: TJDVisualView;
    FibonacciVisual1: TFibonacciVisual;
    FinalFrontierVisual1: TFinalFrontierVisual;
    SpiralOutVisual1: TSpiralOutVisual;
    popFullScreen: TPopupMenu;
    mFullCurrent: TMenuItem;
    mFullMain: TMenuItem;
    mFullAll: TMenuItem;
    RaindropVisual1: TRaindropVisual;
    TessellationVisual1: TTessellationVisual;
    procedure tmrMainTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pTopExit(Sender: TObject);
    procedure cboVisualClick(Sender: TObject);
    procedure btnFullScreenClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mFullAllClick(Sender: TObject);
  private
    FControls: TVisualControlPanel;
    procedure PopulateVisualizations;
    procedure QueryVisuals(AStrings: TStrings);
    procedure SetFullScreen;
    procedure LeaveFullScreen;
  public
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
  FControls:= TVisualControlPanel.Create(pTop);
  FControls.Parent:= pTop;
  FControls.Align:= alClient;
  FControls.Visuals:= View;
  ShowControls(False);
  PopulateVisualizations;
  View.Align:= alClient;
end;

procedure TfrmVisual.SetFullScreen;
var
  M: TMonitor;
begin
  Self.BorderStyle:= bsNone;
  Self.FormStyle:= TFormStyle.fsStayOnTop;
  //Screen.Cursor:= crNone;

  if mFullCurrent.Checked then begin
    //Full screen to current monitor...
    M:= Screen.MonitorFromWindow(Self.Handle, mdNearest);
    Left:= M.Left;
    Top:= M.Top;
    Width:= M.Width;
    Height:= M.Height;
  end else
  if mFullMain.Checked then begin
    //Full screen to main monitor...
    Self.Left:= 0;
    Self.Width:= Screen.Width;
    Self.Top:= 0;
    Self.Height:= Screen.Height;
  end else
  if mFullAll.Checked then begin
    //Full screen to all monitors...
    Self.Left:= Screen.DesktopLeft;
    Self.Top:= Screen.DesktopTop;
    Self.Width:= Screen.DesktopWidth;
    Self.Height:= Screen.DesktopHeight;
  end;

  actFullScreen.Caption:= 'Exit Full Screen';
end;

procedure TfrmVisual.LeaveFullScreen;
begin
  Self.BorderStyle:= bsSizeable;
  Self.FormStyle:= TFormStyle.fsNormal;
  Self.WindowState:= wsNormal;
  Self.WindowState:= wsMaximized;
  //Screen.Cursor:= crDefault;
  actFullScreen.Caption:= 'Enter Full Screen';
end;

procedure TfrmVisual.btnFullScreenClick(Sender: TObject);
begin
  case Self.BorderStyle of
    bsNone: begin
      LeaveFullScreen;
    end;
    bsSizeable: begin
      SetFullScreen;
    end;
  end;
  //TODO: Reset visual?

end;

procedure TfrmVisual.QueryVisuals(AStrings: TStrings);
var
  I: Integer;
  Component: TComponent;
begin
  AStrings.Clear;
  if Assigned(AStrings) then begin
    for I := 0 to Self.ComponentCount - 1 do begin
      Component := Self.Components[I];
      if Component.InheritsFrom(TJDVisual) then begin
        var N: String:= TJDVisual(Component).VisualName;
        AStrings.AddObject(N, Component);
      end;
    end;
  end;
end;

procedure TfrmVisual.cboVisualClick(Sender: TObject);
var
  V: TJDVisual;
begin
  V:= nil;
  try
    if cboVisual.CanFocus then
      cboVisual.SetFocus;

    //View.VisualIndex:= cboVisual.ItemIndex;

    V:= TJDVisual(cboVisual.Items.Objects[cboVisual.ItemIndex]);
    View.Visual:= V;

    FControls.CreateControls;
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

procedure TfrmVisual.mFullAllClick(Sender: TObject);
begin
  TMenuItem(Sender).Checked:= True;
  SetFullScreen;
end;

procedure TfrmVisual.PopulateVisualizations;
var
  X: Integer;
begin
  QueryVisuals(cboVisual.Items);
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
