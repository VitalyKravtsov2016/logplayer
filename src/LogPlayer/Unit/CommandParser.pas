unit CommandParser;

interface

uses
  // VCL
  Classes, SysUtils, System.Generics.Collections,
  // This
  untCommand, Utils.BinStream, BinUtils, TLVParser;

type
  TFieldType = (
    ftByte, ftUInt32, ftUint16, ftINN, ftBarcode, ftBarcodeTLV, ftKMAnswer,
    ftQuantity6, ftQuantity5, ftDateTime, ftDate, ftTime, ftSum, ftString,
    ftString40, ftTableValue, ftFieldType, ftCheckType, ftPaymentTypeSign,
    ftPaymentItemSign, ftTaxValue, ftSumm1Value, ftTax, ftTLV, ftTaxType,
    ftTax1, ftSoftVersion, ftECRMode, ftECRAdvancedMode, ftECRFlags,
    ftBatteryVoltage, ftPowerSourceVoltage, ftPortNumber, ftCheckType2,
    ftCheckItemLocalResult, ftCheckItemLocalError, ftMarkingType2, ftItemStatus,
    ftBarcodeOSU, ftMarkingType, ftMarkingTypeEx, ftAcceptOrDecline,
    ftKMSendAnswer, ftString16, ftDateTimeDoc, ftFNSessionState,
    ftFNCurrentDocument, ftFNDocumentData, ftFNLifeState
  );

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
    function ItemStatusToString(AValue: Byte): string;
  protected
    FFields: TList<TPair<string, TFieldType>>;
    FFieldsValues: TList<TPair<string, string>>;
    FAnswerFieldsValues: TList<TPair<string, string>>;
    FAnswerFields: TList<TPair<string, TFieldType>>;
    FStream: IBinStream;
    function GetFieldValue(const AName: string): string;
    function GetAnswerFieldValue(const AName: string): string;
    procedure Start(const ACmd: TCommand);
    procedure StartAnswer(const ACmd: TCommand);
    procedure StartPlayedAnswer(const ACmd: TCommand);
    procedure AddField(const AName: string; AFieldType: TFieldType);
    procedure AddAnswerField(const AName: string; AFieldType: TFieldType);
    procedure AddValue(const AName: string; const AValue: string; Source: TParseType);
    function PortNumToString(APortNumber: Integer): string;
    function DecodeKMAnswer(Source: TParseType): string;
    function DecodeKMSendAnswer(Source: TParseType): string;
    function DecodeTLVBarcode(Source: TParseType): string;
    function DecodeBarcodeOSU(Source: TParseType): string;
  public
    procedure CreateFields; virtual;
    procedure CreateAnswerFields; virtual;
    function GetShortValue: string; virtual;
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

function GetCommandShortValue(ACmd: TCommand): string;

implementation

uses
  PrinterTypes, ParserCommandFF45, ParserCommandFF46, ParserCommandFF0C,
  ParserCommand17, ParserCommand2F, ParserCommand11, ParserCommand10,
  ParserCommandFC, ParserCommand8D, ParserCommand1E, ParserCommand1F,
  ParserCommand2D, ParserCommand2E, ParserCommand6B, ParserCommand80,
  ParserCommand81, ParserCommand82, ParserCommand83, ParserCommand85,
  ParserCommand89, ParserCommand8E, ParserCommandFF01, ParserCommandFF61,
  ParserCommandFF67, ParserCommandFF69, ParserCommandFF70,
  ParserCommandFF71, ParserCommandFF72, ParserCommandFF73,
  ParserCommandFF74, ParserCommandFF75, ParserCommandFF76,
  ParserCommandFF78;

const
  VALUE_NOT_VISIBLE = '###logplayer_not_visible_value###';

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

function GetCommandShortValue(ACmd: TCommand): string;
var
  Commands: TParserCommands;
  Command: TParserCommand;
  ErrorCode: Integer;
