unit untCommand;

interface
uses
   System.Classes, System.Generics.Collections, BinUtils;

type
  PCommand = ^TCommand;
  TCommand = record
    Data: AnsiString;
    Attributes: AnsiString;
    AnswerData: AnsiString;
    Played: Boolean;
  end;
  TCommandList = TList<TCommand>;

  TCommandHelper = record helper for TCommand
    function TimeStamp: AnsiString;
    function ThreadID: AnsiString;
    function CommandName: string;
    function Code: Integer;
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
  Result := GetCommandName(Data);
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
