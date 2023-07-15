unit ParserCommandFF67;

interface
uses
  SysUtils, CommandParser;

type
  // FNSendItemBarcode
  TParserCommandFF67 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF0C }

procedure TParserCommandFF67.CreateAnswerFields;
begin

end;

procedure TParserCommandFF67.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Barcode', ftBarcode);
  AddField('OSU', ftByte);
end;

function TParserCommandFF67.GetShortValue: string;
begin
  Result := '     KM: ' + GetFieldValue('Barcode');
end;

end.

