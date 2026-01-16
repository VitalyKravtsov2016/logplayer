unit untLogPlayer;

interface

uses
  // This
  EventBus,
  DrvFRLib_TLB, untCommand, System.SysUtils, Classes, BinUtils;

type
  TPlayMode = (pmPlay, pmStop, pmContinue, pmNone);

  TLogPlayer = class
  private
    FStopFlag: Boolean;
    FPlayMode: TPlayMode;
    function ContinueOnError: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure PlayLog(Drv: TDrvFR; Commands: TCommandList; ExceptList: TStrings; AResetECR: Boolean; AFirstCommandIndex: Integer; ACount: Integer; AInfinitePlay: Boolean);
    procedure StopPlaying;
    property PlayMode: TPlayMode read FPlayMode write FPlayMode;
  published
    [Channel('StopPlay')]
    procedure OnStopPlay(AMsg: string);

  end;

//procedure StopPlaying;

//procedure PlayLog(Drv: TDrvFR; Commands: TCommandList; ExceptList: TStrings; AResetECR: Boolean; AFirstCommandIndex: Integer; ACount: Integer);

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
  CmdCode: Integer;
begin
  Result := True;
  if ExceptList = nil then
    Exit;
  for S in ExceptList do
  begin
    CmdCode := TCommand.GetCode(S);
    if ACommand.Code = CmdCode then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure PlayLog(Drv: TDrvFR; Commands: TCommandList; ExceptList: TStrings; AResetECR: Boolean; AFirstCommandIndex: Integer; ACount: Integer);
var
  Command: TCommand;
  Cmd: AnsiString;
  Res: Integer;
  RepCount: Integer;
  Index: Integer;
  Count: Integer;
  ErrorAnswer: AnsiString;
  Data: AnsiString;
begin
  FStopFlag := False;
  try
    if Drv.ResetECR <> 0 then
      raise Exception.CreateFmt('%d, %s', [Drv.ErrorCode, Drv.ResultCodeDescription]);

    if (ACount = 0) or (ACount > (AFirstCommandIndex + Commands.Count - 1)) then
      Count := Commands.Count - 1
    else
      Count := AFirstCommandIndex + ACount - 1;
    for Index := AFirstCommandIndex to Count do
    begin
      if FStopFlag then
        Break;
      Command := Commands[Index];
      if not Command.Selected then
        Continue;
      if not PlayableCommand(Command, ExceptList) then
        Continue;
      GlobalEventBus.Post('CommandRun', Index.ToString);

      Drv.BinaryConversion := BINARY_CONVERSION_HEX;
      Drv.TransferBytes := Command.TxData;
      repeat
        Res := Drv.ExchangeBytes;
        Inc(RepCount);
        if (Res = $50) or (Res = $4B) then
          Sleep(50);
      until ((Res <> $50) and (Res <> $4B)) or (RepCount >= 5);
      if Res > 0 then
      begin
        if Length(Command.TxData) >= 2 then
        begin
          Data := HexToStr(Command.TxData);
          ErrorAnswer := (Data[1]);
          if Data[1] = #$FF then
            ErrorAnswer := ErrorAnswer + Data[2] + Chr(Res)
          else
            ErrorAnswer := ErrorAnswer + Chr(Res);

          Commands[Index].PlayedAnswerData := StrToHex(ErrorAnswer);
        end
        else
          Commands[Index].PlayedAnswerData := '';
      end
      else
        Commands[Index].PlayedAnswerData := Drv.TransferBytes;

      Commands[Index].Played := True;
      if Res <> 0 then
        raise Exception.CreateFmt('%d, %s', [Drv.ResultCode, Drv.ResultCodeDescription]);

      if Command.IsPrintCommand then
      begin
        Drv.WaitForPrinting;
      end;
    end;
  except
    on E: Exception do
      GlobalEventBus.Post('Error', Index.ToString + ' ' + E.Message);
  end;
end;

{ TLogPlayerEvents }

function TLogPlayer.ContinueOnError: Boolean;
begin
  Result := False;
  repeat
    case FPlayMode of
      pmPlay:
        begin
          //Result := False;
          //Exit;
        end;
      pmStop:
        begin
          Result := False;
          Exit;
        end;

      pmContinue:
        begin
          Result := True;
          Exit;
        end;
      pmNone:
        ;
    end;
  until False;
