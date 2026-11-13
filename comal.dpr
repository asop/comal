program comal;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, Messages, Graphics,
  heap32 in 'heap32.pas',
  Stdio in 'STDIO.pas',
  comalUtils in 'comalUtils.pas';

Const
  INDEX_PRMS    = 1;
  INDEX_CAPTURE = 2;
  INDEX_ENUM    = 3;
  INDEX_VISIBLE = 4;
  INDEX_ABOUT   = 5;
  INDEX_HELP    = 6;
  INDEX_PROCESS = 7;
  INDEX_WINDOW  = 8;

  KILPROC   = -100; //result kill process
  TIDPROC   = -101; //result enum tid
  TIDSUSPEND= -102;

  CPlatform ={$IFDEF WIN64}'Win64'{$ELSE}'Win32'{$ENDIF};
  CBit      ={$IFDEF WIN64}'(64 Bit)'{$ELSE}'(32 Bit)'{$ENDIF};
  CAbout    =
  'Command Lite(comal) for '+CPlatform+' version 2.1'#13#10+
  'Copyright (c) 2021-2026 asop';

var
  EnumIdx: DWORD =0;
  iPID: Integer =0;
  THREAD_TASK: TThreadTask;
  iTID: Integer =0;
  iExitCode: Integer =0;
  iTmp: DWORD =0;
  iHeap32: THeap32 = nil;
  switchChar: array [0..13]of char = ('a', 'A', 'c', 'C', 'e', 'E', 'h', 'H', 'p', 'P',
  'v', 'V', 'w', 'W');

Function IsHexa(V: String):Boolean;
var i:integer;
Begin
  Result:= False;
  for i:=1 to Length(V)Do
  if v[i] in ['A'..'F', 'a'..'f'] Then
  Begin
    Result:= True;
    Break;
  End;
End;

Function IsValidNumber(V: String):Boolean;
var i:integer;
Begin
  Result:= True;
  for i:=1 to Length(V)Do
  if not (v[i] in ['A'..'F', 'a'..'f', '0'..'9']) Then
  Begin
    Result:= False;
    Break;
  End;
End;

var x:integer=0;
Function EnumThreadWndProc(hwnd:DWORD; lParam:LPARAM):BOOL; stdcall;
var buff,Tit:array[0..254]of char;
Begin
  FillChar(buff, 254, 0); FillChar(Tit, 254, 0);
  GetClassName(hwnd, buff, SizeOf(buff));
  GetWindowText(hwnd, Tit, SizeOf(Tit));

  if x=0 then
  Begin
    {if (iTID=lParam)AND(iTID<>-1) then
    begin
      FillChar(Tit, 254, 0);
      GetWindowText(hwnd, Tit, SizeOf(Tit));
      WriteLn;
      Echo('Window Handle : '+Format('%d | 0x%s',[hwnd, IntToHex(hwnd,8)]), '', FRG_GRAY, 0);
      Echo('Window Text   : '+Tit, '', FRG_GRAY, 0);
      Echo('Image name    : '+buff, '', FRG_GRAY, 0);
      Echo('TID           : '+Format('%d | 0x%s',[iTID, IntToHex(lParam,8)]), '', FRG_GRAY, 0);
    end;}
    WriteLn;
    Echo(Format('%8s ',['ThreadId']), '', FRG_GREEN, 0, ' ', False);
    Echo(Format('%8s ',['Handle']), '', FRG_GREEN, 0, ' ', False);
    Echo(Format('%25s ',['Class Name']), '', FRG_GREEN, 0, ' ', False);
    Echo('Text', '', FRG_GREEN, 0, ' ');
    WriteLn('======== ======== ========================= =========================');
  End else
  Begin
    if iTmp = 0 Then
    Begin
      Echo(Format('%8d ',[lParam]), '', FRG_WHITE, 0, ' ', False);
      Echo(Format('%8d ',[hwnd]), '', FRG_GREEN, 0, ' ', False);
      Echo(WriteR(buff, 25)+' ', '', FRG_WHITE, 0, ' ', False);
      Echo(Tit, '', FRG_GRAY, 0, ' ');
      iTmp:=1;
    End else
    if iTmp = 1 Then
    Begin
      Echo(Format('%8d ',[lParam]), '', FRG_WHITE, 0, ' ', False);
      Echo(Format('%8d ',[hwnd]), '', FRG_GREEN, 0, ' ', False);
      Echo(WriteR(buff, 25)+' ', '', FRG_WHITE, 0, ' ', False);
      Echo(Tit, '', FRG_GRAY, 0, ' ');
      iTmp:=0;
    End;
  End;
  inc(x);
  if (THREAD_TASK<>THREAD_TASK_SUSPEND)and(x>45)and(iTID=-1) then
  begin
    Writeln('Press any key to continue . . .');
    ReadLn;
    x:=1;
  end else
  If (THREAD_TASK=THREAD_TASK_SUSPEND)And(iTID=lParam) Then
  Begin
    Writeln('THREAD_TASK_FIND ', lParam);
    Result:= False;
    Exit;
  End;
  
  Result:= True;