begin
  Commands := TParserCommands.Create;
  try
    Command := Commands.GetParserCommandClass(ACmd.Code).Create;
    Command.Parse(ACmd, pFields);
    Command.Parse(ACmd, pAnswerFields);
    Result := Command.GetShortValue;
    ErrorCode := ACmd.ErrorCode;
    if ErrorCode <> 0 then
      Result := Result + ' [ERROR] ' + ErrorCode.ToString + ' (0x' + IntToHex(ErrorCode, 2) + ') ' + TPrinterError.GetDescription(ErrorCode, True)
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
  FFieldsValues := TList<TPair<string, string>>.Create;
  FAnswerFieldsValues := TList<TPair<string, string>>.Create;
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

function CheckItemLocalResultToStr(AValue: Integer): string;
begin
  if TestBit(AValue, 0) then
    Result := Result + '  "код маркировки проверен фискальным накопителем с использованием ключа проверки КП"'
  else
    Result := Result + '  "код маркировки не может быть проверен фискальным накопителем с использованием ключа проверки КП"';

  if TestBit(AValue, 1) then
    Result := Result + #13#10 + '  "результат проверки КП КМ фискальным накопителем с использованием ключа проверки КП положительный"'
  else
  begin
    if TestBit(AValue, 0) then
      Result := Result + #13#10 + '  "результат проверки КП КМ фискальным накопителем с использованием ключа проверки КП отрицательный"';
    {else
      Result := Result + '  "код маркировки не может быть проверен фискальным накопителем с использованием ключа проверки КП"'}
  end;
end;

function CheckItemLocalErrorToStr(AValue: Integer): string;
begin
  case AValue of
    0:
      Result := 'КМ проверен в ФН';
    1:
      Result := 'КМ данного типа не подлежит проверке в ФН';
    2:
      Result := 'ФН не содержит ключ проверки кода проверки этого КМ';
    3:
      Result := 'Проверка невозможна, так как отсутствуют теги 91 и / или 92 или их формат неверный';
    4:
      Result := 'Внутренняя ошибка в ФН при проверке этого КМ';
  else
    Result := 'неизвестное значение'
  end;
end;

function MarkingTypeToStr2(AValue: Integer): string;
begin
  case AValue of
    0:
      Result := 'Тип КМ не идентифицирован';
    1:
      Result := 'Короткий КМ';
    2:
      Result := 'КМ со значением кода проверки длиной 88 символов, подлежащим проверке в ФН';
    3:
      Result := 'КМ со значением кода проверки длиной 44 символа, не подлежащим проверке в ФН';
    4:
      Result := 'КМ со значением кода проверки длиной 44 символа, подлежащим проверке в ФН';
    5:
      Result := 'КМ со значением кода проверки длиной 4 символа, не подлежащим проверке в ФН';
  else
    Result := 'неизвестное значение'
  end;
end;

const
  MT_Unrecognized = 0;
  MT_EAN8 = 17672;
  MT_EAN13 = $450D; //17677;
  MT_ITF14 = 18702;
  MT_DataMatrix = 17485;
  MT_Fur = 21062;
  MT_EGAISPDF = 50452;
  MT_EGAISDM = 50462;
  MT_OSU_EAN8 = $4F08;
  MT_OSU_EAN13 = $4F0D;
  MT_OSU_GTIN_ITF14 = $4F0E;
  SUnrecognized = 'Нераспознанный код';
  SEAN8 = 'Код EAN-8, UPC-E';
  SEAN13 = 'Код EAN-13, UPC-A';
  SITF14 = 'Код ITF-14';
  SDataMatrix = 'Код GS1 Data Matrix';
  SFur = 'Код мехового изделия';
  SEGAISPDF = 'Код EGAIS 2.0 PDF14';
  SEGAISDM = 'Код EGAIS 3.0 Data Matrix';
  SOSU_EAN8 = 'ОСУ EAN-8';
  SOSU_EAN13 = 'ОСУ EAN-13';
  SOSU_GTIN_ITF14 = 'ОСУ GTIN ITF14';

