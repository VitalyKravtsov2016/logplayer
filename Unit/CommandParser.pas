unit CommandParser;

interface

uses
  System.SysUtils, untCommand, System.Generics.Collections, Utils.BinStream,
  BinUtils, Classes, TLVParser;

type
  TFieldType = (ftByte, ftUInt32, ftUint16, ftINN, ftQuantity6, ftQuantity5, ftDateTime, ftDate, ftTime, ftSum, ftString, ftString40, ftTableValue, ftFieldType, ftCheckType, ftPaymentTypeSign, ftPaymentItemSign, ftTaxValue, ftSumm1Value, ftTax, ftTLV, ftTaxType, ftTax1, ftSoftVersion, ftECRMode, ftECRAdvancedMode, ftECRFlags, ftBatteryVoltage, ftPowerSourceVoltage, ftPortNumber, ftCheckType2);

  TParseType = (pFields, pAnswerFields, pPlayedFields);

  TParserCommand = class
  private
    function TaxValueToString(AValue: UInt64): string;
    function Summ1ToString(AValue: UInt64): string;
    function CheckTypeToString(AValue: Byte): string;
    function CheckType2ToString(AValue: Byte): string;
    function TaxTypeToString(AValue: Byte): string;
    function Tax1ToString(AValue: Byte): string;
    function PaymentTypeSigntoString(AValue: Byte): string;
    function PaymentItemSignToString(AValue: Byte): string;
    function ECRFlagsToString(AValue: UInt16): string;
    function FieldTypeToString(AValue: Byte): string;
  protected
    FFields: TList<TPair<string, TFieldType>>;
    FAnswerFields: TList<TPair<string, TFieldType>>;
    FStream: IBinStream;
    procedure Start(const ACmd: TCommand);
    procedure StartAnswer(const ACmd: TCommand);
    procedure StartPlayedAnswer(const ACmd: TCommand);
    procedure AddField(const AName: string; AFieldType: TFieldType);
    procedure AddAnswerField(const AName: string; AFieldType: TFieldType);
    function PortNumToString(APortNumber: Integer): string;
  public
    procedure CreateFields; virtual;
    procedure CreateAnswerFields; virtual;
    function Parse(const ACmd: TCommand; Source: TParseType): string; virtual;
    constructor Create;
    destructor Destroy; override;
  end;

  TParserCommandClass = class of TParserCommand;

  TParserCommands = class
  private
    FCommands: TList<TPair<UInt16, TParserCommandClass>>;
    procedure AddCommand(ACode: Uint16; AParserCommandClass: TParserCommandClass);
  public
    constructor Create;
    destructor Destroy; override;
    function GetParserCommandClass(ACode: UInt16): TParserCommandClass;
  end;

procedure ParseCommand(const ACmd: TCommand; var Fields: string; var AnswerFields: string; var PlayedFields: string);

implementation

uses
  PrinterTypes, ParserCommandFF45, ParserCommandFF46, ParserCommandFF0C,
  ParserCommand17, ParserCommand2F, ParserCommand11, ParserCommand10,
  ParserCommandFC, ParserCommand8D, ParserCommand1E, ParserCommand1F,
  ParserCommand2D, ParserCommand2E;

procedure ParseCommand(const ACmd: TCommand; var Fields: string; var AnswerFields: string; var PlayedFields: string);
var
  Commands: TParserCommands;
  Command: TParserCommand;
begin
  Commands := TParserCommands.Create;
  try
    Command := Commands.GetParserCommandClass(ACmd.Code).Create;
    Fields := Command.Parse(ACmd, pFields);
    AnswerFields := Command.Parse(ACmd, pAnswerFields);
    PlayedFields := Command.Parse(ACmd, pPlayedFields);
  finally
    Command.Free;
    Commands.Free;
  end;
end;

{ TParserCommand }

procedure TParserCommand.AddAnswerField(const AName: string; AFieldType: TFieldType);
begin
  FAnswerFields.Add(TPair<string, TFieldType>.Create(AName, AFieldType));
