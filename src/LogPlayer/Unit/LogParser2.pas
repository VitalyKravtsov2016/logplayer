unit LogParser2;

interface

uses
  // VCL
  System.Classes, System.SysUtils,
  // This
  untCommand, BinUtils, ShtrihProtocol1, ShtrihProtocol2;

procedure ParseLog2(Lines: TStrings; Commands: TCommandList);

implementation

const
  TxSign = '[DEBUG] TPrinterProtocol -> ';
  TxSign2 = '[DEBUG] TPrinterProtocol2 -> ';
  TxSign3 = '[DEBUG] TPrinterProtocol3 -> ';
  RxSign = '[DEBUG] TPrinterProtocol <- ';
  RxSign2 = '[DEBUG] TPrinterProtocol2 <- ';
  RxSign3 = '[DEBUG] TPrinterProtocol3 <- ';
  TxSignNg = '] [D] -> ';
  RxSignNg = '] [D] <- ';
  ProtocolAttributes = '[07.12.2021 18:30:04.598] [00002108]';


function DeStuffing(const AStr: AnsiString; var IsFinalEsc: Boolean): AnsiString;
const
  IncorrectPacketFormat = 'Некорректный формат пакета';
  STX = #$8F;
  ESC = #$9F;
  TSTX = #$81;
  TESC = #$83;
var
  i: Integer;
begin
  Result := '';
  IsFinalEsc := False;
  i := 1;
  while i <= Length(AStr) do
  begin
    if AStr[i] = ESC then
    begin
      if i = Length(AStr) then
      begin
        IsFinalEsc := True;
        Exit;
      end;
      if AStr[i + 1] = TSTX then
      begin
        Result := Result + STX;
        Inc(i);
      end
      else if AStr[i + 1] = TESC then
      begin
        Result := Result + ESC;
        Inc(i);
      end
      else
        raise Exception.Create(IncorrectPacketFormat);
    end
    else
      Result := Result + AStr[i];
    Inc(i);
  end;
end;
function GetCommandDatap2(const AData: string): string;
var
  Data: AnsiString;
  i: Boolean;
begin
  Data := HexToStr(AData);
  Data := Destuffing(Copy(Data, 2, Length(Data)), i);
  Result := StrToHex(Copy(Data, 5, Length(Data) - 6));
end;

///////////////////////////////////////////////////////////////////////////////
// pProtocol1 - 02 05 11 1E 00 00 00 0A
// pProtocol3 - 82 00 05 05 00 11 1E 00 00 00 BC 1A


function GetFrame(const HexData: string; Protocol: TProtocol): string;
begin
  Result := HexData;
  case Protocol of
    pProtocol1: Result := Copy(HexData, 7, Length(HexData)-9);
    pProtocol3: Result := Copy(HexData, 16, Length(HexData)-21);
    pProtocol2: Result := GetCommandDatap2(HexData);
  end;
end;

function GetRxFrame(const HexData: string; Protocol: TProtocol): string;
begin
  Result := HexData;
  case Protocol of
    pProtocol1: Result := Copy(HexData, 1, Length(HexData)-3);
    pProtocol2: Result := Copy(HexData, 1, Length(HexData));
    pProtocol3: Result := Copy(HexData, 1, Length(HexData)-6);
  end;
end;

function IsFrameProtocol1(const HexData: string): Boolean;
var
  Frame, Data: AnsiString;
begin
  Data := '';
  Frame := HexToStr(HexData);
  Result := TShtrihProtocol1.Decode(Frame, Data);
end;

function IsFrameProtocol2(const HexData: string): Boolean;
var
  Data: AnsiString;
  Frame: TShtrihFrame2;
begin
  Data := HexToStr(HexData);
  Result := TShtrihProtocol2.Decode(Data, Frame);
end;

function IsFrame(const HexData: string; Protocol: TProtocol): Boolean;
begin
  Result := False;
  case Protocol of
    pProtocol1: Result := IsFrameProtocol1(HexData);
    pProtocol2: Result := IsFrameProtocol2(HexData);
    //pProtocol3: Result := Copy(HexData, 16, Length(HexData)-21);
  end;
end;

function GetTxData(const Line: string; var Protocol: TProtocol): string;
var
  P: Integer;