End;

Function EnumWindowByTID(itid:DWORD):Boolean;
Begin
  Result:= True;
  EnumThreadWindows(itid, @EnumThreadWndProc, itid);
End;

Procedure Help;
Begin
  Echo('Command', '', $a0, 0,' ', false);
  Echo(' Lite', '', $80, 0,' ', false);
  WriteLn('(comal) for '+CPlatform+' version 2.0');
  Write('Copyright (c) 2021-2026 ');
  Echo('asop', '', FRG_GRAY, 0,' ');//WriteLn(CAbout);
  WriteLn('');
  WriteLn('Usage: comal [options]');
  WriteLn('');
  WriteLn('where options include:'); WriteLn('');
  WriteLn('   -c[hwnd]    Capture desktop screen');
  WriteLn('   -e          Enumerates all top level windows on the screen.');
  WriteLn('   -e[hwnd]    Enumerates the child windows on the screen with handle Id.');
  WriteLn('   -v[hwnd]    Set the specified window show state.');
  WriteLn('   -pl         Show short information about a windows process.');
  WriteLn('   -pk[pid]    Kill or terminates the specified windows process with pid.');
  WriteLn('   -pt         Enumerates all windows Thread Id (tid).');
  WriteLn('   -pt[tid]    Find a windows handle by Thread Id.');
  WriteLn('   -w[hwnd]    Find a windows info by handle.');
  WriteLn('   -a          About of comal');
  WriteLn('   -?|h        Print this help message');
  WriteLn('');
  Echo('Examples:', '', FRG_GRAY, 0,' ');
  Echo(WriteL('  comal -c', 18), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -c0', 15), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -e', 15), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -e123', 15), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -vs123', 15), '', FRG_GRAY, 0,' ');

  Echo(WriteL('  comal -vh123', 18), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -pl', 15), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -pk123', 15), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -pt', 15), '', FRG_GRAY, 0,' ', False);
  Echo(WriteL('comal -pt0', 15), '', FRG_GRAY, 0,' ');

  Echo(WriteL('  comal -w123', 18), '', FRG_GRAY, 0,' ', False);
  WriteLn('');
End;

function EnumChildProc(H:HWND; lParam:LPARAM):Boolean; stdcall;
var
  buff,cls:Array[0..254]of char;
begin
  if 0=EnumIdx then
  begin
    WriteLn;
    Echo(Format('%8s ',['Handle']), '', FRG_GREEN, 0, ' ', False);
    Echo(WriteR('Class Name', 25)+' ', '', FRG_GREEN, 0, ' ', False);
    Echo('Title', '', FRG_GREEN, 0, ' ');
    WriteLn('======== ========================= ============================');    
  end;
  if (IsWindow(H))Then    //and(IsWindowVisible(H))
  Begin
    Inc(EnumIdx);

    Echo(Format('%8d ',[h]), '', FRG_GREEN, 0, ' ', false);

    FillChar(cls, sizeof(cls), 0);
    if GetClassName(H, cls, sizeof(cls))<>0 Then
    Echo(WriteR(cls, 25)+' ', '', FRG_WHITE, 0,' ', false);

    FillChar(buff, sizeof(buff), 0);
    GetWindowText(H, buff, sizeof(buff));
    if Length(String(buff))<>0 Then
    Echo(buff, '', FRG_WHITE, 0, ' ')Else
    Echo(cls, '', FRG_GRAY, 0, ' ');
  End;
  Result:= True;
