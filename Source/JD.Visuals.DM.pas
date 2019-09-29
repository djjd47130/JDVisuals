unit JD.Visuals.DM;

interface

uses
  System.SysUtils, System.Classes, dwsComp, dwsClassesLibModule,
  dwsExprs;

type
  TDataModule1 = class(TDataModule)
    DWSUnit: TdwsUnit;
    DWSClasses: TdwsClassesLib;
    DWS: TDelphiWebScript;
    procedure DWSUnitFunctionsDrawLineEval(info: TProgramInfo);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataModule1.DWSUnitFunctionsDrawLineEval(info: TProgramInfo);
var
  X1, Y1, X2, Y2: Integer;
begin
  X1:= Info.Vars['X1'].Value;
  Y1:= Info.Vars['Y1'].Value;
  X2:= Info.Vars['X2'].Value;
  Y2:= Info.Vars['Y2'].Value;
  //TODO: Draw a line on the GP Canvas
  //TODO: How the fuck am I going to actually implement the canvas here???



end;

end.
