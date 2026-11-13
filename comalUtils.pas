unit comalUtils;

interface

Uses SysUtils, windows, messages, graphics, heap32, Stdio;

Type
  TThreadTask = (
    THREAD_TASK_LIST,
    THREAD_TASK_KILL,
    THREAD_TASK_FIND,
    THREAD_TASK_SUSPEND,
    THREAD_TASK_RESUME);

Function WriteR(Const Txt:String; Len:Integer):String;
Function WriteL(Const Txt:String; Len:Integer):String;
function ProcessMessage(): Boolean;
Procedure WinInfo(hwnd:THandle);
Procedure CaptureDesktop(Hnd:THandle=0);
Procedure ErrorExit(Msg:String; exitCode:Integer=0);

implementation

Function WriteR(Const Txt:String; Len:Integer):String;
Begin
  Result:= Format('%'+ IntToStr(Len) +'s',[Copy(Txt, 1, Len)]);
End;

Function WriteL(Const Txt:String; Len:Integer):String;
Begin
  Result:= Copy(Txt, 1, Len);//+ Format('%'+ IntToStr(Len) +'s',[' ']);
  if Length(Result)<Len Then
  Result:= Result+ Format('%'+ IntToStr(Len-Length(Result)) +'s',[' ']);
End;

function ProcessMessage(): Boolean;
var ProcMsg: TMsg;
begin
  Result := False;
  if PeekMessage(ProcMsg, 0, 0, 0, PM_REMOVE) then
  begin
    Result := True;
    if ProcMsg.Message <> WM_QUIT then
    begin
      TranslateMessage(ProcMsg);
      DispatchMessage(ProcMsg);
    end;
  end;
end;

Procedure WinInfo(hwnd:THandle);
var
  buff: Array[0..254]of char;
  I: Integer;
  R:TRect;
Begin
  FillChar(Buff, SizeOf(Buff), 0);
  WriteLn('');
  //windows.Beep(1000, 50);

  Echo(WriteR('TID ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowThreadProcessId(hwnd);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Handle ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  Echo(Format('%d | %s', [hwnd, IntToHex(hwnd, 8)]), '', FRG_GRAY, 0, ' ');
  GetClassName(hwnd, Buff, SizeOf(Buff));
  Echo(WriteR('Classname ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  Echo(Buff, '', FRG_GRAY, 0, ' ');

  FillChar(Buff, SizeOf(Buff), 0);
  GetWindowText(hwnd, Buff, SizeOf(Buff));
  Echo(WriteR('Text ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  Echo(Buff, '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Visible ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  Echo(BoolToStr(IsWindowVisible(hwnd), True), '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Enable ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  Echo(BoolToStr(IsWindowEnabled(hwnd), True), '', FRG_GRAY, 0, ' ');

  if GetWindowRect(hwnd, R)Then
  Begin
    Echo(WriteR('Rect ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
    Echo(Format('(L %d, T %d, R %d, B %d)', [R.Left, R.Top, R.Right, R.Bottom]), '', FRG_GRAY, 0, ' ');
    Echo(WriteR('Point ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
    Echo(Format('%d x %d', [R.Left, R.Top]), '', FRG_GRAY, 0, ' ');
    Echo(WriteR('Size ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
    Echo(Format('%d x %d', [R.Right-R.Left, R.Bottom-R.Top]), '', FRG_GRAY, 0, ' ');
  End else
  Begin
    Echo(WriteR('Rect ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
    Echo(': (0,0,0,0)', '', FRG_GRAY, 0, ' ');
    Echo(WriteR('Point ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
    Echo(': 0 x 0', '', FRG_GRAY, 0, ' ');
    Echo(WriteR('Size ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
    Echo(': 0 x 0', '', FRG_GRAY, 0, ' ');
  End;

  Echo(WriteR('WinProc ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowLong(hwnd, GWL_WNDPROC);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('DlgProc ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowLong(hwnd, DWL_DLGPROC);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('WindowDC ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowDC(hwnd);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Parent ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetParent(hwnd);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Instance ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowLong(hwnd, GWL_HINSTANCE);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Identifier ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowLong(hwnd, GWL_ID);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Styles ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowLong(hwnd, GWL_STYLE);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  Echo(WriteR('Extended ', 30)+': ', '', FRG_WHITE, 0, ' ', False);
  I:= GetWindowLong(hwnd, GWL_EXSTYLE);
  if I<>0 Then
  Echo(Format('%d | %s', [I, IntToHex(i, 8)]), '', FRG_GRAY, 0, ' ') else
  Echo('0 | 00000000', '', FRG_GRAY, 0, ' ');

  I:= GetWindowModuleFileName(hwnd, buff, sizeOf(buff));
  if I<>0 Then
  Echo(WriteR('Module ', 30)+buff, '', FRG_GRAY, 0, ' ') else
  Echo(WriteR('Module ', 30)+': null', '', FRG_GRAY, 0, ' ');

  WriteLn('');

End;

Procedure CaptureDesktop(Hnd:THandle=0);
var
  hdcScreen,hdcCompatible:HDC;
  hbmScreen:HBITMAP;
  w,h:integer;
  B:TBitmap;R:TRect;
  nm:string;
  buff:Array[0..254]of char;
begin
  WriteLn('Will capturing in 3 sec...');
  Sleep(3000);
  if(Hnd=0)Then
  Begin
    hdcScreen := CreateDC('DISPLAY', nil, nil, nil); //hdcScreen := GetDC(GetDesktopWindow);
    // Create a compatible bitmap for hdcScreen.
    W:= GetDeviceCaps(hdcScreen, HORZRES);
    H:= GetDeviceCaps(hdcScreen, VERTRES);    
  End Else
  Begin
    GetWindowRect(Hnd, R);
    SetActiveWindow(Hnd);
    BringWindowToTop(Hnd);
    sleep(0);
    ProcessMessage();
    
    hdcScreen := GetWindowDC(Hnd);
    SetForegroundWindow(Hnd);

    W:= R.Right-R.Left;
    H:= R.Bottom-R.Top;
  end;


  hdcCompatible := CreateCompatibleDC(hdcScreen);
  hbmScreen     := CreateCompatibleBitmap(hdcScreen, W, H);
  if (hbmScreen = 0) Then exit;

  // Select the bitmaps into the compatible DC.
  if (SelectObject(hdcCompatible, hbmScreen)=0)
  then Exit; //errhandler("Compatible Bitmap Selection", hwnd);

  B:= TBitmap.Create;
  try
    B.Width  := W;
    B.Height := H;
    B.PixelFormat  := pf32bit;
    BitBlt(hdcCompatible, 0, 0, W, H, hdcScreen, 0, 0, SRCCOPY);
    B.Canvas.Handle:= hdcCompatible;
    B.Handle       := hbmScreen;

    GetEnvironmentVariable('USERPROFILE', buff, 254);
    nm:= format('%s\Desktop\Capture-%d.bmp', [buff, GetTickCount]);
    B.SaveToFile(nm);
    WriteLn('captured : ',nm);
  finally
    B.Free;
  end;
End;

//%ERRORLEVEL%
Procedure ErrorExit(Msg:String; exitCode:Integer=0);
Begin
  Echo(Msg, '', FRG_RED, 0);
  ExitProcess(exitCode);
End;

end.
