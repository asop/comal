unit Heap32;

interface

uses
  SysUtils, Windows, Messages, TlHelp32;

Type
  TSnapshotType = (SnapHeapLIST, SnapPROCESS, SnapTHREAD, SnapMODULE, SnapALL);

  THeapEntry        = THeapEntry32;
  THeapList         = THeapList32;
  THeapModuleEntry  = TModuleEntry32;
  THeapProcessEntry = TProcessEntry32;
  THeapThreadEntry  = TThreadEntry32;

  TOnHeapList        = Procedure(result: THeapList)of object;
  TOnHeapEntry       = Procedure(result: THeapEntry)of object;
  TOnHeapModuleEntry = Procedure(result: THeapModuleEntry)of object;
  TOnHeapProcessEntry= Procedure(result: THeapProcessEntry; var stop:Boolean);//of object;
  TOnHeapThreadEntry = Procedure(result: THeapThreadEntry; var stop:Boolean);//of object;
  
  THeap32 = class
  Private
    FHandle     : THandle;
    FPID        : DWORD;
    FSnapshotType: TSnapshotType;
    FHeapEnt32  : THeapEntry32;
    FHeapList32 : THeapList32;
    FModEntry32 : TModuleEntry32;
    FProcEntry32: TProcessEntry32;
    FThrEntry32 : TThreadEntry32;
    FOnModuleEntry: TOnHeapModuleEntry;
    FOnProcessEntry: TOnHeapProcessEntry;
    FOnHeapEntry: TOnHeapEntry;
    FOnHeapList: TOnHeapList;
    FOnThreadEntry: TOnHeapThreadEntry;
    function EnumHeapEntry(var xHeapList : THeapList32): Integer;
  Protected

  Public
    Constructor Create(SnapshotType: TSnapshotType; hPID:DWORD=0);
    Destructor Destroy;override;

    function EnumModuls(): Integer;
    function EnumProcess(): Integer;
    function EnumHeapList(): Integer;
    function EnumThreadEntry(): Integer;

    function FindProcessByName(const prcName:PChar; var P:THeapProcessEntry): Boolean;
    function FindProcess(const pid,owner:DWORD; var P:THeapProcessEntry): Boolean;
    function FindThread(const tid,pid:DWORD; var P:THeapThreadEntry): Boolean;

    Property Handle: THandle Read FHandle Write FHandle;
    Property OnModuleEntry: TOnHeapModuleEntry Read FOnModuleEntry Write FOnModuleEntry;
    Property OnProcessEntry: TOnHeapProcessEntry Read FOnProcessEntry Write FOnProcessEntry;
    Property OnHeapList: TOnHeapList Read FOnHeapList Write FOnHeapList;
    Property OnHeapEntry: TOnHeapEntry Read FOnHeapEntry Write FOnHeapEntry;
    Property OnThreadEntry: TOnHeapThreadEntry Read FOnThreadEntry Write FOnThreadEntry;
  End;

implementation


{ THeap32 }

var iSnap:array[TSnapshotType]of DWORD=(TH32CS_SNAPHEAPLIST, TH32CS_SNAPPROCESS,
    TH32CS_SNAPTHREAD, TH32CS_SNAPMODULE,TH32CS_SNAPALL);

constructor THeap32.Create;
begin
  FSnapshotType := SnapshotType;
  FPID          := hPID;
  FHandle       := CreateToolhelp32Snapshot(iSnap[TSnapshotType(FSnapshotType)], FPID);
  if FHandle=0 Then
  Begin
    raise Exception.Create('THeap32 Create Exception:'+ SysErrorMessage(GetLastError));
  End;
  
  fHeapList32.dwSize  := sizeOf(fHeapList32);
  fHeapEnt32.dwSize   := sizeOf(fHeapEnt32);
  fModEntry32.dwSize  := sizeOf(fModEntry32);
  fProcEntry32.dwSize := sizeOf(fProcEntry32);
  fThrEntry32.dwSize  := sizeOf(fThrEntry32);
end;

destructor THeap32.Destroy;
begin
  CloseHandle(FHandle);  
end;

function THeap32.EnumHeapEntry(var xHeapList : THeapList32): Integer;
begin
  Result:= 0;
  if Heap32First(FHeapEnt32, xHeapList.th32ProcessID, xHeapList.th32HeapID)Then //raise Exception.Create('EnumHeapEntry Exception:'+ SysErrorMessage(GetLastError));
  Repeat
    if Assigned(FOnHeapEntry)Then OnHeapEntry(FHeapEnt32);
    WriteLn('   EnumHeapEntry.Handle: ', FHeapEnt32.hHandle);
    Inc(Result);
  Until not Heap32Next(FHeapEnt32);
