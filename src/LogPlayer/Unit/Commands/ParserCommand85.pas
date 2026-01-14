unit ParserCommand85;

interface
uses
  SysUtils, CommandParser;

type
  // CloseCheck
  TParserCommand85 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand85 }

procedure TParserCommand85.CreateAnswerFields;
begin
  AddAnswerField('OperatorNumber', ftByte);
  AddAnswerField('Change', ftSum);
end;

procedure TParserCommand85.CreateFields;
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

function TParserCommand85.GetShortValue: string;
begin
  Result := '«¿ –€“»≈ ◊≈ ¿';
end;

end.

