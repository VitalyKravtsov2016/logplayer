unit TLVParser;

interface
  uses
  // VCL
  sysutils,
  // This
  FormatTLV, TLVTags, DrvFRlib_tlb
  ;

type
  TTLVParser = class
  private
    FList: TTLVTags;
    FIdent: Integer;
    FShowTagNumbers: Boolean;
    FBaseIndent: Integer;
    function GetIdent: string;
  public
    constructor Create;
    destructor Destroy; override;
    function ParseTLV(AData: AnsiString): string;
    function DoParseTLV(AData: AnsiString): string;
    property ShowTagNumbers: Boolean read FShowTagNumbers write FShowTagNumbers;
    property BaseIndent: Integer read FBaseIndent write FBaseIndent;
  end;

implementation


constructor TTLVParser.Create;
begin
  FList := TTLVTags.Create;
  FShowTagNumbers := False;
  FBaseIndent := 0;
end;

destructor TTLVParser.Destroy;
begin
  FList.Free;
  inherited;
end;

resourcestring
  SWrongTagLength = 'Ошибка! Некорректная длина';
  SUnknownTag = 'НЕИЗВЕСТНЫЙ ТЕГ';

function TTLVParser.DoParseTLV(AData: AnsiString): string;
var
  S: string;
  t: Integer;
  i: Integer;
  l: Integer;
  Data: AnsiString;
  Item: TTLVTag;
begin
  Result := '';
  if Length(AData) < 4 then
  begin
    Result := 'TLV length error';
    Exit;
  end;

  S := '';
  i := 1;
  while i <= Length(AData) do
  begin
    t := TFormatTLV.ValueTLV2Int(Copy(AData, i, 2));
    Inc(i, 2);
    l := TFormatTLV.ValueTLV2Int(Copy(AData, i, 2));
    Inc(i, 2);

    Item := FList.FindTag(t);
    if Item = nil then
    begin
      if ShowTagNumbers then
        S := S + GetIdent + IntToStr(t) + ','+ SUnknownTag
      else
        S := S + GetIdent + SUnknownTag;
      S := S + #13#10;
      Inc(i, l);
      continue;
    end;
    if (Length(AData) - 4) < l then
    begin
      if ShowTagNumbers then
        S := S + GetIdent + IntToStr(t) + ','+Item.ShortDescription + ':' + SWrongTagLength
      else
        S := S + GetIdent + Item.ShortDescription + ':' + SWrongTagLength ;
      S := S + #13#10;
      Exit;
    end;
    Data := Copy(AData, i, l);

    if ShowTagNumbers then
      S := S + GetIdent + IntToStr(t) + ','+Item.ShortDescription
    else
      S := S + GetIdent + Item.ShortDescription;
    if  Item.TagType = ttSTLV then
    begin
      Inc(FIdent);
      S := S + #13#10 + DoParseTLV(Data);
      Dec(FIdent);
    end
    else
      S := S + ':' + Item.GetStrValue(Data) + #13#10;
    Inc(i, l);
  end;
  Result := S;
end;

function TTLVParser.GetIdent: string;
begin
  Result := StringOfChar(' ', FBaseIndent);
  if FIdent > 0 then
    Result := StringOfChar(' ', FBaseIndent) + StringOfChar(' ', FIdent);
end;

function TTLVParser.ParseTLV(AData: AnsiString): string;
begin
  FIdent := 0;
  Result := DoParseTLV(AData);
end;

end.