end;

Function GetIndex(P:String; index:Integer; SubChr:Array of Char):Byte;
var i,j:Integer;
Begin
  Result:= 0;
  if index>Length(P)Then Exit;
  for i:=1 to index do
  Begin
    for j:=0 to high(SubChr) do
    if P[i]=SubChr[j] Then  //switchChar
    Begin
      if P[i] in ['-', '/']     Then Result:= INDEX_PRMS Else
      if P[i] in ['a', 'A']     Then Result:= INDEX_ABOUT Else
      if P[i] in ['c', 'C']     Then Result:= INDEX_CAPTURE Else
      if P[i] in ['e', 'E']     Then Result:= INDEX_ENUM Else
      if P[i] in ['h', 'H', '?']Then Result:= INDEX_HELP Else
      if P[i] in ['p', 'P']     Then Result:= INDEX_PROCESS Else
      if P[i] in ['v', 'V']     Then Result:= INDEX_VISIBLE Else
      if P[i] in ['w', 'W']     Then Result:= INDEX_WINDOW Else;
      if Result<>0 Then exit;
    End;
    if Result<>0 Then exit;
  End;
End;

//========================= ======== ================ =========== ============
Procedure OnGetThreadEntry(R: THeapThreadEntry; var stop:Boolean);
Begin
  stop:= false;
  Case THREAD_TASK Of
    THREAD_TASK_FIND:
    Begin
      if DWORD(iTID)=R.th32ThreadID then
      Begin
        WriteLn;
        Echo('TID       : '+Format('%6d ',[R.th32ThreadID]), '', FRG_GRAY, 0);
        Echo('PID Owner : '+Format('%6d ',[R.th32OwnerProcessID]), '', FRG_GRAY, 0);
        stop:= True;
        EnumWindowByTID(R.th32ThreadID);
        iTID:= TIDPROC;
      End;
    End;

    THREAD_TASK_SUSPEND:
    if DWORD(iTID)=r.th32ThreadID Then
    Begin
      WriteLn;

      if SuspendThread(r.th32ThreadID)<>$FFFFFFFF Then
      Begin
        Echo('Owner       : '+Format('%d (%s)', [R.th32OwnerProcessID, IntToHex(R.th32OwnerProcessID, 8)]), '', FRG_WHITE, 0);
        Echo('TID         : '+Format('%d (%s)', [R.th32ThreadID, IntToHex(R.th32ThreadID, 8)]), '', FRG_WHITE, 0);
        Echo('process suspended.', '', FRG_GREEN, 0);
      end else
      Begin
        Echo('Owner       : '+Format('%d (%s)', [R.th32OwnerProcessID, IntToHex(R.th32OwnerProcessID, 8)]), '', FRG_WHITE, 0);
        Echo('TID         : '+Format('%d (%s)', [R.th32ThreadID, IntToHex(R.th32ThreadID, 8)]), '', FRG_WHITE, 0);
        Echo(SysErrorMessage(GetLastError), '', FRG_RED, 0);
      End;
      //if vT<>0 Then CloseHandle(vT);
      stop:= True;
      exit;
    End;

    {THREAD_TASK_RESUME:
    if DWORD(iPID)=R.th32ThreadID Then
    Begin
      prc:= OpenProcess(PROCESS_CREATE_THREAD, false, R.th32ProcessID);
      if prc=0 Then
      Begin
        Echo('OpenProcess '+IntToHex(prc,8)+' failed.', '', FRG_RED, 0);
        stop:= true;
      End;
      WriteLn;

      vT:= CreateRemoteThread(prc, nil, 0, @ThreadFunc, nil, CREATE_SUSPENDED, vTid);
      if vT=0 Then
      Begin
        Echo('CreateRemoteThread'+SysErrorMessage(GetLastError), '', FRG_RED, 0);
        stop:= true;Exit;
      End else
      Echo('CreateRemoteThread ok .', '', FRG_GREEN, 0);
      
      if ResumeThread(vT)<>$FFFFFFFF Then
      Begin
        Echo('TID         : '+Format('%d (%s)', [prc, IntToHex(prc, 8)]), '', FRG_WHITE, 0);
        Echo('Owner       : '+Format('%d (%s)', [R.th32ParentProcessID, IntToHex(R.th32ParentProcessID, 8)]), '', FRG_WHITE, 0);
        Echo('PID         : '+Format('%d (%s)', [R.th32ProcessID, IntToHex(R.th32ProcessID, 8)]), '', FRG_WHITE, 0);
        Echo('Image       : '+R.szExeFile, '', FRG_WHITE, 0);
        Echo('process restarted.', '', FRG_GREEN, 0);
      end else
      Begin
        Echo('TID         : '+Format('%d (%s)', [prc, IntToHex(prc, 8)]), '', FRG_WHITE, 0);
        Echo('Owner       : '+Format('%d (%s)', [R.th32ParentProcessID, IntToHex(R.th32ParentProcessID, 8)]), '', FRG_WHITE, 0);
        Echo('PID         : '+Format('%d (%s)', [R.th32ProcessID, IntToHex(R.th32ProcessID, 8)]), '', FRG_WHITE, 0);
        Echo('Image       : '+R.szExeFile, '', FRG_WHITE, 0);
        Echo('resume process pid '+IntToHex(prc, 8)+' failed.', '', FRG_RED, 0);
        Echo(SysErrorMessage(GetLastError), '', FRG_RED, 0);
      End;
      if vT<>0 Then CloseHandle(vT);
      stop:= True;
      exit;
    End;}

    //view ThreadId only
    THREAD_TASK_LIST: EnumWindowByTID(R.th32ThreadID);
  End;
   
  //if iTID<>-1 Then Goto FindTid;
  //if EnumIdx<10 then
  //Write(Format('%6d ',[R.th32ThreadID]))else   //Write(ZeroSpace(Inttostr(R.th32ThreadID), 6),' ')else
  //WriteLn(Format('%6d ',[R.th32ThreadID]));
  //if EnumIdx<10 then Inc(EnumIdx)else EnumIdx:=0;

