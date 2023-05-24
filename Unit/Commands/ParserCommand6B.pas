unit ParserCommand6B;

interface
uses
  CommandParser;
type
  // GetErrorDescription
  TParserCommand6B = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand6B}

procedure TParserCommand6B.CreateAnswerFields;
begin
  AddAnswerField('ErrorDescription', ftString);
end;

procedure TParserCommand6B.CreateFields;
begin

end;

end.
