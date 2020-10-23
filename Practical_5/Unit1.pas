unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TLHelp32, Registry;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    Button3: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  pe : TProcessEntry32;
  hSnap : THandle;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  ShowMessage(GetEnvironmentVariable('WINDIR'));
  Label1.Caption := GetEnvironmentVariable('WINDIR')
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  dir: array [0..MAX_PATH] of Char;
begin
  GetSystemDirectory(dir, MAX_PATH);
  ShowMessage(StrPas(dir));
end;
procedure TForm1.Button3Click(Sender: TObject);
begin
  pe.dwSize:=SizeOf(pe);
  hSnap:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  if Process32First(hSnap,pe) then
  begin
  ListBox1.Items.Add(pe.szExeFile);
  while Process32Next(hSnap,pe) do ListBox1.Items.Add(pe.szExeFile);
  end;
end;

end.
