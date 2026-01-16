unit ShtrihProtocol2;

interface

uses
  // VCL
  Windows, SysUtils,
  // This
  BinUtils;

type
  { TShtrihFrame2 }

  TShtrihFrame2 = record
    Data: AnsiString;
    Number: Integer
  end;

  { TShtrihProtocol2 }

  TShtrihProtocol2 = class
  public
    class function Stuffing(const AStr: AnsiString): AnsiString;
    class function DeStuffing(const AStr: AnsiString; var IsFinalEsc: Boolean): AnsiString;
    class function Encode(const Frame: TShtrihFrame2): AnsiString;
    class function Decode(Data: AnsiString; var Frame: TShtrihFrame2): Boolean;
  end;

implementation

const
  STX  = #$8F;
  ESC  = #$9F;
  TSTX = #$81;
  TESC = #$83;

function UpdateCRC(CRC: Word; Value: Byte): Word;
begin
  Result := (CRC shr 8) or (CRC shl 8);
  Result := Result xor Value;
  Result := Result xor ((Result and $00FF) shr 4);
  Result := Result xor (Result shl 12);
  Result := Result xor ((Result and $00FF) shl 5);
end;

function GetCRC(const Data: AnsiString): Word;
var
  i: Integer;
begin
  Result := $FFFF;
  for i := 1 to Length(Data) do
    Result := UpdateCRC(Result, Ord(Data[i]));
end;

{ TShtrihProtocol2 }

class function TShtrihProtocol2.Stuffing(const AStr: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AStr) do
  begin
    if AStr[i] = STX then
      Result := Result + ESC + TSTX
    else
      if AStr[i] = ESC then
        Result := Result + ESC + TESC
      else
        Result := Result + AStr[i];
  end;
end;

class function TShtrihProtocol2.DeStuffing(const AStr: AnsiString; var IsFinalEsc: Boolean): AnsiString;
resourcestring
  IncorrectPacketFormat = 'Некорректный формат пакета';
var
  i: Integer;
begin
  Result := '';
  IsFinalEsc := False;
  i := 1;
  while  i <= Length(AStr) do
  begin
    if AStr[i] = ESC then
    begin
      if i = Length(AStr) then
      begin
        IsFinalEsc := True;
        Exit;
      end;
      if AStr[i + 1] = TSTX then
      begin
        Result := Result + STX;
        Inc(i);
      end
      else
        if AStr[i + 1] = TESC then
        begin
          Result := Result + ESC;
          Inc(i);
        end
        else
          raise Exception.Create(IncorrectPacketFormat);
    end
    else
      Result := Result + AStr[i];
    Inc(i);
  end;
end;


class function TShtrihProtocol2.Encode(const Frame: TShtrihFrame2): AnsiString;
var
  Len: Word;
  CRC: Word;
begin
  Result := '';
  Len := Length(Frame.Data);
  if Len = 0 then
    Result := #$00#$00
  else
    Result := IntToBin(Len + 2, 2) + IntToBin(Frame.Number, 2) + Frame.Data;
  CRC := GetCRC(Result);
  Result := STX + Stuffing(Result + IntToBin(CRC, 2));
end;

class function TShtrihProtocol2.Decode(Data: AnsiString;
  var Frame: TShtrihFrame2): Boolean;
var
  Len: Word;
  Crc: Word;
  FrameCrc: Word;
  IsFinalEsc: Boolean;
begin
  Result := Length(Data) > 4;
  if not Result then Exit;

  Result := Data[1] = STX;
  if not Result then Exit;

  Data := Copy(Data, 2, Length(Data));
  Data := Destuffing(Data, IsFinalEsc);

  Len := BinToInt(Data, 1, 2);
  Frame.Number := BinToInt(Data, 3, 2);
  Frame.Data := Copy(Data, 5, Len-2);
  FrameCrc := BinToInt(Data, Len+3, 2);
  Data := Copy(Data, 1, Length(Data)-2);
  Crc := GetCRC(Data);
  Result := Crc = FrameCrc;
end;

end.
