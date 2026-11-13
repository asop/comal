unit Stdio;

interface

uses
  SysUtils, Windows, Messages, SyncObjs;

Const
  IOBUFSz = 32767; //HIWORD div 2
  CRLF    = #13#10;

Const
  FRG_BLACK = $0;
  FRG_BLUE  = $1;
  FRG_GREEN = $2;
  FRG_AQUA  = $3;
  FRG_RED   = $4;
  FRG_PURPLE= $5;
  FRG_YELLOW= $6;
  FRG_WHITE = $7;
  FRG_GRAY  = $8;
  BG_GRAY   = FRG_GRAY;

  FRG_BLUE_LIGHT    = $9;
  FRG_GREEN_LIGHT   = $A;
  FRG_AQUA_LIGHT    = $B;
  FRG_RED_LIGHT     = $C;
  FRG_PURPLE_LIGHT  = $D;
  FRG_YELLOW_LIGHT  = $E;
  FRG_WHITE_LIGHT   = $F;

  BG_LIGHT_BLUE   = $10;
  BG_LIGHT_GREEN  = $20;
  BG_LIGHT_AQUA   = $30;
  BG_LIGHT_RED    = $40;
  BG_LIGHT_PURPLE = $50;
  BG_LIGHT_YELLOW = $60;
  BG_LIGHT_WHITE  = $80;

Type
  TCtrlType = (CTRL_C, CTRL_BREAK, CTRL_CLOSE, CTRL_LOGOFF, CTRL_SHUTDOWN);
  TColorType = (ctBlack, ctBlue, ctGreen, ctAqua, ctRed, ctPurple, ctYellow, ctWhite, ctGray,
                ctBlueLight, ctGreenLight, ctAquaLight, ctRedLight, ctPurpleLight, ctYellowLight, ctWhiteLight,
                ctBGray, ctBLightBlue, ctBLightGreen, ctBLightAqua, ctBLightRed,
                ctBLightPurple, ctBLightYellow, ctBLightWhite, ctSame);
  TOnScanArgumen = Procedure(index:Integer; Value:String);

  TStd = class
  Private
    FHandle: THandle;
    FCord  : COORD;
  Protected
  Public
    Constructor Create;
    function Fill(X, Y: SmallInt; iLen, iColor: WORD): DWORD;
    function Write(Text: String): DWORD; Overload;
    function Write(Text: String; X, Y: Smallint): DWORD; Overload;
    function Write(Text: String; X, Y: Smallint; Color: WORD): DWORD; Overload;
    Function SetColor(const Value: WORD): Boolean;
    function Read(): String;

    class function SignalKey(const iType: TCtrlType):Boolean;
    class Procedure SetColorType(iStdOut: THandle; Value: TColorType); Overload;
    class Procedure SetColorType(iStdOut: THandle; Value: Word); Overload;

    Property Handle: THandle Read FHandle Write FHandle;
  End;

  TStdOutput = class(TStd)
  Public
    Constructor Create;
    Destructor Destroy;Override;

    { Write | WriteLn, diload dari Library di D11 not support }
    class Procedure Write(const Text: String=''; Color:TColorType=ctWhiteLight);overload;
    class Procedure Write(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight);overload;
    class Procedure WriteLn(const Text: String=''; Color:TColorType=ctWhiteLight); overload;
    class Procedure WriteLn(const Key, Value: String; Color1:TColorType=ctWhiteLight; Color2: TColorType=ctWhite);overload;
    class Procedure WriteLn(const Msg: String; args:Array of const; Color:TColorType=ctWhiteLight);overload;

    class Procedure WriteLn(O:TObject; Text: String; Color:TColorType=ctWhiteLight);overload;
    class Procedure WriteLn(O:TObject; const Msg: String; args:Array of const; Color:TColorType=ctWhiteLight);overload;

    class Procedure WriteLnCl(const Msg: String; args:Array of const; Color:DWord);

    class procedure FillLine(Color:TColorType; Y:Integer);
    class Function  printy(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight):Integer;
    class procedure printAtY(const Text: String; args:Array of const; X,Y:Integer; Color:TColorType=ctWhiteLight);
    class Function  PrintCenter(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight): Integer;
    class Function  PrintCenterLeft(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight): Integer;
    class Function  PrintCenterRight(const Text: String; args:Array of const; Y:Integer; Color:TColorType=ctWhiteLight): Integer;
    class Procedure WriteLnAt(const Text: String=''; Color:TColorType=ctWhiteLight; X: Integer=0; Y: Integer=0);
    class procedure WriteLnp(const Text: String; P:TPoint);

    class procedure Print(const Text:String; FG:TColorType=ctWhite; BG:TColorType=ctBlack);
    Class Procedure PrintLn(const Text:String; FG:TColorType=ctWhite; BG:TColorType=ctBlack);overload;
    Class Procedure PrintLn(const Key,Value:String; FG:TColorType=ctWhite; BG:TColorType=ctBlack);overload;
    Class function  GetHandle:THandle;
    Class function  GetConsoleInfo:TConsoleScreenBufferInfo;
    Class Function  Point(): TPoint;
    class Procedure SetStdOut(const newStdOut:THandle);
  End;

  TStdOut = class(TStdOutput);

  TStdData = Record
    sWrite  : THandle;
    sRead   : THandle;
    sClone  : THandle;
    sBackup : THandle;
  End;

  TRedirectEvent = Procedure(const buff:String); stdcall;
  {-----------------------------------------------------------------------------
    If StdSetup Then
    Try
      Sukses:= NewProcess(nil, ...);
    Finally
      StdRestore;
    End;
    StdReadData
   ----------------------------------------------------------------------------}
  TStdReader = class(TStdOut)
  Private
    FSecuAtr: SECURITY_ATTRIBUTES;
    FInput, FOutput : TStdData;
    FRedirect: TRedirectEvent;
  Protected
    Function SetupHandle: Boolean;
    Function CloneHandle(Const Source:THandle; Target:PHandle): Boolean;
  Public
    Constructor Create(Redirect:TRedirectEvent);
    Destructor Destroy; Override;

    procedure ReadHandle;
    procedure RestoreHandle;

    property Input  : TStdData Read FInput;
    property Output : TStdData Read FOutput;
  End;

  TStdInput = class(TStd)
  Private
  Public
    Constructor Create;
    Destructor Destroy;Override;
  End;

  TSTDIO = Class
  Private
    FInput  : TStdInput;
    FOutput : TStdOutput;
    FInfo   : CONSOLE_SCREEN_BUFFER_INFO;
  public
    Constructor Create;
    Destructor Destroy;Override;

    Function Fill(X,Y: WORD; iColor: WORD): DWORD;

    Property Input: TStdInput Read FInput;
    Property Output: TStdOutput Read FOutput;

    { class }
    class function IHandle: THandle;
    class function IWrite(const Text: String): Boolean;

    class function OHandle: THandle;
    class function OWrite(const Text: String): Boolean;
    class function ORead: String;

    class function EHandle: THandle;

    class function ValidHwnd(Const iHwnd: THandle): Boolean;
    class function Read(Const iHwnd: THandle): String;
    class function Write(const iHwnd: THandle; const Text: String): Boolean;

    class function SignalKey(const iType: TCtrlType): Boolean;
    class function SysError: String;
  end;