end;

procedure TParserCommand.AddField(const AName: string; AFieldType: TFieldType);
begin
  FFields.Add(TPair<string, TFieldType>.Create(AName, AFieldType));
end;

function TParserCommand.PortNumToString(APortNumber: Integer): string;
begin
  Result := APortNumber.ToString + ' [';
  case APortNumber of
    0:
      Result := Result + 'RS-232';
    1:
      Result := Result + 'USB vCOM';
    2:
      Result := Result + 'TCP сокет (RNDIS, Ethernet, WI-FI, ppp)';
    3:
      Result := Result + 'I2C (Основная плата)';
  else
    Result := Result + 'неизвестный тип';
  end;
  Result := Result + ']';
end;

function TParserCommand.CheckTypeToString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    0:
      Result := Result + 'Приход';
    2:
      Result := Result + 'Возврат прихода';
    1:
      Result := Result + 'Расход';
    3:
      Result := Result + 'Возврат расхода';
  end;
  Result := Result + ']';
end;

function TParserCommand.CheckType2ToString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    1:
      Result := Result + 'Приход';
    2:
      Result := Result + 'Возврат прихода';
    3:
      Result := Result + 'Расход';
    4:
      Result := Result + 'Возврат расхода';
  end;
  Result := Result + ']';
end;

constructor TParserCommand.Create;
begin
  inherited;
  FFields := TList<TPair<string, TFieldType>>.Create;
  FAnswerFields := TList<TPair<string, TFieldType>>.Create;
  CreateFields;
  CreateAnswerFields;
end;

procedure TParserCommand.CreateAnswerFields;
begin

end;

procedure TParserCommand.CreateFields;
begin

end;

destructor TParserCommand.Destroy;
begin
  FFields.Free;
  FAnswerFields.Free;
  inherited;
end;

function TestBitValue(AValue: Integer; BitNumber: Integer; const TrueValue: string; const FalseValue: string): string;
begin
  if TestBit(AValue, BitNumber) then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function TParserCommand.ECRFlagsToString(AValue: UInt16): string;
begin
  Result := Format('0x%.4x', [AValue]) + #13#10;
  Result := Result + '    Рулон контр. ленты        : ' + TestBitValue(AValue, 0, 'есть', 'нет') + #13#10;
  Result := Result + '    Рулон чековой ленты       : ' + TestBitValue(AValue, 1, 'есть', 'нет') + #13#10;
  Result := Result + '    Опт. датчик контр. ленты  : ' + TestBitValue(AValue, 6, 'бумага есть', 'бумаги нет') + #13#10;
  Result := Result + '    Опт датчик чеков. ленты   : ' + TestBitValue(AValue, 7, 'бумага есть', 'бумаги нет') + #13#10;
  Result := Result + '    Рычаг термог. контр. ленты: ' + TestBitValue(AValue, 8, 'опущен', 'поднят') + #13#10;
  Result := Result + '    Рычаг термог. чеков. ленты: ' + TestBitValue(AValue, 9, 'опущен', 'поднят') + #13#10;
  Result := Result + '    Крышка корпуса ККТ        : ' + TestBitValue(AValue, 10, 'поднята', 'опущена') + #13#10;
  Result := Result + '    Денежный ящик             : ' + TestBitValue(AValue, 11, 'открыт', 'закрыт') + #13#10;
  Result := Result + '    Крышка контр. ленты       : ' + TestBitValue(AValue, 12, 'поднята', 'опущена');
end;

function TParserCommand.FieldTypeToString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    0:
      Result := Result + 'Int';
    1:
      Result := Result + 'Str';
  else
    Result := Result + 'Unknown';
  end;
  Result := Result + ']';
end;

function TParserCommand.Parse(const ACmd: TCommand; Source: TParseType): string;
var
  Field: TPair<string, TFieldType>;
  b: Byte;
  S: TStringList;
  Value: string;
  l: Integer;
  TlvParser: TTLVParser;
  Res: Byte;
  IntValue: Integer;
  FieldList: TList<TPair<string, TFieldType>>;
  Buf: AnsiString;
  Buf1: AnsiString;
