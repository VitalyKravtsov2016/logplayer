unit fmuMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, LogParser, Vcl.StdCtrls, untCommand, untLogPlayer, DrvFRLib_TLB,
  DriverCommands, Vcl.ComCtrls, JvAppStorage, JvAppXMLStorage,
  JvComponentBase, JvFormPlacement, EventBus, NotifyThread, System.ImageList,
  Vcl.ImgList, PngImageList, VersionInfo, Vcl.ExtCtrls, Vcl.Menus,
  CommandParser;

type
  TfmMain = class(TForm)
    btnOpen: TButton;
    btnStart: TButton;
    dlgOpen: TOpenDialog;
    edtStatus: TEdit;
    btnStop: TButton;
    progress: TProgressBar;
    lvCommands: TListView;
    lbl: TLabel;
    memCommandExceptions: TMemo;
    formStorage: TJvFormStorage;
    xmlStorage: TJvAppXMLFileStorage;
    btnStartFromPosition: TButton;
    btnSettings: TButton;
    pngmglst: TPngImageList;
    pngmglstButtons: TPngImageList;
    memInfo: TMemo;
    btnOpenSession: TButton;
    btnCloseSession: TButton;
    btnGetStatus: TButton;
    pmMain: TPopupMenu;
    pmMain1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    dlgSave: TSaveDialog;
    pnl: TPanel;
    pnlTop: TPanel;
    pnlBottom: TPanel;
    spl1: TSplitter;
    procedure btnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure lvCommandsDblClick(Sender: TObject);
    procedure btnStartFromPositionClick(Sender: TObject);
    procedure btnOpenSessionClick(Sender: TObject);
    procedure btnCloseSessionClick(Sender: TObject);
    procedure btnGetStatusClick(Sender: TObject);
    procedure lvCommandsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure pmMain1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
    FCommands: TCommandList;
    FFirstCommandIndex: Integer;
    FDriver: TDrvFR;
    FFinished: Boolean;
    procedure SelLine(Index: integer);
    procedure AddCommand(ACommand: TCommand);
    procedure Play(Sender: TObject);
    procedure Stop;
    procedure OnFinished(Sender: TObject);
    procedure SetControlsState(AStarted: Boolean);
    procedure Check(ACode: Integer; const ACmd: string);
  public
    [Channel('CommandRun')]
    procedure OnCommandRun(AMsg: String);
    [Channel('Error')]
    procedure OnError(AMsg: String);

  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.AddCommand(ACommand: TCommand);
var
  Item: TListItem;
begin
  Item := lvCommands.Items.Add;
  Item.Caption := ACommand.TimeStamp;
  Item.SubItems.Add(ACommand.ThreadID);
  Item.SubItems.Add(ACommand.CommandName);
  Item.SubItems.Add(ACommand.Data);
end;

procedure TfmMain.btnCloseSessionClick(Sender: TObject);
begin
  memInfo.Clear;
  Application.ProcessMessages;

  FDriver.Password := FDriver.SysAdminPassword;
  Check(FDriver.PrintReportWithCleaning, 'Закрытие смены');
end;

procedure TfmMain.btnGetStatusClick(Sender: TObject);
var
  Res: Integer;
begin
  memInfo.Clear;
  Application.ProcessMessages;
  FDriver.Password := FDriver.SysAdminPassword;
  Res := FDriver.GetECRStatus;
  Check(Res, 'Запрос состояния');
  if Res <> 0 then
    Exit;
  memInfo.Lines.Add(Format('Режим   : %d, %s', [FDriver.ECRMode, FDriver.ECRModeDescription]));
  memInfo.Lines.Add(Format('Подрежим: %d, %s', [FDriver.ECRAdvancedMode, FDriver.ECRAdvancedModeDescription]));
end;

procedure TfmMain.btnOpenClick(Sender: TObject);
var
  S: TStringList;
  Command: TCommand;
  cmd: PCommand;
