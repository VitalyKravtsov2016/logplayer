unit fmuMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, LogParser,
  Vcl.StdCtrls, untCommand, untLogPlayer, DrvFRLib_TLB, DriverCommands,
  Vcl.ComCtrls, JvAppStorage, JvAppXMLStorage, JvComponentBase, JvFormPlacement,
  EventBus, NotifyThread, System.ImageList, Vcl.ImgList, PngImageList,
  VersionInfo, Vcl.ExtCtrls, Vcl.Menus, CommandParser, Clipbrd;

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
    btnStartCurrentLine: TButton;
    btnStartSelected: TButton;
    Pfdfa1: TMenuItem;
    N3: TMenuItem;
    lblFileName: TLabel;
    N4: TMenuItem;
    N5: TMenuItem;
    btnFindError: TButton;
    procedure btnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnStartFromPositionClick(Sender: TObject);
    procedure btnOpenSessionClick(Sender: TObject);
    procedure btnCloseSessionClick(Sender: TObject);
    procedure btnGetStatusClick(Sender: TObject);
    procedure lvCommandsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure pmMain1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure btnStartCurrentLineClick(Sender: TObject);
    procedure btnStartSelectedClick(Sender: TObject);
    procedure Pfdfa1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure btnFindErrorClick(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    FPlayer: TLogPlayer;
    FCommands: TCommandList;
    FFirstCommandIndex: Integer;
    FPlayCommandCount: Integer;
    FDriver: TDrvFR;
    FFinished: Boolean;
    FContinueIndex: Integer;
    procedure SelLine(Index: integer);
    procedure AddCommand(ACommand: TCommand);
    procedure Play(Sender: TObject);
    procedure ContinuePlay;
    procedure Stop;
    procedure OnFinished(Sender: TObject);
    procedure SetControlsState(AStarted: Boolean);
    procedure Check(ACode: Integer; const ACmd: string);
    procedure SelectAll;
    procedure SelectNone;
    procedure SelectSelected;
    procedure OpenFromText(const AStr: TStringList);
    procedure OpenFromFile(const AFileName: string);
    procedure LoadFromClipboard;
  public
    [Channel('CommandRun')]
    procedure OnCommandRun(AMsg: string);
    [Channel('Error')]
    procedure OnError(AMsg: string);
    [Channel('ErrorQuery')]
    procedure OnErrorQuery(AMsg: string);
  protected
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses
  ShellAPI;

procedure TfmMain.AddCommand(ACommand: TCommand);
var
  Item: TListItem;
begin
  Item := lvCommands.Items.Add;
  Item.Caption := ACommand.TimeStamp;
  Item.SubItems.Add(ACommand.ThreadID);
  Item.SubItems.Add(ACommand.CommandName);
  Item.SubItems.Add(ACommand.Data);
  if ACommand.HasError then
    Item.StateIndex := 1;
end;

procedure TfmMain.btnCloseSessionClick(Sender: TObject);
begin
  memInfo.Clear;
  Application.ProcessMessages;

  FDriver.Password := FDriver.SysAdminPassword;
  Check(FDriver.PrintReportWithCleaning, 'Закрытие смены');
end;

procedure TfmMain.btnFindErrorClick(Sender: TObject);
var
  i: Integer;
  current: Integer;
begin
  if FCommands.Count = 0 then
    Exit;
  current := lvCommands.ItemIndex;
  if current < 0 then
    current := 0;
  repeat
    if FCommands[current].HasError then
      Inc(current);
    if current = (FCommands.Count - 1) then
      Exit;

    for i := current to FCommands.Count - 1 do
    begin
      if FCommands[i].HasError then
      begin
        lvCommands.ClearSelection;
        lvCommands.Items[i].Selected := True;
        lvCommands.Items[i].MakeVisible(True);
        lvCommands.SetFocus;
        Exit;
      end;
    end;
    if Application.MessageBox('Начать с начала?', 'Поиск завершен', MB_OKCANCEL) = IDOK then
    begin
      current := 0;
      Continue;
    end
    else
      Break
  until False;
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

procedure TfmMain.OpenFromText(const AStr: TStringList);
var
  Command: TCommand;
  cmd: PCommand;
begin
  lvCommands.Clear;
  ParseLog(AStr, FCommands);
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
end;

procedure TfmMain.OpenFromFile(const AFileName: string);
var
  S: TStringList;
  Command: TCommand;
  cmd: PCommand;
begin
  lvCommands.Clear;
  S := TStringList.Create;
  try
    S.LoadFromFile(AFileName);
    OpenFromText(S);
    lblFileName.Caption := AFileName;
  finally
    S.Free;
  end;
end;

procedure TfmMain.btnOpenClick(Sender: TObject);
var
  S: TStringList;
  Command: TCommand;
  cmd: PCommand;
begin
  if not dlgOpen.Execute then
    Exit;
  OpenFromFile(dlgOpen.FileName);
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
  FPlayCommandCount := 0;
  FFinished := False;
  SelectAll;
  AsyncAwait2(Play, OnFinished);
end;

procedure TfmMain.btnStartCurrentLineClick(Sender: TObject);
begin
  SetControlsState(True);
  FFinished := False;
  FPlayCommandCount := 1;
  FFirstCommandIndex := lvCommands.ItemIndex;
  if FFirstCommandIndex < 0 then
    FFirstCommandIndex := 0;
  SelectAll;
  AsyncAwait2(Play, OnFinished);
end;

procedure TfmMain.btnStartFromPositionClick(Sender: TObject);
begin
  SetControlsState(True);
  FFinished := False;
  FPlayCommandCount := 0;
  FFirstCommandIndex := lvCommands.ItemIndex;
  if FFirstCommandIndex < 0 then
    FFirstCommandIndex := 0;
  SelectAll;
  AsyncAwait2(Play, OnFinished);
end;

procedure TfmMain.btnStartSelectedClick(Sender: TObject);
begin
  SetControlsState(True);
  FPlayCommandCount := 0;
  FFinished := False;
  SelectNone;
  SelectSelected;
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

procedure TfmMain.ContinuePlay;
begin
  repeat
    Sleep(1);
  until FFinished;
  SetControlsState(True);
  FFinished := False;
  FPlayCommandCount := 0;
  FFirstCommandIndex := FContinueIndex;
  if FFirstCommandIndex < 0 then
    FFirstCommandIndex := 0;
  //SelectAll;
  AsyncAwait2(Play, OnFinished);
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
Edit: TEdit;
begin
  Caption := 'SHTRIH-M: Log player & analyzer v.' + GetFileVersionInfoStr;
  FCommands := TCommandList.Create;
  FDriver := TDrvFR.Create(nil);
  DragAcceptFiles(Handle, True);
  GlobalEventBus.RegisterSubscriberForChannels(Self);
  FFinished := True;
  FPlayer := TLogPlayer.Create;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  Stop;
  DragAcceptFiles(Handle, False);
  FCommands.Free;
  FDriver.Free;
  FPlayer.Free;
end;

procedure TfmMain.LoadFromClipboard;
var
  S: TStringList;
begin
  if Clipboard.HasFormat(CF_TEXT) then
  begin
    S := TStringList.Create;
    try
      S.Text := ClipBoard.AsText;
      OpenFromText(S);
      lblFileName.Caption := 'Clipboard';
    finally
      S.Free;
    end;
  end;
end;

procedure TfmMain.lvCommandsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  Index: Integer;
  Command: TCommand;
  Fields: string;
  AnswerFields: string;
  PlayedFields: string;
begin
  if not FFinished then
    Exit;
  if not Selected then
    Exit;
  if Item = nil then
    Exit;
  Index := lvCommands.Items.IndexOf(Item);
  if Index > (FCommands.Count - 1) then
    Exit;

  Command := FCommands[Index];
  memInfo.Clear;
  memInfo.Lines.Add(Command.CommandName);
  memInfo.Lines.Add('Передано     : ' + Command.Data);
  memInfo.Lines.Add('Принято (лог): ' + Command.AnswerData);
  memInfo.Lines.Add('Принято (ККТ): ' + Command.PlayedAnswerData);
  ParseCommand(Command, Fields, AnswerFields, PlayedFields);
  memInfo.Lines.Add('');
  memInfo.Lines.Add('Входные параметры:');
  memInfo.Lines.Add(Fields);
  memInfo.Lines.Add('Возвращенные параметры (лог):');
  memInfo.Lines.Add(AnswerFields);
  memInfo.Lines.Add('Возвращенные параметры (ККТ):');
  memInfo.Lines.Add(PlayedFields);
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

      s := Format('[%s] [%s] -> %s'#13#10, [Command.TimeStamp, Command.ThreadID, Command.Data]);
      Bytes := TEncoding.ANSI.GetBytes(s);
      F.Write(Bytes, Length(Bytes));
      if Command.AnswerData <> '' then
      begin
        s := Format('[%s] [%s] <- %s'#13#10, [Command.TimeStamp, Command.ThreadID, Command.AnswerData]);
        Bytes := TEncoding.ANSI.GetBytes(s);
        F.Write(Bytes, Length(Bytes));
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfmMain.N3Click(Sender: TObject);
begin
  btnStartSelectedClick(Sender);
end;

procedure TfmMain.N5Click(Sender: TObject);
begin
  LoadFromClipboard;
end;

procedure TfmMain.N7Click(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  repeat
  //for i := 0 to lvCommands.Items.Count - 1 do
    if lvCommands.Items[i].Selected then
    begin
    //lvCommands.Items.
      lvCommands.Items.Delete(i);
    //  Items[i].Free;
      FCommands.Delete(i);
    end;
    Inc(i);
  until i >= (lvCommands.Items.Count - 1);
     // lvCommands.DeleteSelected;

   for i := 0 to lvCommands.Items.Count - 1 do
   begin
     memInfo.Lines.Add('lv ' + i.ToString + ' ' + lvCommands.Items[i].Caption);
     memInfo.Lines.Add('lv ' + i.ToString + ' ' + FCommands[i].Attributes);
     memInfo.Lines.Add('');
   end;
end;

procedure TfmMain.OnCommandRun(AMsg: string);
var
  Line: Integer;
begin
  Line := AMsg.ToInteger;
  if Line > 0 then
    lvCommands.Items[Line - 1].Selected := False;

  SelLine(Line);
end;

procedure TfmMain.OnError(AMsg: string);
var
  ErrorText: string;
  Index: Integer;
begin
  if lvCommands.Items.Count = 0 then
    Exit;
  Index := StrToIntDef(Copy(AMsg, 1, Pos(' ', AMsg) - 1), 0);
  ErrorText := Copy(AMsg, Pos(' ', AMsg) + 1, Length(AMsg));
  SelLine(Index);
  lvCommands.Items.BeginUpdate;
  lvCommands.Items[Index].StateIndex := 2;
  lvCommands.Items.EndUpdate;
  lvCommands.SetFocus;
 { if Application.MessageBox(PWideChar('Ошибка: ' + ErrorText + #13#10 + 'Продолжить?'), 'Ошибка', MB_YESNO + MB_ICONSTOP) = IDYES then
  begin
    if Index < (FCommands.Count - 1) then
      FContinueIndex := Index + 1;
    ContinuePlay;
  end
  else  }

    edtStatus.Text := Format('(%d/%d) %s: Ошибка: %s', [Index + 1, FCommands.Count, FCommands[Index].CommandName, ErrorText]);
end;

procedure TfmMain.OnErrorQuery(AMsg: string);
begin
  if Application.MessageBox(PWideChar('Ошибка: ' + AMsg + #13#10 + 'Продолжить?'), 'Ошибка', MB_YESNO + MB_ICONSTOP) = IDYES then
  begin
    FPlayer.PlayMode := pmContinue;
  end
  else
    FPlayer.PlayMode := pmStop
end;

procedure TfmMain.OnFinished(Sender: TObject);
begin
  SetControlsState(False);
  FFinished := True;
  lvCommandsSelectItem(Self, lvCommands.Selected, True);
end;

procedure TfmMain.Pfdfa1Click(Sender: TObject);
begin
  btnStartCurrentLineClick(Sender);
end;

procedure TfmMain.Play(Sender: TObject);
var
  Command: TCommand;
  i: Integer;
begin
  FFirstCommandIndex := lvCommands.ItemIndex;
  if FFirstCommandIndex < 0 then
    FFirstCommandIndex := 0;
  for i := 0 to FCommands.Count - 1 do
  begin
    PCommand(@FCommands.List[i])^.PlayedAnswerData := '';
    PCommand(@FCommands.List[i])^.Played := False;
  end;

  FPlayer.PlayLog(FDriver, FCommands, memCommandExceptions.Lines, True, FFirstCommandIndex, FPlayCommandCount);
end;

procedure TfmMain.pmMain1Click(Sender: TObject);
begin
  btnStartFromPositionClick(Sender);
end;

procedure TfmMain.SelectAll;
var
  i: Integer;
begin
  for i := 0 to FCommands.Count - 1 do
    PCommand(@FCommands.List[i])^.Selected := True;
end;

procedure TfmMain.SelectNone;
var
  i: Integer;
begin
  for i := 0 to FCommands.Count - 1 do
    PCommand(@FCommands.List[i])^.Selected := False;
end;

procedure TfmMain.SelectSelected;
var
  i: Integer;
begin
  for i := 0 to lvCommands.Items.Count - 1 do
    PCommand(@FCommands.List[i])^.Selected := lvCommands.Items[i].Selected;
end;

procedure TfmMain.SelLine(Index: integer);
begin
  //lvcommands.Items.BeginUpdate;
  try
  if Index > 0 then
    lvCommands.Items[Index - 1].StateIndex := -1;
  if Index < 0 then
    Exit;

  //lvCommands.ClearSelection;
  lvCommands.Items[Index].Selected := True;
  lvCommands.Items[Index].MakeVisible(True);
  if lvCommands.Items[Index].StateIndex < 1 then
    lvCommands.Items[Index].StateIndex := 0;
  lvCommands.SetFocus;
  finally
    //lvCommands.Items.EndUpdate;
  end;
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
    begin
      if FCommands[i].HasError then
        lvCommands.Items[i].StateIndex := 1
      else
        lvCommands.Items[i].StateIndex := -1;
    end;
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
  FPlayer.StopPlaying;
  repeat
    Application.ProcessMessages;
  until FFinished;
end;

procedure TfmMain.WMDropFiles(var Msg: TMessage);
var
  hDrop: THandle;
  FileCount: Integer;
  NameLen: Integer;
  fNumber: Integer;
  fName: string;
begin
  hDrop := Msg.wParam;
  FileCount := DragQueryFile(hDrop, $FFFFFFFF, nil, 0);
  try
    if FileCount = 0 then
      Exit;
    fNumber := 0;
    NameLen := DragQueryFile(hDrop, fNumber, nil, 0) + 1;
    SetLength(fName, NameLen);
    DragQueryFile(hDrop, fNumber, Pointer(fName), NameLen);
    OpenFromFile(fName);
  finally
    DragFinish(hDrop);
  end;
end;

end.