begin
  case Source of
    pFields:
      Start(ACmd);
    pAnswerFields:
      StartAnswer(ACmd);
    pPlayedFields:
      StartPlayedAnswer(ACmd);
  end;

  if FStream.Size = 0 then
  begin
    Result := '';
    Exit;
  end;
  FStream.Stream.Position := 0;
  b := FStream.ReadByte;
  if b = $FF then
    FStream.ReadByte;
  if Source in [pAnswerFields, pPlayedFields] then
  begin
    Res := FStream.ReadByte;
    if Res <> 0 then
    begin
      Result := 'Error: ' + Res.ToString + '(0x' + IntToHex(Res, 2) + ') ' + TPrinterError.GetDescription(Res, True);
      Exit;
    end;
  end;
  S := TStringList.Create;
  try
    if Source in [pAnswerFields, pPlayedFields] then
      FieldList := FAnswerFields
    else
      FieldList := FFields;

    for Field in FieldList do
    begin
      l := 15 - Length(Field.Key);
      if l < 0 then
        l := 0;

      Value := ' ' + Field.Key + StringOfChar(' ', l) + ': ';

      case Field.Value of
        ftByte:
          begin
            Value := Value + FStream.ReadByte.ToString;
          end;
        ftUInt32:
          begin
            Value := Value + FStream.ReadUInt32.ToString;
          end;
        ftUInt16:
          begin
            Value := Value + FStream.ReadUInt16.ToString;
          end;
        ftSoftVersion:
          begin
            Value := Value + FStream.ReadString(1) + '.' + FStream.ReadString(1);
          end;
        ftQuantity6:
          begin
            Value := Value + Format('%.6f', [FStream.ReadInt(6) / 1000000]);
          end;
        fTQuantity5:
          begin
            Value := Value + Format('%.3f', [FStream.ReadInt(5) / 1000]);
          end;
        ftDate:
          begin
            Value := Value + DateToStr(Str2Date(IntToBin(FStream.ReadInt(3), 3), 1));
          end;
        ftTime:
          begin
            Value := Value + TimeToStr(Str2Time(IntToBin(FStream.ReadInt(3), 3), 1));
          end;
        ftDateTime:
          begin
            Value := Value + DateTimeToStr(Str2Date(IntToBin(FStream.ReadInt(5), 5), 1));
          end;
        ftSum:
          begin
            Value := Value + Format('%.2f', [FStream.ReadInt(5) / 100]);
          end;
        ftString:
          begin
            Value := Value + FStream.ReadString;
          end;
        ftString40:
          begin
            Value := Value + TrimRight(FStream.ReadString(40));
          end;
        ftFieldType:
          begin
            Value := Value + FieldTypeToString(FStream.ReadByte);
          end;
        ftTableValue:
          begin
            Buf := FStream.ReadString;
            Buf1 := Copy(Buf, 1, 8);
            Value := Value + StrToHex(Buf) + #13#10 + '    Str: ' + TrimRight(Buf) + #13#10 + '    Int: ' + BinToInt(Buf1, 1, Length(Buf1)).ToString;
          end;
        ftCheckType:
          begin
            Value := Value + CheckTypeToString(FStream.ReadByte);
          end;
        ftCheckType2:
          begin
            Value := Value + CheckType2ToString(FStream.ReadByte);
          end;
        ftPaymentTypeSign:
          begin
            Value := Value + PaymentTypeSigntoString(FStream.ReadByte);
          end;
        ftPaymentItemSign:
          begin
            Value := Value + PaymentItemSignToString(FStream.ReadByte);
          end;
        ftTaxValue:
          begin
            Value := Value + TaxValueToString(FStream.ReadInt(5));
          end;
        ftSumm1Value:
          begin
            Value := Value + Summ1ToString(FStream.ReadInt(5));
          end;
        ftTax:
          begin
            Value := Value + FStream.ReadByte.ToString;
          end;
        ftTLV:
          begin
            TlvParser := TTLVParser.Create;
            try
              TlvParser.ShowTagNumbers := True;
              TlvParser.BaseIndent := 4;
              Value := Value + #13#10 + TlvParser.ParseTLV(FStream.ReadString);
            finally
              TlvParser.Free;
            end;
          end;
        ftTaxType:
          begin
            Value := Value + TaxTypeToString(FStream.ReadByte);
          end;
        ftTax1:
          begin
            Value := Value + Tax1ToString(FStream.ReadByte);
          end;
        ftINN:
          begin
            Value := Value + Int64ToStr(FStream.ReadInt(6));
          end;
        ftECRMode:
          begin
            IntValue := FStream.ReadByte;
            Value := Value + Format('%d [%s]', [IntValue, GetECRModeDescription(IntValue)]);
          end;
        ftECRAdvancedMode:
          begin
            IntValue := FStream.ReadByte;
            Value := Value + Format('%d [%s]', [IntValue, GetAdvancedModeDescription(IntValue)]);
          end;
        ftECRFlags:
          begin
            Value := Value + ECRFlagsToString(FStream.ReadUInt16);
          end;
        ftBatteryVoltage:
          begin
            Value := Value + Format('%.2f В.', [Round2(FStream.ReadByte / 255 * 100 * 5) / 100]);
          end;
        ftPowerSourceVoltage:
          begin
            Value := Value + Format('%.2f В.', [Round2(FStream.ReadByte * 24 / $D8 * 100) / 100]);
          end;
        ftPortNumber:
          begin
            Value := Value + PortNumToString(FStream.ReadByte);
          end;
      end;
      S.Add(Value);
    end;
  finally
    Result := S.Text;
    S.Free;
  end;
