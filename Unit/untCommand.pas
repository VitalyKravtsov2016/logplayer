unit untCommand;

interface
uses
   System.SysUtils, System.Classes, System.Generics.Collections, BinUtils,
   Utils.BinStream;

type
  TProtocol = (pNone, pProtocol1, pProtocol2, pPlain);

  PCommand = ^TCommand;
  TCommand = record
    Data: AnsiString;
    Attributes: AnsiString;
    AnswerData: AnsiString;
    PlayedAnswerData: AnsiString;
    Played: Boolean;
    Selected: Boolean;
    Protocol: TProtocol;
    LineNumber: Integer;
    DriverError: string;
  end;
  TCommandList = TList<TCommand>;

  TCommandHelper = record helper for TCommand
    function TimeStamp: AnsiString;
    function ThreadID: AnsiString;
    function CommandName: string;
    function Code: Integer;
    function HasError: Boolean;
    function HasData(const AData: string): Boolean;
  end;

implementation
uses DriverCommands;
{ TCommandHelper }

function TCommandHelper.Code: Integer;
var
  Cmd: Word;
begin
  Cmd := BinToInt(HexToStr(Data), 1, 1);
  if (Cmd = $FF) or (Cmd = $FE) then
    Cmd := (Cmd shl 8) or (BinToInt(HexToStr(Data), 2, 1));
  Result := Cmd;
end;

function TCommandHelper.CommandName: string;
begin
  if (Protocol = pProtocol2) and (Data = '') then
    Result := 'Sync'
  else
    Result := GetCommandName(Data);
end;

function TCommandHelper.HasData(const AData: string): Boolean;
begin
  Result := (Pos(LowerCase(AData, loUserLocale), LowerCase(Attributes, loUserLocale)) > 0) or
            (Pos(LowerCase(AData, loUserLocale), LowerCase(TimeStamp, loUserLocale)) > 0) or
            (Pos(LowerCase(AData, loUserLocale), LowerCase(CommandName, loUserLocale)) > 0);
end;

function TCommandHelper.HasError: Boolean;
var
  Stream: IBinStream;
  b: Byte;
begin
  Result := False;
  if AnswerData = '' then
  begin
    Result := True;
    Exit;
  end;
  Stream := TBinStream.Create([]);
  Stream.WriteBytes(HexToBytes(AnswerData));
  Stream.Stream.Position := 0;
  if Stream.Size < 2 then Exit;
  b := Stream.ReadByte;
  if b = $FF then
    Stream.ReadByte;
  b := Stream.ReadByte;
  Result := b <> 0;
end;

function TCommandHelper.ThreadID: AnsiString;
begin
  Result := Copy(Attributes, Length('[08.12.2021 23:50:07.520] [ '), 8);
end;

function TCommandHelper.TimeStamp: AnsiString;
begin
  Result := Copy(Attributes, 2, Length('08.12.2021 23:50:07.520'));
end;

end.
