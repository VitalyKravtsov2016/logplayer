unit ParserCommandFF0C;

interface
uses
  CommandParser;
type
  // FNSendTLV
  TParserCommandFF0C = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
  end;

implementation

{ TParserCommandFF0C }

procedure TParserCommandFF0C.CreateAnswerFields;
begin

end;

procedure TParserCommandFF0C.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TLVData', ftTLV);
end;


end.

