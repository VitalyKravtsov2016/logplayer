unit fmuMain;

interface

uses
  // VCL
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, LogParser,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, System.ImageList,
  Vcl.ImgList, Clipbrd,
  // 3'd
  JvAppStorage, JvAppXMLStorage, JvComponentBase, JvFormPlacement,
  EventBus,
  PngImageList,
  // This
  untCommand, untLogPlayer, DrvFRLib_TLB, DriverCommands,
  NotifyThread, VersionInfo, CommandParser, FileUtils, untFileUtil;

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
    btnPasteFromClipboard: TButton;
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
    edtSearch: TEdit;
    btnSearch: TButton;
    chkIngoreKKTErrors: TCheckBox;
    chkInfinitePlay: TCheckBox;
    procedure btnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnStartFromPositionClick(Sender: TObject);
    procedure btnPasteFromClipboardClick(Sender: TObject);
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
    procedure formStorageAfterRestorePlacement(Sender: TObject);
    procedure lvCommandsAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure lvCommandsAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure edtSearchClick(Sender: TObject);
  private
    FPlayer: TLogPlayer;
    FCommands: TCommandList;
    FFirstCommandIndex: Integer;
    FPlayCommandCount: Integer;
    FDriver: TDrvFR;
    FFinished: Boolean;
    FContinueIndex: Integer;
    FLastStateIndex: Integer;
    FLastIndex: Integer;
    procedure SelLine(Index: integer; ACycleNumber: Integer);
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
  Item.SubItems.Add(GetCommandShortValue(ACommand){ACommand.Data});
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
  memInfo.Clear;
  edtStatus.Text := '  Загрузка...';
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
    edtStatus.Clear;
  end;
end;

procedure TfmMain.OpenFromFile(const AFileName: string);
var
  S: TStringList;
  Command: TCommand;
  cmd: PCommand;
begin
  memInfo.Clear;
  lvCommands.Clear;
  edtStatus.Clear;
  S := TStringList.Create;
  try
    LoadFromFile2v1(AFileName, TEncoding.GetEncoding(1251), S);
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

procedure TfmMain.btnPasteFromClipboardClick(Sender: TObject);
begin
  LoadFromClipboard;
end;

procedure TfmMain.btnSearchClick(Sender: TObject);
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
    if FCommands[current].HasData(edtSearch.Text) or (Pos(LowerCase(edtSearch.Text, loUserLocale), LowerCase(lvCommands.Items[current].SubItems[2], loUserLocale)) > 0) then
      Inc(current);
    if current = (FCommands.Count - 1) then
      Exit;

    for i := current to FCommands.Count - 1 do
    begin
      if FCommands[i].HasData(edtSearch.Text) or (Pos(LowerCase(edtSearch.Text, loUserLocale), LowerCase(lvCommands.Items[i].SubItems[2], loUserLocale)) > 0) then
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

procedure TfmMain.btnSettingsClick(Sender: TObject);
begin
  FDriver.ShowProperties;
end;

procedure TfmMain.btnStartClick(Sender: TObject);
begin
  SetControlsState(True);
  FFirstCommandIndex := 0;
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
  AsyncAwait2(Play, OnFinished);
end;

procedure TfmMain.edtSearchChange(Sender: TObject);
begin
  btnOpen.Default := False;
  btnSearch.Default := True;
end;

procedure TfmMain.edtSearchClick(Sender: TObject);
begin
  edtSearchChange(Self);
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  Edit: TEdit;
begin
  Caption := 'TorgBalance: Log player & analyzer v.' + GetFileVersionInfoStr;
  FCommands := TCommandList.Create;
  FDriver := TDrvFR.Create(nil);
  DragAcceptFiles(Handle, True);
  ChangeWindowMessageFilter(WM_DROPFILES, MSGFLT_ADD);
  ChangeWindowMessageFilter(WM_COPYDATA, MSGFLT_ADD);
  ChangeWindowMessageFilter($0049, MSGFLT_ADD);
  GlobalEventBus.RegisterSubscriberForChannels(Self);
  FFinished := True;
  FPlayer := TLogPlayer.Create;
  FLastStateIndex := -1;
  FLastIndex := 0;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  Stop;
  DragAcceptFiles(Handle, False);
  FCommands.Free;
  FDriver.Free;
  FPlayer.Free;
