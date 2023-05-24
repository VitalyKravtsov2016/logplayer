unit ParserCommand8B;

interface
uses
  CommandParser;
type
  // OpenCheck
  TParserCommand8B = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand8B }

procedure TParserCommand8B.CreateAnswerFields;
begin
  AddAnswerField('OperatorNumber', ftByte);
end;

procedure TParserCommand8B.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('CheckType', ftCheckType);
end;

end.
