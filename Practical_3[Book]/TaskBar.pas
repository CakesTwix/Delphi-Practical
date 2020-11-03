unit TaskBar;
interface
uses Windows, ShellAPI;
const
// Визначені у Windows флажки для іконки
NIF_TIP = $00000004;
NIF_ICON = $00000002;
// Функція для створення іконки на Панелі Задач
function TaskBarAddIcon(
hWindow: THandle; // ідентифікатор вікна, що створює іконку (значок)
ID: Cardinal; // ідентифікатор значка
ICON: hIcon; // іконка
CallbackMessage: Cardinal; // повідомдення, яке буде посилатися вікну від іконки
Tip: PChar // Підказка
): Boolean;
// Функція для модифікації іконки на Панелі Задач
function TaskBarModifyIcon(hWindow: THandle; ID: Cardinal; Flags: Cardinal;
ICON: hIcon; Tip: PChar): Boolean;
// Функція для знищення іконки на Панелі Задач
function TaskBarDeleteIcon(hWindow: THandle; ID: Integer): Boolean;
implementation
// Функція для створення іконки на Панелі Задач
function TaskBarAddIcon(hWindow:THandle; ID:Cardinal; ICON:hIcon; CallbackMessage:Cardinal;
Tip:PChar):Boolean;
var NID: TNotifyIconData;
begin
FillChar(NID,SizeOf(TNotifyIconData),0);
// Заповнюємо структуру типу TNotifyIconData інформацією про іконку
with NID do
begin

Wnd := hWindow; // Обробник головного вікна
uID := ID; // Ідентифікатор іконки
uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP; // Флажки показу

uCallbackMessage := CallbackMessage; // Повідомлення від іконки
hIcon := Icon; // Обробник іконки
// Із-за того, що szTip має тип масива символів, а Tip- рядок типу PChar,
// треба скопіювати Tip у szTip за допомогою спеціальної функції lstrcpyn
lstrcpyn(szTip,Tip,SizeOf()); // Підказка іконки
end;
// Викликаємо стандартну функцію Windows Shell_NotifyIcon для створення
// іконки на Панелі Задач
Result:=Shell_NotifyIcon(NIM_ADD,@NID);
end;
// Функція для модифікації іконки на Панелі Задач
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
// Викликаємо стандартну функцію Windows Shell_NotifyIcon для зміни
// іконки на Панелі Задач
Result := Shell_NotifyIcon(NIM_MODIFY, @NID);
end;
// Функція для знищення іконки на Панелі Задач
function TaskBarDeleteIcon(hWindow:THandle; ID:Integer):Boolean;
var NID: TNotifyIconData;
begin
FillChar(NID,SizeOf(TNotifyIconData),0);
with NID do
begin

Wnd := hWindow;
uID := ID;
end;
// Викликаємо стандартну функцію Windows Shell_NotifyIcon для створення
// іконки на Панелі Задач
Result := Shell_NotifyIcon(NIM_DELETE,@NID);
end;
end.
