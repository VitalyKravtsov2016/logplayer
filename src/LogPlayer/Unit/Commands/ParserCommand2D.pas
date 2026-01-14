unit ParserCommand2D;

interface
uses
  CommandParser;
type
  // ReadTableStruct
  TParserCommand2D = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand2D}

procedure TParserCommand2D.CreateAnswerFields;
begin
  AddAnswerField('TableName', ftString40);
  AddAnswerField('RowCount', ftUInt16);
  AddAnswerField('FieldCount', ftByte);
end;

procedure TParserCommand2D.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TableNumber', ftByte);
end;

end.
