unit untCommand;
interface
uses
   // VCL
   System.SysUtils, System.Classes, System.Generics.Collections,
   // This
   BinUtils,  Utils.BinStream;

type
  TProtocol = (pNone,
    pProtocol1, pProtocol2, pProtocol3, pPlain,
    pProtocolNg1, pProtocolNg2, pProtocolNg1Plain);

  { TCommandRec }

  TCommandRec = record
    Code: Integer;
    ResCode: Integer;
    Attributes: string;
    TxData: AnsiString;
    AnswerData: AnsiString;
    Protocol: TProtocol;
    LineNumber: Integer;
  end;

  { TCommand }

  TCommand = class
  private
    FData: TCommandRec;
  public
    Played: Boolean;
    Selected: Boolean;
    PlayedAnswerData: AnsiString;

    constructor Create(const AData: TCommandRec);

    function TimeStamp: AnsiString;
    function ThreadID: AnsiString;
    function CommandName: string;
    class function GetCode(const Data: string): Integer;
    class function GetResCode(const Data: string): Integer; static;
    function HasError: Boolean;
    function HasData(const AData: string): Boolean;
    function IsPrintCommand: Boolean;
    function IsStatusCommand: Boolean;
    function IsRecRepCommand: Boolean;

    property CmdData: TCommandRec read FData;
    property Code: Integer read FData.Code;
    property TxData: AnsiString read FData.TxData;
    property Attributes: string read FData.Attributes;
    property Protocol: TProtocol read FData.Protocol;
    property LineNumber: Integer read FData.LineNumber;
    property ResCode: Integer read FData.ResCode write FData.ResCode;
    property AnswerData: AnsiString read FData.AnswerData write FData.AnswerData;
  end;
  TCommandList = TObjectList<TCommand>;

function ProtocolToStr(Protocol: TProtocol): string;

implementation

uses DriverCommands;

function ProtocolToStr(Protocol: TProtocol): string;
begin
  case Protocol of
    pProtocol1: Result := 'Protocol v1';
    pProtocol2: Result := 'Protocol v2';
    pProtocol3: Result := 'Protocol v3';
    pPlain: Result := 'Protocol v1 (plain)';
    pProtocolNg1: Result := 'Protocol v1 (NG)';
    pProtocolNg1Plain: Result := 'Protocol v1 (plain) (NG)';
  else
    Result := '';
  end;
end;

{ TCommand }

constructor TCommand.Create(const AData: TCommandRec);
begin
  inherited Create;
  FData := AData;
end;

class function TCommand.GetCode(const Data: string): Integer;
var
  Cmd: Word;
  BinData: AnsiString;
begin
  BinData := HexToStr(Data);
  Cmd := BinToInt(BinData, 1, 1);
  if (Cmd = $FF) or (Cmd = $FE) then
    Cmd := (Cmd shl 8) or (BinToInt(BinData, 2, 1));
  Result := Cmd;
end;

function TCommand.CommandName: string;
begin
  if (Protocol = pProtocol2) and (TxData = '') then
  begin
    Result := 'Sync'
  end else
  begin
    Result := Format('%.2X, %s', [Code, GetCommandName(Code)]);
  end;
end;

class function TCommand.GetResCode(const Data: string): Integer;
var
  Stream: IBinStream;
  b: Byte;
begin
  Result := 0;
  Stream := TBinStream.Create([]);
  Stream.WriteBytes(HexToBytes(Data));
  Stream.Stream.Position := 0;
  if Stream.Size < 2 then Exit;
  b := Stream.ReadByte;
  if b = $FF then
    Stream.ReadByte;
  b := Stream.ReadByte;
  Result := b;
end;

function TCommand.HasData(const AData: string): Boolean;
begin
  Result := (Pos(LowerCase(AData, loUserLocale), LowerCase(Attributes, loUserLocale)) > 0) or
            (Pos(LowerCase(AData, loUserLocale), LowerCase(TimeStamp, loUserLocale)) > 0) or
            (Pos(LowerCase(AData, loUserLocale), LowerCase(CommandName, loUserLocale)) > 0);
end;

function TCommand.ThreadID: AnsiString;
var
  k: Integer;
  s: string;
