unit duLogParser;

interface

uses
  // VCL
  Windows, ActiveX, ComObj, SysUtils, Classes,
  // DUnit
  TestFramework,
  // This
  //LogParser,
  LogParser2, untCommand, BinUtils,
  ShtrihProtocol1, ShtrihProtocol2, ShtrihProtocol3;

type
  { TLogParserTest }

  TLogParserTest = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestShtrihProtocol1;
    procedure TestShtrihProtocol2;
    procedure TestShtrihProtocol3;

    procedure TestParseProtocol1;
    procedure TestParseProtocol2;
    procedure TestParseProtocol2_1;
    procedure TestParseProtocol2_2;
    procedure TestParseProtocol1_1;
    procedure TestParseProtocol1_2;

    procedure TestParseProtocol3;
    procedure TestCommand2F;
    procedure TestUnknownCommandLog;
  end;

implementation

{ TLogParserTest }

procedure TLogParserTest.SetUp;
begin
end;

procedure TLogParserTest.TearDown;
begin
end;

procedure TLogParserTest.TestParseProtocol1;
var
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
  AnswerData: string;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Protocol1.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(1, Commands.Count, 'Commands.Count <> 1');
    Command := Commands[0];

    CheckEquals('11 1E 00 00 00', Command.TxData, 'Command.Data');
    AnswerData := '11 00 1E 54 33 1C 1C 11 0C 19 01 DA 00 92 02 04 00 02 57 ' +
      '41 00 00 01 01 10 0E 01 1A 0D 2F 04 00 86 45 00 00 59 00 00 00 00 00 12 8C 86 42 02 00';
    CheckEquals(AnswerData, Command.AnswerData, 'Command.AnswerData');
    CheckEquals($11, Command.Code, 'Command.Code');
    CheckEquals(0, Command.ResCode, 'Command.ResCode');
    CheckEquals(1, Command.LineNumber, 'Command.LineNumber');

  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestParseProtocol1_1;
var
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
  AnswerData: string;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Protocol1_1.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(1, Commands.Count, 'Commands.Count <> 1');
    Command := Commands[0];

    CheckEquals('1A 1E 00 00 00 D9 10', Command.TxData, 'Command.Data');
    AnswerData := '1A 00 1E 00 00 00 00 00 00';
    CheckEquals(AnswerData, Command.AnswerData, 'Command.AnswerData');
    CheckEquals($1A, Command.Code, 'Command.Code');

  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestParseProtocol1_2;
var
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
  AnswerData: string;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Protocol1_2.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(4, Commands.Count, 'Commands.Count <> 1');
    // Command0
    Command := Commands[0];
    CheckEquals('FC', Command.TxData, 'Command.Data');
    AnswerData := 'FC 00 00 00 01 0E FC 00 D8 D2 D0 C8 D5 2D CB C0 C9 D2 2D 30 32 D4';
    CheckEquals(AnswerData, Command.AnswerData, 'Command.AnswerData');
    CheckEquals($FC, Command.Code, 'Command.Code');
    // Command1
    Command := Commands[1];
    CheckEquals('FC', Command.TxData, 'Command.Data');
    AnswerData := 'FC 00 00 00 01 0E FC 00 D8 D2 D0 C8 D5 2D CB C0 C9 D2 2D 30 32 D4';
    CheckEquals(AnswerData, Command.AnswerData, 'Command.AnswerData');
    CheckEquals($FC, Command.Code, 'Command.Code');
    // Command2
    Command := Commands[2];
    CheckEquals('F7 01', Command.TxData, 'Command.Data');
    AnswerData := 'F7 00 5A A0 40 03 20 EC 31 00 0C 18 01 0C 10 00 00 00 00 00 00 1E 00 00 00 00 06 FF 00 30 40 B6 03 12 13 18 11 11 19';
    CheckEquals(AnswerData, Command.AnswerData, 'Command.AnswerData');
    CheckEquals($F7, Command.Code, 'Command.Code');

  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestParseProtocol3;
var
  Lines: TStrings;
  Commands: TCommandList;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Protocol3.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(1, Commands.Count, 'Commands.Count <> 1');
  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestParseProtocol2;
var
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
  AnswerData: string;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Protocol2.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(1, Commands.Count, 'Commands.Count <> 1');
    Command := Commands[0];

    CheckEquals('FC', Command.TxData, 'Command.TxData');
    //AnswerData := 'FC 00 00 00 01 0E 98 00 D8 D2 D0 C8 D5 2D CD C0 CD CE 2D D4';
    AnswerData := 'FC 00 00 00 01 0E 98 00 D8 D2 D0 C8 D5 2D CD C0 CD CE 2D D4 CA';
    CheckEquals(AnswerData, Command.AnswerData, 'Command.AnswerData');
    CheckEquals($FC, Command.Code, 'Command.Code');
  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestParseProtocol2_1;