begin
  Result := '';
  // Protocol1
  P := Pos(TxSign, Line);
  if P > 0 then
  begin
    Protocol := pProtocol1;
    Result := Copy(Line, P + Length(TxSign), Length(Line));
    Exit;
  end;
  // Protocol2
  P := Pos(TxSign2, Line);
  if P > 0 then
  begin
    Protocol := pProtocol2;
    Result := Copy(Line, P + Length(TxSign2), Length(Line));
    Exit;
  end;
  // Protocol3
  P := Pos(TxSign3, Line);
  if P > 0 then
  begin
    Protocol := pProtocol3;
    Result := Copy(Line, P + Length(TxSign3), Length(Line));
    Exit;
  end;
  P := Pos(TxSignNg, Line);
  if P > 0 then
  begin
    Protocol := pProtocolNg1Plain;
    Result := Copy(Line, P + Length(TxSignNg), Length(Line));
    Exit;
  end;
end;
function GetRxBytes(const Line: string; Protocol: TProtocol): string;
var
  P: Integer;
  pSign: string;
begin
  Result := '';
  case Protocol of
    pProtocol1: pSign := RxSign;
    pProtocol2: pSign := RxSign2;
    pProtocol3: pSign := RxSign3;
    pProtocolNg1,
    pProtocolNg1Plain: pSign := RxSignNg;
    pNone: Exit;
  end;
  P := Pos(pSign, Line);
  if P = 0 then Exit;
  Result := Copy(Line, P + Length(pSign), Length(Line));
end;
procedure ParseLog2(Lines: TStrings; Commands: TCommandList);
var
  i: Integer;
  P: Integer;
  Line: string;
  TxLine: string;
  Data: string;
  TxData: string;
  RxData: string;
  Protocol: TProtocol;
  LineNumber: Integer;
  Command: TCommand;
  CommandRec: TCommandRec;
begin
  TxData := '';
  RxData := '';
  LineNumber := 0;
  Protocol := pNone;
  Commands.Clear;
  for i := 0 to Lines.Count-1 do
  begin
    Line := Lines[i];
    // Tx data
    Data := GetTxData(Line, Protocol);
    if Data <> '' then
    begin
      if TxData = '' then
      begin
        TxLine := Line;
        LineNumber := i+1;
      end;
      TxData := TxData + Data;
      if (Length(RxData) > 2)and(Commands.Count > 0) then
      begin
        Command := Commands[Commands.Count-1];
        Command.AnswerData := GetFrame(RxData, Protocol);
        Command.ResCode := TCommand.GetResCode(Command.AnswerData);
      end;
      if IsFrame(TxData, Protocol) then
      begin
        CommandRec.ResCode := 0;
        CommandRec.AnswerData := '';
        CommandRec.Protocol := Protocol;
        CommandRec.LineNumber := LineNumber;
        CommandRec.TxData := GetFrame(TxData, Protocol);
        CommandRec.Code := TCommand.GetCode(CommandRec.TxData);
        CommandRec.Attributes := Copy(TxLine, 1, Length(ProtocolAttributes));
        Commands.Add(TCommand.Create(CommandRec));
        TxData := '';
      end;
      RxData := '';
    end;
    // Rx data
    P := Pos('<- ', Line);
    if P <> 0 then
    begin
      if Length(TxData) > 6 then
      begin
        CommandRec.ResCode := -1;
        CommandRec.AnswerData := '';
        CommandRec.Protocol := Protocol;
        CommandRec.LineNumber := LineNumber;
        CommandRec.TxData := GetFrame(TxData, Protocol);
        CommandRec.Code := TCommand.GetCode(CommandRec.TxData);
        CommandRec.Attributes := Copy(TxLine, 1, Length(ProtocolAttributes));
        Commands.Add(TCommand.Create(CommandRec));
      end;
      TxData := '';
      Data := Copy(Line, P + 3, Length(Line));

      if RxData <> '' then
        RxData := RxData + ' ';
      RxData := RxData + Trim(Data);
      if (RxData = '06')and (Protocol in [pProtocol1, pProtocol3]) then
      begin
        RxData := '';
      end;
    end;
  end;
  if (RxData <> '')and(Commands.Count > 0) then
  begin
    Command := Commands[Commands.Count-1];
    Command.AnswerData := GetFrame(RxData, Protocol);
    Command.ResCode := TCommand.GetResCode(Command.AnswerData);
    RxData := '';
  end;
end;

end.
