unit LogParser;

interface

uses
  System.Classes, System.SysUtils, untCommand, BinUtils;

procedure ParseLog(SL: TStringList; ACommandList: TCommandList);

// function GetTransferBytes(const AStr: string): string;

implementation

const
  TxSign = '[DEBUG] TPrinterProtocol -> ';
  TxSign2 = '[DEBUG] TPrinterProtocol2 -> ';
  RxSign = '[DEBUG] TPrinterProtocol <- ';
  RxSign2 = '[DEBUG] TPrinterProtocol2 <- ';

type
  TState = (sNone, sTransfer, sRx02, sRx, sRxp2, sRxplain, sWaitFor02);

function IsPlain(const AStr: string): Boolean;
begin

end;

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

function GetTransferBytes(const AStr: string; var Protocol: TProtocol): string;
var
  k: Integer;
begin
  Result := '';
  k := Pos(TxSign, AStr);
  if k > 0 then
  begin
    if Protocol <> pPlain then
      Protocol := pProtocol1;
    Result := Copy(AStr, k + Length(TxSign), Length(AStr));
  end
  else
  begin
    k := Pos(TxSign2, AStr);
    if k > 0 then
    begin
      Protocol := pProtocol2;
      Result := Copy(AStr, k + Length(TxSign2), Length(AStr));
    end;
  end;
end;

function GetRxBytes(const AStr: string; AProtocol: TProtocol): string;
var
  k: Integer;
  pSign: string;
begin
  Result := '';
  case AProtocol of
    pProtocol1:
      pSign := RxSign;
    pProtocol2:
      pSign := RxSign2;
    pNone:
      Exit;
  end;
  k := Pos(pSign, AStr);
  if k = 0 then
    Exit;
  Result := Copy(AStr, k + Length(pSign), Length(AStr));
end;

procedure ParseLog(SL: TStringList; ACommandList: TCommandList);
var
  i: Integer;
  S: string;
  SPrev: string;
  SNext: string;
  State: TState;
  TxData: string;
  RxData: string;
  Data: string;
  DataStamp: string;
  Command: TCommand;
  Protocol: TProtocol;
  LineNumber: Integer;
begin
  TxData := '';
  RxData := '';
  Protocol := pNone;
  ACommandList.Clear;
  State := sNone;
  LineNumber := -1;
  for i := 0 to SL.Count - 1 do
  begin
    S := SL[i];
    SPrev := '';
    SNext := '';
    if i > 0 then
      SPrev := SL[i - 1];
    if i < (SL.Count - 1) then
      SNext := SL[i + 1];
    case State of
      sNone:
        begin
          Data := GetTransferBytes(S, Protocol);
          if Data <> '' then
          begin
            case Protocol of
              pProtocol1:
                if (Pos('05', Data) = 1) and (Length(Data) = 2) then
                begin
                  DataStamp := Copy(S, 1, Length('[07.12.2021 18:30:04.598] [00002108]'));
                  State := sWaitFor02;
                end
                else if Length(Data) > 4 then
                begin
                  DataStamp := Copy(S, 1, Length('[07.12.2021 18:30:04.598] [00002108]'));
                  TxData := TxData + Data;
                  State := sTransfer;
                  Protocol := pPlain;
                  if LineNumber < 0 then
                    LineNumber := i + 1;
                end;
              pProtocol2:
                begin
                  DataStamp := Copy(S, 1, Length('[07.12.2021 18:30:04.598] [00002108]'));
                  TxData := TxData + ' ' + Data;
                  if LineNumber < 0 then
                    LineNumber := i + 1;
                  if GetRxBytes(SNext, pProtocol2) <> '' then
                    State := sRxp2;
                end;
            end;
          end
          else
          begin
            case Protocol of
              pProtocol1:
                begin
                  Data := GetRxBytes(S, Protocol);
                  if Pos('02', Data) = 1 then
                  begin
                    State := sRx02;
                  end;
                end;
              pProtocol2:
                begin
                  if GetRxBytes(SNext, pProtocol2) <> '' then
                    State := sRxp2;
                end;
              pPlain:
                begin
                  if GetRxBytes(SNext, pProtocol1) <> '' then
                    State := sRxplain;
                end;
            end;
          end;
        end;
      sWaitFor02:
        begin
          Data := GetTransferBytes(S, Protocol);
          if (Pos('02', Data) = 1) then
          begin
            TxData := TxData + Data;
            State := sTransfer;
            if LineNumber < 0 then
              LineNumber := i + 1;
          end
        end;
      sTransfer:
        begin
          Data := GetTransferBytes(S, Protocol);
          if Data = '' then
          begin
            if Protocol = pPlain then
              Command.Data := Copy(TxData, 4, Length(TxData))
            else
              Command.Data := Copy(TxData, 7, Length(TxData) - 9);
            Command.Attributes := DataStamp;
            Command.Protocol := Protocol;
            Command.LineNumber := LineNumber;
            ACommandList.Add(Command);
            TxData := '';
            State := sNone;
            LineNumber := -1;
          end
          else
          begin
            TxData := TxData + ' ' + Data;
          end;
        end;
      sRx02:
        begin
          Data := GetRxBytes(S, pProtocol1);
          if Data <> '' then
            State := sRx
          else
            State := sNone;
        end;
      sRx:
        begin
          Data := GetRxBytes(S, pProtocol1);
          if Data = '' then
          begin
            if Pos('06', GetTransferBytes(S, Protocol)) = 1 then
            begin
              if ACommandList.Count > 0 then
              begin
                Command := ACommandList[ACommandList.Count - 1];
                Command.AnswerData := Copy(RxData, 1, Length(RxData) - 2);
                Command.Protocol := pProtocol1;
                ACommandList[ACommandList.Count - 1] := Command;
              end;
              RxData := '';
              State := sNone;
            end;
          end
          else
          begin
            if RxData = '' then
              RxData := Data
            else
              RxData := RxData + ' ' + Data;
          end;
        end;
      sRxp2:
        begin
          Data := GetRxBytes(S, pProtocol2);
          if Data <> '' then
            RxData := RxData + ' ' + Data;
          if GetRxBytes(SNext, pProtocol2) = '' then
          begin
            Command.Data := GetCommandDatap2(TxData);
            Command.AnswerData := GetCommandDatap2(RxData); // Copy(TxData, 16, Length(TxData) - 7 - 5);
            Command.Attributes := DataStamp;
            Command.Protocol := pProtocol2;
            Command.LineNumber := LineNumber;
            ACommandList.Add(Command);
            TxData := '';
            RxData := '';
            State := sNone;
            LineNumber := -1;
            Protocol := pNone;
          end;
        end;
      sRxplain:
        begin
          Data := GetRxBytes(S, pProtocol1);
          if Data <> '' then
            RxData := RxData + ' ' + Data;
          if GetRxBytes(SNext, pProtocol1) = '' then
          begin
            if ACommandList.Count > 0 then
            begin
              Command := ACommandList[ACommandList.Count - 1];
              Command.AnswerData := Copy(RxData, 2, Length(RxData));
              Command.Protocol := pPlain;
              ACommandList[ACommandList.Count - 1] := Command;
            end;
            TxData := '';
            RxData := '';
            State := sNone;
            LineNumber := -1;
            Protocol := pNone;
          end;
        end
    end;
  end;
  if TxData <> '' then
  begin
    Command.Data := Copy(TxData, 7, Length(TxData) - 9);
    Command.Attributes := DataStamp;
    Command.Protocol := Protocol;
    Command.LineNumber := LineNumber;
    ACommandList.Add(Command);
  end;
end;

end.

