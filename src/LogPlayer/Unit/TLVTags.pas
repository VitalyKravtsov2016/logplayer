unit TLVTags;

interface

Uses
  // VCL
  SysUtils, Classes, strutils,
  // This
  drvfrlib_tlb, FormatTLV, BinUtils;

type

  TTLVTag = class;

  { TTLVTags }

  TTLVTags = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TTLVTag;
    procedure InsertItem(AItem: TTLVTag);
    procedure RemoveItem(AItem: TTLVTag);
    procedure CreateTags;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TTLVTag;
    procedure AddTag(ANumber: Integer; const ADescription: string; const AShortDescription: string; AType: TTagType; ALength: Integer; AFixedLength: Boolean = False);
    procedure Clear;
    function FindTag(ANumber: Integer): TTLVTag;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TTLVTag read GetItem; default;
  end;

  { TTLVTag }

  TTLVTag = class
  private
    FOwner: TTLVTags;
    FTag: Integer;
    FLength: Integer;
    FDescription: string;
    FTagType: TTagType;
    FShortDescription: string;
    FFixedLength: Boolean;
    procedure SetOwner(AOwner: TTLVTags);
    function GetDescription: string;
  public
    constructor Create(AOwner: TTLVTags);
    destructor Destroy; override;
    function GetStrValue(AData: string): string;
    property Tag: Integer read FTag write FTag;
    property TagType: TTagType read FTagType write FTagType;
    property Description: string read GetDescription write FDescription;
    property ShortDescription: string read FShortDescription write FShortDescription;
    property Length: Integer read FLength write FLength;
    property FixedLength: Boolean read FFixedLength write FFixedLength;
  end;


function TLVDocTypeToStr(ATag: Integer): string;

implementation

resourcestring
  SRegReport = 'ОТЧЕТ О РЕГИСТРАЦИИ';
  SChangeRegReport = 'ОТЧЕТ ОБ ИЗМЕНЕНИИ ПАРАМЕТРОВ РЕГИСТРАЦИИ';
  SOpenSessionReport = 'ОТЧЕТ ОБ ОТКРЫТИИ СМЕНЫ';
  SCurrentStateReport = 'ОТЧЕТ О ТЕКУЩЕМ СОСТОЯНИИ РАСЧЕТОВ';
  SReceipt = 'КАССОВЫЙ ЧЕК';
  SCorrReceipt = 'КАССОВЫЙ ЧЕК КОРРЕКЦИИ';
  SBSO = 'БЛАНК СТРОГОЙ ОТЧЕТНОСТИ';
  SBSOCorr = 'БЛАНК СТРОГОЙ ОТЧЕТНОСТИ КОРРЕКЦИИ';
  SCloseSessionReport ='ОТЧЕТ О ЗАКРЫТИИ СМЕНЫ';
  SCloseFNReport = 'ОТЧЕТ О ЗАКРЫТИИ ФН';
  SCnofirmOperator = 'ПОДТВЕРЖДЕНИЕ ОПЕРАТОРА';
  SUnknownDocTye = 'Неизвестный тип документа: ';
function TLVDocTypeToStr(ATag: Integer): string;
begin
  case ATag of
    1: Result := SRegReport;
    11: Result := SChangeRegReport;
    2: Result := SOpenSessionReport;
    21: Result := SCurrentStateReport;
    3: Result := SReceipt;
    31: Result := SCorrReceipt;
    4: Result := SBSO;
    41: Result := SBSOCorr;
    5: Result := SCloseSessionReport;
    6: Result := SCloseFNReport;
    7: Result := SCnofirmOperator;
  else
    Result := SUnknownDocTye + IntToStr(ATag);
  end;
end;

resourcestring
  SSale = 'Приход';
  SReturnSale = 'Возврат прихода';
  SBuy = 'Расход';
  SReturnBuy = 'Возврат расхода';
  SUnknownType = 'Неизв. тип: ';

function CalcTypeToStr(AType: Integer): string;
begin
  case AType of
    1: Result := SSale;
    2: Result := SReturnSale;
    3: Result := SBuy;
    4: Result := SReturnBuy;
  else
    Result := SUnknownType  + IntToStr(AType);
  end;
end;

//
{
0 Общая
1 Упрощенная Доход
2 Упрощенная Доход минус Расход
3 Единый налог на вмененный доход
4 Единый сельскохозяйственный налог
5 Патентная система налогообложения}
resourcestring
  SOSN = 'ОБЩ.';
  SUD = '+УД';
  SUDMR = '+УДМР';
  SENVD = '+ЕНВД';
  SESN = '+ЕСН';
  SPSN = '+ПСН';

function TaxSystemToStr(AType: Integer): string;
begin
  If AType = 0 then
  begin
    Result := 'Нет';
    Exit;
  end;
  if TestBit(AType, 0) then
    Result := SOSN;
  if TestBit(AType, 1) then
    Result := Result + SUD;
  if TestBit(AType, 2) then
    Result := Result + SUDMR;
  if TestBit(AType, 3) then
    Result := Result + SENVD;
  if TestBit(AType, 4) then
    Result := Result + SESN;
  if TestBit(AType, 5) then
    Result := Result + SPSN;
end;

{ TTLVTags }

constructor TTLVTags.Create;
begin
  inherited Create;
  FList := TList.Create;
  CreateTags;
end;

destructor TTLVTags.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TTLVTags.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TTLVTags.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTLVTags.GetItem(Index: Integer): TTLVTag;
begin
  Result := FList[Index];
end;

