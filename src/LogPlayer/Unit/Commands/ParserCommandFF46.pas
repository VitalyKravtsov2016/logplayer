unit ParserCommandFF46;

interface
uses
  SysUtils, CommandParser;

type
  // FNOperation
  TParserCommandFF46 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF46 }

procedure TParserCommandFF46.CreateAnswerFields;
begin

end;

procedure TParserCommandFF46.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('CheckType', ftCheckType2);
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

function TParserCommandFF46.GetShortValue: string;
begin
  Result := Format('%s %s X %s (%s %s ) %s', [
          GetFieldValue('CheckType'),
          GetFieldValue('Price'), GetFieldValue('Quantity'),
          GetFieldValue('PaymentTypeSign'), GetFieldValue('PaymentItemSign'),
          GetFieldValue('StringForPrinting')]);
end;

end.

