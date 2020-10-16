program Window;



{$R 'Res.res' 'Res.rc'}

uses
  Windows,
  Messages;

const
  AppName = 'API Window';
var
  AMessage: TMsg;
  Buff : Array[0..127] of char;

  //Определяем элементы интерфейса

  //Само окно
  hWindow: HWnd;

  //Кнопки
  hBtnExit: HWnd;
  hBtnAbout: HWnd;

  //Лейблы
  hLabel_1: HWnd;
  hLabel_2: HWnd;
  hLabel_3: HWnd;

  //Поле ввода текста
  hEdit: HWnd;

  {$R Res.res}
//Функция, которая обрабатывает кнопки
function WindowProc(Window: HWnd; AMessage, WParam, LParam: longint): longint; stdcall; export;
begin
  WindowProc := 0;
  case AMessage of
    WM_DESTROY:
    begin
      PostQuitMessage(0);
      exit;
    end;
    WM_COMMAND:
      //Обработчик кнопки выхода
      if LParam = hBtnExit then
      begin
        PostQuitMessage(0);
        exit;
      end

      //Обработчик кнопки Про окно
      else if LParam = hBtnAbout then
        DialogBox(hInstance,'ICDialog',hWindow,@WindowProc);
        
    WM_KEYDOWN: if (WParam = VK_RETURN) or (WParam = VK_ESCAPE) then
        SendMessage(hBtnExit, BM_CLICK, 0, 0)
      else if WParam = VK_F1 then
        SendMessage(hBtnAbout, BM_CLICK, 0, 0);
  end;

  WindowProc := DefWindowProc(Window, AMessage, WParam, LParam);
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
    WS_OVERLAPPEDWINDOW and WS_MINIMIZEBOX, 100, 100, 600, 400, 0, 0, HInstance, nil);

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
    hEdit := CreateWindowEx(WS_EX_CLIENTEDGE, 'Edit', 'Введите текст', WS_VISIBLE or
      WS_CHILD or ES_LEFT or ES_AUTOHSCROLL, 10, 70, 360, 23, hWindow, 0, hInstance, nil);


    GetWindowText(hLabel_1,Buff,SizeOf(Buff));
    //SetWindowText(hLabel_1,Buff);
    SendMessage(hEdit,WM_SETTEXT,0,DWORD(PChar(''+Buff)));

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