begin
  if not dlgOpen.Execute then
    Exit;
  lvCommands.Clear;
  S := TStringList.Create;
  try
    S.LoadFromFile(dlgOpen.FileName);
    ParseLog(S, FCommands);
    progress.Min := 0;
    if FCommands.Count > 0 then
      progress.Max := FCommands.Count - 1;
    progress.Position := 0;
    lvCommands.Items.BeginUpdate;
    try
      for Command in FCommands do
      begin
        AddCommand(Command);
        progress.Position := Progress.Position + 1;
        Application.ProcessMessages;
      end;
    finally
      lvCommands.Items.EndUpdate;
      progress.Position := 0;
    end;
  finally
    S.Free;
  end;
end;

procedure TfmMain.btnOpenSessionClick(Sender: TObject);
begin
  memInfo.Clear;
  Application.ProcessMessages;

  FDriver.Password := FDriver.SysAdminPassword;
  Check(FDriver.OpenSession, 'Открытие смены');
end;

procedure TfmMain.btnSettingsClick(Sender: TObject);
begin
  FDriver.ShowProperties;
end;

procedure TfmMain.btnStartClick(Sender: TObject);
begin
  SetControlsState(True);
  FFinished := False;
  AsyncAwait2(Play, OnFinished);
end;

procedure TfmMain.btnStartFromPositionClick(Sender: TObject);
begin
  SetControlsState(True);
  FFinished := False;
  FFirstCommandIndex := lvCommands.ItemIndex;
  if FFirstCommandIndex < 0 then
    FFirstCommandIndex := 0;
  AsyncAwait2(Play, OnFinished);
end;

procedure TfmMain.btnStopClick(Sender: TObject);
begin
  Stop;
end;

procedure TfmMain.Check(ACode: Integer; const ACmd: string);
begin
  if ACode <> 0 then
    memInfo.Text := Format('%s: Ошибка: %d, %s', [ACmd, ACode, FDriver.ResultCodeDescription])
  else
    memInfo.Text := Format('%s: Успешно', [ACmd]);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Caption := 'SHTRIH-M: Log player v.' + GetFileVersionInfoStr;
  FCommands := TCommandList.Create;
  FDriver := TDrvFR.Create(nil);
  GlobalEventBus.RegisterSubscriberForChannels(Self);
  FFinished := True;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  Stop;
  FCommands.Free;
  FDriver.Free;
end;

procedure TfmMain.lvCommandsDblClick(Sender: TObject);
begin
  ShowMessage(FCommands[lvCommands.ItemIndex].AnswerData);
end;

procedure TfmMain.lvCommandsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  Index: Integer;
  Command: TCommand;
  Fields: string;
  AnswerFields: string;
begin
  if not FFinished then
    Exit;
  if not Selected then
    Exit;
  if Item = nil then
    Exit;
  Index := lvCommands.Items.IndexOf(Item);
  if Index > (FCommands.Count - 1)  then
    Exit;

  Command := FCommands[Index];
  memInfo.Clear;
  memInfo.Lines.Add(Command.CommandName);
  memInfo.Lines.Add('Передано: ' + Command.Data);
  memInfo.Lines.Add('Принято : ' + Command.AnswerData);
  ParseCommand(Command, Fields, AnswerFields);
  memInfo.Lines.Add('');
  memInfo.Lines.Add('Входные параметры:');
  memInfo.Lines.Add(Fields);
  memInfo.Lines.Add('Возвращенные параметры:');
  memInfo.Lines.Add(AnswerFields);
  memInfo.SelStart := 0;
  memInfo.SelLength := 0;
end;

procedure TfmMain.N2Click(Sender: TObject);
var
  F: TFileStream;
  s: string;
  Command: TCommand;
  Bytes: TBytes;
