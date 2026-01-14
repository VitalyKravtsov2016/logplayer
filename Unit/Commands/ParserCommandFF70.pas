unit ParserCommandFF70;

interface
uses
  SysUtils, CommandParser;

type
  // FNGetMarkingCodeWorkStatus
  TParserCommandFF70 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand70 }

procedure TParserCommandFF70.CreateAnswerFields;
begin
  AddAnswerField('MCCheckStatus', ftUInt32);
  AddAnswerField('MCNotificationStatus', ftUInt32);
  AddAnswerField('MCCommandFlags', ftUInt32);
  AddAnswerField('MCCheckResultSavedCount', ftUInt32);
  AddAnswerField('MCRealizationCount', ftUInt32);
  AddAnswerField('MCStorageSize', ftUInt32);
  AddAnswerField('MessageCount', ftUInt32);
end;

procedure TParserCommandFF70.CreateFields;
begin
end;

function TParserCommandFF70.GetShortValue: string;
begin
  Result := '«апрос статуса по работе с кодами маркировки';
end;

end.