procedure TTLVTags.InsertItem(AItem: TTLVTag);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TTLVTags.RemoveItem(AItem: TTLVTag);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TTLVTags.Add: TTLVTag;
begin
  Result := TTLVTag.Create(Self);
end;

procedure TTLVTags.AddTag(ANumber: Integer;
  const ADescription: string; const AShortDescription: string; AType: TTagType; ALength: Integer; AFixedLength: Boolean = False);
var
  T: TTLVTag;
begin
  T := Add;
  T.FTag := ANumber;
  T.FLength := ALength;
  T.FDescription := ADescription;
  T.FShortDescription := AShortDescription;
  T.FixedLength := AFixedLength;
  T.FTagType := AType;
end;

procedure TTLVTags.CreateTags;
begin
//  AddTag(1000, 'наименование документа', 'НАИМ. ДОК.',	ttString, 0);
  AddTag(1001, 'признак автоматического режима', 'ПРИЗН. АВТОМ. РЕЖ.', ttByte, 1);
  AddTag(1002, 'признак автономного режима', 'ПРИЗН. АВТОНОМН. РЕЖ.', ttByte, 1);
  AddTag(1005, 'адрес оператора перевода', 'АДР. ОПЕР. ПЕРЕВОДА', ttString, 256);
  AddTag(1008, 'телефон или электронный адрес покупателя', 'ТЕЛ. ИЛИ EMAIL ПОКУПАТЕЛЯ', ttString, 64);
  AddTag(1009, 'адрес расчетов', 'АДР.РАСЧЕТОВ', ttString, 256);
  // Старые теги
  AddTag(1010, 'размер вознаграждения банковского агента', 'РАЗМЕР ВОЗНАГР. БАНК. АГЕНТА', ttVLN, 8);
  AddTag(1011, 'размер вознаграждения платежного агента', 'РАЗМЕР ВОЗНАГР. ПЛАТ. АГЕНТА', ttVLN, 8);

  AddTag(1012, 'дата, время', 'ДАТА, ВРЕМЯ', ttUnixTime, 4);
  AddTag(1013, 'заводской номер ККТ', 'ЗАВ. НОМЕР ККТ', ttString, 20);
  AddTag(1016, 'ИНН оператора перевода', 'ИНН ОПЕРАТОРА ПЕРЕВОДА', ttString, 12, True);
  AddTag(1017, 'ИНН ОФД', 'ИНН ОФД', ttString, 12, True);
  AddTag(1018, 'ИНН пользователя', 'ИНН ПОЛЬЗ.', ttString, 12, True);
  AddTag(1020, 'сумма расчета, указанного в чеке (БСО)', 'СУММА РАСЧЕТА В ЧЕКЕ(БСО)', ttVLN, 6);
  AddTag(1021, 'кассир', 'КАССИР', ttString, 64);
  AddTag(1022, 'код ответа ОФД', 'КОД ОТВЕРА ОФД', ttByte, 1);
  AddTag(1023, 'количество предмета расчета', 'КОЛ-ВО ПРЕДМ. РАСЧЕТА', ttFVLN, 8);
  AddTag(1026, 'наименование оператора перевода', 'НАИМЕН. ОПЕР. ПЕРЕВОДА', ttString, 64);
  AddTag(1030, 'наименование предмета расчета', 'НАИМЕН. ПРЕДМ. РАСЧЕТА', ttString, 128);
  AddTag(1031, 'сумма по чеку (БСО) наличными', 'СУММА ПО ЧЕКУ НАЛ (БСО)', ttVLN, 6);
  AddTag(1036, 'номер автомата', 'НОМЕР АВТОМАТА', ttString, 20);
  AddTag(1037, 'регистрационный номер ККТ', 'РЕГ. НОМЕР ККТ', ttString, 20, True);
  AddTag(1038, 'номер смены', 'НОМЕР СМЕНЫ', ttUInt32, 4);
  AddTag(1040, 'номер ФД', 'НОМЕР ФД', ttUInt32, 4);
  AddTag(1041, 'номер ФН', 'НОМЕР ФН', ttString, 16, True);
  AddTag(1042, 'номер чека за смену', 'НОМЕР ЧЕКА ЗА СМЕНУ', ttUInt32, 4);
  AddTag(1043, 'стоимость предмета расчета', 'СТОИМ. ПРЕДМ. РАСЧЕТА', ttVLN, 6);
  AddTag(1044, 'операция платежного агента', 'ОПЕРАЦИЯ ПЛАТ. АГЕНТА', ttString, 24);
  // Старый тег
  AddTag(1045, 'операция банковского субагента', 'ОПЕРАЦИЯ БАНК. СУБАГЕНТА', ttString, 24);

  AddTag(1046, 'наименование ОФД', 'НАИМЕН. ОФД', ttString, 256);
  AddTag(1048, 'наименование пользователя', 'НАИМЕН. ПОЛЬЗ.', ttString, 256);
  AddTag(1050, 'признак исчерпания ресурса ФН', 'ПРИЗН. ИСЧЕРП. РЕСУРСА ФН', ttByte, 1);
  AddTag(1051, 'признак необходимости срочной замены ФН', 'ПРИЗН. НЕОБХ. СРОЧН. ЗАМЕНЫ ФН', ttByte, 1);
  AddTag(1052, 'признак переполнения памяти ФН', 'ПРИЗН. ПЕРЕПОЛН. ПАМЯТИ ФН', ttByte, 1);
  AddTag(1053, 'признак превышения времени ожидания ответа ОФД', 'ПРИЗН ПРЕВЫШ. ВРЕМЕНИ ОЖИД. ОТВ. ОФД', ttByte, 1);
  AddTag(1054, 'признак расчета', 'ПРИЗН. РАСЧЕТА', ttByte, 1);
  AddTag(1055, 'применяемая система налогообложения', 'ПРИМЕН. СИСТ. НАЛОГООБЛОЖЕНИЯ', ttByte, 1);
  AddTag(1056, 'признак шифрования', 'ПРИЗН. ШИФРОВАНИЯ', ttByte, 1);
  AddTag(1057, 'признак платежного агента', 'ПРИЗН. ПЛАТ. АГЕНТА', ttByte, 1);
  AddTag(1059, 'предмет расчета', 'ПРЕДМ. РАСЧЕТА', ttSTLV, 1024);
  AddTag(1060, 'адрес сайта ФНС', 'АДР. САЙТА ФНС', ttString, 256);
  AddTag(1062, 'системы налогообложения', 'СИСТЕМЫ НАЛОГООБЛ.', ttByte, 1);
  AddTag(1068, 'сообщение оператора для ФН', 'СООБЩ. ОПЕРАТОРА ДЛЯ ФН', ttSTLV, 9);
  AddTag(1073, 'телефон платежного агента', 'ТЕЛ. ПЛАТ. АГЕНТА', ttString, 19);
  AddTag(1074, 'телефон оператора по приему платежей', 'ТЕЛ ОПЕР. ПО ПРИЕМУ ПЛАТЕЖЕЙ', ttString, 19);
  AddTag(1075, 'телефон оператора перевода', 'ТЕЛ. ОПЕР. ПЕРЕВОДА', ttString, 19);
  AddTag(1077, 'ФП документа', 'ФП ДОКУМЕНТА', ttByteArray, 6);
  AddTag(1078, 'ФП оператора', 'ФП ОПЕРАТОРА', ttByteArray, 16);
  AddTag(1079, 'цена за единицу предмета расчета', 'ЦЕНА ЗА ЕД. ПРЕДМ. РАСЧ.', ttVLN, 6);
  AddTag(1080, 'штриховой код EAN 13', 'ШК EAN 13', ttString, 16);
  AddTag(1081, 'сумма по чеку (БСО) электронными', 'СУММА ПО ЧЕКУ ЭЛЕКТРОННЫМИ(БСО)', ttVLN, 6);
  // Старые теги
  AddTag(1082, 'телефон банковского субагента', 'ТЕЛ. БАНК. СУБАГЕНТА', ttString, 19);
  AddTag(1083, 'телефон платежного субагента', 'ТЕЛ. ПЛАТ. СУБАГЕНТА', ttString, 19);


  AddTag(1084, 'дополнительный реквизит пользователя', 'ДОП. РЕКВИЗИТ ПОЛЬЗОВ.', ttSTLV, 320);
  AddTag(1085, 'наименование дополнительного реквизита пользователя', 'НАИМЕН. ДОП. РЕКВИЗИТ. ПОЛЬЗОВ.', ttString, 64);
  AddTag(1086, 'значение дополнительного реквизита пользователя', 'ЗНАЧ. ДОП. РЕКВИЗИТ. ПОЛЬЗОВ.', ttString, 256);
  AddTag(1097, 'количество непереданных ФД', 'КОЛ-ВО НЕПЕРЕДАННЫХ ФД', ttUInt32, 4);
  AddTag(1098, 'дата и время первого из непереданных ФД', 'ДАТА И ВРЕМЯ ПЕРВОГО НЕПЕРЕДАНН. ФД', ttUnixTime, 4);
  AddTag(1101, 'код причины перерегистрации', 'КОД ПРИЧИНЫ ПЕРЕРЕГИСТР.', ttByte, 1);
  AddTag(1102, 'сумма НДС чека по ставке 18%', 'СУММА НДС ЧЕКА 18%', ttVLN, 6);
  AddTag(1103, 'сумма НДС чека по ставке 10%', 'СУММА НДС ЧЕКА 10%', ttVLN, 6);
  AddTag(1104, 'сумма расчета по чеку с НДС по ставке 0%', 'СУММА РАСЧ. ПО ЧЕКУ 0%', ttVLN, 6);
  AddTag(1105, 'сумма расчета по чеку без НДС', 'СУММА РАСЧ. ПО ЧЕКУ БЕЗ НДС', ttVLN, 6);
  AddTag(1106, 'сумма НДС чека по расч. ставке 18/118', 'СУММА НДС ЧЕКА ПО РАСЧ. СТАВКЕ 18/118', ttVLN, 6);
  AddTag(1107, 'сумма НДС чека по расч. ставке 10/110', 'СУММА НДС ЧЕКА ПО РАСЧ. СТАВКЕ 10/110', ttVLN, 6);
  AddTag(1108, 'признак ККТ для расчетов только в Интернет', 'ПРИЗН. ККТ ДЛЯ РАСЧ. ТОЛЬКО В ИНТЕРНЕТ', ttByte, 1);
  AddTag(1109, 'признак расчетов за услуги', 'ПРИЗН. РАСЧ. ЗА УСЛУГИ', ttByte, 1);
  AddTag(1110, 'признак АС БСО', 'ПРИЗН. АС БСО', ttByte, 1);
  AddTag(1111, 'общее количество ФД за смену', 'ОБЩ. КЛ-ВО ФД ЗА СМЕНУ', ttUInt32, 4);
  AddTag(1116, 'номер первого непереданного документа', 'НОМЕР ПЕРВОГО НЕПЕРЕДАНН. ДОК-ТА', ttUInt32, 4);
  AddTag(1117, 'адрес электронной почты отправителя чека', 'АДР. ЭЛ. ПОЧТЫ ОТПРАВ. ЧЕКА', ttString, 64);
  AddTag(1118, 'количество кассовых чеков (БСО) за смену', 'КОЛ-ВО КАССОВЫХ ЧЕКОВ ЗА СМЕНУ(БСО)', ttUInt32, 4);
  // старый тег
  AddTag(1119, 'телефон оператора по приему платежей', 'ТЕЛ. ОПЕР. ПО ПРИЕМУ ПЛАТ.', ttString, 19);

  AddTag(1126, 'признак проведения лотереи', 'ПРИЗН. ПРОВЕДЕНИЯ ЛОТЕРЕИ', ttByte, 1);
  AddTag(1129, 'счетчики операций «приход»', 'СЧЕТЧИКИ ОПЕР. "ПРИХОД"', ttSTLV, 116);
  AddTag(1130, 'счетчики операций «возврат прихода»', 'СЧЕТЧИКИ ОПЕР. "ВОЗВР. ПРИХОДА"', ttSTLV, 116);
  AddTag(1131, 'счетчики операций «расход»', 'СЧЕТЧИКИ ОПЕР. "РАСХОД"', ttSTLV, 116);
  AddTag(1132, 'счетчики операций «возврат расхода»', 'СЧЕТЧИКИ ОПЕР. "ВОЗВР. РАСХОДА"', ttSTLV, 116);
  AddTag(1133, 'счетчики операций по чекам коррекции', 'СЧЕТЧИКИ ОПЕР ПО ЧЕКАМ КОРР.', ttSTLV, 216);
  AddTag(1134, 'количество чеков (БСО) со всеми признаками расчетов', 'КОЛ-ВО ЧЕКОВ БСО СО ВСЕМИ ПРИЗН. РАСЧ.', ttUInt32, 4);
  AddTag(1135, 'количество чеков по признаку расчетов', 'КОЛ-ВО ЧЕКОВ ПО ПРИЗН. РАСЧ.', ttUInt32, 4);
  AddTag(1136, 'итоговая сумма в чеках (БСО) наличными', 'ИТОГ. СУММ. В ЧЕКАХ БСО НАЛ.', ttVLN, 8);
  AddTag(1138, 'итоговая сумма в чеках (БСО) электронными', 'ИТОГ СУММА В ЧЕКАХ БСО ЭЛЕКТР.', ttVLN, 8);
  AddTag(1139, 'сумма НДС по ставке 18%', 'СУММА НДС 18%', ttVLN, 8);
  AddTag(1140, 'сумма НДС по ставке 10%', 'СУММА НДС 10%', ttVLN, 8);
  AddTag(1141, 'сумма НДС по расч. ставке 18/118', 'СУММА НДС ПО РАСЧ. СТАВКЕ 18/118', ttVLN, 8);
  AddTag(1142, 'сумма НДС по расч. ставке 10/110', 'СУММА НДС ПО РАСЧ. СТАВКЕ 10/110', ttVLN, 8);
  AddTag(1143, 'сумма расчетов с НДС по ставке 0%', 'СУММА РАСЧ. С НДС 0%', ttVLN, 8);
  AddTag(1144, 'количество чеков коррекции', 'КОЛ-ВО ЧЕКОВ ОПЕРАЦИИ', ttUInt32, 4);
  AddTag(1145, 'счетчики коррекций «приход»', 'СЧЕТЧ. КОРРЕКЦИЙ "ПРИХОД"', ttSTLV, 100);
  AddTag(1146, 'счетчики коррекций «расход»', 'СЧЕТЧ. КОРРЕКЦИЙ "РАСХОД"', ttSTLV, 100);
  AddTag(1148, 'количество самостоятельных корректировок', 'КОЛ-ВО САМОСТ. КОРРЕКТИРОВОК', ttUInt32, 4);
  AddTag(1149, 'количество корректировок по предписанию', 'КОЛ-ВО КОРРЕКТИРОВОК ПО ПРЕДПИС.', ttUInt32, 4);
  AddTag(1151, 'сумма коррекций НДС по ставке 18%', 'СУММА КОРРЕКЦИЙ НДС 18%', ttVLN, 8);
  AddTag(1152, 'сумма коррекций НДС по ставке 10%', 'СУММА КОРРЕКЦИЙ НДС 10%', ttVLN, 8);
  AddTag(1153, 'сумма коррекций НДС по расч. ставке 18/118', 'СУММА КОРРЕКЦИЙ НДС ПО РАСЧ. СТ. 18/110', ttVLN, 8);
  AddTag(1154, 'сумма коррекций НДС расч. ставке 10/110', 'СУММА КОРРЕКЦИЙ НДС ПО РАС. СТ. 10/110', ttVLN, 8);
  AddTag(1155, 'сумма коррекций с НДС по ставке 0%', 'СУММА КОРРЕКЦИЙ НДС 0%', ttVLN, 8);
  AddTag(1157, 'счетчики итогов ФН', 'СЧЕТЧИКИ ИТОГОВ ФН', ttSTLV, 708);
  AddTag(1158, 'счетчики итогов непереданных ФД', 'СЧЕТЧ ИТОГОВ НЕПЕРЕД. ФД', ttSTLV, 708);
  AddTag(1162, 'код товарной номенклатуры', 'КОД ТОВАРН. НОМЕНКЛ.', ttByteArray, 32);
  AddTag(1171, 'телефон поставщика', 'ТЕЛ. ПОСТАВЩИКА', ttString, 19);
  AddTag(1173, 'тип коррекции', 'ТИП КОРРЕКЦИИ', ttByte, 1);
  AddTag(1174, 'основание для коррекции', 'ОСНОВАНИЕ ДЛЯ КООРЕКЦИИ', ttSTLV, 292);
  AddTag(1177, 'наименование основания для коррекции', 'НАИМЕН. ОСН. ДЛЯ КОРРЕКЦ', ttString, 256);
  AddTag(1178, 'дата документа основания для коррекции', 'ДАТА ДОК-ТА ОСН. ДЛЯ КОРРЕКЦ', ttUnixTime, 4);
  AddTag(1179, 'номер документа основания для коррекции', 'НОМЕР ДОК-ТА ОСН. ДЛЯ КОРРЕКЦ', ttString, 32);
  AddTag(1183, 'сумма расчетов без НДС', 'СУММА РАСЧ. БЕЗ НДС', ttVLN, 8);
  AddTag(1184, 'сумма коррекций без НДС', 'СУММА КОРРЕКЦ. БЕЗ НДС', ttVLN, 8);
  AddTag(1187, 'место расчетов', 'МЕСТО РАСЧЕТОВ', ttString, 256);
  AddTag(1188, 'версия ККТ', 'ВЕРСИЯ ККТ', ttString, 8);
  AddTag(1189, 'версия ФФД ККТ', 'ВЕРСИЯ ФФД ККТ', ttByte, 1);
  AddTag(1190, 'версия ФФД ФН', 'ВЕРСИЯ ФФД ФН', ttByte, 1);
  AddTag(1191, 'дополнительный реквизит предмета расчета', 'ДОП. РЕКВ. ПРЕДМ. РАСЧЕТА', ttString, 64);
  AddTag(1192, 'дополнительный реквизит чека (БСО)', 'ДОП. РЕКВ. ЧЕКА БСО', ttString, 16);
  AddTag(1193, 'признак проведения азартных игр', 'ПРИЗН. ПРОВЕД. АЗАРТН. ИГР', ttByte, 1);
  AddTag(1194, 'счетчики итогов смены', 'СЧЕТЧИКИ ИТОГОВ СМЕНЫ', ttSTLV, 708);
  AddTag(1196, 'QR-код', 'QR-КОД', ttString, 0);
  AddTag(1197, 'единица измерения предмета расчета', 'ЕД. ИЗМЕР. ПРЕДМЕТА РАСЧ.', ttString, 16);
  AddTag(1198, 'размер НДС за единицу предмета расчета', 'РАЗМ. НДС ЗА ЕД. ПРЕДМ. РАСЧ.', ttVLN, 6);
  AddTag(1199, 'ставка НДС ', 'СТАВКА НДС', ttByte, 1);
  AddTag(1200, 'сумма НДС за предмет расчета', 'СУММА НДС ЗА ПРЕДМ. РАСЧ.', ttVLN, 6);
  AddTag(1201, 'общая итоговая сумма в чеках (БСО)', 'ОБЩ. ИТОГ. СУММА В ЧЕКАХ БСО', ttVLN, 8);
  AddTag(1203, 'ИНН кассира', 'ИНН КАССИРА', ttString, 12, True);
  AddTag(1205, 'коды причин изменения сведений о ККТ', 'КОДЫ ПРИЧИНЫ ИЗМ. СВЕД. О ККТ', ttBitMask, 4);
  AddTag(1206, 'сообщение оператора', 'СООБЩ. ОПЕР.', ttBitMask, 1);
  AddTag(1207, 'признак торговли подакцизными товарами', 'ПРИЗН. ТОРГОВЛИ ПОДАКЦИЗН. ТОВАРАМИ', ttByte, 1);
  AddTag(1208, 'сайт чеков', 'САЙТ ЧЕКОВ', ttString, 256);
  AddTag(1209, 'версия ФФД', 'ВЕРСИЯ ФФД', ttByte, 1);
  AddTag(1212, 'признак предмета расчета', 'ПРИЗН. ПРЕДМЕТА РАСЧ.', ttByte, 1);
  AddTag(1213, 'ресурс ключей ФП', 'РЕСУРС КЛЮЧЕЙ ФП', ttUInt16, 2);
  AddTag(1214, 'признак способа расчета', 'ПРИЗН. СПОСОБА РАСЧ.', ttByte, 1);
  AddTag(1215, 'сумма по чеку (БСО) предоплатой (зачетом аванса))', 'СУММА ПО ЧЕКУ БСО ПРЕДОПЛ.', ttVLN, 6);
  AddTag(1216, 'сумма по чеку (БСО) постоплатой (в кредит)', 'СУММА ПО ЧЕКУ БСО ПОСТОПЛ.', ttVLN, 6);
  AddTag(1217, 'сумма по чеку (БСО) встречным предоставлением', 'СУММА ПО ЧЕКУ БСО ВСТРЕЧН. ПРЕДОСТ.', ttVLN, 6);
  AddTag(1218, 'итоговая сумма в чеках (БСО) предоплатами (авансами)', 'ИТОГ. СУММА В ЧЕКАХ БСО ПРЕДОПЛ.', ttVLN, 8);
  AddTag(1219, 'итоговая сумма в чеках (БСО) постоплатами (кредитами)', 'ИТОГ. СУММА В ЧЕКАХ БСО ПОСТОПЛ.', ttVLN, 8);
  AddTag(1220, 'итоговая сумма в чеках (БСО) встречными предоставлениями', 'ИТОГ. СУММА В ЧЕКАХ БСО ВСТРЕЧН. ПРЕДОСТ.', ttVLN, 8);
  AddTag(1221, 'признак установки принтера в автомате', 'ПРИЗН. УСТАНОВКИ ПРИНТЕРА В АВТОМАТЕ', ttByte, 1);
  AddTag(1222, 'признак агента по предмету расчета', 'ПРИЗН. АГ. ПО ПРЕДМ. РАСЧ', ttByte, 1);
  AddTag(1223, 'данные агента', 'ДАННЫЕ АГЕНТА', ttSTLV, 512);
  AddTag(1224, 'данные поставщика', 'ДАННЫЕ ПОСТАВЩИКА', ttSTLV, 512);
  AddTag(1225, 'наименование поставщика', 'НАИМЕН. ПОСТАВЩИКА', ttString, 256);
  AddTag(1226, 'ИНН поставщика', 'ИНН ПОСТАВЩИКА', ttString, 12, True);
  // ФН 1.1
  AddTag(1227, 'покупатель (клиент)', 'ПОКУПАТЕЛЬ', ttString, 128);
  AddTag(1228, 'ИНН покупателя (клиента)', 'ИНН ПОКУПАТЕЛЯ', ttString, 12, True);
  AddTag(1229, 'акциз', 'АКЦИЗ', ttVLN, 6);
  AddTag(1230, 'код страны происхождения', 'КОД СТРАНЫ', ttString, 3, True);
  AddTag(1231, 'номер декларации на товар', 'ДЕКЛАРАЦИЯ', ttString, 32);
  AddTag(1232, 'счетчики по признаку "возврат прихода"', 'СЧЕТЧ. ПО ПРИЗН. ВОЗВР.ПРИХ.', ttSTLV, 32);
  AddTag(1233, 'счетчики по признаку "возврат расхода"', 'СЧЕТЧ. ПО ПРИЗН. ВОЗВР.РАСХ.', ttSTLV, 32);

  // ФН 1.2

  AddTag(1163, 'код товара', 'КТ', ttSTLV, 64);
  AddTag(1243, 'дата рождения покупателя (клиента)', 'ДР ПОКУПАТЕЛЯ', ttString, 10, True);
  AddTag(1244, 'гражданство', 'ГРАЖДАНСТВО', ttString, 3, True); //Если код страны происхождения имеет длину меньше 3 цифр, то он дополняется справа пробелами
  AddTag(1245, 'код вида документа, удостоверяющего личность', 'КОД ВИДА ДОК. УДОСТ. ЛИЧН.', ttString, 32, True);
  AddTag(1246, 'данные документа, удостоверяющего личность', 'ДАННЫЕ ДОК. УДОСТ. ЛИЧН.', ttString, 64);
  AddTag(1254, 'адрес покупателя (клиента)', 'АДРЕС КЛИЕНТА', ttString, 256);
  AddTag(1256, 'сведения о покупателе (клиенте)', 'СВЕД. О ПОКУПАТ.', ttSTLV, 1024);
  AddTag(1260, 'отраслевой реквизит предмета расчета', 'ОТРАСЛ. РЕКВ. ПРЕДМ. РАСЧ.', ttSTLV, 302);
  AddTag(1261, 'отраслевой реквизит чека', 'ОТРАСЛ. РЕКВ. ЧЕКА', ttSTLV, 302);
  AddTag(1262, 'идентификатор ФОИВ', 'ИД. ФОИВ', ttString, 3);
  AddTag(1263, 'дата документа основания', 'ДАТА ДОК. ОСН.', ttString, 10, True);
  AddTag(1264, 'номер документа основания', 'НОМЕР ДОК. ОСН.', ttString, 32);
  AddTag(1265, 'значение отраслевого реквизита', 'ЗНАЧ. ОТР. РЕКВ.', ttString, 265);
  AddTag(1270, 'операционный реквизит чека', 'ОПЕРАЦ. РЕКВ. ЧЕКА', ttSTLV, 144);
  AddTag(1271, 'идентификатор операции', 'ИДЕНТИФ. ОПЕРАЦ.', ttByte, 1);

  AddTag(1272, 'данные операции', 'ДАННЫЕ ОПЕРАЦ.', ttString, 64);
  AddTag(1273, 'дата, время операции', 'ДАТА. ОПЕРАЦ.', ttUnixTime, 4);
  AddTag(1274, 'дополнительный реквизит ОР', 'ДОП. РЕКВ. OP', ttString, 32);
  AddTag(1275, 'дополнительные данные ОР', 'ДОП. ДАННЫЕ OP.', ttByteArray, 32);
  AddTag(1276, 'дополнительный реквизит ООС', 'дополнительный реквизит ООС', ttString, 32);
  AddTag(1277, 'дополнительные данные ООС', 'дополнительные данные ООС', ttByteArray, 32);
  AddTag(1278, 'дополнительный реквизит ОЗС', 'дополнительный реквизит ОЗС', ttString, 32);
  AddTag(1279, 'дополнительные данные ОЗС', 'дополнительные данные ОЗС', ttByteArray, 32);
  AddTag(1280, 'дополнительный реквизит ОТР', 'дополнительный реквизит ОТР	', ttString, 32);
  AddTag(1281, 'дополнительные данные ОТР', 'дополнительные данные ОТР', ttByteArray, 32);
  AddTag(1282, 'дополнительный реквизит ОЗФН', 'дополнительный реквизит ОЗФН', ttString, 32);
  AddTag(1283, 'дополнительные данные ОЗФН', 'дополнительные данные ОЗФН', ttByteArray, 32);
  AddTag(1290, 'признаки условий применения ККТ', 'признаки условий применения ККТ', ttUInt32, 1);
  AddTag(1291, 'дробное количество маркированного товара', 'дробное количество маркированного товара', ttSTLV, 52);
  AddTag(1292, 'дробная часть', 'дробная часть', ttString, 24);
  AddTag(1293, 'числитель', 'числитель', ttVLN, 8);
  AddTag(1294, 'знаменатель', 'знаменатель', ttVLN, 8);
  AddTag(1300, 'нераспознанный код товара', 'нераспознанный код товара', ttString, 32);

  AddTag(1301, 'КТ EAN-8', 'КТ EAN-8', ttString, 8, True);
  AddTag(1302, 'КТ EAN-13', 'КТ EAN-13', ttString, 13, True);
  AddTag(1303, 'КТ ITF-14', 'КТ ITF-14', ttString, 14, True);
  AddTag(1304, 'КТ GS1.0', 'КТ GS1.0', ttString, 38);
  AddTag(1305, 'КТ GS1.М', 'КТ GS1.М', ttString, 38);
  AddTag(1306, 'КТ КМК', 'КТ КМК', ttString, 38);
  AddTag(1307, 'КТ МИ', 'КТ МИ', ttString, 20, True);
  AddTag(1308, 'КТ ЕГАИС-2.0', 'КТ ЕГАИС-2.0', ttString, 33, True);
  AddTag(1309, 'КТ ЕГАИС-3.0', 'КТ ЕГАИС-3.0', ttString, 14, True);
  AddTag(1320, 'КТ Ф.1', 'КТ Ф.1', ttString, 32);
  AddTag(1321, 'КТ Ф.2', 'КТ Ф.2', ttString, 32);
  AddTag(1322, 'КТ Ф.3', 'КТ Ф.3', ttString, 32);
  AddTag(1323, 'КТ Ф.4', 'КТ Ф.4', ttString, 32);
  AddTag(1324, 'КТ Ф.5', 'КТ Ф.5', ttString, 32);
  AddTag(1325, 'КТ Ф.6', 'КТ Ф.6', ttString, 32);
  AddTag(2000, 'код маркировки', 'КМ', ttString, 256);
  AddTag(2001, 'номер запроса', 'НОМЕР ЗАПРОСА', ttUInt32, 4);
  AddTag(2002, 'номер уведомления', 'НОМЕР УВЕДОМЛ.', ttUInt32, 4);
  AddTag(2003, 'планируемый статус товара', 'ПЛАНИР. СТАТУС ТОВАРА', ttByte, 1);
  AddTag(2004, 'результат проверки КМ', 'РЕЗ-Т ПРОВЕРКИ КМ', ttByte, 1);
  AddTag(2005, 'результаты обработки запроса', 'РЕЗ-ТЫ ОБР. ЗАПРОСА', ttByte, 1);
  AddTag(2006, 'результаты обработки уведомления', 'РЕЗ-ТЫ ОБР. УВЕДОМЛ.', ttByte, 1);
  AddTag(2007, 'данные о маркированном товаре', 'ДАННЫЕ О МАРКИР. ТОВ.', ttSTLV, 512);
  AddTag(2100, 'тип кода маркировки', 'ТИП КМ', ttByte, 1);
  AddTag(2101, 'идентификатор товара', 'ИД. ТОВАРА', ttString, 34);
  AddTag(2102, 'режим обработки кода маркировки', 'РЕЖ. ОБРАБОТКИ КМ', ttByte, 1);
  AddTag(2104, 'количество непереданных уведомлений', 'НЕПЕРЕДАНО УВЕДОМЛЕНИЙ', ttUInt32, 4);
  AddTag(2105, 'коды обработки запроса', 'КОДЫ ОБР. ЗАПРОСА', ttByte, 1);
  AddTag(2106, 'результат проверки сведений о товаре', 'РЕЗ-Т ПРОВ. СВЕД. О ТОВ.', ttByte, 1);
  AddTag(2107, 'результаты проверки маркированных товаров', 'РЕЗ-ТЫ ПРОВ. СВЕД О МАРК. ТОВ', ttByte, 1);
  AddTag(2108, 'мера количества предмета расчета', 'МЕРА КОЛ-ВА ПРЕДМ. РАСЧ.', ttByte, 1);
  AddTag(2109, 'ответ ОИСМ о статусе товара', 'ОТВ. ОИСМ О СТАТ. ТОВ.', ttByte, 1);
  AddTag(2110, 'присвоенный статус товара', 'ПРИСВ. СТАТ. ТОВ.', ttByte, 1);
  AddTag(2111, 'коды обработки уведомления', 'КОДЫ ОБР. УВЕДОМЛ.', ttByte, 1);
  AddTag(2112, 'признак некорректных кодов маркировки', 'ПРИЗН. НЕКОРР. КМ', ttByte, 1);
  AddTag(2113, 'признак некорректных запросов и уведомлений', 'ПРИЗН. НЕКОРР. ЗАПР. И УВЕД.', ttByte, 1);
  AddTag(2114, 'дата и время запроса', 'ДАТА И ВР. ЗАПР.', ttUnixTime, 4);
  AddTag(2115, 'контрольный код КМ', 'КОНТРОЛЬНЫЙ КОД КМ', ttString, 4, True);






  AddTag(1000, 'Документ', 'ДОКУМЕНТ', ttStlv, 0);
  AddTag(16100, '', 'РНМ', ttString, 0);
  AddTag(16101, '', 'Номер смены', ttUInt32, 4);
  AddTag(16102, '', 'Номер ФД до', ttUInt32, 4);
  AddTag(16103, '', 'Время ФД до', ttUnixTime, 4);
  AddTag(16105, '', 'Номер ФД после', ttUInt32, 4);
  AddTag(16106, '', 'Время ФД после',  ttUnixTime, 4);
  AddTag(16104, '', 'Текст слипа', ttString, 0);





  AddTag(100, 'Параметры фискализации', 'Параметры фискализации', ttSTLV, 0);
  AddTag(101, 'Отчет о регистрации', 'Отчет о регистрации', ttSTLV, 0);
  AddTag(102, 'Отчет об открытии смены', 'Отчет об открытии смены', ttSTLV, 0);
  AddTag(103, 'Кассовый чек', 'Кассовый чек', ttSTLV, 0);
  AddTag(104, 'БСО', 'БСО', ttSTLV, 0);
  AddTag(105, 'Отчет о закрытии смены', 'Отчет о закрытии смены', ttSTLV, 0);
  AddTag(106, 'Отчет о закрытии фискального накопителя',
    'Отчет о закрытии фискального накопителя', ttSTLV, 0);
  AddTag(107, 'Подтверждение оператора', 'Подтверждение оператора', ttSTLV, 0);

  AddTag(111, 'Отчет об изменении параметров регистрации',
    'Отчет об изменении параметров регистрации', ttSTLV, 0);

  AddTag(121, 'Отчет о текущем состоянии расчетов',
    'Отчет о текущем состоянии расчетов', ttSTLV, 0);

  AddTag(131, 'Кассовый чек коррекции', 'Кассовый чек коррекции', ttSTLV, 0);

  AddTag(141, 'БСО коррекции', 'БСО коррекции', ttSTLV, 0);

  AddTag(1, 'Отчет о регистрации', 'Отчет о регистрации', ttSTLV, 0);
  AddTag(2, 'Отчет об открытии смены', 'Отчет об открытии смены', ttSTLV, 0);
  AddTag(3, 'Кассовый чек', 'Кассовый чек', ttSTLV, 0);
  AddTag(4, 'БСО', 'БСО', ttSTLV, 0);
  AddTag(5, 'Отчет о закрытии смены', 'Отчет о закрытии смены', ttSTLV, 0);
  AddTag(6, 'Отчет о закрытии фискального накопителя',
    'Отчет о закрытии фискального накопителя', ttSTLV, 0);
  AddTag(7, 'Подтверждение оператора', 'Подтверждение оператора', ttSTLV, 0);
   AddTag(11, 'Отчет об изменении параметров регистрации',
    'Отчет об изменении параметров регистрации', ttSTLV, 0);
   AddTag(21, 'Отчет о текущем состоянии расчетов',
    'Отчет о текущем состоянии расчетов', ttSTLV, 0);
   AddTag(31, 'Кассовый чек коррекции', 'Кассовый чек коррекции', ttSTLV, 0);

  AddTag(41, 'БСО коррекции', 'БСО коррекции', ttSTLV, 0);

  AddTag(81, 'Запрос о коде маркировки', 'Запрос о коде маркировки', ttSTLV, 0);
  AddTag(82, 'Уведомление о реализации маркированного товара', 'Уведомление о реализации маркированного товара', ttSTLV, 0);
  AddTag(83, 'Ответ на запрос', 'Ответ на запрос', ttSTLV, 0);
  AddTag(84, 'Квитанция на уведомление', 'Квитанция на уведомление', ttSTLV, 0);