Const
  ColorType: Array[TColorType] of WORD =(
  FRG_BLACK, FRG_BLUE, FRG_GREEN, FRG_AQUA, FRG_RED, FRG_PURPLE, FRG_YELLOW,
  FRG_WHITE, FRG_GRAY,
  FRG_BLUE_LIGHT, FRG_GREEN_LIGHT, FRG_AQUA_LIGHT, FRG_RED_LIGHT, FRG_PURPLE_LIGHT,
  FRG_YELLOW_LIGHT, FRG_WHITE_LIGHT,
  BG_GRAY, BG_LIGHT_BLUE, BG_LIGHT_GREEN, BG_LIGHT_AQUA, BG_LIGHT_RED,
  BG_LIGHT_PURPLE, BG_LIGHT_YELLOW, BG_LIGHT_WHITE, 0);

  Procedure InitScreenBufferSizeInfo();
  Function ZeroSpace(Txt:String; Len:Integer; ch:Char='0'):String;
  Function AddSpace(Txt:String; max:Byte=40; idx:byte=1; ch:Char=' '):String;
  //function HandlerRoutine(dwCtrlType:DWORD):Boolean;stdcall;external kernel32;
  Procedure CWriteLn(const Key, Value: String; Color1, Color2: Byte; Dot:Char='.');
  //Procedure Echo(const Text, Value: String; Color1:TColorType=ctWhite; Color2:TColorType=ctGreen; Spasi:Char=' ');
  Procedure EchoSetup;
  Procedure Echo(const Text, Value: String; Color1:Word; Color2:Word=FRG_WHITE; Spasi:Char=' '; ln:Boolean=true);
  Procedure PrintLn(Const Key:String); Overload;
  Procedure PrintLn(Const Key:String; Const Value:String; Color:TColorType=ctWhite;
            BG:TColorType=ctSame); Overload;
 Function GetColorInfo(var FColor, BColor: Word): Boolean;
 Function ScreenBufferSizeInfo(var BufferSize: TConsoleScreenBufferInfo): Boolean;
 Function GetDefaultScreenBufferColor(iBufferSize: TConsoleScreenBufferInfo; var ForeC,BgC,Color:Word):Boolean;
 procedure SetColor(const Value: Word);
 function ParamString(inStr:String; Index: Integer): string;
 Procedure ScanArgumen(onScan:TOnScanArgumen);
 Function SringToByteString(const Value:String; Print:Boolean=False): String;
 Procedure ErrorExit(Const Message: String; ErrorCode:DWord=IDABORT);
 Procedure printf(const msg:string);overload;
 Procedure printf(const msg:string; args:Array of const);overload;
 Function AutoColor:TColorType;
 Function GetBGColor():Word;
 Procedure CheckColor();

var
  ScreenBufferSize: TConsoleScreenBufferInfo;
  DefaultColor: Word = $0F;

implementation

uses Math;

var
  FLock   : TCriticalSection;
  GStdOut : DWORD;
  ScreenBufferSz: TConsoleScreenBufferInfo;

procedure SetColor(const Value: Word);
begin
  if not SetConsoleTextAttribute(GStdOut, Value)Then;
end;

Function ScreenBufferSizeInfo(var BufferSize: TConsoleScreenBufferInfo): Boolean;
//var buffer: TConsoleScreenBufferInfo;
Begin
  Result:= GetConsoleScreenBufferInfo(GStdOut, BufferSize);
  if Result Then
  With BufferSize Do
  Begin
    {WriteLn('Size(X,Y)          :   ', dwSize.X, ' ', dwSize.Y);
    WriteLn('CursorPosition(X,Y):   ', dwCursorPosition.x, ' ', dwCursorPosition.y);
    WriteLn('Attributes         :   ', wAttributes);
    WriteLn('srWindow(LT, RB)   :   ', srWindow.Left, ' ', srWindow.Top, ', ',srWindow.Right, ' ', srWindow.Bottom);
    WriteLn('MaximumWindowSize  :   ', dwMaximumWindowSize.x, ' ', dwMaximumWindowSize.y);

    if ScreenBufferSize.wAttributes And 0 = 0 Then WriteLn('Black');
    if ScreenBufferSize.wAttributes And 1 = 1 Then WriteLn('Blue');
    if ScreenBufferSize.wAttributes And 2 = 2 Then WriteLn('Green');
    if ScreenBufferSize.wAttributes And 3 = 3 Then WriteLn('Aqua');
    if ScreenBufferSize.wAttributes And 4 = 4 Then WriteLn('Red');
    if ScreenBufferSize.wAttributes And 5 = 5 Then WriteLn('Purple');
    if ScreenBufferSize.wAttributes And 6 = 6 Then WriteLn('Yellow');
    if ScreenBufferSize.wAttributes And 7 = 7 Then WriteLn('White');

    if ScreenBufferSize.wAttributes And 8 = 8 Then WriteLn('Gray');
    if ScreenBufferSize.wAttributes And 0 = 9 Then WriteLn('Light Blue');
    if ScreenBufferSize.wAttributes And $A = $A Then WriteLn('Light Green');
    if ScreenBufferSize.wAttributes And $B = $B Then WriteLn('Light Aqua');
    if ScreenBufferSize.wAttributes And $C = $C Then WriteLn('Light Red');
    if ScreenBufferSize.wAttributes And $D = $D Then WriteLn('Light Purple');
    if ScreenBufferSize.wAttributes And $E = $E Then WriteLn('Light Yellow');
    if ScreenBufferSize.wAttributes And $F = $F Then WriteLn('Bright White'); }
  End;
