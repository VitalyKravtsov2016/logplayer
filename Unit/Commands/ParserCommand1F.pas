unit ParserCommand1F;

interface
uses
  CommandParser;
type
  // ReadTable
  TParserCommand1F = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand1F}

procedure TParserCommand1F.CreateAnswerFields;
begin
  AddAnswerField('Value (HEX)', ftTableValue);
end;

procedure TParserCommand1F.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TableNumber', ftByte);
  AddField('Row', ftUInt16);
  AddField('Field', ftByte);

end;

end.
