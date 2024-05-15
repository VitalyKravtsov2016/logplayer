unit Parser;

interface
  uses
  // VCL
  sysutils,
  // This
  FormatTLV, TLVTags, DrvFRlib_tlb
  ;

type
  TParser = class
  private
    FList: TTLVTags;
    FIdent: Integer;
    FShowTagNumbers: Boolean;
    FShortDescription: Boolean;
    function GetIdent: string;
    function GetDescription (Item: TTLVTag): string;
  public
    constructor Create;
    destructor Destroy; override;
    function ParseTLV(AData: Ansistring): string;
    function DoParseTLV(AData: Ansistring): string;
    property ShowTagNumbers: Boolean read FShowTagNumbers write FShowTagNumbers;
    property ShortDescription: Boolean read FShortDescription write FShortDescription;
  end;

implementation


constructor TParser.Create;
begin
  FList := TTLVTags.Create;
  FShowTagNumbers := False;
end;

destructor TParser.Destroy;
begin
  FList.Free;
  inherited;
end;

resourcestring
  SWrongTagLength = 'Ошибка! Некорректная длина';
  SUnknownTag = 'НЕИЗВЕСТНЫЙ ТЕГ';

function TParser.DoParseTLV(AData: AnsiString): string;
var
  S: string;
  t: Integer;
  i: Integer;
  l: Integer;
  Data: string;
  Item: TTLVTag;
begin
  Result := '';
  if Length(AData) = 0 then
  begin
    Result := GetIdent + '---' + #13#10 ;
    Exit;
  end;

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
        S := S + GetIdent + IntToStr(t) + ',' + GetDescription(Item) + ': ' + SWrongTagLength
      else
        S := S + GetIdent + GetDescription(Item) + ': ' + SWrongTagLength ;
      S := S + #13#10;
      Exit;
    end;
    Data := Copy(AData, i, l);

    if ShowTagNumbers then
      S := S + GetIdent + IntToStr(t) + ',' + GetDescription(Item)
    else
      S := S + GetIdent + GetDescription(Item);
    if  Item.TagType = ttSTLV then
    begin
      Inc(FIdent);
      S := S + #13#10 + DoParseTLV(Data);
      Dec(FIdent);
    end
    else
      S := S + ': ' + Item.GetStrValue(Data) + #13#10;
    Inc(i, l);

//    if FIdent = 0 then
//      S := S + #13#10;

  end;
  Result := S;
end;

function TParser.GetDescription(Item: TTLVTag): string;
begin
  if FShortDescription then
    Result := Item.ShortDescription
  else
    Result := Item.Description;
end;

function TParser.GetIdent: string;
begin
  Result := '';
  if FIdent > 0 then
    Result := StringOfChar(' ', FIdent * 2);
end;

function TParser.ParseTLV(AData: Ansistring): string;
begin
  FIdent := 0;
  Result := DoParseTLV(AData);
end;

end.