end;

Function GetDefaultScreenBufferColor(iBufferSize: TConsoleScreenBufferInfo; var ForeC,BgC,Color:Word):Boolean;
var i:Integer; C:String; F,B:Char;
Begin
  Result:= False;
  for i:=$80 downto 0 Do
  if iBufferSize.wAttributes And i = i Then
  Begin
    C:= IntToHex(i, 2); //0F, 1C, 3B
    B:= C[1];
    F:= C[2];
    ForeC := StrToInt(Format('$%s', [F]));
    BgC   := StrToInt(Format('$%s', [B]));
    Color:=  StrToInt(Format('$%s%s', [B,F]));
    DefaultColor:= Color;
    Result:= true;
    Break;
  End;
End;

Function GetColorInfo(var FColor, BColor: Word): Boolean;
var buffer: TConsoleScreenBufferInfo;   i:byte;
Begin
  Result:= GetConsoleScreenBufferInfo(GStdOut, buffer);
  if Result Then
  Begin
    for i:=0 to 10 Do
    Begin
      SetColor(i);
      WriteLn( i, ' ',(buffer.wAttributes in [i]));
    End;

    WriteLn('');
    for i:=8 to 17 Do
    Begin
      if i=8 then
      SetColor(i OR FOREGROUND_GREEN)else
      SetColor(i*10 OR FOREGROUND_GREEN);

      WriteLn( i*10, ' ',(buffer.wAttributes in [i*10]), ' ', $10);
    End;

  End;
end;

Procedure CWriteLn(const Key, Value: String; Color1, Color2: Byte; Dot:Char='.');