begin
  if not dlgSave.Execute then
    Exit;
  F := TFileStream.Create(dlgSave.FileName, fmCreate);
  try
    for Command in FCommands do
    begin
      s := Format('[%s] [%s] [%s]'#13#10, [Command.TimeStamp, Command.ThreadID, Command.CommandName]);
      Bytes := TEncoding.ANSI.GetBytes(s);
      F.Write(Bytes, Length(Bytes));

      s := Format('[%s] [%s] -> %s'#13#10, [Command.TimeStamp, Command.ThreadID, command.Data]);
      Bytes := TEncoding.ANSI.GetBytes(s);
      F.Write(Bytes, Length(Bytes));
      if Command.AnswerData <> '' then
      begin
        s := Format('[%s] [%s] <- %s'#13#10, [Command.TimeStamp, Command.ThreadID, command.AnswerData]);
        Bytes := TEncoding.ANSI.GetBytes(s);
        F.Write(Bytes, Length(Bytes));
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfmMain.OnCommandRun(AMsg: String);
begin
  SelLine(AMsg.ToInteger);
end;

procedure TfmMain.OnError(AMsg: String);
var
  ErrorText: string;
  Index: Integer;
begin
  if lvCommands.Items.Count = 0 then
    Exit;
  Index := StrToIntDef(Copy(AMsg, 1, Pos(' ', AMsg)), 0);
  ErrorText := Copy(AMsg, Pos(' ', AMsg) + 1, Length(AMsg));
  SelLine(Index);
  lvCommands.Items.BeginUpdate;
  lvCommands.Selected.StateIndex := 1;
  lvCommands.Items.EndUpdate;
  lvCommands.SetFocus;
  edtStatus.Text := Format('(%d/%d) %s: Ошибка: %s', [Index + 1, FCommands.Count, FCommands[Index].CommandName, ErrorText]);
end;

procedure TfmMain.OnFinished(Sender: TObject);
begin
  SetControlsState(False);
  FFinished := True;
  SelLine(lvCommands.ItemIndex);
end;

procedure TfmMain.Play(Sender: TObject);
var
  Command: TCommand;
  i: Integer;
begin
  FFirstCommandIndex := lvCommands.ItemIndex;
  if FFirstCommandIndex < 0 then FFirstCommandIndex := 0;
  for i := 0 to FCommands.Count - 1 do
  begin
    PCommand(@FCommands.List[i])^.AnswerData := '';
    PCommand(@FCommands.List[i])^.Played := False;
  end;

  PlayLog(FDriver, FCommands, memCommandExceptions.Lines, True, FFirstCommandIndex);
end;

procedure TfmMain.pmMain1Click(Sender: TObject);
begin
  btnStartFromPositionClick(Sender);
end;

procedure TfmMain.SelLine(Index: integer);
begin
  if Index > 0 then
    lvCommands.Items[Index - 1].StateIndex := -1;
  if Index < 0 then
    Exit;
  lvCommands.Selected := lvCommands.Items[Index];
  lvCommands.Selected.MakeVisible(True);
  lvCommands.Selected.StateIndex := 0;
  lvCommands.SetFocus;

  progress.Position := Index;
  edtStatus.Text := Format('(%d/%d) %s', [Index + 1, FCommands.Count, FCommands[Index].CommandName]);
end;

procedure TfmMain.SetControlsState(AStarted: Boolean);
var
  i: Integer;
begin
  if AStarted then
  begin
    progress.Position := 0;
    lvCommands.Items.BeginUpdate;
    for i := 0 to lvCommands.Items.Count - 1 do
      lvCommands.Items[i].StateIndex := -1;
    lvCommands.Items.EndUpdate;
  end;
  btnStart.Enabled := not AStarted;
  btnStop.Enabled := AStarted;
  btnStartFromPosition.Enabled := not AStarted;
  btnOpen.Enabled := not AStarted;
  memCommandExceptions.Enabled := not AStarted;
  memInfo.Clear;
end;

procedure TfmMain.Stop;
begin
  StopPlaying;
  repeat
    Application.ProcessMessages;
  until FFinished;
end;

end.
