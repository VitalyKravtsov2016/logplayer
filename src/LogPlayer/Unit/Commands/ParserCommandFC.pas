unit ParserCommandFC;

interface
uses
  SysUtils, CommandParser;

type
  // GetDeviceMetrics
  TParserCommandFC = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFC }

procedure TParserCommandFC.CreateAnswerFields;
begin
{

CheckMinLength(Data, 6);
  UMajorType := Ord(Data[1]);
  UMinorType := Ord(Data[2]);
  UMajorProtocolVersion := Ord(Data[3]);
  UMinorProtocolVersion := Ord(Data[4]);
  FUModel := Ord(Data[5]);
  UCodePage := Ord(Data[6]);
  UDescription := Translate(DeviceToStr(PAnsiChar(Copy(Data, 7, 255))));

  }


  AddAnswerField('MajorType', ftByte);
  AddAnswerField('MinorType', ftByte);
  AddAnswerField('ProtocolVersion', ftByte);
  AddAnswerField('ProtocolSubVersion', ftByte);
  AddAnswerField('Model', ftByte);
  AddAnswerField('CodePage', ftByte);
  AddAnswerField('Description', ftString);
end;

procedure TParserCommandFC.CreateFields;
begin

end;

function TParserCommandFC.GetShortValue: string;
begin
  Result := Format('%s (%s)', [Trim(GetAnswerFieldValue('Description')),
                               GetAnswerFieldValue('Model')]);
end;

end.