End;

Function ThreadFunc(hwnd:HWND):DWORD; stdcall;
Begin
  Result:= 0;
End;

Procedure OnGetProcessEntry(R: THeapProcessEntry; var stop:Boolean);
var Prc:DWORD;
Label Terminate;
Begin
  Case THREAD_TASK Of
    THREAD_TASK_KILL:
    Begin
        if DWORD(iPID)=R.th32ProcessID Then
        Begin
          prc:= OpenProcess(PROCESS_ALL_ACCESS, false, iPID);
          if prc=0 Then
          Begin
            Echo('OpenProcess 0x'+IntToHex(prc,8)+' failed.', '', FRG_RED, 0);
            stop:= true;
          End;
          if TerminateProcess(prc, 0)Then
          Begin
            Echo('Image name  : '+R.szExeFile, '', FRG_GRAY, 0);
            Echo('PID         : 0x'+IntToHex(prc,8), '', FRG_GRAY, 0);
            Echo('Kill process successful.', '', FRG_GREEN, 0);
          end else
          Echo('Kill process pid 0x'+IntToHex(prc,8)+' failed.', '', FRG_RED, 0);
          iPID:= KILPROC;
          stop:= true;
          Exit;
        End;
    End;

    Else
    Begin
      if EnumIdx=0 then
      Begin
        //Image Name                     PID Session Name        Session#    Mem Usage
        WriteLn('');
        Echo(WriteL(' Image Name', 25), '', FRG_GREEN, 0, ' ', False);
        Echo(Format('%9s ',['PID']), '', FRG_GREEN, 0, ' ', False);
        Echo(Format('%10s ',['Parent']), '', FRG_GREEN, 0, ' ', False);
        Echo(Format('%9s ',['Count']), '', FRG_GREEN, 0, ' ');
        WriteLn('========================= ======== ========== ==============');
      End else
      Begin
        if iTmp = 0 Then
        Begin
          Echo(WriteL(R.szExeFile, 25), '', FRG_GREEN, 0, ' ', False);
          Echo(Format('%9.d ',[R.th32ProcessID]), '', FRG_WHITE, 0, ' ', False);
          Echo(Format('%9.d ',[R.th32ParentProcessID]), '', FRG_WHITE, 0, ' ', False);
          Echo(Format('%9.d ',[R.cntThreads]), '', FRG_GRAY, 0, ' ');
          iTmp:=1;
        End else
        if iTmp = 1 Then
        Begin
          Echo(WriteL(R.szExeFile, 25), '', FRG_GREEN, 0, ' ', False);
          Echo(Format('%9.d ',[R.th32ProcessID]), '', FRG_GRAY, 0, ' ', False);
          Echo(Format('%9.d ',[R.th32ParentProcessID]), '', FRG_GRAY, 0, ' ', False);
          Echo(Format('%9.d ',[(R.cntThreads)]), '', FRG_GRAY, 0, ' ');
          iTmp:=0;
        End;
      //Terminate Process
      //Terminate:

      End;
    End;
  End;

  //if iPID<>0 Then goto Terminate;
  Inc(EnumIdx);