end;

function TParserCommand.PaymentItemSignToString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    1:
      Result := Result + 'Товар'; // TObject(1));
    2:
      Result := Result + 'Подакцизный товар'; // TObject(2));
    3:
      Result := Result + 'Работа'; // TObject(3));
    4:
      Result := Result + 'Услуга'; // TObject(4));
    5:
      Result := Result + 'Ставка азартной игры'; // TObject(5));
    6:
      Result := Result + 'Выигрыш азартной игры'; // TObject(6));
    7:
      Result := Result + 'Лотерейный билет'; // TObject(7));
    8:
      Result := Result + 'Выигрыш лотереи'; // TObject(8));
    9:
      Result := Result + 'Предоставление РИД'; // TObject(9));
    10:
      Result := Result + 'Платеж'; // TObject(10));
    11:
      Result := Result + 'Агентское вознаграждение'; // TObject(11));
    12:
      Result := Result + 'Выплата'; // TObject(12));
    13:
      Result := Result + 'Иной предмет расчета'; // TObject(13));
    14:
      Result := Result + 'Имущественное право'; // TObject(14));
    15:
      Result := Result + 'Внереализационный доход'; // TObject(15));
    16:
      Result := Result + 'Страховые взносы'; // TObject(16));
    17:
      Result := Result + 'Торговый сбор'; // TObject(17));
    18:
      Result := Result + 'Курортный сбор'; // TObject(18));
    19:
      Result := Result + 'Залог'; // TObject(19));
    20:
      Result := Result + 'Расход'; // TObject(20));
    21:
      Result := Result + 'Взносы на ОПС ИП'; // TObject(21));
    22:
      Result := Result + 'Взносы на ОПС'; // TObject(22));
    23:
      Result := Result + 'Взносы на ОМС ИП'; // TObject(23));
    24:
      Result := Result + 'Взносы на ОМС'; // TObject(24));
    25:
      Result := Result + 'Взносы на ОСС'; // TObject(25));
    26:
      Result := Result + 'Платеж казино'; // TObject(26));
    27:
      Result := Result + 'Выдача ДС'; // TObject(27));
    30:
      Result := Result + 'АТНМ'; // TObject(30));
    31:
      Result := Result + 'АТМ'; // TObject(31));
    32:
      Result := Result + 'ТНМ'; // TObject(32));
    33:
      Result := Result + 'ТМ'; // TObject(33));
  end;
  Result := Result + ']';
