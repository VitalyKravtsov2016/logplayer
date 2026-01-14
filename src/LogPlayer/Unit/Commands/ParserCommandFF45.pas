unit ParserCommandFF45;

interface
uses
  SysUtils, CommandParser;

type
  // FNCloseCheckEx
  TParserCommandFF45 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF45 }

procedure TParserCommandFF45.CreateAnswerFields;
begin
//Сдача (5 байт)
//Номер ФД (4 байта)
//Фискальный признак (4 байта)
//Дата и время (5 байт) DATE_TIME3
  AddAnswerField('Change', ftSum);
  AddAnswerField('DocumentNumber', ftUInt32);
  AddAnswerField('FiscalSign', ftUInt32);
 // AddAnswerField('Date Time', ftDateTime);
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

function TParserCommandFF45.GetShortValue: string;
begin
  Result := Format('ЗАКРЫТИЕ ЧЕКА [ДОК: %s] [ФП: %s]  ', [GetAnswerFieldValue('DocumentNumber'), GetAnswerFieldValue('FiscalSign')]);
end;

end.
