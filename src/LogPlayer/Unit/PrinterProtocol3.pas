unit PrinterProtocol3;

interface

uses
  //VCL
  System.SysUtils, WinAPI.Windows,
  // This
  DriverError, DriverTypes, SerialPort, untLogger, PrinterProtocolInterface,
  ConnectionParams, LangUtils;


const
  PSEL  =   #$90;
  PCF   =   #$91;

  STP   =   #$82;

type
  TPrinterProtocol3 = class(TInterfacedObject, IPrinterProtocol)
  private
    FPort:ISerialPort;
    FParams:TConnectionParams;
    FLogger:TLogger;

    FOutput:AnsiString;
    FRawInput:AnsiString;
    FRawOutput:AnsiString;

    FFrameNumber:Byte;

    procedure NoHardwareError;

    procedure AddRawData(AData:AnsiString);
    procedure SetCmdTimeout(Value: DWORD);

    function EncodeFrame(const AData:AnsiString):AnsiString;
    function CRC16(AData:AnsiString):Word;

    procedure SendCommand(const AData:AnsiString);
    procedure Write(const AData:AnsiString);

    function ReadAnswerData(var CRCError:Boolean):Boolean;
    function ReadChar(var AChar:AnsiChar):Boolean;
    function Read(ACount:Word; var AData:AnsiString; ATimeout:Integer):Boolean;

    function ReadWord:Word;

    property Port:ISerialPort read FPort;
  public
    constructor Create(APort: ISerialPort; AParams: TConnectionParams);
    destructor Destroy; override;

    procedure Send(var Command: TCommandRec);
    function Encode(const Data: AnsiString): AnsiString;
    procedure Sync;
    procedure Reset;

    function CheckVer:Boolean;
  end;



implementation

{ TPrinterProtocol3 }

procedure TPrinterProtocol3.AddRawData(AData: AnsiString);
begin
  FRawOutput:=FRawInput+AData;
end;

function TPrinterProtocol3.CheckVer: Boolean;
var
  Answer:AnsiChar;
begin
  FLogger.WriteSeparator;
  FLogger.Debug('Команда: PSEL, Выбор протокола');
  FLogger.WriteSeparator;
  Port.Write(PSEL);
  FLogger.WriteTxData(PSEL);
  Result:=Port.ReadChar(Answer);
  if Result then
    begin
      FLogger.WriteRxData(Answer);
      Result := Answer = PCF;
    end
  else
    FLogger.Debug('No answer');
end;

function TPrinterProtocol3.CRC16(AData: AnsiString): Word;
var
  i: Integer;
  j: Integer;
begin
  Result:=$FFFF;
  for i := 1 to Length(AData) do
    begin
      Result:=Result xor (Byte(AData[i]) shl 8);
      for j := 0 to 7 do
        begin
          if (Result and $8000) <> 0 then
            Result:=(Result shl 1) xor $8005
          else
            Result:=Result shl 1;
        end;
    end;
end;

constructor TPrinterProtocol3.Create(APort: ISerialPort;
  AParams: TConnectionParams);
begin
  inherited Create;
  FFrameNumber:=1;
  FLogger:=TLogger.Create(ClassName);
  FPort:=APort;
  FParams:=AParams;
end;

destructor TPrinterProtocol3.Destroy;
begin
  FPort:=nil;
  FLogger.Free;
  inherited Destroy;
end;

function TPrinterProtocol3.Encode(const Data: AnsiString): AnsiString;
begin
  Result:=EncodeFrame(Data);
end;

function TPrinterProtocol3.EncodeFrame(const AData: AnsiString): AnsiString;
var
  DataLen:Word;
  CRC:Word;
begin
  FLogger.WriteSeparator;
  FLogger.Debug('Функция EncodeFrame');
  FLogger.WriteData('AData: ',AData);
  FLogger.WriteSeparator;
  DataLen:=Length(AData);
  Result:=#$00+AnsiChar(FFrameNumber)+AnsiChar(Lo(DataLen))+AnsiChar(Hi(DataLen))+
    AData;
  CRC:=CRC16(Result);
  Result:=STP+Result+AnsiChar(Lo(CRC))+AnsiChar(Hi(CRC));
  FLogger.WriteData('Result: ',Result);
  FLogger.WriteSeparator;
end;

procedure TPrinterProtocol3.NoHardwareError;
begin
  RaiseError(E_NOHARDWARE, GetRes(@SDriverNoHardware));
//  FParams.ENQSent := False;
//  FPlainTransferMode := False;
end;

