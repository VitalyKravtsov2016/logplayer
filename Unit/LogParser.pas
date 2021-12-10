unit LogParser;

interface

uses System.Classes, System.SysUtils, untCommand;

procedure ParseLog(SL: TStringList; ACommandList: TCommandList);
function GetTransferBytes(const AStr: string): string;

implementation
const TxSign = '[DEBUG] TPrinterProtocol -> ';

type
  TState = (sNone, sTransfer);


function GetTransferBytes(const AStr: string): string;
var
  k: Integer;
begin
  Result := '';
  k := Pos(TxSign, AStr);
  if k = 0 then
    Exit;
  Result := Copy(AStr, k + Length(TxSign), Length(AStr));
end;

procedure ParseLog(SL: TStringList; ACommandList: TCommandList);
var
  S: string;
  State: TState;
  TxData: string;
  Data: string;
  DataStamp: string;
  Command: TCommand;
begin
  ACommandList.Clear;
  State := sNone;
  for S in SL do
  begin
    case State of
      sNone: begin
        Data := GetTransferBytes(S);
        if Data <> '' then
        begin
          if Pos('02', Data) = 1 then
          begin
            DataStamp := Copy(S, 1, Length('[07.12.2021 18:30:04.598] [00002108]'));
            TxData := TxData + Data;
            State := sTransfer;
          end;
        end;
      end;
      sTransfer: begin
        Data := GetTransferBytes(S);
        if Data = '' then
        begin
          Command.Data := Copy(TxData, 7, Length(TxData) - 9);
          Command.Attributes := DataStamp;
          ACommandList.Add(Command);
          TxData := '';
          State := sNone;
        end
        else
        begin
          TxData := TxData + ' ' + Data;
        end;
      end;
    end;
  end;
  if TxData <> ''  then
  begin
    Command.Data := Copy(TxData, 7, Length(TxData) - 9);
    Command.Attributes := DataStamp;
    ACommandList.Add(Command);
  end;
end;

end.
