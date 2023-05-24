unit ParserCommand17;

interface
uses
  CommandParser;
type
  // PrintString
  TParserCommand17 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommand17 }

procedure TParserCommand17.CreateAnswerFields;
begin

end;

procedure TParserCommand17.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Tape type', ftByte);
  AddField('StringForPrinting', ftString);
end;

end.