function MarkingTypeToStr(AValue: Integer): string;
begin
  Result := 'Неизвестный тип';
  case AValue of
    MT_Unrecognized:
      Result := SUnrecognized;
    MT_EAN8:
      Result := SEAN8;
    MT_EAN13:
      Result := SEAN13;
    MT_ITF14:
      Result := SITF14;
    MT_DataMatrix:
      begin
        Result := SDataMatrix; // + ': ' + MarkingTypeExToStr(AMarkingTypeEx);
      end;
    MT_Fur:
      Result := SFur;
    MT_EGAISPDF:
      Result := SEGAISPDF;
    MT_EGAISDM:
      Result := SEGAISDM;
    MT_OSU_EAN8:
      Result := SOSU_EAN8;
    MT_OSU_EAN13:
      Result := SOSU_EAN13;
    MT_OSU_GTIN_ITF14:
      Result := SOSU_GTIN_ITF14;
  end;
end;

function MarkingTypeExToStr(AValue: Integer): string;
begin
  case AValue of
    0:
      Result := 'КМ-88';
    1:
      Result := 'Симметричный';
    2:
      Result := 'Табачный';
    3:
      Result := 'КМ-44';
    $FF:
      Result := 'GS-1 без маркировки';
  end;
end;

function KMServerErrorCodeToStr(AValue: Integer): string;
begin
  case AValue of
    0:
      Result := 'Ошибок нет';
    $FF:
      Result := 'Сервер не ответил в течение таймаута';
  else
    Result := ''
  end;
end;

function KMServerCheckingStatusToStr(AValue: Integer): string;
begin
  Result := '';
  if TestBit(AValue, 0) then
    Result := Result + '  "код маркировки проверен"'
  else
    Result := Result + '  "код маркировки не был проверен ФН и (или) ОИСМ"';

  Result := Result + #13#10;

  if TestBit(AValue, 1) then
    Result := Result + '  "результат проверки КП КМ положительный"'
  else
    Result := Result + '  "результат проверки КП КМ отрицательный или код маркировки не был проверен"';

  Result := Result + #13#10;

  if TestBit(AValue, 2) then
    Result := Result + '  "проверка статуса ОИСМ выполнена"'
  else
    Result := Result + '  "сведения о статусе товара от ОИСМ не получены"';

  Result := Result + #13#10;

  if TestBit(AValue, 3) then
    Result := Result + '  "от ОИСМ получены сведения, что планируемый статус товара корректен"'
  else
    Result := Result + '  "от ОИСМ получены сведения, что планируемый статус товара некорректен или сведения о статусе товара от ОИСМ не получены"';

  Result := Result + #13#10;

  if TestBit(AValue, 4) then
    Result := Result + '  "результат проверки КП КМ сформирован ККТ, работающей в автономном режиме"'
  else
    Result := Result + '  "результат проверки КП КМ и статуса товара сформирован ККТ, работающей в режиме передачи данных"'
end;

function ReasonErrorToStr(AValue: Integer): string;
begin
  case AValue of
    1:
      Result := 'Неверный фискальный признак';
    2:
      Result := 'Неверный формат ответа';
    3:
      Result := 'Неверный номер запроса в ответе';
    4:
      Result := 'Неверный номер ФН';
    5:
      Result := 'Неверный CRC блока данных';
    7:
      Result := 'Неверная длина ответа';
  else
    Result := 'неизвестное значение'
  end;
end;

function FNSessionStateToStr(AValue: Integer): string;
begin
  case AValue of
    $00:
      Result := 'Смена закрыта';
    $01:
      Result := 'Смена открыта';
  else
    Result := 'Неизвестное значение';
  end;
end;

