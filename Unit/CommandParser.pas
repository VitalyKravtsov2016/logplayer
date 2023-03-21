unit CommandParser;

interface

uses
  System.SysUtils, untCommand, System.Generics.Collections, Utils.BinStream,
  BinUtils, Classes, TLVParser;

type
  TFieldType = (ftByte, ftUInt32, ftQuantity6, fTQuantity5, ftDate, ftTime,
  ftSum, ftString, ftCheckType, ftPaymentTypeSign, ftPaymentItemSign,
  ftTaxValue, ftSumm1Value, ftTax, ftTLV, ftTaxType, ftTax1);

  TParserCommand = class
  private
    function TaxValueToString(AValue: UInt64): string;
    function Summ1ToString(AValue: UInt64): string;
    function CheckTypeToString(AValue: Byte): string;
    function TaxTypeToString(AValue: Byte): string;
    function Tax1ToString(AValue: Byte): string;
    function PaymentTypeSigntoString(AValue: Byte): string;
    function PaymentItemSignToString(AValue: Byte): string;
  protected
    FFields: TList<TPair<string, TFieldType>>;
    FAnswerFields: TList<TPair<string, TFieldType>>;
    FStream: IBinStream;
    procedure Start(const ACmd: TCommand);
    procedure StartAnswer(const ACmd: TCommand);
    procedure AddField(const AName: string; AFieldType: TFieldType);
    procedure AddAnswerField(const AName: string; AFieldType: TFieldType);
  public
    procedure CreateFields; virtual;
    procedure CreateAnswerFields; virtual;
    function Parse(const ACmd: TCommand; Answer: Boolean = False): string; virtual;
    constructor Create;
    destructor Destroy; override;
  end;

  TParserCommandClass = class of TParserCommand;

  // FNOperation
  TParserCommandFF45 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

  // FNCloseCheckEx
  TParserCommandFF46 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

  // FNSendTLV
  TParserCommandFF0C = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

  // PrintString
  TParserCommand17 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

  // PrintStringWithFont
  TParserCommand2F = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;


  TParserCommands = class
  private
    FCommands: TList<TPair<UInt16, TParserCommandClass>>;
    procedure AddCommand(ACode: Uint16; AParserCommandClass: TParserCommandClass);
  public
    constructor Create;
    destructor Destroy; override;
    function GetParserCommandClass(ACode: UInt16): TParserCommandClass;
  end;

procedure ParseCommand(const ACmd: TCommand; var Fields: string; var AnswerFields: string);

implementation

procedure ParseCommand(const ACmd: TCommand; var Fields: string; var AnswerFields: string);
var
  Commands: TParserCommands;
  Command: TParserCommand;
begin
  Commands := TParserCommands.Create;
  try
    Command := Commands.GetParserCommandClass(ACmd.Code).Create;
    Fields := Command.Parse(ACmd);
    AnswerFields := Command.Parse(ACmd, True);
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

function TParserCommand.CheckTypeToString(AValue: Byte): string;
begin
  Result := AValue.ToString + ' [';
  case AValue of
    0:
      Result := Result + 'Приход';
    1:
      Result := Result + 'Возврат прихода';
    2:
      Result := Result + 'Расход';
    3:
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

function TParserCommand.Parse(const ACmd: TCommand; Answer: Boolean): string;
var
  Field: TPair<string, TFieldType>;
  b: Byte;
  S: TStringList;
  Value: string;
  l: Integer;
  TlvParser: TTLVParser;
begin
  if Answer then
    StartAnswer(ACmd)
  else
    Start(ACmd);
  if FStream.Size = 0 then
  begin
    Result := '';
    Exit;
  end;
  FStream.Stream.Position := 0;
  b := FStream.ReadByte;
  if b = $FF then
    FStream.ReadByte;
  S := TStringList.Create;
  try
    for Field in FFields do
    begin
      l := 10 - Length(Field.Key);
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
            //Value := Value +
          end;
        ftTime:
          begin
            //Value := Value +
          end;
        ftSum:
          begin
            Value := Value + Format('%.2f', [FStream.ReadInt(5) / 100]);
          end;
        ftString:
          begin
            Value := Value + FStream.ReadString;
          end;
        ftCheckType:
          begin
            Value := Value + CheckTypeToString(FStream.ReadByte);
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
  FStream := TBinStream.Create(StringToBytes(ACmd.AnswerData));
end;

function TParserCommand.Tax1ToString(AValue: Byte): string;
begin
 Result := AValue.ToString + ' [';
  case AValue of
    1:
      Result := Result + 'НДС 20%';
    2:
      Result := Result + 'НДС 10%';
    3:
      Result := Result + 'НДС 0%';
    4:
      Result := Result + 'БЕЗ НДС';
    5:
      Result := Result + 'НДС 20/120';
    6:
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
  AddCommand($17, TParserCommand17);
  AddCommand($2F, TParserCommand2F);
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

{ TParserCommandFF46 }

procedure TParserCommandFF46.CreateAnswerFields;
begin

end;

procedure TParserCommandFF46.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('CheckType', ftCheckType);
  AddField('Quantity', ftQuantity6);
  AddField('Price', ftSum);
  AddField('Summ1', ftSumm1Value);
  AddField('TaxValue', ftTaxValue);
  AddField('Tax1', ftTax1);
  AddField('Department', ftByte);
  AddField('PaymentTypeSign', ftPaymentTypeSign);
  AddField('PaymentItemSign', ftPaymentItemSign);
  AddField('StringForPrinting', ftString);
end;

{ TParserCommandFF45 }

procedure TParserCommandFF45.CreateAnswerFields;
begin

end;

procedure TParserCommandFF45.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Summ1', ftSum);
  AddField('Summ2', ftSum);
  AddField('Summ3', ftSum);
  AddField('Summ4', ftSum);
  AddField('Summ5', ftSum);
  AddField('Summ6', ftSum);
  AddField('Summ7', ftSum);
  AddField('Summ8', ftSum);
  AddField('Summ9', ftSum);
  AddField('Summ10', ftSum);
  AddField('Summ11', ftSum);
  AddField('Summ12', ftSum);
  AddField('Summ13', ftSum);
  AddField('Summ14', ftSum);
  AddField('Summ15', ftSum);
  AddField('Summ16', ftSum);
  AddField('RoundingSumm', ftByte);
  AddField('TaxValue1', ftTaxValue);
  AddField('TaxValue2', ftTaxValue);
  AddField('TaxValue3', ftTaxValue);
  AddField('TaxValue4', ftTaxValue);
  AddField('TaxValue5', ftTaxValue);
  AddField('TaxValue6', ftTaxValue);
  AddField('TaxType', ftTaxType);
  AddField('StringForPrinting', ftString);
end;

{ TParserCommandFF0C }

procedure TParserCommandFF0C.CreateAnswerFields;
begin


end;

procedure TParserCommandFF0C.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TLVData', ftTLV);
end;

{ TParserCommand17 }

procedure TParserCommand17.CreateAnswerFields;
begin

end;

procedure TParserCommand17.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Tape type', ftByte);
  AddField('StringForPrinting', ftString);
end;

{ TParserCommand2F }

procedure TParserCommand2F.CreateAnswerFields;
begin

end;

procedure TParserCommand2F.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Tape type', ftByte);
  AddField('FontType', ftByte);
  AddField('StringForPrinting', ftString);
end;

end.

