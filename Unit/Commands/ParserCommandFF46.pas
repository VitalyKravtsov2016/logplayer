unit ParserCommandFF46;

interface
uses
  CommandParser;
type
  // FNOperation
  TParserCommandFF46 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
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

end.

