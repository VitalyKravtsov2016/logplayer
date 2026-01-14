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

{ TParserCommand67}

procedure TParserCommandFF67.CreateAnswerFields;
begin
  AddAnswerField('MarkingType', ftMarkingType);
  AddAnswerField('MarkingTypeEx', ftMarkingTypeEx);
  AddAnswerField('KM Server Answer', ftKMSendAnswer);
end;

procedure TParserCommandFF67.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('Barcode', ftBarcodeOSU);
end;

function TParserCommandFF67.GetShortValue: string;
begin
  Result := '[M] ' + GetFieldValue('Barcode');
end;

end.
