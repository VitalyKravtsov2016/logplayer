unit untLogPlayer;

interface
uses
  DrvFRLib_TLB, untCommand, System.SysUtils, Classes, EventBus;

procedure StopPlaying;
procedure PlayLog(Drv: TDrvFR; Commands: TCommandList; ExceptList: TStrings; AResetECR: Boolean; AFirstCommandIndex: Integer);

implementation

var
  FStopFlag: Boolean = False;

procedure StopPlaying;
begin
  FStopFlag := True;
end;

function PlayableCommand(const ACommand: TCommand; const ExceptList: TStrings): Boolean;
var
  S: AnsiString;
  Cmd: TCommand;
begin
  Result := True;
  if ExceptList = nil then
    Exit;
  for S in ExceptList do
  begin
    Cmd.Data := S;
    if ACommand.Code = Cmd.Code then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure PlayLog(Drv: TDrvFR; Commands: TCommandList; ExceptList: TStrings; AResetECR: Boolean; AFirstCommandIndex: Integer);
var
  Command: TCommand;
  Cmd: AnsiString;
  Res: Integer;
  RepCount: Integer;
  Index: Integer;
begin
  FStopFlag := False;
  try
    if Drv.ResetECR <> 0 then
      raise Exception.CreateFmt('%d, %s', [Drv.ErrorCode, Drv.ResultCodeDescription]);
    for Index := AFirstCommandIndex to Commands.Count - 1 do
    begin
      if FStopFlag then
        Break;
      Command := Commands[Index];
      if not PlayableCommand(Command, ExceptList) then
        Continue;
      GlobalEventBus.Post('CommandRun', Index.ToString);

      Drv.BinaryConversion := BINARY_CONVERSION_HEX;
      Drv.TransferBytes := Command.Data;
      repeat
        Res := Drv.ExchangeBytes;
        Inc(RepCount);
        if (Res = $50) or (Res = $4B) then
          Sleep(50);
      until ((Res <> $50) and (Res <> $4B)) or (RepCount >= 5);
      if Res <> 0 then
        raise Exception.CreateFmt('%d, %s', [Drv.ErrorCode, Drv.ResultCodeDescription]);
      PCommand(@Commands.List[Index])^.AnswerData := Drv.TransferBytes;
      PCommand(@Commands.List[Index])^.Played := True;
      if Pos('FF 45', Command.Data) > 0 then
      begin
        Drv.WaitForPrinting;
      end;
    end;
  except
    on E: Exception do
      GlobalEventBus.Post('Error', Index.ToString + ' ' + E.Message);

  end;
end;

end.
