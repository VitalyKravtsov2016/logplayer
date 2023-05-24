unit ParserCommand2E;

interface
uses
  CommandParser;
type
  // ReadFieldStruct
  TParserCommand2E = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand2E}

procedure TParserCommand2E.CreateAnswerFields;
begin
  AddAnswerField('FieldName', ftString40);
  AddAnswerField('FieldType', ftFieldType);
end;

procedure TParserCommand2E.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TableNumber', ftByte);
  AddField('FieldNumber', ftByte);
end;

end.
