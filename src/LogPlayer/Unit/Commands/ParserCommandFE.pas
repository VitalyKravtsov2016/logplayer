unit ParserCommandFE;

interface
uses
  SysUtils, CommandParser;

type
  // ServiceCommand
  TParserCommandFE = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFE }

procedure TParserCommandFE.CreateAnswerFields;
begin
end;

procedure TParserCommandFE.CreateFields;
begin
  AddField('ServiceCmd', ftServiceCmd);
end;

function TParserCommandFE.GetShortValue: string;
begin
  Result := GetFieldValue('ServiceCmd');
end;

end.

