(***************************************************************
Цей приклад демонструє створення програми з інтерфейсом
у вигляді значка в System Tray. Програма написана без
використання VCL і в скомпільованому вигляді займає
12 Кб (у Delphi 6 Enterprise). Призначений для користувача
інтерфейс скомпільований в окрему DLL і підвантажується при потребі.
***************************************************************)
program TrayIcon;
uses Windows, Messages, Constant, TaskBar;
{$R *.RES}
{$R TrayRes.RES}
const
Hint : array[0..63] of Char='Демонстрація TaskBar Application';
WM_TASKBAR = WM_APP+1; // повідомлення від Tray Icon
ICON_ID=0; // ідентифікатор значка
sClassName='sTaskBarHandlerWindow'; // Ім'я класу вікна
AboutText='Simple TaskBar Application Demo'#13#13 +
'Copyright© ICSoft, ТДТУ, Кафедра АВ. 2002.';
AboutCaption='Демонстрація простої TaskBar-програми';
var
hWnd : THandle;
WndClass : TWndClass;
Msg : TMsg;
TaskBarCreated : Integer;
// Прапорець "Форма завантажена". Для запобігання повторному
// завантаженню форми
FormRunning : Boolean=false;
procedure ShowAboutDialog;
var
Version : TOSVersionInfo; // Змінна для отримання версії ОС
MsgBoxParamsW : TMsgBoxParamsW; // Параметри для вікна повідомлення під WinNT
MsgBoxParamsA : TMsgBoxParamsA; // Параметри для вікна повідомлення під Win9x
begin
// Функція MessageBoxIndirect, яка використовується для
// виведення About, по різному працює під Windows 9x і NT.
// Тому визначаєм спочатку версію Windows.
// Отримуєм інформацію про версію ОС
Version.dwOSVersionInfoSize:=SizeOf(TOSVersionInfo);
GetVersionEx(Version);
if Version.dwPlatformId=VER_PLATFORM_WIN32_NT then
begin // Якщо Windows NT, 2000, XP
// Обнуляємо структуру (record) з параметрами повідомлення
FillChar(MsgBoxParamsW,SizeOf(MsgBoxParamsW),#0);
// Задаєм параметри повідомлення
with MsgBoxParamsW do
begin
cbSize:=SizeOf(MsgBoxParamsW);
hwndOwner:=hWnd;
hInstance:=SysInit.hInstance;
lpszText:=AboutText;
lpszCaption:=AboutCaption;
lpszIcon:='MAINICON';
dwStyle:=MB_USERICON;
end;
// Показуєм повідомлення під WinNT
MessageBoxIndirectW(MsgBoxParamsW);
end
else begin // Якщо Windows 95, 98, ME...
// Обнуляємо структуру (record) з параметрами повідомлення
FillChar(MsgBoxParamsA,SizeOf(MsgBoxParamsA),#0);
// Задаєм параметри повідомлення
with MsgBoxParamsA do
begin
cbSize:=SizeOf(MsgBoxParamsA);
hwndOwner:=hWnd;
hInstance:=SysInit.hInstance;
lpszText:=AboutText;
lpszCaption:=AboutCaption;
lpszIcon:='MAINICON';
dwStyle:=MB_USERICON;
end;
// Показуєм повідомлення під Win9x
MessageBoxIndirectA(MsgBoxParamsA);
end;
end;
// Показ форми з динамічної бібліотеки
procedure ShowDLLForm(hWnd: THandle);
type
// Прототип функції з DLL. Напряму написати Uses не варто, так як
// при цьому в проект скомпілюється і форма, що збільшить його розмір.
TDoDLLForm=function(lpNewHint:PChar; iSize:Integer):Boolean; stdcall;
var
hDLL : THandle; // Handler (ідентифікатор) динам. бібліотеки
DoDLLForm : TDoDLLForm; // Функція для створення вікна з DLL
begin
// Якщо вікно з DLL вже показано, то виходимо
if FormRunning then Exit;
// Завантажуємо DLL
hDLL:=LoadLibrary('ProjectUI.dll');
// Якщо не вийшло, пишем про це і припиняємо спробу показу вікна
if hDLL=0 then MessageBox(0, 'Чет не подключилась библиотека', NIL, MB_OK)
else begin
// Якщо DLL завантажено, отримуємо адресу функції DoDLLForm
// (див. проект бібліотеки UI.dpr), яка показує вікно з DLL
DoDLLForm:=GetProcAddress(hDLL,'DoDLLForm');
if Assigned(DoDLLForm) then // Якщо таку функцію знайдено, то ...
begin
FormRunning:=TRUE;
try
// Пробуємо показати вікно форми з DLL
if DoDLLForm(@Hint,SizeOf(Hint)) then
begin
// Модифікуємо іконку на Панелі Задач (а саме- її підказку),
// якщо користувач натиснув кнопку "ОК" у формі з DLL.
TaskBarModifyIcon(hWnd,ICON_ID,NIF_TIP,0,Hint);
end;
finally
// В будь-якому випадку змінній FormRunning присвоюємо значення FALSE
// що свідчить про те, що вікно з DLL не показується.
FormRunning:=FALSE;
end;
end;
end;
// Вивантажуємо DLL з пам'яті
FreeLibrary(hDLL);
end;
// Функція поміщає вікно форми з DLL на передній план
procedure TopDLLForm;
type TForegroundDLLForm=procedure;
var hDLL : THandle; // Handler (ідентифікатор) динам. бібліотеки
ForegroundDLLForm : TForegroundDLLForm;
begin
hDLL:=LoadLibrary('ProjectUI.dll');
if hDLL<>0 then begin
ForegroundDLLForm:=GetProcAddress(hDLL,'ForegroundDLLForm');
if Assigned(ForegroundDLLForm) then ForegroundDLLForm;
end;
end;
// Процедура для знищення вікна з DLL
procedure DestructDLLForm;
type TDestroyDLLForm=procedure;
var DestroyDLLForm : TDestroyDLLForm;
hDLL : THandle;
begin
hDLL:=LoadLibrary('ProjectUI.dll');
if hDLL<>0 then begin
DestroyDLLForm:=GetProcAddress(hDLL,'DestroyDLLForm');
if Assigned(DestroyDLLForm) then
begin
DestroyDLLForm;
FormRunning:=FALSE;
end;
end;
end;
// Процедура для створення іконки на Панелі Задач
procedure CreateTaskBarIcon;
begin
TaskBarAddIcon(hWnd,ICON_ID,LoadIcon(hInstance,'MAINICON'),WM_TASKBAR,Hint);
end;
// Процедура для показу контекстного меню для іконки на панелі задач
procedure PopupMenu(hWnd: THandle);
var
Menu : hMenu; // Обробник меню з ресурса
Popup : hMenu; // Обробник контекстного меню
P : TPoint;
begin
// Меню загружається з ресурса (див. файл TrayRes.RC)
Menu:=LoadMenu(hInstance,'MAINMENU');
// Отримуємо обробник першого елемента меню (з номером 0)
Popup:=GetSubMenu(Menu,0);
// Отримуємо позицію курсора
GetCursorPos(P);
// Задаємо активне вікно (ним є _невидиме_ головне вікно програми)
// Задається того, що наше контекстне меню відноситься до нього
SetForegroundWindow(hWnd);
// Показуємо контекстне меню на іконці у Панелі Задач
TrackPopupMenu(Popup,TPM_CENTERALIGN or TPM_LEFTBUTTON,P.X,P.Y,0,hWnd,NIL);
// Ховаємо меню, якщо з нього не було вибрано жодної команди,
// і якщо вікно меню перестало бути активним
PostMessage(hWnd, WM_NULL, 0, 0);
// Знищуємо меню
DestroyMenu(Menu);
end;
// Віконна процедура
function WindowProc(hWnd: THandle; uMsg, wParam, lParam: Integer): Integer; stdcall; export;
begin
// Якщо отримано зареєстроване нами повідомлення про перезапуск Провідника
// Windows (таке часом буває при збоях у Windows), то створюємо іконку
// до своєї програми ще раз
if uMsg=TaskBarCreated then CreateTaskbarIcon;
case uMsg of
// Повідомлення від меню
WM_COMMAND:
case wParam of
// Повідомлення від команди меню "Вихід"
ID_CLOSE : PostMessage(hWnd,WM_DESTROY,0,0); // Посилаємо головному
// вікну повідомлення
// про знищення
// Повідомлення від команди меню "Про програму"
ID_ABOUT : ShowAboutDialog; // Показати Діалог "Про програму"
// Повідомлення від команди меню "Форма з DLL"
ID_DLLFORM: ShowDLLForm(hWnd); // Показати вікно з DLL
end;
// Повідомлення від іконки на Панелі Задач
WM_TASKBAR:
case wParam of
ICON_ID:
case lParam of
// При клацанні лівою кнопкою миші на іконці показуєм вікно з DLL
WM_LBUTTONDOWN : if not FormRunning then ShowDLLForm(hWnd) else TopDLLForm;
// При клацанні правою кнопкою миші показуємо контекстне меню
WM_RBUTTONDOWN : PopupMenu(hWnd);
end;
end;
// Повідомлення про вихід
WM_DESTROY:
begin
if FormRunning then DestructDLLForm;
PostQuitMessage(0); // Посилаємо головному вікну повідомлення про вихід
end;
end;
// Інші повідомлення Windows
Result:=DefWindowProc(hWnd,uMsg,wParam,lParam);
end;
begin
FillChar(WndClass,SizeOf(WndClass),0);
with WndClass do
begin
// Задаємо параметри класу для головного вікна
hInstance := SysInit.hInstance;
lpszClassName := sClassName;
lpfnWndProc := @WindowProc;
// Всі інші властивості для невидимого вікна не обов'язкові
end;
// Реєструємо клас вікна
RegisterClass(WndClass);
// Створюємо головне вікно програми. Воно мусить бути, але
// так як воно непотрібне і буде невидимим, то задаєм йому
// нульовий розмір.
hWnd:=CreateWindow(sClassName,'',0,0,0,0,0,0,0,hInstance,NIL);
if hWnd=0 then // Якщо не вийшло, то виходим з програми
begin
MessageBox(0,'Ініціалізацію не проведено!',NIL,ID_OK);
Exit;
end;
// Реєструємо повідомлення про перезапуск Explorer'а
TaskBarCreated:=RegisterWindowMessage('TaskbarCreated');
// Створюємо значок
CreateTaskBarIcon;
// Ховаємо вікно
ShowWindow(hWnd, SW_HIDE);
// Цикл обробки повідомлень
while GetMessage(Msg,0,0,0) do
begin
TranslateMessage(Msg);
DispatchMessage(Msg);
end;
// Забираємо значок при виході
TaskBarDeleteIcon(hWnd, ICON_ID);
// Виходим
Halt(Msg.wParam);
// Кінець. Вийшли.
end.
