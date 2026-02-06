unit ShtrihProtocol3;

interface

uses
  // VCL
  Windows, SysUtils,
  // This
  BinUtils;

const
  PSEL = #$90;
  PCF = #$91;
  STP = #$82;

type
  { TShtrihFrame3 }

  TShtrihFrame3 = record
    Data: AnsiString;
    Number: Integer
  end;

  { TShtrihProtocol3 }

  TShtrihProtocol3 = class
  public
    class function GetCRC(const Data: AnsiString): Word;
    class function Encode(const Frame: TShtrihFrame3): AnsiString;
    class function Decode(Data: AnsiString; var Frame: TShtrihFrame3): Boolean;
  end;

implementation

{ Вычисление CRC кадра }

class function TShtrihProtocol3.GetCRC(const Data: AnsiString): Word;
var
  i: Integer;
  j: Integer;
begin
  Result := $FFFF;
  for i := 1 to Length(Data) do
  begin
    Result := Result xor (Byte(Data[i]) shl 8);
    for j := 0 to 7 do
    begin
      if (Result and $8000) <> 0 then
        Result := (Result shl 1) xor $8005
      else
        Result := Result shl 1;
    end;
  end;
end;

class function TShtrihProtocol3.Encode(const Frame: TShtrihFrame3): AnsiString;
var
  Len: Word;
  CRC: Word;
begin
  Result := '';
  Len := Length(Frame.Data);
  Result := #$00 + AnsiChar(Frame.Number) + AnsiChar(Lo(Len)) + AnsiChar(Hi(Len)) + Frame.Data;
  CRC := GetCRC(Result);
  Result := STP + Result + AnsiChar(Lo(CRC)) + AnsiChar(Hi(CRC));
end;

class function TShtrihProtocol3.Decode(Data: AnsiString;
  var Frame: TShtrihFrame3): Boolean;
var
  Len: Word;
  Crc: Word;
  FrameCrc: Word;
  IsFinalEsc: Boolean;
begin
  Result := Length(Data) > 4;
  if not Result then Exit;

  Result := Data[1] = STP;
  if not Result then Exit;

  Frame.Number := BinToInt(Data, 3, 1);
  Len := BinToInt(Data, 4, 2);
  Result := Length(Data) >= (Len + 7);
  if not Result then Exit;

  Frame.Data := Copy(Data, 6, Len);
  FrameCrc := BinToInt(Data, Len + 6, 2);
  Data := Copy(Data, 2, Len + 4);
  Crc := GetCRC(Data);
  Result := Crc = FrameCrc;
end;

end.

