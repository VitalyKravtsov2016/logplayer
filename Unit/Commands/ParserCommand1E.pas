unit ParserCommand1E;

interface
uses
  SysUtils, CommandParser;

type
  // WriteTable
  TParserCommand1E = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand1E}

procedure TParserCommand1E.CreateAnswerFields;
begin
end;

procedure TParserCommand1E.CreateFields;
begin
  AddField('Password', ftUInt32);
  AddField('TableNumber', ftByte);
  AddField('Row', ftUInt16);
  AddField('Field', ftByte);
  AddField('Value', ftTableValue);
end;

function TParserCommand1E.GetShortValue: string;
begin
  Result := Format('Запись Т%sР%sП%s = %s', [
  GetFieldValue('TableNumber'), GetFieldValue('Row'), GetFieldValue('Field'), GetFieldValue('Value')
  ]);
end;

end.