end;

function TParserCommand.PaymentTypeSigntoString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    1:
      Result := Result + 'Предоплата 100%';
    2:
      Result := Result + 'Частичная предоплата';
    3:
      Result := Result + 'Аванс';
    4:
      Result := Result + 'Полный расчет';
    5:
      Result := Result + 'Частичный расчет и кредит';
    6:
      Result := Result + 'Передача в кредит';
    7:
      Result := Result + 'Оплата кредита';
  end;
  Result := Result + ']';
end;

procedure TParserCommand.Start(const ACmd: TCommand);
begin
  FStream := TBinStream.Create(StringToBytes(HexToStr(ACmd.Data)));
end;

procedure TParserCommand.StartAnswer(const ACmd: TCommand);
begin
  FStream := TBinStream.Create(StringToBytes(HexToStr(ACmd.AnswerData)));
end;

procedure TParserCommand.StartPlayedAnswer(const ACmd: TCommand);
begin
  FStream := TBinStream.Create(StringToBytes(HexToStr(ACmd.PlayedAnswerData)));
end;

function TParserCommand.Tax1ToString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    1:
      Result := Result + 'НДС 20%';
    2:
      Result := Result + 'НДС 10%';
    4:
      Result := Result + 'НДС 0%';
    8:
      Result := Result + 'БЕЗ НДС';
    16:
      Result := Result + 'НДС 20/120';
    32:
      Result := Result + 'НДС 10/110';
  end;
  Result := Result + ']';
end;

function TParserCommand.TaxTypeToString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    1:
      Result := Result + 'ОСН';
    2:
      Result := Result + 'УСНД';
    4:
      Result := Result + 'УСНДМР';
    8:
      Result := Result + 'ЕНВД';
    16:
      Result := Result + 'ЕСХН';
    32:
      Result := Result + 'ПСН';
  end;
  Result := Result + ']';
end;

function TParserCommand.TaxValueToString(AValue: UInt64): string;
begin
  if AValue = $FFFFFFFFFF then
    Result := '[нет]'
  else
    Result := Format('%.2f', [AValue / 100]);
end;

function TParserCommand.Summ1ToString(AValue: UInt64): string;
begin
  if AValue = $FFFFFFFFFF then
    Result := '[нет]'
  else
    Result := Format('%.2f', [AValue / 100]);
end;

{ TCommandParser }

procedure TParserCommands.AddCommand(ACode: Uint16; AParserCommandClass: TParserCommandClass);
begin
  FCommands.Add(TPair<UInt16, TParserCommandClass>.Create(ACode, AParserCommandClass));
end;

constructor TParserCommands.Create;
begin
  FCommands := TList<TPair<UInt16, TParserCommandClass>>.Create;
  AddCommand($FF45, TParserCommandFF45);
  AddCommand($FF46, TParserCommandFF46);
  AddCommand($FF0C, TParserCommandFF0C);
  AddCommand($FF4D, TParserCommandFF0C);
  AddCommand($10, TParserCommand10);
  AddCommand($11, TParserCommand11);
  AddCommand($17, TParserCommand17);
  AddCommand($1E, TParserCommand1E);
  AddCommand($1F, TParserCommand1F);
  AddCommand($2F, TParserCommand2F);
  AddCommand($2D, TParserCommand2D);
  AddCommand($2E, TParserCommand2E);
  AddCommand($8D, TParserCommand8D);
  AddCommand($FC, TParserCommandFC);
end;

destructor TParserCommands.Destroy;
begin
  FCommands.Free;
  inherited;
end;

function TParserCommands.GetParserCommandClass(ACode: UInt16): TParserCommandClass;
var
  Cmd: TPair<UInt16, TParserCommandClass>;
begin
  for Cmd in FCommands do
    if Cmd.Key = ACode then
    begin
      Result := Cmd.Value;
      Exit;
    end;
  Result := TParserCommand;
end;

end.

