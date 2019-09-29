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

*)

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JD.Visuals, JD.Visuals.Controls, JD.Visuals.Utils,
  VisualControls;

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
    FControls: TVisualControlPanel;
    procedure PopulateVisualizations;
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