var
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
  AnswerData: string;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Protocol2_1.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(11, Commands.Count, 'Commands.Count <> 1');

    Command := Commands[9];
    CheckEquals('E0 1E 00 00 00', Command.TxData, 'Command.TxData');
    CheckEquals('', Command.AnswerData, 'Command.AnswerData');
    CheckEquals($E0, Command.Code, 'Command.Code');

    Command := Commands[10];
    CheckEquals('E0 1E 00 00 00', Command.TxData, 'Command.TxData');
    AnswerData := 'E0 30';
    CheckEquals(AnswerData, Command.AnswerData, 'Command.AnswerData');
    CheckEquals($E0, Command.Code, 'Command.Code');
  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestParseProtocol2_2;
var
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
  AnswerData: string;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Protocol2_2.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(1, Commands.Count, 'Commands.Count <> 1');

    Command := Commands[0];
    CheckEquals('', Command.TxData, 'Command.TxData');
    CheckEquals('', Command.AnswerData, 'Command.AnswerData');
    CheckEquals(0, Command.Code, 'Command.Code');
    CheckEquals(0, Command.ResCode, 'Command.ResCode');
    CheckEquals(False, Command.HasError, 'Command.HasError');
  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestShtrihProtocol1;
var
  Frame, Data: AnsiString;
begin
  Frame := TShtrihProtocol1.Encode(#$FC);
  Check(TShtrihProtocol1.Decode(Frame, Data));
  CheckEquals('', Frame, 'Frame');
  CheckEquals(#$FC, Data, 'Data');
end;

procedure TLogParserTest.TestShtrihProtocol2;
var
  Data: AnsiString;
  Frame: TShtrihFrame2;
begin
  Frame.Data := #$FC;
  Frame.Number := 23;

  Data := TShtrihProtocol2.Encode(Frame);
  Check(TShtrihProtocol2.Decode(Data, Frame));
  CheckEquals(#$FC, Frame.Data, 'Frame.Data');
  CheckEquals(23, Frame.Number, 'Frame.Number');

  Data := HexToStr('8F 00 00 0F 1D');
  Check(TShtrihProtocol2.Decode(Data, Frame));
  CheckEquals('', Frame.Data, 'Frame.Data');
  CheckEquals($1D0F, Frame.Number, 'Frame.Number');
end;

procedure TLogParserTest.TestShtrihProtocol3;
var
  Data: AnsiString;
  Frame: TShtrihFrame3;
begin
  Frame.Data := #$FC;
  Frame.Number := 23;

  Data := TShtrihProtocol3.Encode(Frame);
  CheckEquals('82 00 17 01 00 FC 1A 0A', StrToHex(Data), 'TShtrihProtocol3.Encode');

  Check(TShtrihProtocol3.Decode(Data, Frame));
  CheckEquals(#$FC, Frame.Data, 'Frame.Data');
  CheckEquals(23, Frame.Number, 'Frame.Number');

  Data := HexToStr('82 00 05 05 00 11 1E 00 00 00 BC 1A');
  Check(TShtrihProtocol3.Decode(Data, Frame));
  CheckEquals('11 1E 00 00 00', StrToHex(Frame.Data), 'Frame.Data');
  CheckEquals(5, Frame.Number, 'Frame.Number');
end;

procedure TLogParserTest.TestCommand2F;
var
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\Command2F.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(1, Commands.Count, 'Commands.Count <> 1');

    Command := Commands[0];
    CheckEquals('2F 1E 00 00 00 02 01 D1 EA E8 E4 EA E0 20 33 35 2E 37 31 25 2E 2E 2E 2E 2E 2E 2E 2E 2E 2E 2E 2E 34 32 31 38 2E 37 38 00 00 00 00 00 00 00 00', Command.TxData, 'Command.TxData');
    CheckEquals('2F 00 1E', Command.AnswerData, 'Command.AnswerData');
    CheckEquals($2F, Command.Code, 'Command.Code');
    CheckEquals(0, Command.ResCode, 'Command.ResCode');
    CheckEquals(False, Command.HasError, 'Command.HasError');

  finally
    Lines.Free;
    Commands.Free;
  end;
end;

procedure TLogParserTest.TestUnknownCommandLog;
var
  Index: Integer;
  Lines: TStrings;
  Command: TCommand;
  Commands: TCommandList;
begin
  Lines := TStringList.Create;
  Commands := TCommandList.Create(True);
  try
    Lines.LoadFromFile('Data\UnknownCommand.log');
    Check(Lines.Count > 0, 'Lines.Count <= 0');
    ParseLog2(Lines, Commands);
    CheckEquals(2, Commands.Count, 'Commands.Count <> 2');

    Command := Commands[1];
    CheckEquals('2F 1E 00 00 00 02 01 D1 EA E8 E4 EA E0 20 33 35 2E 37 31 25 2E 2E 2E 2E 2E 2E 2E 2E 2E 2E 2E 2E 34 32 31 38 2E 37 38 00 00 00 00 00 00 00 00', Command.TxData, 'Command.TxData');
    CheckEquals('2F 00 1E', Command.AnswerData, 'Command.AnswerData');
    CheckEquals($2F, Command.Code, 'Command.Code');
    CheckEquals(0, Command.ResCode, 'Command.ResCode');
    CheckEquals(False, Command.HasError, 'Command.HasError');
  finally
    Lines.Free;
    Commands.Free;
  end;
end;


initialization
  RegisterTest('', TLogParserTest.Suite);
end.
