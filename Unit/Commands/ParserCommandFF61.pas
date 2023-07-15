unit ParserCommandFF61;

interface
uses
  SysUtils, CommandParser;

type
  // FNCheckItemBarcode
  TParserCommand61 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand61}

procedure TParserCommand61.CreateAnswerFields;
begin
{
CheckItemLocalResult := BinToInt(Data, 1, 1); //Статус  локальной проверки
  CheckItemLocalError := BinToInt(Data, 2, 1); //ричина, по которой не была проведена локальная проверка	В соответствии с таблицей 123
  MarkingType2 := BinToInt(Data, 3, 1); //Распознанный тип КМ	Тег 2100
  AddLength := BinToInt(Data, 4, 1);
  KMServerErrorCode := -1;
  KMServerCheckingStatus := -1;
  TLVData := '';
  if AddLength > 0 then
  begin
    KMServerErrorCode := BinToInt(Data, 5, 1);    // Код ответа ФН на команду онлайн-проверки	В соответствии и вводом ошибки ФН.
                                                  // Если 0x20, то в следующем байте возвращается причина в соответствии с таблицей 130 протокола ККТ-ФНМ.
                                                  // 0xFF Если сервер не ответил в течении таймаута.

    if (AddLength > 1) and ((KMServerErrorCode = 0) or (KMServerErrorCode = $20)) then
      KMServerCheckingStatus := BinToInt(Data, 6, 1); // Результат проверки КМ 	Тег 2106	Только если сервер ответил без ошибок

    if (AddLength > 2) and (KMServerErrorCode = 0) then

}
  AddAnswerField('CheckItemLocalResult', ftByte);
  AddAnswerField('CheckItemLocalError', ftByte);
  AddAnswerField('MarkingType2', ftByte);
  AddAnswerField('KMAnswer', ftKMAnswer);


end;

procedure TParserCommand61.CreateFields;
begin
{//    Result := Send(#$FF#$61 + FPassw +
AnsiChar(ItemStatus) +
Char(CheckItemMode) +
AnsiChar(Length(LBarcode)) +
AnsiChar(Length(TLVData)) +
LBarcode +
TLVData);}
  AddField('Password', ftUInt32);
  AddField('CheckItemMode', ftByte);
  AddField('Barcode', ftBarcodeTLV);
end;

function TParserCommand61.GetShortValue: string;
begin
 { Result := Format('Запись Т%sР%sП%s = %s', [
  GetFieldValue('TableNumber'), GetFieldValue('Row'), GetFieldValue('Field'), GetFieldValue('Value')
  ]);}
end;

end.
