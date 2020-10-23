program Window;
uses Windows, Messages, SysUtils;
const AppName='API Window';
var AMessage : TMsg;
hWindow : HWnd;
hBtnExit : HWnd;
hBtnAbout : HWnd;
hBtnDlg : HWnd;
hText1 : HWnd;
hText2 : HWnd;
var hcbType : hWnd;
hEdit : hWnd;
ParamEdit : array [1..50] of char;
ParamCB : PChar;
{$R 'Res.RES' 'Res.rc'}
function DlgProc(Window : hWnd; Msg,WParam,LParam : Integer): Integer; stdcall;
begin
Result:=0;
case Msg of
WM_INITDIALOG : begin
// Ініціалізація діалогового вікна
Result:=0;
hcbType:=GetDlgItem(Window,101);
SendMessage(hcbType,CB_ADDSTRING,0,DWORD(PChar('Параметр 1')));
SendMessage(hcbType,CB_ADDSTRING,0,DWORD(PChar('Параметр 2')));
SendMessage(hcbType,CB_ADDSTRING,0,DWORD(PChar('Параметр 3')));
SendMessage(hcbType,CB_ADDSTRING,0,DWORD(PChar('Параметр 4')));
SendMessage(hcbType,CB_ADDSTRING,0,DWORD(PChar('Параметр 5')));
SendMessage(hcbType,CB_SETCURSEL,0,0);
hEdit:=GetDlgItem(Window,102);
SendMessage(hEdit,WM_SETTEXT,0,DWORD(PChar('Тут є якийсь текст !')));
end;
WM_COMMAND : if (LoWord(WParam)=IDOK) then begin // Натиснено кнопку "ОК"
SendMessage(hEdit,WM_GETTEXT,
SendMessage(hEdit,WM_GETTEXTLENGTH,0,0)+1,DWORD(@ParamEdit));
SendMessage(hcbType,WM_GETTEXT,
SendMessage(hcbType,WM_GETTEXTLENGTH,0,0)+1,DWORD(ParamCB));
EndDialog(Window,idOK)
end // Натиснено кнопку "Відміна"
else if (LoWord(WParam)=IDCANCEL) then EndDialog(Window,idCancel)
else // Натиснено кнопку "Довідка"
if (LoWord(WParam)=IDHELP) then MessageBox(Window,
'Довідка про діалогове вікно, яке створене з використанням Microsoft® '+
'Windows® Application Program Interface®.'+
#13#13+'Copyright© Microsoft® & K°',
'Довідка про API Window',MB_OK or MB_ICONINFORMATION);
WM_CLOSE : EndDialog(Window,idCancel);
else Result:=0;
end;
end;
procedure ChangeParams;
begin
SendMessage(hText1,WM_SETTEXT,0,DWORD(PChar('Вибраний параметр з комбінованого списку: '+ParamCB)));
SendMessage(hText2,WM_SETTEXT,0,DWORD(@ParamEdit));
end;
function WindowProc(Window:HWnd; AMessage, WParam, LParam:longint):longint;stdcall; export;
begin
WindowProc:=0;
case AMessage of
WM_DESTROY: begin PostQuitMessage(0); Exit; end;
WM_COMMAND: if HWnd(LParam)=hBtnExit then begin PostQuitMessage(0); Exit; end
else if HWnd(LParam)=hBtnAbout then MessageBox(Window,
'Вікно, створене функціями API, без використання VCL Delphi.'+#13#13+
'Copyright© Microsoft... і т.д.','API Window',MB_OK or MB_ICONINFORMATION)
else if HWnd(LParam)=hBtnDlg then begin
if DialogBox(hInstance,'ICDialog',hWindow,@DlgProc)=IDOK then ChangeParams;
end;
WM_KEYDOWN: if (WParam=VK_RETURN) or (WParam=VK_ESCAPE) then
SendMessage(hBtnExit,BM_CLICK,0,0)
else if WParam=VK_F1 then SendMessage(hBtnAbout,BM_CLICK,0,0);
end;
WindowProc:=DefWindowProc(Window, AMessage, WParam, LParam);
end;
function WinRegister: boolean;
var WindowClass: TWndClass;
begin
with WindowClass do begin
Style:=CS_HREDRAW or CS_VREDRAW;
lpfnWndProc:=@WindowProc;
cbClsExtra:=0;
cbWndExtra:=0;
hInstance:=HInstance;
hIcon:=LoadIcon(0, IDI_APPLICATION);
hCursor:=LoadCursor(0, IDC_ARROW);
hbrBackGround:=COLOR_WINDOW;
lpszMenuName:=nil;
lpszClassName:=AppName;
end;
Result:=RegisterClass(WindowClass)<>0;
end;
function WinCreate: HWnd;
var hWindow : HWnd;
begin
hWindow:=CreateWindow(AppName, 'Вікно, створене з використанням API',WS_OVERLAPPEDWINDOW,
200, 200, 600, 185, 0, 0, HInstance, nil);
if hWindow<>0 then
begin
ShowWindow(hWindow, SW_SHOWNORMAL);
UpdateWindow(hWindow);
end;
hBtnExit:=CreateWindow('BUTTON', 'Вихід',WS_CHILD or BS_DEFPUSHBUTTON or WS_TABSTOP, 500, 10,
90, 30, hWindow, 0, HInstance, nil);
if hBtnExit<>0 then ShowWindow(hBtnExit, SW_SHOWNORMAL);
SendMessage(hBtnExit,WM_SETFONT,
CreateFont(18,0,0,0,700,0,0,0,ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,DEFAULT_PITCH,'Times New Roman Cyr'),1);
hBtnDlg:=CreateWindow('BUTTON', 'Діалог',WS_CHILD or WS_TABSTOP, 500, 75, 90, 30, hWindow, 0,
HInstance, nil);
if hBtnDlg<>0 then ShowWindow(hBtnDlg, SW_SHOWNORMAL);
hBtnAbout:=CreateWindow('BUTTON', 'Про вікно...',WS_CHILD or WS_TABSTOP, 500, 115, 90, 30,
hWindow, 0, HInstance, nil);
if hBtnAbout<>0 then ShowWindow(hBtnAbout, SW_SHOWNORMAL);
hText1:=CreateWindow('STATIC', 'Перший параметр ще не задано',WS_CHILD, 10, 15, 450, 20,
hWindow, 0, HInstance, nil);
if hText1<>0 then ShowWindow(hText1, SW_SHOWNORMAL);
hText2:=CreateWindow('STATIC', 'Другий параметр також ще не задано',WS_CHILD, 10, 40, 450,
20, hWindow, 0, HInstance, nil);
if hText2<>0 then ShowWindow(hText2, SW_SHOWNORMAL);
Result:=hWindow;
end;
begin
if not WinRegister then
begin
MessageBox(0, // обробник батьківського вікна
'Клас вікна не зареєстровано', // адреса тексту повідомлення
'API Window', // адреса заголовку вікна повідомлення
MB_OK); // стиль вікна повідомлення
Exit;
end;
hWindow:=WinCreate;
if hWindow=0 then
begin
MessageBox(0, 'Не вийшло створити вікно.', 'API Window', MB_OK);
Exit;
end;
GetMem(ParamCB,50);
while GetMessage(AMessage,0,0,0) do
begin
TranslateMessage(AMessage);
DispatchMessage(AMessage);
end;
FreeMem(ParamCB);
Halt(AMessage.wParam);
end.
