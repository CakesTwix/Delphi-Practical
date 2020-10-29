unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TLHelp32, Registry, Math;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    MainDisk_GroupBox: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ProductName_Label: TLabel;
    PlatformInfo_Label: TLabel;
    WinVersion_Label: TLabel;
    WinDir_Label: TLabel;
    SysDir_Label: TLabel;
    ComputerName_Label: TLabel;
    UserName_Label: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    TotalMemory_Label: TLabel;
    FreeMemory_Label: TLabel;
    PercentMemory_Label: TLabel;
    TotalVirtualMemory_Label: TLabel;
    AvailableVirtualMemory_Label: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    SerialNumber_Label: TLabel;
    Label_Label: TLabel;
    FileSystem_Label: TLabel;
    MemoryHDD_Label: TLabel;
    FreeMemoryHDD_Label: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    CPUName_Label: TLabel;
    CPUVendor_Label: TLabel;
    CPUSpeed_Label: TLabel;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Process_List: TListBox;
    lbWindows: TListBox;
    cbAllWindows: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetMemoryInfo;
    procedure GetCPUInfo;
    procedure GetHDInfo;
  end;

const
  Win7 = 6;

var
  Form1: TForm1;
  pe: TProcessEntry32;
  hSnap: THandle;
  C: cardinal;
  R, Path: string;

implementation

{$R *.dfm}

//Формат в более читаемый вид размера ОЗУ
function ConvertBytes(Bytes: int64): string;
const
  Description: array [0 .. 8] of string = ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
var
  i: integer;
begin
  i := 0;

  while Bytes > Power(1024, i + 1) do
    Inc(i);

  result := FormatFloat('###0.##', Bytes / Power(1024, i)) + #32 + Description[i];
end;

//Список окнов
function EnumWndFunc(Hnd: HWND; PrID: DWORD): boolean; stdcall;
var
  lpS: PWideChar;
begin
  result := true;
  GetMem(lpS, 127);
  if Form1.cbAllWindows.Checked then
  begin
    if (GetWindowText(Hnd, lpS, 127) <> 0) then
      if lps <> '' then
        Form1.lbWindows.Items.Add(lpS);
  end
  else
  if (IsWindowVisible(Hnd)) and (GetWindow(Hnd, GW_OWNER) = 0) and (GetWindowText(Hnd, lpS, 127) <> 0) then
    if lpS <> '' then
      Form1.lbWindows.Items.Add(lpS);
  FreeMem(lpS, 127);
end;

//Определение частоты процессора
function GetCPUSpeed: double;
const
  DelayTime = 500;
var
  TimerHi: DWORD;
  TimerLo: DWORD;
  PriorityClass: integer;
  Priority: integer;
begin
  PriorityClass := GetPriorityClass(GetCurrentProcess);
  Priority := GetThreadPriority(GetCurrentThread);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  asm
           PUSH    10
           CALL    Sleep
           DW      310Fh
           MOV     TimerLo, EAX
           MOV     TimerHi, EDX
           PUSH    DelayTime
           CALL    Sleep
           DW      310Fh
           SUB     EAX, TimerLo
           SBB     EDX, TimerHi
           MOV     TimerLo, EAX
           MOV     TimerHi, EDX
  end;
  SetThreadPriority(GetCurrentThread, Priority);
  SetPriorityClass(GetCurrentProcess, PriorityClass);
  result := TimerLo / (1000.0 * DelayTime);
end;