resourcestring
  SNoOpenDocument = 'Нет открытого документа';
  SRegistrationReport = 'Отчет о регистрации';
  SOpenSessionReport = 'Отчет об открытии смены';
  SCashReceipt = 'Кассовый чек';
  SBSO = 'Бланк строгой отчетности';
  SCloseSessionReport = 'Отчет о закрытии смены';
  SCloseFNReport = 'Отчет о закрытии фискального накопителя';
  SOperatorConfirm = 'Подтверждение оператора';
  SRegistrationChangeReport = 'Отчет об изменении параметров регистрации';
  SRegistrationChangeFNReport = 'Отчет об изменении параметров регистрации в связи с заменой ФН';
  SCalculationStateReport = 'Отчет о текущем состоянии расчетов';
  SCorrectionReceipt = 'Кассовый чек коррекции';
  SBSOCorrectionReceipt = 'Бланк строгой отчетности коррекции';
  SDocTypeUnknown = 'Неизвестный тип документа';

function FNCurrentDocumentToStr(AValue: Integer): string;
begin
  case AValue of
    $00:
      Result := SNoOpenDocument;
    $01:
      Result := SRegistrationReport;
    $02:
      Result := SOpenSessionReport;
    $04:
      Result := SCashReceipt;
    $08:
      Result := SCloseSessionReport;
    $10:
      Result := SCloseFNReport;
    $11:
      Result := SBSO;
    $12:
      Result := SRegistrationChangeFNReport;
    $13:
      Result := SRegistrationChangeReport;
    $14:
      Result := SCorrectionReceipt;
    $15:
      Result := SBSOCorrectionReceipt;
    $17:
      Result := SCalculationStateReport;
  else
    Result := SDocTypeUnknown;
  end;
end;

resourcestring
  SFNNoDocumentData = 'Нет данных документа';
  SFNDocumentDataReceived = 'Получены данные документа';
  SFNUnknownValue = 'Неизвестное значение';

function FNDocumentDataToStr(AValue: Integer): string;
begin
  case AValue of
    $00:
      Result := SFNNoDocumentData;
    $01:
      Result := SFNDocumentDataReceived;
  else
    Result := SFNUnknownValue;
  end;
end;

