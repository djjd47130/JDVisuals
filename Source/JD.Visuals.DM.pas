unit JD.Visuals.DM;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  GDIPAPI, GDIPOBJ,
  JD.Visuals,
  dwsComp, dwsClassesLibModule, dwsExprs;

type
  TdmJDVisualsScript = class(TDataModule)
    DWSUnit: TdwsUnit;
    DWSClasses: TdwsClassesLib;
    DWS: TDelphiWebScript;
    procedure DWSUnitFunctionsDrawLineEval(info: TProgramInfo);
    procedure DataModuleCreate(Sender: TObject);
  private
    FThread: TJDVisualsThread;
  public

  end;

var
  dmJDVisualsScript: TdmJDVisualsScript;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmJDVisualsScript.DataModuleCreate(Sender: TObject);
var
  U: TStringList;
  Prog: IdwsProgram;
  Exec: IdwsProgramExecution;
begin
  U:= TStringList.Create;
  try
    U.Append('');
    U.Append('');
    U.Append('procedure DoSomething;');
    U.Append('begin');
    U.Append('  ');
    U.Append('end;');
    U.Append('');
    U.Append('');
    U.Append('');
    U.Append('');
    U.Append('');
    Prog:= DWS.Compile(U.Text);
    Exec:= Prog.Execute(0); //AFAIK, this is synchronous, so how to make next line work?
    Exec.Info.Func['DoSomething'].Call;

  finally
    U.Free;
  end;
end;

procedure TdmJDVisualsScript.DWSUnitFunctionsDrawLineEval(info: TProgramInfo);
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
