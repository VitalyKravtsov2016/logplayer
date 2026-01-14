unit ParserCommandFF74;

interface
uses
  SysUtils, CommandParser;

type
  // FNGetImplementation
  TParserCommandFF74 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF74 }

procedure TParserCommandFF74.CreateAnswerFields;
begin
  AddAnswerField('FNImplementation', ftString);
end;

procedure TParserCommandFF74.CreateFields;
begin
end;

function TParserCommandFF74.GetShortValue: string;
begin
  Result := 'Запрос исполнения ФН';
end;

end.
