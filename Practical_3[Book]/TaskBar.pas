unit TaskBar;
interface
uses Windows, ShellAPI;
const
// �������� � Windows ������ ��� ������
NIF_TIP = $00000004;
NIF_ICON = $00000002;
// ������� ��� ��������� ������ �� ����� �����
function TaskBarAddIcon(
hWindow: THandle; // ������������� ����, �� ������� ������ (������)
ID: Cardinal; // ������������� ������
ICON: hIcon; // ������
CallbackMessage: Cardinal; // �����������, ��� ���� ���������� ���� �� ������
Tip: PChar // ϳ������
): Boolean;
// ������� ��� ����������� ������ �� ����� �����
function TaskBarModifyIcon(hWindow: THandle; ID: Cardinal; Flags: Cardinal;
ICON: hIcon; Tip: PChar): Boolean;
// ������� ��� �������� ������ �� ����� �����
function TaskBarDeleteIcon(hWindow: THandle; ID: Integer): Boolean;
implementation
// ������� ��� ��������� ������ �� ����� �����
function TaskBarAddIcon(hWindow:THandle; ID:Cardinal; ICON:hIcon; CallbackMessage:Cardinal;
Tip:PChar):Boolean;
var NID: TNotifyIconData;
begin
FillChar(NID,SizeOf(TNotifyIconData),0);
// ���������� ��������� ���� TNotifyIconData ����������� ��� ������
with NID do
begin

Wnd := hWindow; // �������� ��������� ����
uID := ID; // ������������� ������
uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP; // ������ ������

uCallbackMessage := CallbackMessage; // ����������� �� ������
hIcon := Icon; // �������� ������
// ��-�� ����, �� szTip �� ��� ������ �������, � Tip- ����� ���� PChar,
// ����� ��������� Tip � szTip �� ��������� ���������� ������� lstrcpyn
lstrcpyn(szTip,Tip,SizeOf()); // ϳ������ ������
end;
// ��������� ���������� ������� Windows Shell_NotifyIcon ��� ���������
// ������ �� ����� �����
Result:=Shell_NotifyIcon(NIM_ADD,@NID);
end;
// ������� ��� ����������� ������ �� ����� �����
function TaskBarModifyIcon(hWindow:THandle; ID:Cardinal; Flags:Cardinal;
ICON:hIcon; Tip:PChar):Boolean;
var NID: TNotifyIconData;
begin
FillChar(NID, SizeOf(TNotifyIconData), 0);
with NID do begin
Wnd := hWindow;
uID := ID;
uFlags := Flags;
hIcon := Icon;
lstrcpyn(szTip, Tip, SizeOf());
end;
// ��������� ���������� ������� Windows Shell_NotifyIcon ��� ����
// ������ �� ����� �����
Result := Shell_NotifyIcon(NIM_MODIFY, @NID);
end;
// ������� ��� �������� ������ �� ����� �����
function TaskBarDeleteIcon(hWindow:THandle; ID:Integer):Boolean;
var NID: TNotifyIconData;
begin
FillChar(NID,SizeOf(TNotifyIconData),0);
with NID do
begin

Wnd := hWindow;
uID := ID;
end;
// ��������� ���������� ������� Windows Shell_NotifyIcon ��� ���������
// ������ �� ����� �����
Result := Shell_NotifyIcon(NIM_DELETE,@NID);
end;
end.