function TPrinterProtocol3.Read(ACount: Word; var AData: AnsiString; ATimeout:Integer): Boolean;
begin
  AData:=Port.ReadEx(ACount,ATimeout);
  AddRawData(AData);
  Result:=Length(AData) = ACount;
  FLogger.WriteRxData(AData);
end;

function TPrinterProtocol3.ReadAnswerData(var CRCError: Boolean): Boolean;
var
  rxChar:AnsiChar;
  rxData:AnsiString;
  DataLen,CRC:Word;
begin
//  Sleep(500);
  Result:=False;
//  Port.Purge;
  {Получаем байт заголовка}
  if ReadChar(rxChar) then
    begin
      AddRawData(rxChar);
      if rxChar<>STP then
        Exit;
    end
  else
    begin
      Exit;
    end;
  {Получаем байт канала}
  if ReadChar(rxChar) then
    begin
      AddRawData(rxChar);
      if rxChar<>#$00 then
        Exit;
    end
  else
    begin
      Exit;
    end;
  {Получаем байт фрейма}
  if ReadChar(rxChar) then
    begin
      AddRawData(rxChar);
      if rxChar<>AnsiChar(FFrameNumber) then
        Exit;
    end
  else
    begin
      Exit;
    end;
  {Получаем длину}
  DataLen:=ReadWord;
  if DataLen = 0 then
    begin
      Exit;
    end;
  {Получаем данные}
  if not Read(DataLen,rxData,FParams.Timeout) then
    Exit;
  FOutput:=rxData;
  {Получаем CRC}
  CRC:=ReadWord;

//  if CRC = 0 then
//    Exit;
  {Проверяем CRC}
  FLogger.WriteData('CRC16 = ',AnsiChar(Hi(CRC))+AnsiChar(Lo(CRC)));
  {}
  Result:=True;
end;

function TPrinterProtocol3.ReadChar(var AChar: AnsiChar): Boolean;
begin
  Result:=Port.ReadChar(AChar);
  if Result then
    FLogger.WriteRxData(AChar)
  else
    FLogger.Error('Нет ответа');
end;

function TPrinterProtocol3.ReadWord: Word;
var
  rxChar:AnsiChar;
begin
  if ReadChar(rxChar) then
    begin
      AddRawData(rxChar);
      Result:=Byte(rxChar);
      if ReadChar(rxChar) then
        begin
          AddRawData(rxChar);
          try
            Result:=Result+(Byte(rxChar) shl 8);
          except
            on E:Exception do
              begin
                Result:=0;
                FLogger.Error(E.Message);
              end;
          end;
        end
      else
        begin
          Result:=0;
          Exit;
        end;
    end
  else
    begin
      Result:=0;
      Exit;
    end;
end;

procedure TPrinterProtocol3.Reset;
begin

end;

procedure TPrinterProtocol3.Send(var Command: TCommandRec);
var
  CRCError:Boolean;
  _Timeout:Integer;
begin
  FOutput:='';
  FRawInput:='';
  FRawOutput:='';
  try
    Port.Purge;
    SetCmdTimeout(FParams.Timeout);
    {Читаем ответ}
    {Проверяем версию протокола}
    if not CheckVer then
      raise Exception.Create('Многоканальный протокол не поддерживается.');
    {Вычисляем следующий фрейм}
    if FFrameNumber = 255 then
      FFrameNumber:=1
    else
      inc(FFrameNumber);
    {Передаём команду}
    SendCommand(Encode(Command.Command));
    {Читаем ответ}
    _Timeout:=FParams.Timeout;
    FParams.Timeout:=Command.Timeout;
    SetCmdTimeout(FParams.Timeout);
    if ReadAnswerData(CRCError) then
      begin
        Command.Answer := FOutput;
        Command.TxData := FRawInput;
        Command.RxData := FRawOutput;
      end;
    FParams.Timeout:=_Timeout;
    SetCmdTimeout(FParams.Timeout);
  except
    on E:Exception do
      begin
        FLogger.Error(E.Message);
        raise;
      end;
  end;
end;

procedure TPrinterProtocol3.SendCommand(const AData: AnsiString);
var
  CmdCount:Integer;
begin
  CmdCount:=1;
  FRawInput:=AData;
  FRawOutput:='';
  Write(AData);
end;

procedure TPrinterProtocol3.SetCmdTimeout(Value: DWORD);
begin
  FLogger.Debug('SetCmdTimeout: '+IntToStr(Value));
  Port.SetCmdTimeout(Value);
end;

procedure TPrinterProtocol3.Sync;
begin

end;

procedure TPrinterProtocol3.Write(const AData: AnsiString);
begin
  FLogger.WriteTxData(AData);
  Port.Write(AData);
end;

end.