begin
  k := Pos('] [', Attributes);
  s := Copy(Attributes, k + 3, Length(Attributes));
  k := Pos(']', s);
  s := Copy(s, 1, k - 1);
  Result := s;
end;

function TCommand.TimeStamp: AnsiString;
begin
  Result := Copy(Attributes, 2, Length('08.12.2021 23:50:07.520'));
end;

function TCommand.HasError: Boolean;
begin
  Result := (ResCode <> 0)or((AnswerData = '')and(TxData <> '')); // !!!
end;

function TCommand.IsPrintCommand: Boolean;
const
  PrintCommandCodes: array [0..3] of Integer = (
    $FF45,  // Закрытие чека расширенное вариант V2
    $FF76,  // Закрытие чека расширенное вариант V3
    $FF77,  // Сформировать чек коррекции V3
    $FF78   // Закрытие чека расширенное вариант V4
  );
var
  i: Integer;
begin
  Result := False;
  for i := Low(PrintCommandCodes) to High(PrintCommandCodes) do
  begin
    Result := Code = PrintCommandCodes[i];
    if Result then Break;
  end;
end;

// Receipt or Report command
function TCommand.IsRecRepCommand: Boolean;
const
  PrintCommandCodes: array [0..49] of Integer = (
    $40, // Суточный отчет без гашения
    $41, // Суточный отчет с гашением
    $42, // Отчёт по секциям
    $43, // Отчёт по налогам
    $44, // Отчёт по кассирам
    $45, // Отчёт почасовой
    $46, // Отчёт по товарам
    $50, // Внесение
    $51, // Выплата
    $80, // Продажа
    $81, // Покупка
    $82, // Возврат продажи
    $83, // Возврат покупки
    $84, // Сторно
    $85, // Закрытие чека
    $86, // Скидка
    $87, // Надбавка
    $88, // Аннулирование чека
    $89, // Подытог чека
    $8A, // Сторно скидки
    $8B, // Сторно надбавки
    $8C, // Повтор документа
    $8D, // Открыть чек
    $E0, // Открытие смены
    $FF34, // Сформировать отчёт о перерегистрации ККТ
    $FF35, // Начать формирование чека коррекции
    $FF36, // Сформировать чек коррекции
    $FF37, // Начать формирование отчёта о состоянии расчётов
    $FF38, // Сформировать отчёт о состоянии расчётов
    $FF3D, // Начать закрытие фискального режима
    $FF3E, // Закрыть фискальный режим
    $FF41, // Начать открытие смены
    $FF42, // Начать закрытие смены
    $FF45, // Закрытие чека расширенное вариант V2
    $FF46, // Операция V2
    $FF47, // Дополнительный реквизит ФНС
    $FF48, // Скидки и надбавки в операции
    $FF49, // Передача кода товарной номенклатуры
    $FF4A, // Сформировать чек коррекции V2
    $FF4B, // Скидка, надбавка на чек для Роснефти
    $FF4D, // Передать произвольную TLV структуру привязанную к операции
    $FF50, // Онлайн платёж
    $FF51, // Статус онлайн платёжа
    $FF61, // Проверка  маркированного товара
    $FF64, // Передача в ФН  TLV из буфера
    $FF67, // Привязка  маркированного товара к позиции
    $FF69, // Принять/отклонить КМ
    $FF76, // Закрытие чека расширенное вариант V3
    $FF77, // Сформировать чек коррекции V3
    $FF78 // Закрытие чека расширенное вариант V4
  );
var
  i: Integer;
begin
  Result := False;
  for i := Low(PrintCommandCodes) to High(PrintCommandCodes) do
  begin
    Result := Code = PrintCommandCodes[i];
    if Result then Break;
  end;
end;

function TCommand.IsStatusCommand: Boolean;

const
  StatusCommandCodes: array [0..1] of Integer = (
    $10, // Короткий запрос состояния
    $11  // Запрос состояния
  );
var
  i: Integer;
begin
  Result := False;
  for i := Low(StatusCommandCodes) to High(StatusCommandCodes) do
  begin
    Result := Code = StatusCommandCodes[i];
    if Result then Break;
  end;
end;

end.
