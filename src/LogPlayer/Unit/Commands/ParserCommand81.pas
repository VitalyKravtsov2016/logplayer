unit ParserCommand81;

interface
uses
  SysUtils, CommandParser;

type
  // Buy
  TParserCommand81 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand81 }

procedure TParserCommand81.CreateAnswerFields;
begin

end;

procedure TParserCommand81.CreateFields;
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

function TParserCommand81.GetShortValue: string;
begin
  Result := Format('œŒ ”œ ¿ %sX%s %s', [GetFieldValue('Price'),
                     GetFieldValue('Quantity'),
                     GetFieldValue('StringForPrinting')]);
end;


end.