end;

function THeap32.EnumHeapList: Integer;
begin
  Result:= 0;
  if not Heap32ListFirst(FHandle, FHeapList32)Then Exit;
  //raise Exception.Create('EnumHeapList Exception:'+ SysErrorMessage(GetLastError));

  Repeat
    if Assigned(FOnHeapList)Then OnHeapList(FHeapList32);
    WriteLn('EnumHeapList PID: ', FHeapList32.th32ProcessID);
    EnumHeapEntry(FHeapList32);
    Inc(Result);
  Until not Heap32ListNext(FHandle, FHeapList32);
end;

function THeap32.EnumModuls(): Integer;
begin
  Result:= 0;
  fModEntry32.dwSize  := sizeOf(FModEntry32);
  if not Module32First(FHandle, FModEntry32)Then
  begin
    //WriteLn('EnumModuls Failed:', SysErrorMessage(GetLastError));
    Exit;
  end;
  //raise Exception.Create('EnumModuls Exception:'+ SysErrorMessage(GetLastError));

  Repeat
    //WriteLn(FModEntry32.szModule,':', FModEntry32.szExePath);
    //WriteLn('ModuleName ', GetModuleName(FModEntry32.hModule));
    if Assigned(FOnModuleEntry)Then OnModuleEntry(FModEntry32);
    Inc(Result);
  Until not Module32Next(FHandle, FModEntry32);
end;

function THeap32.EnumProcess: Integer;
var stop:Boolean;
begin
  Result:= 0;
  if not Process32First(FHandle, FProcEntry32)Then Exit;
  //raise Exception.Create('EnumProcess Exception:'+ SysErrorMessage(GetLastError));
  stop:= false;
  Repeat
    if Assigned(FOnProcessEntry)Then OnProcessEntry(FProcEntry32, stop);
    if stop then break;
    //WriteLn('ExeFile ', FProcEntry32.szExeFile, ' | ', FProcEntry32.th32ProcessID, ' | ', FProcEntry32.th32ParentProcessID);
    Inc(Result);
  Until not Process32Next(FHandle, FProcEntry32);
end;

function THeap32.EnumThreadEntry: Integer;
var stop:Boolean;
begin
  Result:= 0;
  if not Thread32First(FHandle, FThrEntry32)Then Exit;
  //raise Exception.Create('EnumThread Exception:'+ SysErrorMessage(GetLastError));
  stop:= false;
  Repeat
    if Assigned(FOnThreadEntry)Then OnThreadEntry(FThrEntry32, stop);
    if stop then break;
    Inc(Result);
  Until not Thread32Next(FHandle, FThrEntry32);
end;

function THeap32.FindProcessByName(const prcName:PChar; var P:THeapProcessEntry): Boolean;
begin
  Result:= false;
  P.dwSize:= SizeOf(THeapProcessEntry);
  if not Process32First(FHandle, P)Then Exit;
  Repeat
    WriteLn(prcName, ' = ', P.szExeFile);
    if (LowerCase(prcName)=LowerCase(P.szExeFile)) then
    begin
      Result:= true;
      break;
    end;   
  Until not Process32Next(FHandle, P);  
end;

function THeap32.FindProcess(const pid,owner:DWORD; var P:THeapProcessEntry): Boolean;
begin
  Result:= false;
  P.dwSize:= SizeOf(THeapProcessEntry);
  if not Process32First(FHandle, P)Then Exit;
  Repeat
    if (pid>0)and(owner=0)and(pid=P.th32ProcessID) then
    begin
      Result:= true;
      break;
    end else
    if (pid=0)and(owner>0)and(owner=P.th32ParentProcessID) then
    begin
      Result:= true;
      break;
    end;    
  Until not Process32Next(FHandle, P);
end;

function THeap32.FindThread(const tid,pid:DWORD; var P:THeapThreadEntry): Boolean;
begin
  Result:= false;
  P.dwSize:= SizeOf(THeapThreadEntry);
  if not Thread32First(FHandle, P)Then
  begin
    //MessageBox(0, pchar(SysErrorMessage(GetLastError)), nil, 0);
    Exit;
  end;
  Repeat
    //WriteLn('PID:', P.th32OwnerProcessID, ' TID:',P.th32ThreadID);
    if (tid>0)and(pid=0)and(tid=P.th32ThreadID) then
    begin
      Result:= true;
      break;
    end else
    if (tid=0)and(pid>0)and(pid=P.th32OwnerProcessID) then
    begin
      Result:= true;
      break;
    end;
  Until not Thread32Next(FHandle, P);  
end;

end.
