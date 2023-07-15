unit ParserCommand89;

interface
uses
  CommandParser;
type
  // Subtotal
  TParserCommand89 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand89 }

procedure TParserCommand89.CreateAnswerFields;
begin
  AddAnswerField('OperatorNumber', ftByte);
  AddAnswerField('Summ1', ftSum);
end;

procedure TParserCommand89.CreateFields;
begin
  AddField('Password', ftUInt32);
end;

function TParserCommand89.GetShortValue: string;
begin
  Result := 'ондшрнц ' + GetAnswerFieldValue('Summ1');
end;

end.

