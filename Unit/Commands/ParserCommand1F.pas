unit ParserCommand1F;

interface
uses
  SysUtils, CommandParser;

type
  // ReadTable
  TParserCommand1F = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand1F}

procedure TParserCommand1F.CreateAnswerFields;
begin
  AddAnswerField('Value', ftTableValue);
end;

procedure TParserCommand1F.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TableNumber', ftByte);
  AddField('Row', ftUInt16);
  AddField('Field', ftByte);
end;

function TParserCommand1F.GetShortValue: string;
begin
  Result := Format('Чтение T%sР%sП%s = %s', [GetFieldValue('TableNumber'),
                       GetFieldValue('Row'),
                       GetFieldValue('Field'),
                       StringReplace(GetAnswerFieldValue('Value'), #13#10, ' ', [rfReplaceAll])]);

end;

end.
