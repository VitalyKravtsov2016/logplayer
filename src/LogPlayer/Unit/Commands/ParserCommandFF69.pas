unit ParserCommandFF69;

interface
uses
  SysUtils, CommandParser;

type
  // Accept of Decline marking code
  TParserCommandFF69 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand69}

procedure TParserCommandFF69.CreateAnswerFields;
begin

end;

procedure TParserCommandFF69.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Accept or Decline', ftAcceptOrDecline);
end;

function TParserCommandFF69.GetShortValue: string;
begin
  Result := GetFieldValue('Accept or Decline');
end;

end.
