unit ParserCommand8E;

interface
uses
  CommandParser;
type
  // CloseCheckEx
  TParserCommand8E = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand8E }

procedure TParserCommand8E.CreateAnswerFields;
begin

end;

procedure TParserCommand8E.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Summ1', ftQuantity5);
  AddField('Summ2', ftQuantity5);
  AddField('Summ3', ftQuantity5);
  AddField('Summ4', ftQuantity5);
  AddField('DiscountOnCheck', ftUint16);
  AddField('Tax1', ftTax);
  AddField('Tax2', ftTax);
  AddField('Tax3', ftTax);
  AddField('Tax4', ftTax);
  AddField('StringForPrinting', ftString);
end;

end.

