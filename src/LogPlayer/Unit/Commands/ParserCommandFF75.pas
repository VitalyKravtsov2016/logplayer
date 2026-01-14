unit ParserCommandFF75;

interface
uses
  SysUtils, CommandParser;

type
  // FNGetDocumentSize
  TParserCommandFF75 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF75 }

procedure TParserCommandFF75.CreateAnswerFields;
begin
  AddAnswerField('DocumentSize', ftUInt32);
  AddAnswerField('NotificationSize', ftUInt32);
end;

procedure TParserCommandFF75.CreateFields;
begin
end;

function TParserCommandFF75.GetShortValue: string;
begin
  Result := 'Запрос размера данных документа в ФН';
end;

end.