function BoolToYesNo(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'Да'
  else
    Result := 'Нет';
end;

function GetBitStr(AValue: Integer; Bit: Integer): WideString;
begin
  Result := BoolToYesNo(TestBit(AValue, Bit));
end;

resourcestring
  SFNAdjusted = 'Проведена настройка ФН';
  SFNFiscalModeOpened = 'Открыт фискальный режим';
  SFNFiscalModeClosed = 'Закрыт фискальный режим';
  SFNOFDTransferFinished = 'Закончена передача фискальных данных в ОФД';

function FNLifeStateToStr(AValue: Integer): string;
begin
  Result := Result + #13#10 + '  ' + SFNAdjusted + ' ' + GetBitStr(AValue, 0) + #13#10 + '  ' + SFNFiscalModeOpened + ' ' + GetBitStr(AValue, 1) + #13#10 + '  ' + SFNFiscalModeClosed + ' ' + GetBitStr(AValue, 2) + #13#10 + '  ' + SFNOFDTransferFinished + ' ' + GetBitStr(AValue, 3);
end;

function TParserCommand.DecodeBarcodeOSU(Source: TParseType): string;
var
  BarcodeLength: Byte;
  BarcodeData: AnsiString;
  BarcodeStr: string;
  OSU: Boolean;
  OSUData: Byte;
begin
  BarcodeData := '';
  BarcodeStr := '';
  BarcodeLength := FStream.ReadByte;
  OSU := False;
  if BarcodeLength > 0 then
  begin
    BarcodeData := FStream.ReadString(BarcodeLength);
    BarcodeStr := StringReplace(BarcodeData, #$1D, '<0x1D>', [rfReplaceAll]);
    AddValue('Barcode HEX', StrToHex(BarcodeData), Source);
    AddValue('Barcode', BarcodeStr, Source);
  end;
  if FStream.Remaining > 0 then
  begin
    OSUData := FStream.ReadByte;
    OSU := OSUData = $FF;
  end;
  AddValue('OSU', BoolToStr(OSU, True), Source);
end;

function TParserCommand.DecodeKMAnswer(Source: TParsetype): string;
var
  KMServerErrorCode: Integer;
  KMServerCheckingStatus: Integer;
  TLVData: string;
  TLVDataStr: string;
  AddLength: Byte;
  Parser: TTLVParser;
begin
  KMServerErrorCode := -1;
  KMServerCheckingStatus := -1;
  TLVData := '';
  TLVDataStr := '';
  AddLength := FStream.ReadByte;
  if AddLength > 0 then
  begin
    KMServerErrorCode := FStream.ReadByte;    // Код ответа ФН на команду онлайн-проверки	В соответствии и вводом ошибки ФН.
                                                  // Если 0x20, то в следующем байте возвращается причина в соответствии с таблицей 130 протокола ККТ-ФНМ.
                                                  // 0xFF Если сервер не ответил в течении таймаута.

    if (AddLength > 1) and ((KMServerErrorCode = 0) or (KMServerErrorCode = $20)) then
      KMServerCheckingStatus := FStream.ReadByte; // Результат проверки КМ 	Тег 2106	Только если сервер ответил без ошибок
    if (AddLength > 2) and (KMServerErrorCode = 0) then
    begin
      TLVData := FStream.ReadString;
      Parser := TTLVParser.Create;
      try
        Parser.ShowTagNumbers := True;
        Parser.BaseIndent := 2;
        TLVDataStr := Parser.ParseTLV(TLVData);
      finally
        Parser.Free;
      end;
    end;
  end;
  if KMServerErrorCode >= 0 then
    AddValue('KMServerErrorCode', KMServerErrorCode.ToString + ' [' + KMServerErrorCodeToStr(KMServerErrorCode) + ']', Source);
  if KMServerCheckingStatus >= 0 then
    AddValue('KMServerCheckingStatus (Тег 2106)', KMServerCheckingStatus.ToString + ' [' + KMServerCheckingStatusToStr(KMServerCheckingStatus) + ']', Source);
  if Length(TLVData) > 0 then
  begin
    AddValue('TLVData Hex', StrToHex(TLVData), Source);
    AddValue('TLV Data', #13#10 + TLVDataStr, Source);
  end;
end;

function TParserCommand.DecodeKMSendAnswer(Source: TParseType): string;
var
  CheckItemLocalResult: Byte;
  CheckItemLocalError: Byte;
  MarkingType2: Byte;
begin
  if FStream.Remaining >= 3 then
  begin
    CheckItemLocalResult := FStream.ReadByte;
    CheckItemLocalError := FStream.ReadByte;
    MarkingType2 := FStream.ReadByte;
    AddValue('CheckItemLocalResult', Format('%d [%s]', [CheckItemLocalResult, CheckItemLocalResultToStr(CheckItemLocalResult)]), Source);
    AddValue('CheckItemLocalError', Format('%d [%s]', [CheckItemLocalError, CheckItemLocalErrorToStr(CheckItemLocalError)]), Source);
    AddValue('MarkingType2', Format('%d [%s]', [MarkingType2, MarkingTypeToStr2(MarkingType2)]), Source);
    if FStream.Remaining > 0 then
      DecodeKMAnswer(Source);
  end;
end;

function TParserCommand.DecodeTLVBarcode(Source: TParseType): string;
var
  BarcodeLength: Byte;
  TlvLength: Byte;
  BarcodeData: AnsiString;
  TLVData: AnsiString;
  TLVStr: string;
  BarcodeStr: string;
  Parser: TTLVParser;
begin
  BarcodeData := '';
  TLVData := '';
  BarcodeStr := '';
  BarcodeLength := FStream.ReadByte;
  TlvLength := FStream.ReadByte;
  if BarcodeLength > 0 then
  begin
    BarcodeData := FStream.ReadString(BarcodeLength);
    BarcodeStr := StringReplace(BarcodeData, #$1D, '<0x1D>', [rfReplaceAll]);
    AddValue('Barcode HEX', StrToHex(BarcodeData), Source);
    AddValue('Barcode', BarcodeStr, Source);
  end;
  if TlvLength > 0 then
  begin
    TLVData := FStream.ReadString(TlvLength);
    Parser := TTLVParser.Create;
    try
      Parser.BaseIndent := 2;
      Parser.ShowTagNumbers := True;
      TLVStr := Parser.ParseTLV(TLVData);
      AddValue('TLVData HEX', StrToHex(BarcodeData), Source);
      AddValue('TLVData', TLVStr, Source);
    finally
      Parser.Free
    end;
  end;
end;

destructor TParserCommand.Destroy;
begin
  FFields.Free;
  FFieldsValues.Free;
  FAnswerFieldsValues.Free;
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

function TParserCommand.GetFieldValue(const AName: string): string;
var
  Pair: TPair<string, string>;
begin
  Result := '';
  for Pair in FFieldsValues do
    if AnsiLowerCase(Pair.Key) = AnsiLowerCase(AName) then
      Result := Pair.Value;
end;

function TParserCommand.GetAnswerFieldValue(const AName: string): string;
var
  Pair: TPair<string, string>;
begin
  Result := '';
  for Pair in FAnswerFieldsValues do
    if AnsiLowerCase(Pair.Key) = AnsiLowerCase(AName) then
      Result := Pair.Value;
end;

function TParserCommand.GetShortValue: string;
begin
  Result := '';
end;

function TParserCommand.ItemStatusToString(AValue: Byte): string;
begin
  case AValue of
    1:
      Result := 'Штучный товар, реализован';
    2:
      Result := 'Мерный товар, в стадии реализации';
    3:
      Result := 'Штучный товар, возвращен';
    4:
      Result := 'Часть товара, возвращена';
  else
    Result := 'Неизвестный статус';
  end;
end;

procedure TParserCommand.AddValue(const AName: string; const AValue: string; Source: TParseType);
begin
  if Source = pFields then
    FFieldsValues.Add(TPair<string, string>.Create(AName, AValue))
  else if Source = pAnswerFields then
    FAnswerFieldsValues.Add(TPair<string, string>.Create(AName, AValue));
end;

function TParserCommand.Parse(const ACmd: TCommand; Source: TParseType): string;
var
  Field: TPair<string, TFieldType>;
  b: Byte;
  S: TStringList;
  Value: string;
  l: Integer;
  Len: Integer;
  TlvParser: TTLVParser;
  Res: Byte;
  IntValue: Integer;
  FieldList: TList<TPair<string, TFieldType>>;
  Buf: AnsiString;
  Buf1: AnsiString;
  FieldValue: string;
  AddLength: Byte;
  FieldElement: TPair<string, string>;
begin
  case Source of
    pFields:
      begin
        FFieldsValues.Clear;
        Start(ACmd);
      end;
    pAnswerFields:
      begin
        FAnswerFieldsValues.Clear;
        StartAnswer(ACmd);
      end;
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
      FieldValue := '';
      case Field.Value of
        ftByte:
          begin
            FieldValue := FStream.ReadByte.ToString;
           // Value := Value + FieldValue;
          end;
        ftUInt32:
          begin
            FieldValue := FStream.ReadUInt32.ToString;
           // Value := Value +
          end;
        ftUInt16:
          begin
            FieldValue := FStream.ReadUInt16.ToString;
          end;
        ftSoftVersion:
          begin
            FieldValue := FStream.ReadString(1) + '.' + FStream.ReadString(1);
          end;
        ftQuantity6:
          begin
            FieldValue := Format('%.6f', [FStream.ReadInt(6) / 1000000]);
          end;
        fTQuantity5:
          begin
            FieldValue := Format('%.3f', [FStream.ReadInt(5) / 1000]);
          end;
        ftDate:
          begin
            FieldValue := DateToStr(Str2Date(IntToBin(FStream.ReadInt(3), 3), 1));
          end;
        ftTime:
          begin
            FieldValue := TimeToStr(Str2Time(IntToBin(FStream.ReadInt(3), 3), 1));
          end;
        ftDateTime:
          begin
            FieldValue := DateTimeToStr(Str2Date(IntToBin(FStream.ReadInt(5), 5), 1));
          end;
        ftDateTimeDoc:
          begin
            FieldValue := DateTimeToStr(Str2DateDoc(IntToBin(FStream.ReadInt(5), 5), 1));
          end;
        ftSum:
          begin
            FieldValue := Format('%.2f', [FStream.ReadInt(5) / 100]);
          end;
        ftString:
          begin
            FieldValue := FStream.ReadString;
          end;
        ftString16:
          begin
            FieldValue := TrimRight(FStream.ReadString(16));
          end;
        ftString40:
          begin
            FieldValue := TrimRight(FStream.ReadString(40));
          end;
        ftBarcode:
          begin
            Len := FStream.ReadByte;
            FieldValue := StringReplace(FStream.ReadString(Len), #$1D, '<0x1D>', [rfReplaceAll]);
          end;
        ftFieldType:
          begin
            FieldValue := FieldTypeToString(FStream.ReadByte);
          end;
        ftTableValue:
          begin
            Buf := FStream.ReadString;
            Buf1 := Copy(Buf, 1, 8);
            if Length(Buf) > 8 then
              FieldValue := TrimRight(Buf)
            else if Length(Buf) = 0 then
              FieldValue := ''
            else if Trim(Buf) = '' then
              FieldValue := BinToInt(Buf1, 1, Length(Buf1)).ToString
            else
              FieldValue := #13#10 + 'Str: ' + TrimRight(Buf) + #13#10 + 'Int: ' + BinToInt(Buf1, 1, Length(Buf1)).ToString;
          end;
        ftCheckType:
          begin
            FieldValue := CheckTypeToString(FStream.ReadByte);
          end;
        ftCheckType2:
          begin
            FieldValue := CheckType2ToString(FStream.ReadByte);
          end;
        ftPaymentTypeSign:
          begin
            FieldValue := PaymentTypeSigntoString(FStream.ReadByte);
          end;
        ftPaymentItemSign:
          begin
            FieldValue := PaymentItemSignToString(FStream.ReadByte);
          end;
        ftTaxValue:
          begin
            FieldValue := TaxValueToString(FStream.ReadInt(5));
          end;
        ftSumm1Value:
          begin
            FieldValue := Summ1ToString(FStream.ReadInt(5));
          end;
        ftTax:
          begin
            FieldValue := FStream.ReadByte.ToString;
          end;
        ftTLV:
          begin
            TlvParser := TTLVParser.Create;
            try
              TlvParser.ShowTagNumbers := True;
              TlvParser.BaseIndent := 4;
              FieldValue := #13#10 + TlvParser.ParseTLV(FStream.ReadString);
            finally
              TlvParser.Free;
            end;
          end;
        ftTaxType:
          begin
            FieldValue := TaxTypeToString(FStream.ReadByte);
          end;
        ftTax1:
          begin
            FieldValue := Tax1ToString(FStream.ReadByte);
          end;
        ftINN:
          begin
            FieldValue := Int64ToStr(FStream.ReadInt(6));
          end;
        ftECRMode:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, GetECRModeDescription(IntValue)]);
          end;
        ftECRAdvancedMode:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, GetAdvancedModeDescription(IntValue)]);
          end;
        ftECRFlags:
          begin
            FieldValue := ECRFlagsToString(FStream.ReadUInt16);
          end;
        ftBatteryVoltage:
          begin
            FieldValue := Format('%.2f В.', [Round2(FStream.ReadByte / 255 * 100 * 5) / 100]);
          end;
        ftPowerSourceVoltage:
          begin
            FieldValue := Format('%.2f В.', [Round2(FStream.ReadByte * 24 / $D8 * 100) / 100]);
          end;
        ftPortNumber:
          begin
            FieldValue := PortNumToString(FStream.ReadByte);
          end;
        ftCheckItemLocalResult:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, CheckItemLocalResultToStr(IntValue)]);
          end;
        ftCheckItemLocalError:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, CheckItemLocalErrorToStr(IntValue)]);
          end;
        ftMarkingType2:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, MarkingTypeToStr2(IntValue)]);
          end;
        ftKMAnswer:
          begin
            FieldValue := VALUE_NOT_VISIBLE;
            DecodeKMAnswer(Source);
          end;
        ftKMSendAnswer:
          begin
            FieldValue := VALUE_NOT_VISIBLE;
            DecodeKMSendAnswer(Source);
          end;
        ftBarcodeTLV:
          begin
            FieldValue := VALUE_NOT_VISIBLE;
            DecodeTLVBarcode(Source);
          end;
        ftItemStatus:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, ItemStatusToString(IntValue)]);
          end;
        ftBarcodeOSU:
          begin
            FieldValue := VALUE_NOT_VISIBLE;
            DecodeBarcodeOSU(Source);
          end;
        ftMarkingType:
          begin
            IntValue := FStream.ReadIntRev(2);
            FieldValue := Format('%d [%s]', [IntValue, MarkingTypeToStr(IntValue)]);
          end;
        ftMarkingTypeEx:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, MarkingTypeExToStr(IntValue)]);
          end;
        ftAcceptOrDecline:
          begin
            IntValue := FStream.ReadByte;
            if IntValue = 1 then
              FieldValue := IntValue.ToString + ' [Принять]'
            else
              FieldValue := IntValue.ToString + ' [Отклонить]';
          end;
        ftFNSessionState:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, FNSessionStateToStr(IntValue)]);
          end;
        ftFNCurrentDocument:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, FNCurrentDocumentToStr(IntValue)]);
          end;
        ftFNDocumentData:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, FNDocumentDataToStr(IntValue)]);
          end;
        ftFNLifeState:
          begin
            IntValue := FStream.ReadByte;
            FieldValue := Format('%d [%s]', [IntValue, FNLifeStateToStr(IntValue)]);
          end;
      end;
      Value := Value + FieldValue;
      if FieldValue <> VALUE_NOT_VISIBLE then
        AddValue(Field.Key, FieldValue, Source);
    end;
    if Source = pFields then
    begin
      for FieldElement in FFieldsValues do
        S.Add(FieldElement.Key + ': ' + FieldElement.Value)
    end
    else if Source = pAnswerFields then
    begin
      for FieldElement in FAnswerFieldsValues do
        S.Add(FieldElement.Key + ': ' + FieldElement.Value)
    end
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
  AddCommand($FF01, TParserCommandFF01);
  AddCommand($FF0C, TParserCommandFF0C);
  AddCommand($FF4D, TParserCommandFF0C);
  AddCommand($FF61, TParserCommandFF61);
  AddCommand($FF67, TParserCommandFF67);
  AddCommand($FF69, TParserCommandFF69);
  AddCommand($FF70, TParserCommandFF70);
  AddCommand($FF71, TParserCommandFF71);
  AddCommand($FF72, TParserCommandFF72);
  AddCommand($FF73, TParserCommandFF73);
  AddCommand($FF74, TParserCommandFF74);
  AddCommand($FF75, TParserCommandFF75);
  AddCommand($FF76, TParserCommandFF76);
  AddCommand($FF78, TParserCommandFF78);

  AddCommand($10, TParserCommand10);
  AddCommand($11, TParserCommand11);
  AddCommand($17, TParserCommand17);
  AddCommand($1E, TParserCommand1E);
  AddCommand($1F, TParserCommand1F);
  AddCommand($2F, TParserCommand2F);
  AddCommand($2D, TParserCommand2D);
  AddCommand($2E, TParserCommand2E);
  AddCommand($6B, TParserCommand6B);
  AddCommand($80, TParserCommand80);
  AddCommand($81, TParserCommand81);
  AddCommand($82, TParserCommand82);
  AddCommand($83, TParserCommand83);
  AddCommand($85, TParserCommand85);
  AddCommand($89, TParserCommand89);
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

