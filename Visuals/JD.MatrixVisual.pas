unit JD.MatrixVisual;

(*
  IMPORTANT NOTE:
  This visual is in raw beginning stages, and is far from ready. This visual
  will simulate the "Matrix" green characters falling down the screen and
  leaving a trail of other characters...
*)

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals, JD.Visuals.Utils, JD.Visuals.Controls;

type

  TStringArray = array of String;

  TMatrixChar = record
    Char: String;
    SubChars: TStringArray;
    VertPos: Currency;
    HorzPos: Currency;
  end;

  TMatrixVisual = class(TJDVisual)
  private
    FPen: TGPPen;
  protected
    procedure DoStep; override;
    procedure DoPaint; override;
    procedure CreateControls; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

{ TMatrixVisual }

constructor TMatrixVisual.Create;
begin
  inherited;
  VisualName:= 'Matrix';

end;

destructor TMatrixVisual.Destroy;
begin

  inherited;
end;

procedure TMatrixVisual.CreateControls;
begin

end;

procedure TMatrixVisual.DoStep;
begin

end;

procedure TMatrixVisual.DoPaint;
begin

end;

initialization
  Visuals.RegisterVisualClass(TMatrixVisual);
end.
