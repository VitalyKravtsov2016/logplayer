unit ParserCommandFF73;

interface
uses
  SysUtils, CommandParser;

type
  // FNConfirmNotificationRead
  TParserCommandFF73 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF73 }

procedure TParserCommandFF73.CreateAnswerFields;
begin
end;

procedure TParserCommandFF73.CreateFields;
begin
  AddField('NotificationNumber', ftUInt32);
  AddField('CheckSum', ftUInt16);
end;

function TParserCommandFF73.GetShortValue: string;
begin
  Result := 'Подтвердить выгрузку уведомления';
end;

end.
