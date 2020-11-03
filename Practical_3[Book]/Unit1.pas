unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

// Функція для створення вікна
function DoDLLForm (lpNewHint:PChar; iSize:Integer):Boolean;
// Процедура знищення вікна
procedure DestroyDLLForm; stdcall; export;
// Процедура, яка ставить вікно на передній план
procedure ForegroundDLLForm; stdcall; export;
implementation
{$R *.DFM}
procedure ForegroundDLLForm;
begin
if Assigned(Form1) then SetForegroundWindow(Form1.Handle);
end;
procedure DestroyDLLForm;
begin
if Assigned(Form1) then Form1.Close;
end;

function DoDLLForm (lpNewHint:PChar; iSize:Integer):Boolean;
begin
Form1:=TForm1.Create(nil);
with Form1 do
try
Edit1.Text:=lpNewHint;
Edit1.MaxLength:=iSize-1;
Caption:='Форма DLL';
SetForegroundWindow(Form1.Handle);
Result:=ShowModal=mrOk;
if Result then StrPCopy(lpNewHint, Edit1.Text);
finally
if Form1<>nil then Free;
end;
end;

end.