end;

function TTLVTags.FindTag(ANumber: Integer): TTLVTag;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].Tag = ANumber then
    begin
      Result := Items[i];
      Break;
    end;
  end;
end;

{ TTLVTag }

constructor TTLVTag.Create(AOwner: TTLVTags);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TTLVTag.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

function TTLVTag.GetDescription: string;
begin
  if FDescription <> '' then
    FDescription[1] := AnsiUpperCase(FDescription[1])[1];
  Result :=  FDescription;
end;

function TTLVTag.GetStrValue(AData: string): string;
var
  saveSeparator: Char;
begin
  Result := '';
  saveSeparator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    case TagType of
      ttByte: begin
                case Tag of
                  1054: Result := CalcTypeToStr(TFormatTLV.ValueTLV2Int(AData));
                  1055, 1062: Result := TaxSystemToStr(TFormatTLV.ValueTLV2Int(AData));
                else
                  Result := IntToStr(TFormatTLV.ValueTLV2Int(AData));
                end;
              end;
      ttByteArray: begin
                     case Tag of
                       1077: Result := IntToStr(Cardinal(TFormatTLV.ValueTLV2Int(Reversestring(Copy(AData, 3, 4)))));
                     else
                       Result := StrToHex(AData);
                     end;
                   end;
      ttUInt32: Result := IntToStr(Cardinal(TFormatTLV.ValueTLV2Int(AData)));
      ttUInt16: Result := IntToStr(Cardinal(TFormatTLV.ValueTLV2Int(AData)));
      ttUnixTime: Result := DateTimeToStr(TFormatTLV.ValueTLV2UnixTime(AData));
      ttVLN: Result := Format('%.2f', [TFormatTLV.ValueTLV2VLN(AData) / 100]);
      ttFVLN: Result := TFormatTLV.ValueTLV2FVLNstr(AData);
      ttString: Result := TrimRight(TFormatTLV.ValueTLV2ASCII(AData));
    end;
  finally
    FormatSettings.DecimalSeparator := saveSeparator;
  end;
end;


procedure TTLVTag.SetOwner(AOwner: TTLVTags);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

end.
