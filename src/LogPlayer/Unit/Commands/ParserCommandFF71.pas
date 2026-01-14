unit ParserCommandFF71;

interface
uses
  SysUtils, CommandParser;

type
  // FNBeginReadNotifications
  TParserCommandFF71 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF71 }

procedure TParserCommandFF71.CreateAnswerFields;
begin
  AddAnswerField('NotificationCount', ftUInt32);
  AddAnswerField('NotificationNumber', ftUInt32);
  AddAnswerField('NotificationSize', ftUInt32);
end;

procedure TParserCommandFF71.CreateFields;
begin
end;

function TParserCommandFF71.GetShortValue: string;
begin
  Result := 'Начать выгрузку уведомлений  о реализации маркированных товаров';
end;

end.
