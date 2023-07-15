unit ParserCommand80;

interface
uses
  SysUtils, CommandParser;

type
  // Sale
  TParserCommand80 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand80 }

procedure TParserCommand80.CreateAnswerFields;
begin

end;

procedure TParserCommand80.CreateFields;
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

function TParserCommand80.GetShortValue: string;
begin
  Result := Format('ÏÐÎÄÀÆÀ %sX%s %s', [GetFieldValue('Price'),
                     GetFieldValue('Quantity'),
                     GetFieldValue('StringForPrinting')]);
end;

end.