end;

procedure TfmMain.formStorageAfterRestorePlacement(Sender: TObject);
begin
  Resize;
  Repaint;
end;

procedure TfmMain.LoadFromClipboard;
var
  S: TStringList;
begin
  edtStatus.Clear;
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

procedure TfmMain.lvCommandsAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
  if Item.StateIndex = 1 then
    Sender.Canvas.Font.Color := clRed;
end;

procedure TfmMain.lvCommandsAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
  if Item.StateIndex = 1 then
    Sender.Canvas.Font.Color := clRed;
  if SubItem <= 1 then
    Exit;

  if Pos('[ERROR]', Item.SubItems[2]) > 0 then
  begin
    Sender.Canvas.Font.Color := clRed;
    Exit;
  end;

  if (Item.SubItems[1] = 'Открыть чек') or (Item.SubItems[1] = 'Открытие смены') or (Item.SubItems[1] = 'Суточный отчет с гашением') or (Item.SubItems[1] = 'Операция V2') or
  (Item.SubItems[1] = 'Закрытие чека расширенное вариант V2') or (Item.SubItems[1] = 'Продажа') or (Item.SubItems[1] = 'Покупка') or (Item.SubItems[1] = 'Возврат продажи') or
  (Item.SubItems[1] = 'Возврат покупки') or (Item.SubItems[1] = 'Закрытие чека') or
  (Item.SubItems[1] = 'Подытог чека') then
    Sender.Canvas.Font.Style := [fsBold]
  else if (SubItem = 3) and (Item.SubItems[1] = 'Печать строки данным шрифтом') then
    Sender.Canvas.Font.Name := 'Courier New'
  else if (SubItem = 3) and ((Item.SubItems[1] = 'Запрос состояния') or (Item.SubItems[1] = 'Короткий запрос состояния')) then
    Sender.Canvas.Font.Color := clPurple
  else if (SubItem = 3) and (Item.SubItems[1] = 'Запрос описания ошибки') then
    Sender.Canvas.Font.Color := clRed;
end;

procedure TfmMain.lvCommandsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  Index: Integer;
  Command: TCommand;
  Fields: string;
  AnswerFields: string;
  PlayedFields: string;
  protocolstr: string;
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
  case Command.Protocol of
    pProtocol1:
      protocolstr := '[Protocol v1]';
    pProtocol2:
      protocolstr := '[Protocol v2]';
    pPlain:
      protocolstr := '[Protocol v1 (plain)]';
    pProtocolNg1:
      protocolstr := '[Protocol v1 (NG)]';
    pProtocolNg1Plain:
      protocolstr := '[Protocol v1 (plain) (NG)]';
  else
    protocolstr := '';
  end;
  memInfo.Lines.Add(Command.Attributes + ' ' + protocolstr + ' (Line ' + Command.LineNumber.ToString + ')');
  memInfo.Lines.Add(Command.CommandName);
  memInfo.Lines.Add('Передано     : ' + Command.Data);
  if Command.AnswerData = '' then
    memInfo.Lines.Add('Принято (лог): НЕТ ОТВЕТА')
  else
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
  CycleNumber: Integer;
  Splitted: TArray<string>;
begin
  Splitted := AMsg.Split([' ']);
  if Length(Splitted) = 0 then
    Exit;

  Line := Splitted[0].ToInteger;
  if Line > 0 then
    lvCommands.Items[Line - 1].Selected := False;

  if Length(Splitted) > 1 then
    CycleNumber := Splitted[1].ToInteger
  else
    CycleNumber := -1;
  SelLine(Line, CycleNumber);
end;

procedure TfmMain.OnError(AMsg: string);
var
  ErrorText: string;
  Index: Integer;
  CycleNumber: Integer;
  Splitted: TArray<string>;
