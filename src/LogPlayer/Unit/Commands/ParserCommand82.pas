unit ParserCommand82;

interface
uses
  SysUtils, CommandParser;

type
  // ReturnSale
  TParserCommand82 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand82 }

procedure TParserCommand82.CreateAnswerFields;
begin

end;

procedure TParserCommand82.CreateFields;
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

function TParserCommand82.GetShortValue: string;
begin
  Result := Format('ÂÎÇÂÐÀÒ ÏÐÎÄÀÆÈ %sX%s %s', [GetFieldValue('Price'),
                     GetFieldValue('Quantity'),
                     GetFieldValue('StringForPrinting')]);
end;

end.

