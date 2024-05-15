unit ParserCommandFF01;

interface

uses
  SysUtils, CommandParser;

type
  // FNSendTLV
  TParserCommandFF01 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommandFF01 }

procedure TParserCommandFF01.CreateAnswerFields;
begin
  AddAnswerField('FNLifeState', ftFNLifeState);
  AddAnswerField('FNCurrentDocument', ftFNCurrentDocument);
  AddAnswerField('FNDocumentData', ftFNDocumentData);
  AddAnswerField('FNSessionState', ftFNSessionState);
  AddAnswerField('FNWarningFlags', ftByte);
  AddAnswerField('ECRDate', ftDateTimeDoc);
  AddAnswerField('SerialNumber', ftString16);
  AddAnswerField('DocumentNumber', ftUInt32);
end;

procedure TParserCommandFF01.CreateFields;
begin
  AddField('Password', ftUInt32);
end;

function TParserCommandFF01.GetShortValue: string;
begin
  Result := 'SN: ' + GetAnswerFieldValue('SerialNumber');
end;

end.