var N0,N1, I:Integer; iSpace, iKey, iVal:String;
begin
  {if not IsConsole Then
  Begin
    MessageBox(GetActiveWindow, PChar(Format('%s%s', [Key+#13#10, Value])),
    'CWriteLn', MB_ICONINFORMATION);
    Exit;
  End; }

  iSpace:= '';
  FLock.Enter;
  Try
    N0:= Length(Key);
    N1:= Length(Value);
    if (N0>60) Then
    iKey:= Copy(Key, 1, 57)+'...' else
    iKey:= Key;
    N0  := Length(iKey);

    if (N1>20) Then //80.000.000 byte
    iVal:= Copy(Value, 1, 18)+'..' else
    iVal:= Value;
    N1  := Length(iVal);

    if (N0+N1>80) Then Exit;
    I:= 80 - (N0+N1);
    Repeat
      iSpace:= iSpace + Dot;
      dec(I);
    Until I<=1;

    SetColor(Color1);   System.Write(iKey);
    SetColor(BG_GRAY);  System.Write(iSpace);
    SetColor(Color2);   System.WriteLn(iVal);
  Finally
    FLock.Release;
    SetColor(FRG_WHITE);
  End;
end;

Function ZeroSpace(Txt:String; Len:Integer; ch:Char='0'):String;
Begin
  Result:= Format('%'+IntToStr(Len)+'s',[Txt]);
  if ch<>' ' then 
  Result:= StringReplace(Result, ' ', ch, [rfReplaceAll]);
end;

Function AddSpace(Txt:String; max:Byte=40; idx:byte=1; ch:Char=' '):String;
Begin
  if Length(Txt)>max Then
    Result:= Copy(Txt,1,max) Else
  Begin
    Result:= Format('%'+IntToStr(max)+'s',[ch]);
    if idx=1 then
    Move(Txt[1], Result[max-Length(Txt)], Length(Txt))Else
    Move(Txt[1], Result[idx], Length(Txt));
  End;
end;

Procedure EchoSetup;
Begin
  ScreenBufferSizeInfo(ScreenBufferSize);
end;

Procedure Echo(const Text, Value: String; Color1:Word; Color2:Word=FRG_WHITE; Spasi:Char=' '; ln:Boolean=true);
Var
  lMessage: Array[0..254] of String;
  Function SplitMessage(const M:String; LenM, LenMax:Integer):Integer;
  var
    P:PChar;
    Split:String;
    Len, index:Integer;
  Begin
    index := 0;
    Len   := 0;
    Split := '';
    if LenM>LenMax Then
    Begin
      P:= PChar(M);
      Repeat
        if Len>LenMax-1 Then
        Begin
          Len   := -1;
          //lMessage[index]:= Format('[%d]%s', [Length(Split), Split]);
          lMessage[index]:= Split;
          Split := '';
          Inc(index);
          //WriteLn(index, lMessage[index]);
        End Else
        Begin
          Split:= Split+ P[0];
          P:= CharNext(P);
        End;

        if(P^=#0)And (Len<LenMax)Then
        Begin
          //lMessage[index]:= Format('[%d]%s', [Length(Split), Split]);
          lMessage[index]:= Split;
          Split := '';
          //WriteLn(index, lMessage[index]);
          Break;
        End;

        Inc(Len);
      Until (P[0]=#0)Or (index>254);
    End Else
      lMessage[index]:= M;

    Result:= index;
  End;

Label OverloadWidth;
var N0,N1, I:Integer;
  iSpace, iKey, iVal, iAll:String;
  maxWidth, Jumlah: Integer;
begin
  iSpace:= '';
  FLock.Enter;
  Try
    // untuk mengetahui nilai dari ScreenBufferSize.dwSize.X
    // harus manggil fungsi ScreenBufferSizeInfo, dulu. Lihat Echi.dpr (298)
    //
    maxWidth:= ScreenBufferSize.dwSize.X;
    if maxWidth<80 then maxWidth:=80;

    N0:= Length(Text);
    N1:= Length(Value);

    // Jika panjang text lebih dari lebar ScreenBufferSize
    if N0>maxWidth Then Goto OverloadWidth;

    if N1>0 Then
    Begin
      if (N0>maxWidth-10) Then
      //iKey:= Copy(Text, 1, maxWidth-13+'..') Else
      iKey:= Copy(Text, 1, maxWidth-13) Else
      iKey:= Text;
    End Else
    if N1=0 Then
    Begin
      if (N0>maxWidth) Then
      //iKey:= Copy(Text, 1, maxWidth-3+'..') else
      iKey:= Copy(Text, 1, maxWidth-1) else
      iKey:= Text;
    End;
    N0  := Length(iKey);

    if (N1>10) Then
    //iVal:= Copy(Value, 1, 8)+'..' else
    iVal:= Copy(Value, 1, 11) else
    iVal:= Value;
    N1  := Length(iVal);

    if (N0+N1>maxWidth) Then Exit;
    I:= maxWidth - (N0+N1);
    Repeat
      iSpace:= iSpace + Spasi;
      dec(I);
    Until I<=0;

    if N1>0 Then
    Begin
      SetColor(Color1);   System.Write(iKey);
      SetColor(DefaultColor);  System.Write(iSpace);
      SetColor(Color2);   System.WriteLn(iVal);
    End else
    Begin
      SetColor(Color1);
      if ln then
      System.WriteLn(iKey)else
      System.Write(iKey);
    End;
    Exit;

    //=========================== Overload Char Width ==========================
    OverloadWidth:
    Jumlah:= SplitMessage(Text, N0, maxWidth);
    N0    := Length(lMessage[Jumlah]);
    
    if (N1>10) Then
    //iVal:= Copy(Value, 1, 8)+'..' else
    iVal:= Copy(Value, 1, 11) else
    iVal:= Value;
    N1  := Length(iVal);

    // Set ulang lebar, text ahir
    if N1>0 Then
    Begin
      if (N0>maxWidth-N1) Then
      Begin
        //iKey:= Copy(lMessage[Jumlah], 1, maxWidth);
        lMessage[Jumlah]:= lMessage[Jumlah];
        if length(lMessage[Jumlah])<maxWidth Then
        repeat
          lMessage[Jumlah]:= lMessage[Jumlah]+Spasi;
        until length(lMessage[Jumlah])>=maxWidth;
        Inc(Jumlah);
        lMessage[Jumlah]:= '';
        //lMessage[Jumlah]:= Copy(iKey, maxWidth+1, maxWidth)+'**';
      End;
    End;
    N0  := Length(lMessage[Jumlah]);

    I:= N0+N1;
    if I<maxWidth-1 Then
    Repeat
      iSpace:= iSpace + Spasi;
      inc(I);
    Until I>maxWidth-1;
    
    if N1>0 Then
    Begin
      SetColor(Color1);
      iAll:= '';
      For I:=0 To Jumlah Do
      Begin
        if I=Jumlah Then
        Begin
          SetColor(Color1);
          System.Write(iAll, lMessage[i]);
          //System.Write(lMessage[i]);
          SetColor(DefaultColor); System.Write(iSpace);
          SetColor(Color2);       System.Write(iVal);
        End else
          iAll:= iAll+ lMessage[i];
          //System.WriteLn(lMessage[i]);
      End;
    End else
    Begin
      SetColor(Color1);
      For I:=0 To Jumlah Do System.Write(lMessage[i]);
      WriteLn('');
    End;
  Finally
    FLock.Release;
    SetColor(DefaultColor);
  End;
end;

var C:Byte=0;
Procedure PrintLn(Const Key:String);
Const
  FR:Array[0..11]of WORD=(2, 3, 4, 5, 6, 7, 2, 3, 4, 5, 6, 7);
  BG:Array[0..11]of WORD=(2, $30, 4, $50, 6, 7, $20, 3, $40, 5, $60, $70);
begin
  if IsConsole Then
  Begin
    CWriteLn(Key, ' ', FR[C], FR[C], ' ');
    Inc(C);
    if C>High(FR){6} Then C:=0;
  End else
  MessageBox(GetActiveWindow, PChar(Format('%s', [Key])), 'PrintLn', MB_ICONINFORMATION);
end;

Procedure PrintLn(Const Key:String; Const Value:String; Color:TColorType=ctWhite;
BG:TColorType=ctSame);
begin
  if IsConsole Then
  CWriteLn(Key, Value, ColorType[Color], Word(IfThen(BG=ctSame, ColorType[Color], ColorType[BG])), ' ') else
  MessageBox(GetActiveWindow, PChar(Format('%s%s', [Key+#13#10, Value])),
  'PrintLn', MB_ICONINFORMATION);
end;

Procedure ErrorExit(Const Message: String; ErrorCode:DWord=IDABORT);
Begin
  WriteLn(Format('%s [%s]', [Message, SysErrorMessage(GetLastError)]));
  ExitProcess(ErrorCode);
End;

Procedure printf(const msg:string);overload;
Begin
  if IsConsole Then WriteLn(msg);
End;

Procedure printf(const msg:string; args:Array of const);overload;
Begin
  if IsConsole Then WriteLn(Format(msg, args));
End;

Function AutoColor:TColorType;
Begin
  Result:= TColorType(RandomRange(1, 14));
End;


{ TStd }

constructor TStd.Create;
begin
  FHandle:= 0;
  FCord.X:= 0;
  FCord.Y:= 0;
end;

function TStd.Write(Text: String): DWORD;
begin
  Result := 0;
  if Handle=0 Then exit;
  WriteConsoleOutputCharacter(Handle, PChar(Text), Length(Text), FCord, Result);
end;

function TStd.Write(Text: String; X, Y: Smallint): DWORD;
begin
  FCord.X:= X;
  FCord.Y:= Y;
  Result := Write(Text);
end;

function TStd.Write(Text: String; X, Y: Smallint; Color: WORD): DWORD;
begin
  FCord.X:= X;
  FCord.Y:= Y;
  Fill(X, Y, Length(Text), Color);
  Result := Write(Text);
end;

class function TStd.SignalKey(const iType: TCtrlType): Boolean;
begin
  Result := false;//HandlerRoutine(DWORD(TCtrlType(iType)));
end;

function TStd.Fill(X, Y:SmallInt; iLen, iColor: WORD): DWORD;
begin
  Result := 0;
  if FHandle=0 Then exit;
  FCord.X:= X;
  FCord.Y:= Y;
  FillConsoleOutputAttribute(Handle, iColor, iLen, FCord, Result);
end;

Function TStd.SetColor(const Value: WORD): Boolean;
begin                             
  Result:= SetConsoleTextAttribute( Handle, Value);
end;

class procedure TStd.SetColorType(iStdOut: THandle; Value: TColorType);
begin
  SetConsoleTextAttribute( iStdOut, ColorType[TColorType(Value)] + GetBGColor );
end;

class procedure TStd.SetColorType(iStdOut: THandle; Value: Word);
begin
  SetConsoleTextAttribute( iStdOut, Value );
end;

function TStd.Read(): String;
Var
   iRead: DWORD;
   chBuf: array[0..IOBUFSz]of CHAR;
Begin
  Result := '';
  if Handle=0 Then Exit;
  ZeroMemory(@chBuf, SizeOf(chBuf));
  if ReadFile(Handle, chBuf, SizeOf(chBuf), iRead, Nil)And(iRead<>0)Then
  Result := chBuf;
end;

{ TStdI }

constructor TStdInput.Create;
begin
  Handle:= GetStdHandle( STD_INPUT_HANDLE );
end;

destructor TStdInput.Destroy;
begin

  inherited;
end;

{ TStdO }

constructor TStdOutput.Create;
begin
  Handle:= GetStdHandle( STD_OUTPUT_HANDLE );
end;

destructor TStdOutput.Destroy;
begin

  inherited;
end;

class Procedure TStdOutput.Write(const Text: String=''; Color:TColorType=ctWhiteLight);
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    System.Write(Text);
  Finally
    FLock.Release;
    SetColorType(GStdOut, DefaultColor);
  End;
end;

class Procedure TStdOutput.Write(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight);
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    System.Write(Format(Text, args));
  Finally
    FLock.Release;
    SetColorType(GStdOut, DefaultColor);
  End;
end;

class Procedure TStdOutput.WriteLn(const Text: String=''; Color:TColorType=ctWhiteLight);
begin 
  if not IsConsole then Exit;
  FLock.Enter;
  Try                         
    SetColorType(GStdOut, Color);
    System.WriteLn(Text);
  Finally
    SetColorType(GStdOut, DefaultColor);
    FLock.Release;
  End;
end;

class Procedure TStdOutput.WriteLn(O:TObject; Text: String; Color:TColorType);
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    System.WriteLn(Format('%s.%s', [O.ClassName, Text]));
  Finally
    SetColorType(GStdOut, DefaultColor);
    FLock.Release;
  End;
end;

class Procedure TStdOutput.WriteLn(O:TObject; const Msg: String; args:Array of const; Color:TColorType);
var s:string;
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    s:= Format('%s.%s', [O.ClassName, Format(Msg, args)]);
    System.WriteLn(s);
  Finally
    SetColorType(GStdOut, DefaultColor);
    FLock.Release;
  End;
end;

class procedure TStdOutput.FillLine(Color:TColorType; Y:Integer);
var L: COORD; R:DWord; C:Array[0..255]of char;
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    L.X:= 0; L.Y:= Y;
    FillChar(C, SizeOf(C), #0);
    FillConsoleOutputAttribute(GStdOut, ColorType[Color], ScreenBufferSz.dwSize.X, L, R);
    WriteConsoleOutputCharacter(GStdOut, C, ScreenBufferSz.dwSize.X, L, R);
  Finally
    FLock.Release;
  End;
end;

class Function TStdOutput.printy(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight): Integer;
var 
  csb:_CONSOLE_SCREEN_BUFFER_INFO;
begin
  Result:= 0;
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    if GetConsoleScreenBufferInfo(GStdOut, csb) Then
    Begin
      TStdOutput.WriteLn(Format(Text, args), Color);
      Result:= csb.dwCursorPosition.Y;
    End;
  Finally
    FLock.Release;
    SetColorType(GStdOut, ctWhite);
  End;
End;

class procedure TStdOutput.printAtY(const Text: String; args:Array of const; X,Y:Integer; Color:TColorType=ctWhiteLight);
var L: COORD; R:DWord; txt:PChar;
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    L.X:= X; L.Y:= Y;
    //FillLine(Color, Y);
    txt:= PChar(Format(Text, args));
    FillConsoleOutputAttribute(GStdOut, ColorType[Color], Length(Txt), L, R);
    WriteConsoleOutputCharacter(GStdOut, PChar(txt), Length(Txt), L, R);
  Finally
    FLock.Release;
    SetColorType(GStdOut, ctWhite);
  End;
end;

class Function TStdOutput.PrintCenter(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight): Integer;
var
  csb:_CONSOLE_SCREEN_BUFFER_INFO;
//  L: Integer;
  Txt: String;
begin
  Result:= 0;
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    if GetConsoleScreenBufferInfo(GStdOut, csb) Then
    Begin
      Txt:= Format(Text, args);
      Txt:= AddSpace(Txt, 79, 40-(Length(Txt)div 2) );
      TStdOutput.WriteLn(Txt, Color);
      Result:= csb.dwCursorPosition.Y;
    End;
  Finally
    FLock.Release;
    SetColorType(GStdOut, ctWhite);
  End;
End;

class Function TStdOutput.PrintCenterLeft(const Text: String; args:Array of const; Color:TColorType=ctWhiteLight): Integer;
var
  csb:_CONSOLE_SCREEN_BUFFER_INFO;
  //L: Integer;
  Txt: String;
begin
  Result:= 0;
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    if GetConsoleScreenBufferInfo(GStdOut, csb) Then
    Begin
      Txt:= Format(Text, args);
      Txt:= AddSpace(Txt);
      TStdOutput.WriteLn(Txt, Color);
      Result:= csb.dwCursorPosition.Y;
    End;
  Finally
    FLock.Release;
    SetColorType(GStdOut, ctWhite);
  End;
End;

class Function TStdOutput.PrintCenterRight(const Text: String; args:Array of const;
Y:Integer; Color:TColorType=ctWhiteLight): Integer;
var
  L: COORD; R:DWord;
  T: String;
begin
  Result:= 0;
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    L.X:= 40; L.Y:= Y;
    T:= Format(Text, args);
    FillConsoleOutputAttribute(GStdOut, ColorType[Color], Length(T), L, R);
    WriteConsoleOutputCharacter(GStdOut, PChar(T), Length(T), L, R);
  Finally
    FLock.Release;
    SetColorType(GStdOut, ctWhite);
  End;
end;

class procedure TStdOutput.WriteLnAt(const Text: String=''; Color:TColorType=ctWhiteLight;
X: Integer=0; Y: Integer=0);
var L: COORD; R:DWord; //C:Array[0..255]of char;
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    L.X:= X; L.Y:= Y;
    FillLine(Color, Y);
    WriteConsoleOutputCharacter(GStdOut, PChar(Text), Length(Text), L, R);
  Finally
    FLock.Release;
    SetColorType(GStdOut, ctWhite);
  End;
end;

class procedure TStdOutput.WriteLnp(const Text: String; P:TPoint);
var L: COORD; R:DWord; //C:Array[0..255]of char;
begin
  if not IsConsole then Exit;
  //FLock.Enter;
  Try
    SetColorType(GStdOut, ctPurpleLight);
    L.X:= P.X; L.Y:= P.Y;
    FillLine(ctPurpleLight, L.Y);
    WriteConsoleOutputCharacter(GStdOut, PChar(Text), Length(Text), L, R);
  Finally
    //FLock.Release;
    SetColorType(GStdOut, ctWhite);
  End;
end;

class Procedure TStdOutput.WriteLn(const Key, Value: String; Color1:TColorType=ctWhiteLight; Color2: TColorType=ctWhite);
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color1);   System.Write(Key);
    SetColorType(GStdOut, Color2);   System.WriteLn(Value);
  Finally
    FLock.Release;
    SetColorType(GStdOut, DefaultColor);
  End;
end;

class Procedure TStdOutput.WriteLn(const Msg: String; args:Array of const; Color:TColorType=ctWhiteLight);
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetColorType(GStdOut, Color);
    TStdOutput.WriteLn(Format(Msg, args), Color);
    //System.WriteLn(Value);
  Finally
    FLock.Release;
    SetColorType(GStdOut, DefaultColor);
  End;
end;

// masih gagal
class Procedure TStdOutput.WriteLnCl(const Msg: String; args:Array of const; Color:DWord);
begin
  if not IsConsole then Exit;
  FLock.Enter;
  Try
    SetConsoleTextAttribute(GStdOut, Color);
    //SetColorType(GStdOut, Color);
    System.WriteLn(Format(Msg, args));
    //System.WriteLn(Value);
  Finally
    FLock.Release;
    //SetColorType(GStdOut, DefaultColor);
  End;
end;

class procedure TStdOutput.Print(const Text:String; FG:TColorType=ctWhite; BG:TColorType=ctBlack);
begin
  if IsConsole then
  Echo(Text, '', ColorType[FG], ColorType[BG], ' ', False);
end;

Class Procedure TStdOutput.PrintLn(const Text:String; FG:TColorType=ctWhite; BG:TColorType=ctBlack);//overload;
begin
  if IsConsole then
  Echo(Text, '', ColorType[FG], ColorType[BG]);
end;

class procedure TStdOutput.PrintLn(const Key,Value:String; FG:TColorType=ctWhite; BG:TColorType=ctBlack);
begin
  if IsConsole then
  Echo(Key, Value, ColorType[FG], ColorType[BG]);
end;

class procedure TStdOutput.SetStdOut(const newStdOut: THandle);
begin
  if GStdOut<>newStdOut then GStdOut:= newStdOut;
end;

{ TSTDIO }

class function TSTDIO.IHandle: THandle;
begin
  Result := GetStdHandle( STD_INPUT_HANDLE );
end;

class function TSTDIO.IWrite(const Text: String): Boolean;
Begin
  Result := TSTDIO.Write(TSTDIO.IHandle, Text);
end;

class function TSTDIO.OHandle: THandle;
begin
  Result := GetStdHandle( STD_OUTPUT_HANDLE );
end;

class function TSTDIO.ORead: String;
Begin
  Result := TSTDIO.Read(TSTDIO.OHandle);
end;

class function TSTDIO.EHandle: THandle;
Begin
  Result := GetStdHandle( STD_ERROR_HANDLE );
end;

class function TSTDIO.OWrite(const Text: String): Boolean;
Begin
  Result := TSTDIO.Write(TSTDIO.OHandle, Text);
end;

class function TSTDIO.Read(const iHwnd: THandle): String;
Var
   iRead: DWORD;
   chBuf  : array[0..IOBUFSz]of CHAR;
Begin
  Result := '';
  ZeroMemory(@chBuf, SizeOf(chBuf));
  if ReadFile(iHwnd, chBuf, SizeOf(chBuf), iRead, Nil)And(iRead<>0)Then
  Result := chBuf;
end;

class function TSTDIO.Write(const iHwnd: THandle; const Text: String): Boolean;
Var
   iWrite: DWORD;
   chBuf  : array[0..IOBUFSz]of CHAR;
Begin
  lstrcpy(chBuf, PChar(Text));
  Result := WriteFile(iHwnd, chBuf, Length(Text), iWrite, Nil) And (iWrite<>0);
end;

class function TSTDIO.ValidHwnd(const iHwnd: THandle): Boolean;
begin
  Result := iHwnd<>INVALID_HANDLE_VALUE;
end;

class function TSTDIO.SysError: String;
begin
  Result := SysErrorMessage(GetLastError);
end;

class function TSTDIO.SignalKey(const iType: TCtrlType): Boolean;
begin
  Result := false;//HandlerRoutine(DWORD(TCtrlType(iType)));
end;

constructor TSTDIO.Create;
begin
  FInput  := TStdInput.Create;
  FOutput := TStdOutput.Create;

  GetConsoleScreenBufferInfo(FOutput.Handle, FInfo);
end;

destructor TSTDIO.Destroy;
begin
  FOutput.SetColor(FInfo.wAttributes);
  FInput.Free;
  FOutput.Free;

  inherited;
end;

function TSTDIO.Fill(X, Y, iColor: WORD): DWORD;
var iCord: COORD;
begin
  iCord.X:= X;
  iCord.Y:= Y;
  FillConsoleOutputAttribute(0, iColor, 1, iCord, Result);
end;

function GetParamString(P: PChar; var Param: string): PChar;
var
  i, Len: Integer;
  Start, S, Q: PChar;
begin
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      P := CharNext(P);
      if (P[0] = #163) and (P[1] = #163) then Inc(P, 2) else Break;
  end;

  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = #163 then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> #163) do
      begin
        Q := CharNext(P);
        Inc(Len, Q - P);
        P := Q;
      end;
      if P[0] <> #0 then
        P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      Inc(Len, Q - P);
      P := Q;
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = #163 then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> #163) do
      begin
        Q := CharNext(P);
        while P < Q do
        begin
          S[i] := P^;
          Inc(P);
          Inc(i);
        end;
      end;
      if P[0] <> #0 then P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      while P < Q do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
    end;
  end;

  Result := P;
end;

function ParamString(inStr:String; Index: Integer): string;
var
  P: PChar;
  Buffer: array[0..260] of Char;
begin
  Result := '';
  if Index = 0 then
    SetString(Result, Buffer, GetModuleFileName(0, Buffer, SizeOf(Buffer)))
  else
  begin
    P := PChar(StringReplace(inStr, '"', #163#164, [rfReplaceAll]));
    while True do
    begin
      P := GetParamString(P, Result);
      if (Index = 0) or (Result = '') then Break;
      Dec(Index);
    end;
    if Result<>'' Then
    Result := StringReplace(Result, #164, '"', [rfReplaceAll]);
  end;
end;

Procedure ScanArgumen(onScan:TOnScanArgumen);
var
  I: Integer;
  S: String;
begin
  S:= GetCommandLineA;
  if ParamCount=0 Then Exit;
  for i:=0 to ParamCount Do
  onScan(i, ParamString(S, i));
End;

Function SringToByteString(const Value:String; Print:Boolean=False): String;
var
  I,N,J: Integer;
  X: String;
begin
  N:= Length(Value);
  I:= 1;
  J:= 0;
  X:= '';
  if I>N then Exit;  
  repeat
    if J<16 then
    begin
      if X='' then  
      X:= Format('%s', [ IntToHex(Byte(Value[I]), 2)]) else
      X:= X + ' ' + Format('%s', [ IntToHex(Byte(Value[I]), 2)]);
      //if Print then TStdOutput.WriteLn(X, ctGreen);
    end
    else
    begin
      X:= X + #13+#10+ Format('%s', [ IntToHex(Byte(Value[I]), 2)]);
      J:= 0;
    end;

    Inc(I);
    Inc(J);
  until I>N;
  if Print then TStdOutput.WriteLn(X, ctYellowLight);
  Result:= X;
end;

class function TStdOutput.GetConsoleInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(GStdOut, Result);
end;

class Function TStdOutput.Point(): TPoint;
begin
  with TStdOut.GetConsoleInfo.dwCursorPosition do
  begin
    Result.X:= X;
    Result.Y:= Y;
  end;
end;

class function TStdOutput.GetHandle: THandle;
begin
  Result:= GStdOut;
end;

Procedure CheckColor();
Begin
  WriteLn('BLACK    : ', (DefaultColor and FRG_BLACK)=FRG_BLACK );
  WriteLn('BLUE     : ', (DefaultColor and FRG_BLUE)=FRG_BLUE );
  WriteLn('GREEN    : ', (DefaultColor and FRG_GREEN)=FRG_GREEN );
  WriteLn('AQUA     : ', (DefaultColor and FRG_AQUA)=FRG_AQUA );
  WriteLn('RED      : ', (DefaultColor and FRG_RED)=FRG_RED );
  WriteLn('PURPLE   : ', (DefaultColor and FRG_PURPLE)=FRG_PURPLE );
  WriteLn('YELLOW   : ', (DefaultColor and FRG_YELLOW)=FRG_YELLOW );
  WriteLn('WHITE    : ', (DefaultColor and FRG_WHITE)=FRG_WHITE );
  WriteLn('GRAY     : ', (DefaultColor and FRG_GRAY)=FRG_GRAY );

  WriteLn('FRG_BLUE_LIGHT : ', (DefaultColor and FRG_BLUE_LIGHT)=FRG_BLUE_LIGHT );
  WriteLn('FRG_GREEN_LIGHT: ', (DefaultColor and FRG_GREEN_LIGHT)=FRG_GREEN_LIGHT );
  WriteLn('FRG_AQUA_LIGHT : ', (DefaultColor and FRG_AQUA_LIGHT)=FRG_AQUA_LIGHT );
  WriteLn('FRG_RED_LIGHT  : ', (DefaultColor and FRG_RED_LIGHT)=FRG_RED_LIGHT );
  WriteLn('FRG_PURPLE_LIGHT : ', (DefaultColor and FRG_PURPLE_LIGHT)=FRG_PURPLE_LIGHT );
  WriteLn('FRG_YELLOW_LIGHT : ', (DefaultColor and FRG_YELLOW_LIGHT)=FRG_YELLOW_LIGHT );
  WriteLn('FRG_WHITE_LIGHT  : ', (DefaultColor and FRG_WHITE_LIGHT)=FRG_WHITE_LIGHT );

  WriteLn('BG_LIGHT_BLUE    : ', (DefaultColor and BG_LIGHT_BLUE)=BG_LIGHT_BLUE);
  WriteLn('BG_LIGHT_GREEN   : ', (DefaultColor and BG_LIGHT_GREEN)=BG_LIGHT_GREEN );
  WriteLn('BG_LIGHT_AQUA    : ', (DefaultColor and BG_LIGHT_AQUA)=BG_LIGHT_AQUA );
  WriteLn('BG_LIGHT_RED     : ', (DefaultColor and BG_LIGHT_RED)=BG_LIGHT_RED );
  WriteLn('BG_LIGHT_PURPLE  : ', (DefaultColor and BG_LIGHT_PURPLE)=BG_LIGHT_PURPLE );
  WriteLn('BG_LIGHT_YELLOW  : ', (DefaultColor and BG_LIGHT_YELLOW)=BG_LIGHT_YELLOW );
  WriteLn('BG_LIGHT_WHITE   : ', (DefaultColor and BG_LIGHT_WHITE)=BG_LIGHT_WHITE );
end;

Function GetBGColor(): Word;
Begin
  if (DefaultColor and BG_LIGHT_BLUE)=BG_LIGHT_BLUE then Result:= BG_LIGHT_BLUE Else
  if (DefaultColor and BG_LIGHT_GREEN)=BG_LIGHT_GREEN then Result:= BG_LIGHT_GREEN Else
  if (DefaultColor and BG_LIGHT_AQUA)=BG_LIGHT_AQUA then Result:= BG_LIGHT_AQUA Else
  if (DefaultColor and BG_LIGHT_RED)=BG_LIGHT_RED then Result:= BG_LIGHT_RED Else
  if (DefaultColor and BG_LIGHT_PURPLE)=BG_LIGHT_PURPLE then Result:= BG_LIGHT_PURPLE Else
  if (DefaultColor and BG_LIGHT_YELLOW)=BG_LIGHT_YELLOW then Result:= BG_LIGHT_YELLOW Else
  if (DefaultColor and BG_LIGHT_WHITE)=BG_LIGHT_WHITE then Result:= BG_LIGHT_WHITE Else
  Result:= 0;
end;

Procedure InitScreenBufferSizeInfo();
var DefaultCL: String;
Begin
  if not IsConsole then Exit;
  DefaultCL:= '0F';
  FLock   := TCriticalSection.Create;
  GStdOut := GetStdHandle( STD_OUTPUT_HANDLE );

  if GetConsoleScreenBufferInfo(GStdOut, ScreenBufferSz) Then
  With ScreenBufferSz Do
  Begin
    // Default 7 = White
    DefaultCL   := IntToHex(ScreenBufferSz.wAttributes, 2);
    DefaultColor:= StrToInt('$'+DefaultCL);
    //WriteLn('DefaultColor: ', DefaultCL);
    
    {System.WriteLn('Size(X,Y)          :   ', dwSize.X, ' ', dwSize.Y);
    System.WriteLn('CursorPosition(X,Y):   ', dwCursorPosition.x, ' ', dwCursorPosition.y);
    System.WriteLn('Attributes         :   ', wAttributes, ' = $', DefaultColor);
    System.WriteLn('srWindow(LT, RB)   :   ', srWindow.Left, ' ', srWindow.Top, ', ',srWindow.Right, ' ', srWindow.Bottom);
    System.WriteLn('MaximumWindowSize  :   ', dwMaximumWindowSize.x, ' ', dwMaximumWindowSize.y);}
  End;
end;

{ TStdReader }

Function TStdReader.CloneHandle(Const Source:THandle; Target:PHandle): Boolean;
begin
  // Create nonInheritable read handle and close the inheritable read handle
  Result := DuplicateHandle(
          GetCurrentProcess,	    // handle to process with handle to duplicate
          Source,	                // handle to duplicate
          GetCurrentProcess,	    // handle to process to duplicate to
          Target,	                // pointer to duplicate handle
          0,	                    // access for duplicate handle
          False,	                // handle inheritance flag
          DUPLICATE_SAME_ACCESS);
end;

constructor TStdReader.Create(Redirect:TRedirectEvent);
begin
  Inherited Create;
  FRedirect:= Redirect;
  SetupHandle;
end;

destructor TStdReader.Destroy;
begin
  RestoreHandle;
  inherited;
end;

procedure TStdReader.RestoreHandle;
begin
  if (Not SetStdHandle(STD_INPUT_HANDLE, FInput.sBackup))Then
  ;//ErrorExit('Restore Stdin failed');

  if (Not SetStdHandle(STD_OUTPUT_HANDLE, FOutput.sBackup))Then
  ;//ErrorExit('Restore Stdout failed');

	// Get a handle to the parent's input file.
  //if (ParamCount > 0) Then
  //hInputFile = CreateFile(argv[1], GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_READONLY, NULL) else
  //iInputFile := iStdInBkp;
  //if (iInputFile = INVALID_HANDLE_VALUE)Then ExitMessage('no input file');
end;

Procedure TStdReader.ReadHandle;
Var
   dwRead, dwWritten: DWORD;
   chBuf: array[0..IOBUFSz]Of byte;
Begin
   // hStdout:= GetStdHandle(STD_OUTPUT_HANDLE);
  //  Close the write handle pipe before reading read handle pipe.
  if(Not CloseHandle(FOutput.sWrite))Then
  ErrorExit('Close write handle failed.');

  // Read output from the child process, and write to parent's STDOUT.
  Repeat
    if(Not ReadFile(FOutput.sClone, chBuf, IOBUFSz, dwRead, Nil))OR(dwRead=0)Then
    Begin
      WriteLn('STDOUT read failed: '+SysErrorMessage(GetLastError));
      Exit;
    End Else
    Try
      chBuf[dwRead]:= 2;
      if Assigned(FRedirect) then FRedirect(PAnsiChar(@chBuf));
      WriteFile(FOutput.sBackup, chBuf, dwRead, dwWritten, Nil);
      Exit;
    Except
      on e:exception Do
      begin
        WriteLn('ReadHandle Exception: ',e.Message);
        Exit;
      end;
    End;
    //if(Not WriteFile(iStdOutBkp, chBuf, dwRead, dwWritten, Nil))Then break;
  Until True;
End;

function TStdReader.SetupHandle: Boolean;
begin
  FSecuAtr.nLength       := SizeOf(SECURITY_ATTRIBUTES);
  FSecuAtr.bInheritHandle:= True;

  //result:= False;
  FOutput.sBackup := GetStdHandle(STD_OUTPUT_HANDLE);

  if (not CreatePipe(FOutput.sRead, FOutput.sWrite, @FSecuAtr, 0))Then
  ErrorExit('Create STDOUT child failed.');

  if (Not SetStdHandle(STD_OUTPUT_HANDLE, FOutput.sWrite))Then
  ErrorExit('Re-Set STDOUT failed');

  // Create nonInheritable read handle and
  // close the inheritable read handle
  if( Not CloneHandle(FOutput.sRead, @FOutput.sClone ) ) Then
  ErrorExit('Duplicate STDOUT failed');
  CloseHandle(FOutput.sRead);

  // -----------------------------------------------------------------
  // Save the handle to the current STDIN.
  FInput.sBackup := GetStdHandle(STD_INPUT_HANDLE);
  if (Not CreatePipe(FInput.sRead, FInput.sWrite, @FSecuAtr, 0)) Then
  ErrorExit('Create STDIN child failed');

  if (not SetStdHandle(STD_INPUT_HANDLE, FInput.sRead))Then
  ErrorExit('Re-Set STDIN failed');

  if (Not CloneHandle(FInput.sWrite, @FInput.sClone)) Then
  ErrorExit('Duplicate STDIN failed');
  CloseHandle(FInput.sWrite);
  Result:= True;
end;

Initialization
  InitScreenBufferSizeInfo();

Finalization
  if Assigned(FLock)Then
  FLock.Free;

end.