//Информация про процессор
procedure TForm1.GetCPUInfo;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_READ); //Без KEY_READ чет не читались данные
  Registry.RootKey := HKEY_LOCAL_MACHINE;
  if Registry.OpenKey('HARDWARE\DESCRIPTION\System\CentralProcessor\0\', false) then
  begin
    CPUName_Label.Caption := Registry.ReadString('ProcessorNameString');
    //Поменял, чтобы было более человеческое название
    CPUVendor_Label.Caption := Registry.ReadString('VendorIdentifier');
  end;
end;

//Информация про память
//https://stackoverflow.com/questions/4023572/delphxe-globalmemorystatus-vs-globalmemorystatusex
procedure TForm1.GetMemoryInfo;
var
  lpBuffer: TMemoryStatusEx;
begin
  with lpBuffer do
  begin
    dwLength := SizeOf(TMemoryStatus);
    GlobalMemoryStatusEx(lpBuffer);
    FillChar(lpBuffer, SizeOf(lpBuffer), 0);
    lpBuffer.dwLength := SizeOf(lpBuffer);
    Win32Check(GlobalMemoryStatusEx(lpBuffer));

    TotalMemory_Label.Caption := ConvertBytes(lpBuffer.ullTotalPhys);
    FreeMemory_Label.Caption := ConvertBytes(lpBuffer.ullAvailPhys);
    PercentMemory_Label.Caption := IntToStr(lpBuffer.dwMemoryLoad);
    TotalVirtualMemory_Label.Caption := ConvertBytes(lpBuffer.ullTotalVirtual);
    AvailableVirtualMemory_Label.Caption := ConvertBytes(lpBuffer.ullAvailVirtual);
  end;
end;

//Информация про диски
procedure TForm1.GetHDInfo;
var
  VolumeName, FileSystemName: array [0..MAX_PATH - 1] of char;
  VolumeSerialNo: DWORD;
  MaxComponentLength, FileSystemFlags: DWORD;
  SC: PChar;
  MainDir: string;
  FreeAvailable, TotalSpace: TLargeInteger;
  TotalFree: TLargeInteger;
begin
  MainDir := ExtractFilePath(Application.ExeName);
  MainDisk_GroupBox.Caption := ' Жорсткий диск ' + MainDir[1] + MainDir[2] + ' ';
  SC := StrAlloc(4);
  StrPCopy(SC, MainDir[1] + MainDir[2] + MainDir[3]);
  GetVolumeInformation(SC, VolumeName, MAX_PATH, @VolumeSerialNo,
    MaxComponentLength, FileSystemFlags, FileSystemName, MAX_PATH);
  SerialNumber_Label.Caption := IntToStr(VolumeSerialNo);
  FileSystem_Label.Caption := FileSystemName;
  Label_Label.Caption := VolumeName; //Почему-то пустая строка
  GetDiskFreeSpaceEx(SC, FreeAvailable, TotalSpace, @TotalFree);
  MemoryHDD_Label.Caption := IntToStr(TotalSpace div (1024 * 1024 * 1024)) + ' GB';
  FreeMemoryHDD_Label.Caption := IntToStr(TotalFree div (1024 * 1024)) + ' MB';
  StrDispose(SC);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  dir: array [0..MAX_PATH] of char;
  version: integer;
  Registry: TRegistry;
begin
  //Папка Windows
  WinDir_Label.Caption := GetEnvironmentVariable('WINDIR');

  //Системная папка
  GetSystemDirectory(dir, MAX_PATH);
  SysDir_Label.Caption := StrPas(dir);

  //Частота процессора
  CPUSpeed_Label.Caption := IntToStr(Round(GetCPUSpeed)) + ' МГц';

  //Список процессов
  pe.dwSize := SizeOf(pe);
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Process32First(hSnap, pe) then
  begin
    Process_List.Items.Add(pe.szExeFile);
    while Process32Next(hSnap, pe) do
      Process_List.Items.Add(pe.szExeFile);
  end;

  //Версия Windows
  version := LOWORD(GetVersion);
  case version of
    10: PlatformInfo_Label.Caption := 'Windows 10';
    4: PlatformInfo_Label.Caption := 'Windows 95';
    261: PlatformInfo_Label.Caption := 'Windows XP';
    262: PlatformInfo_Label.Caption := 'Windows 7';
    6: PlatformInfo_Label.Caption := 'Windows Vista'
  end;

  //Информация про ОЗУ
  GetMemoryInfo;

  //Информация про процессор
  GetCPUInfo;

  //Информация про диски
  GetHDInfo;

  //Информация про окна
  EnumWindows(@EnumWndFunc, 0);

  //Информация про юзера и имени ПК
  //http://docwiki.embarcadero.com/Libraries/Sydney/en/System.SysUtils.GetEnvironmentVariable
  //Полезная ссылка для значений GetEnvironmentVariable()
  UserName_Label.Caption := GetEnvironmentVariable('USERNAME');
  ComputerName_Label.Caption := GetEnvironmentVariable('COMPUTERNAME');

  Registry := TRegistry.Create(KEY_READ); //Без KEY_READ чет не читались данные
  Registry.RootKey := HKEY_LOCAL_MACHINE;
  if Registry.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion', false) then
  begin
    WinVersion_Label.Caption := Registry.ReadString('CurrentBuild');
    ProductName_Label.Caption := Registry.ReadString('ProductName');
  end;
end;

end.
