unit ParserCommand8D;

interface
uses
  CommandParser;
type
  // OpenCheck
  TParserCommand8D = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand8D }

procedure TParserCommand8D.CreateAnswerFields;
begin
  AddAnswerField('OperatorNumber', ftByte);
end;

procedure TParserCommand8D.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('CheckType', ftCheckType);
end;

end.
