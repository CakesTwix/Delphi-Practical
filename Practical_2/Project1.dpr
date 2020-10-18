program Window;



{$R 'Res.res' 'Res.rc'}

uses
  Windows,
  Messages;

const
  AppName = 'API Window';
var
  AMessage: TMsg;
  ParamEditA, ParamEditB : PWideChar;
  result : PWideChar;
  Buff : array[0 .. 132] of Char;
  test : PWideChar;

  //Определяем элементы интерфейса

  //Само окно
  hWindow: HWnd;
  h1Window: HWnd;

  //Кнопки
  hBtnExit: HWnd;
  hBtnAbout: HWnd;

  //Лейблы
  hLabel_1: HWnd;

  //Поле ввода текста
  hEdit: HWnd;
  A,B: HWnd;

  {$R Res.res}
//Функция, которая обрабатывает кнопки
function WindowProc(Window: HWnd; AMessage, WParam, LParam: longint): longint; stdcall; export;
begin
  WindowProc := 0;

case AMessage of
  WM_INITDIALOG : begin
    // Ініціалізація діалогового вікна
    A:=GetDlgItem(Window,101);
    B:=GetDlgItem(Window,102);
    Result:=0;
  end;

  WM_COMMAND : if (LoWord(WParam)=IDOK) then
  begin
    SendMessage(A,WM_GETTEXT,SendMessage(A,WM_GETTEXTLENGTH,0,0)+1,DWORD(@ParamEditA));
    SendMessage(B,WM_GETTEXT,SendMessage(B,WM_GETTEXTLENGTH,0,0)+1,DWORD(@ParamEditB));
    //GetWindowText(101,Buff,SizeOf(Buff));
    //SetWindowText(hEdit, DWORD(test));
    SendMessage(hEdit,WM_SETTEXT,0, DWORD(PChar(@ParamEditA)));
  end
  else if (LoWord(WParam)=IDCANCEL) then  begin EndDialog(Window,idCancel); end
  else if LParam=hBtnAbout then begin DialogBox(hInstance,'ICDialog',h1Window,@WindowProc); end
  else if LParam=hBtnExit then  begin PostQuitMessage(0); Exit; end;


    WM_DESTROY : EndDialog(h1Window,idCancel);
    //else Result:=0;

    else WindowProc:=DefWindowProc(Window, AMessage, WParam, LParam);
end;
  end;


function WinRegister: boolean;
var
  WindowClass: TWndClass;
begin
  with WindowClass do
  begin
    Style := CS_HREDRAW or CS_VREDRAW;
    lpfnWndProc := @WindowProc;
    cbClsExtra := 0;
    cbWndExtra := 0;
    hInstance := HInstance;
    hIcon := LoadIcon(0, IDI_APPLICATION);
    hCursor := LoadCursor(0, IDC_ARROW);
    hbrBackGround := COLOR_WINDOW;
    lpszMenuName := nil;
    lpszClassName := AppName;
  end;
  result := RegisterClass(WindowClass) <> 0;
end;

//Функция, которая создает окно и раставляет элементы
function WinCreate: HWnd;
var
  hWindow: HWnd;
begin
  hWindow := CreateWindow(AppName, 'Вікно, створене з використанням API',
    WS_EX_TOPMOST, 100, 100, 600, 400, 0, 0, HInstance, nil);

  if hWindow <> 0 then
  begin
    //Параметры окна
    ShowWindow(hWindow, SW_SHOWNORMAL);
    UpdateWindow(hWindow);

    //Параметры кнопки выхода
    hBtnExit := CreateWindow('BUTTON', 'Вихід', WS_CHILD or BS_DEFPUSHBUTTON or WS_TABSTOP,
      500, 105, 90, 30, hWindow, 0, HInstance, nil);

    //Параметры лейблов
    hLabel_1 := CreateWindow('Static', 'Результат вычислений:', WS_VISIBLE or
      WS_CHILD or SS_LEFT, 10, 10, 360, 44, hWindow, 0, hInstance, nil);

    //Параметры поля ввода
    hEdit := CreateWindowEx(WS_EX_CLIENTEDGE, 'Edit', '', WS_VISIBLE or
      WS_CHILD or ES_LEFT or ES_AUTOHSCROLL, 10, 70, 360, 23, hWindow, 0, hInstance, nil);


    //GetWindowText(hEdit,Buff,SizeOf(Buff));
    //SetWindowText(hLabel_1,Buff);
    //SendMessage(hEdit,WM_SETTEXT,0,DWORD(PChar(''+Buff)));

    if hBtnExit <> 0 then
      ShowWindow(hBtnExit, SW_SHOWNORMAL);
    SendMessage(hBtnExit, WM_SETFONT, CreateFont(18, 0, 0, 0, 700, 0, 0, 0,
      ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH,
      'Times New Roman Cyr'), 1);

    //Параметры кнопки Про окно
    hBtnAbout := CreateWindow('BUTTON', 'Про вікно...', WS_CHILD or WS_TABSTOP,
      500, 75, 90, 30, hWindow, 0, HInstance, nil);
    if hBtnAbout <> 0 then
      ShowWindow(hBtnAbout, SW_SHOWNORMAL);
  end;
  result := hWindow;
end;

begin
  if not WinRegister then
  begin
    MessageBox(0, 'Клас вікна не зареєстровано', AppName, MB_OK);
    exit;
  end;
  hWindow := WinCreate;
  if hWindow = 0 then
  begin
    MessageBox(0, 'Не вийшло створити вікно.', AppName, MB_OK);
    exit;
  end;
  while GetMessage(AMessage, 0, 0, 0) do
  begin
    TranslateMessage(AMessage);
    DispatchMessage(AMessage);
  end;
  Halt(AMessage.wParam);
end.