end;

constructor TLogPlayer.Create;
begin
  inherited;
  GlobalEventBus.RegisterSubscriberForChannels(Self);
end;

destructor TLogPlayer.Destroy;
begin

  inherited;
end;

procedure TLogPlayer.OnStopPlay(AMsg: string);
begin
  FPlayMode := pmStop;
end;

procedure TLogPlayer.PlayLog(
  Drv: TDrvFR;
  Commands: TCommandList;
  ExceptList: TStrings;
  AResetECR: Boolean;
  AFirstCommandIndex, ACount: Integer;
  AInfinitePlay: Boolean);
var
  Command: TCommand;
  Cmd: AnsiString;
  Res: Integer;
  RepCount: Integer;
  Index: Integer;
  Count: Integer;
  ErrorAnswer: AnsiString;
  Data: AnsiString;
  fCycleNumber: Integer;
begin
  FStopFlag := False;
  try
    //if Drv.ResetECR <> 0 then
    //  raise Exception.CreateFmt('%d, %s', [Drv.ErrorCode, Drv.ResultCodeDescription]);
    if AInfinitePlay then
      fCycleNumber := 0
    else
      fCycleNumber := -1;
    while True do
    begin
      if AInfinitePlay then
        Inc(fCycleNumber);
      if (ACount = 0) or (ACount > (AFirstCommandIndex + Commands.Count - 1)) then
        Count := Commands.Count - 1
      else
        Count := AFirstCommandIndex + ACount - 1;
      FPlayMode := pmPlay;
      for Index := AFirstCommandIndex to Count do
      begin
        try
          if FStopFlag then
            Break;
          Command := Commands[Index];
          if not Command.Selected then
            Continue;
          if not PlayableCommand(Command, ExceptList) then
            Continue;
          if AInfinitePlay then
            GlobalEventBus.Post('CommandRun', Index.ToString + ' ' + fCycleNumber.ToString)
          else
            GlobalEventBus.Post('CommandRun', Index.ToString);

          Drv.BinaryConversion := BINARY_CONVERSION_HEX;
          Drv.TransferBytes := Command.TxData;
          repeat
            Res := Drv.ExchangeBytes;
            Inc(RepCount);
            if (Res = $50) or (Res = $4B) then
              Sleep(50);
          until ((Res <> $50) and (Res <> $4B)) or (RepCount >= 5);
          if Res > 0 then
          begin
            if Length(Command.TxData) >= 2 then
            begin
              Data := HexToStr(Command.TxData);
              ErrorAnswer := (Data[1]);
              if Data[1] = #$FF then
                ErrorAnswer := ErrorAnswer + Data[2] + Chr(Res)
              else
                ErrorAnswer := ErrorAnswer + Chr(Res);
              Commands[Index].PlayedAnswerData := StrToHex(ErrorAnswer);
            end
            else
              Commands[Index].PlayedAnswerData := '';
          end
          else
            Commands[Index].PlayedAnswerData := Drv.TransferBytes;

          Commands[Index].Played := True;
          if Res <> 0 then
            raise Exception.CreateFmt('%d, %s', [Drv.ResultCode, Drv.ResultCodeDescription]);

          if Command.IsPrintCommand then
          begin
            Drv.WaitForPrinting;
          end;
        except
          on E: Exception do
          begin
            if Index < Count then
            begin
              GlobalEventBus.Post('ErrorQuery', Index.ToString + ' ' + E.Message);
              if ContinueOnError then
              begin
                FPlayMode := pmPlay;
                Continue;
              end
              else
                raise;
            end;
          end;
        end;
      end;
      if FStopFlag then
        Break;
      if not AInfinitePlay then
        Break;
    end;
  except
    on E: Exception do
    begin
      if AInfinitePlay then
        GlobalEventBus.Post('Error', Index.ToString + ' ' + E.Message)
      else
        GlobalEventBus.Post('Error', Index.ToString + ' ' + fCycleNumber.ToString + ' ' + E.Message);
    end;
  end;
end;

procedure TLogPlayer.StopPlaying;
begin
  FStopFlag := True;
end;

end.