End;

var wnd:Integer;
  P,S:string;
  Buff:array [0..255]of char;

Procedure MainMenu;
var
  i :Integer;
  PE:THeapProcessEntry;
  TE:THeapThreadEntry;
Begin
  if ParamCount>0 Then
  Begin
    For i:=1 to ParamCount Do
    Begin
      P:= ParamStr(i);
      if GetIndex(P, 1, ['-', '/'])=INDEX_PRMS Then
      Begin
        Case GetIndex(P, 2, switchChar) Of
          INDEX_ABOUT:
            Begin
              WriteLn(CAbout);
              Exit;
            End;

          INDEX_CAPTURE: //-c28776396
          Begin
            if (Length(P)>=3) then
            Begin
              Try
                S:= Trim(Copy(P, 3, Length(P)-2)); // WriteLn(S);exit;
                if IsValidNumber(S) Then
                  if IsHexa(S) Then
                    wnd:= StrToint('$'+S)else
                    wnd:= StrToint(S)
                else
                Begin
                  Echo(Format('Handle %s not valid value.', [S]), '', FRG_RED, 0);
                  ExitProcess(1);
                End;

                if not IsWindow(wnd)then
                Begin
                  Echo('Invalid window handle '+S, '', FRG_RED, 0);
                  ExitProcess(1);
                End;
                CaptureDesktop(wnd);
              Except
                On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
              End;
            End else
            CaptureDesktop;

            Exit;
          End;

          INDEX_ENUM: //-e28776396
          Begin
            if (Length(P)>=3)Then
            Begin
              Try
                S:= Trim(Copy(P, 3, Length(P)-2));
                if IsValidNumber(S) Then
                  if IsHexa(S) Then
                    wnd:= StrToint('$'+S)else
                    wnd:= StrToint(S)
                else
                Begin
                  Echo(Format('Handle %s not valid value.', [S]), '', FRG_RED, 0);
                  ExitProcess(1);
                End;
                
                if not IsWindow(wnd)then
                Begin
                  Echo('Invalid window handle '+S, '', FRG_RED, 0);
                  ExitProcess(1);
                End;

                Echo('Hwnd      : 0x'+IntToHex(wnd, 8), '', FRG_GRAY, 0, ' ');
                FillChar(Buff, SizeOf(Buff), 0);
                GetClassName(wnd, Buff, SizeOf(Buff));
                Echo('Classname : '+Buff, '', FRG_GRAY, 0, ' ');

                FillChar(Buff, SizeOf(Buff), 0);
                GetWindowText(wnd, Buff, SizeOf(Buff));
                Echo('Title     : '+Buff, '', FRG_GRAY, 0, ' ');
                WriteLn('');
                EnumChildWindows(wnd, @EnumChildProc, 0);
              Except
                On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
              End;
            End else
            EnumWindows(@EnumChildProc, 0);
            Exit;
          End;

          INDEX_HELP:
          Begin
            Help();
            Exit;
          End;

          INDEX_VISIBLE: //-vs552233
          Begin
            if (Length(P)>=3)And(P[3] in ['s', 'S', 'h', 'H']) then
            Begin
              Try
                S:= Trim(Copy(P, 4, Length(P)-3));  //WriteLn(S);exit;
                if IsValidNumber(S) Then
                  if IsHexa(S) Then
                    wnd:= StrToint('$'+S)else
                    wnd:= StrToint(S)
                else
                Begin
                  Echo(Format('Handle %s not valid value.', [S]), '', FRG_RED, 0);
                  ExitProcess(1);
                End;

                if not IsWindow(wnd)then
                Begin
                  Echo('Invalid window handle '+S, '', FRG_RED, 0);
                  ExitProcess(1);
                End;

                Echo('Hwnd      : 0x'+IntToHex(wnd, 8), '', FRG_GRAY, 0, ' ');
                FillChar(Buff, SizeOf(Buff), 0);
                GetClassName(wnd, Buff, SizeOf(Buff));
                Echo('Classname : '+Buff, '', FRG_GRAY, 0, ' ');

                FillChar(Buff, SizeOf(Buff), 0);
                GetWindowText(wnd, Buff, SizeOf(Buff));
                Echo('Title     : '+Buff, '', FRG_GRAY, 0, ' ');
                Echo('Visible   : '+BoolToStr(IsWindowVisible(wnd), True), '', FRG_GRAY, 0, ' ');
                WriteLn('');

                if P[3] in ['s', 'S']Then
                ShowWindow(wnd, SW_SHOW) Else
                ShowWindow(wnd, SW_HIDE);

              Except
                On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
              End;
            End else
            ErrorExit(Format('The input parameter is incorrect. "%s".  Try comal -?', [P]), 1);

            Exit;
          End;

          INDEX_PROCESS:
          Begin
            //---------------------------------------------------------------
            // Show short information about a windows process.
            // -pl
            //---------------------------------------------------------------
            if (Length(P)=3)And(P[3] in ['l', 'L']) then
            Try
              THREAD_TASK:= THREAD_TASK_LIST;
              iHeap32:= THeap32.Create(SnapALL);
              try
                iHeap32.OnProcessEntry:= OnGetProcessEntry;
                iHeap32.EnumProcess;
                WriteLn('========================= ======== ========== ==============');
                Echo(WriteL(Format('%d process',[EnumIdx]), 25), '', FRG_WHITE, 0, ' ');
              finally
                iHeap32.Free;
              end;
              Exit;
            Except
              On E:Exception Do ErrorExit(E.Message, 1);
            End else
            
            //---------------------------------------------------------------
            // Kill or terminates the specified windows process with pid.
            // -pk1111
            //---------------------------------------------------------------
            if (Length(P)>3)And(P[3] in ['k', 'K']) then 
            Try
              THREAD_TASK:= THREAD_TASK_KILL;
              S:= Trim(Copy(P, 4, Length(P)-3));  //WriteLn(S);exit;
              if IsValidNumber(S) Then
                if IsHexa(S) Then
                  iPID:= StrToint('$'+S)else
                  iPID:= StrToint(S)
              else
              ErrorExit(Format('PID %s not valid value.', [S]), 1);

              iHeap32:= THeap32.Create(SnapALL);
              try
                iHeap32.OnProcessEntry:= OnGetProcessEntry;
                iHeap32.EnumProcess;
              finally
                iHeap32.Free;
              end;
              if iPID<>KILPROC Then
              ErrorExit(Format('PID %s not found.', [S]), 1);
              Exit;
            Except
              On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
            End else
            //---------------------------------------------------------------
            // comal -pt1111
            // Find a windows handle by Thread Id
            //---------------------------------------------------------------            
            if (Length(P)>=3)And(P[3] in ['t', 'T']) then
            Try
              if (Length(P)>3)And(P[3] in ['t', 'T']) then
              Begin
                THREAD_TASK:= THREAD_TASK_FIND;
                S:= Trim(Copy(P, 4, Length(P)-3));  //WriteLn(S);exit;
                if IsValidNumber(S) Then
                  if IsHexa(S) Then
                    iTID:= StrToint('$'+S)else
                    iTID:= StrToint(S)
                else
                ErrorExit(Format('ThreadID %s not valid value.', [S]), 1);
              End else
              Begin
                iTID:= -1; //-pt only
                THREAD_TASK:= THREAD_TASK_LIST;
              End;

              iHeap32:= THeap32.Create(SnapALL);
              try
                iHeap32.OnThreadEntry:= OnGetThreadEntry;
                iHeap32.EnumThreadEntry;
              finally
                iHeap32.Free;
              end;
              if (iTID<>-1)And(iTID<>TIDPROC) Then
              ErrorExit(Format('ThreadID %s not found.', [S]), 1) else;
              Exit;
            Except
              On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
            End else
            //---------------------------------------------------------------
            // Suspends the specified windows process by pid.
            // comal -pp1111
            //---------------------------------------------------------------
            if (Length(P)>3)And(P[3] in ['p', 'P']) then
            Try
              S:= Trim(Copy(P, 4, Length(P)-3));  //WriteLn(S);exit;
              if IsValidNumber(S) Then
                if IsHexa(S) Then
                  iPID:= StrToint('$'+S)else
                  iPID:= StrToint(S)
              else
              Begin
                ErrorExit(Format('PID %s not valid value.', [S]), 1);
              End;
              THREAD_TASK:= THREAD_TASK_SUSPEND;
              iHeap32:= THeap32.Create(SnapALL);
              try
                iHeap32.FindProcess(iPID, 0, PE);   
              finally
                iHeap32.Free;
              end;
            Except
              On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
            End else
            //---------------------------------------------------------------
            // Restart | resume the specified windows process by pid.
            // comal -pr1111
            //---------------------------------------------------------------
            if (Length(P)>3)And(P[3] in ['r', 'R']) then
            Try
              S:= Trim(Copy(P, 4, Length(P)-3));  //WriteLn(S);exit;
              if IsValidNumber(S) Then
                if IsHexa(S) Then
                  iPID:= StrToint('$'+S)else
                  iPID:= StrToint(S)
              else
              Begin
                ErrorExit(Format('PID %s not valid value.', [S]), 1);
              End;
              THREAD_TASK:= THREAD_TASK_RESUME;
              iHeap32:= THeap32.Create(SnapALL);
              try
                iHeap32.OnProcessEntry:= OnGetProcessEntry;
                iHeap32.EnumProcess;
              finally
                iHeap32.Free;
              end;
            Except
              On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
            End else            
            ErrorExit(Format('The input parameter is incorrect. "%s".  Try comal -?', [P]), 1);
            Exit;
          End;

          INDEX_WINDOW: //-w552233
          Begin                       
            if (Length(P)>=3)Then //And(P[3] in ['s', 'S', 'h', 'H']) then
            Begin
              Try
                S:= Trim(Copy(P, 3, Length(P)-2));  //WriteLn(S);exit;
                if IsValidNumber(S) Then
                  if IsHexa(S) Then
                    wnd:= StrToint('$'+S)else
                    wnd:= StrToint(S)
                else
                Begin
                  Echo(Format('Handle %s not valid value.', [S]), '', FRG_RED, 0);
                  Exit;
                End;

                if not IsWindow(wnd)then
                Begin
                  Echo('Invalid window handle '+S, '', FRG_RED, 0);
                  exit;
                End;
                WinInfo(wnd);
                Exit;
              Except
                On E:Exception Do Echo(E.Message, '', FRG_RED, 0);
              End;
            End else
            ErrorExit(Format('The input parameter is incorrect. "%s".  Try comal -?', [P]), 1);
            Exit;
          End
          
          else
          Begin
            ErrorExit(Format('The input parameter is incorrect. "%s".  Try comal -?', [P]), 1);
          End;

        end;//Case
      end else
      Begin
        ErrorExit(Format('The input parameter is incorrect. "%s".  Try comal -?', [P]), 1);
      End;
    End;
  End else
  Help;
End;

begin
  EchoSetup;  //Heap32: THeap32;
  MainMenu;
end.
