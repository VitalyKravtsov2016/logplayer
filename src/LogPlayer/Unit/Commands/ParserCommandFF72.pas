unit ParserCommandFF72;

interface
uses
  SysUtils, CommandParser;

type
  // FNReadNotificationBlock
  TParserCommandFF72 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF72 }

procedure TParserCommandFF72.CreateAnswerFields;
begin
  AddAnswerField('NotificationNumber', ftUInt32);
  AddAnswerField('NotificationSize', ftUInt32);
  AddAnswerField('DataOffset', ftUInt32);
  AddAnswerField('DataBlockSize', ftUInt32);
  AddAnswerField('BlockDataHex', ftString);
end;

procedure TParserCommandFF72.CreateFields;
begin
end;

function TParserCommandFF72.GetShortValue: string;
begin
  Result := 'Прочитать блок уведомления';
end;

end.