begin
  if lvCommands.Items.Count = 0 then
    Exit;
  Splitted := AMsg.Split([' ']);
  if Length(Splitted) = 0 then
    Exit;

  Index := Splitted[0].ToInteger;

  if Length(Splitted) > 2 then
    CycleNumber := Splitted[1].ToInteger
  else
    CycleNumber := -1;
  ErrorText := '';
  if Length(Splitted) = 2 then
    ErrorText := Splitted[2]
  else if Length(Splitted) > 2 then
    ErrorText := Splitted[3];

  if Index < 0 then
    Index := 0;

  SelLine(Index, -1);
  lvCommands.Items.BeginUpdate;
  lvCommands.Items[Index].StateIndex := 2;
  lvCommands.Items.EndUpdate;
  lvCommands.SetFocus;
  if CycleNumber >= 0 then
    edtStatus.Text := Format('Цикл %d (%d/%d) %s: Ошибка: %s', [CycleNumber, Index + 1, FCommands.Count, FCommands[Index].CommandName, ErrorText])
  else
    edtStatus.Text := Format('(%d/%d) %s: Ошибка: %s', [Index + 1, FCommands.Count, FCommands[Index].CommandName, ErrorText]);
end;

function ExtractErrorCode(const AMsg: string): Integer;
var
  k: Integer;
  s: string;
begin
  k := Pos(' ', AMsg);
  s := Copy(AMsg, k, Pos(',', AMsg) - k);
  try
    Result := StrToInt(Trim(s));
  except
    Result := -1;
  end;
end;

procedure TfmMain.OnErrorQuery(AMsg: string);
begin
  if (chkIngoreKKTErrors.Checked) and (ExtractErrorCode(AMsg) > 0) then
  begin
    FPlayer.PlayMode := pmContinue;
    Exit;
  end;

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
  if FFirstCommandIndex < 0 then
    FFirstCommandIndex := 0;
  for i := 0 to FCommands.Count - 1 do
  begin
    PCommand(@FCommands.List[i])^.PlayedAnswerData := '';
    PCommand(@FCommands.List[i])^.Played := False;
  end;

  FPlayer.PlayLog(FDriver, FCommands, memCommandExceptions.Lines, True, FFirstCommandIndex, FPlayCommandCount, chkInfinitePlay.Checked);
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

procedure TfmMain.SelLine(Index: integer; ACycleNumber: Integer);
begin
  if (FLastIndex >= 0) {and (FLastIndex < lvCommands.Items.Count)} then
  begin
    lvCommands.Items[FLastIndex].StateIndex := FLastStateIndex;
    lvCommands.Items[FLastIndex].Selected := False;
  end;
  if (Index < 0) or (Index > (lvCommands.Items.Count - 1)) then
    Exit;
  lvCommands.Items[Index].Selected := True;
  lvCommands.Items[Index].MakeVisible(True);
  FLastStateIndex := lvCommands.Items[Index].StateIndex;
  FLastIndex := Index;
  if lvCommands.Items[Index].StateIndex < 1 then
    lvCommands.Items[Index].StateIndex := 0;
  lvCommands.SetFocus;
  progress.Position := Index;
  if ACycleNumber >= 0 then
    edtStatus.Text := Format('Цикл %d (%d/%d) %s', [ACycleNumber, Index + 1, FCommands.Count, FCommands[Index].CommandName])
  else
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
  btnStartFromPosition.Enabled := not AStarted;
  btnStartCurrentLine.Enabled := not AStarted;
  btnStartSelected.Enabled := not AStarted;
  btnOpen.Enabled := not AStarted;
  btnSettings.Enabled := not AStarted;
  btnPasteFromClipboard.Enabled := not AStarted;
  btnFindError.Enabled := not AStarted;
  memCommandExceptions.Enabled := not AStarted;
  chkInfinitePlay.Enabled := not AStarted;
  chkIngoreKKTErrors.Enabled := not AStarted;
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

