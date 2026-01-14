unit ParserCommand83;

interface
uses
  SysUtils, CommandParser;

type
  // ReturnBuy
  TParserCommand83 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand83 }

procedure TParserCommand83.CreateAnswerFields;
begin

end;

procedure TParserCommand83.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Quantity', ftQuantity5);
  AddField('Price', ftSum);
  AddField('Department', ftByte);
  AddField('Tax1', ftTax);
  AddField('Tax2', ftTax);
  AddField('Tax3', ftTax);
  AddField('Tax4', ftTax);
  AddField('StringForPrinting', ftString);
end;

function TParserCommand83.GetShortValue: string;
begin
  Result := Format('¬Œ«¬–¿“ œŒ ”œ » %sX%s %s', [GetFieldValue('Price'),
                     GetFieldValue('Quantity'),
                     GetFieldValue('StringForPrinting')]);
end;

end.

