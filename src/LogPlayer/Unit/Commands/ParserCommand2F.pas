unit ParserCommand2F;

interface
uses
  CommandParser;
type
  // PrintStringWithFont
  TParserCommand2F = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand2F }

procedure TParserCommand2F.CreateAnswerFields;
begin

end;

procedure TParserCommand2F.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Tape type', ftByte);
  AddField('FontType', ftByte);
  AddField('StringForPrinting', ftString);
end;

function TParserCommand2F.GetShortValue: string;
begin
  Result := GetFieldValue('StringForPrinting');
end;

end.

