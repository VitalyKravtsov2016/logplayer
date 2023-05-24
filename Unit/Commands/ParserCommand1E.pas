unit ParserCommand1E;

interface
uses
  CommandParser;
type
  // WriteTable
  TParserCommand1E = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand1E}

procedure TParserCommand1E.CreateAnswerFields;
begin
end;

procedure TParserCommand1E.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TableNumber', ftByte);
  AddField('Row', ftUInt16);
  AddField('Field', ftByte);
  AddField('Value', ftTableValue);
end;

end.
