unit ParserCommandFF0C;

interface
uses
  SysUtils, CommandParser;

type
  // FNSendTLV
  TParserCommandFF0C = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
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

function TParserCommandFF0C.GetShortValue: string;
begin
  Result := StringReplace(GetFieldValue('TLVData'), #13#10, ' ', [rfReplaceAll]);
end;

end.

