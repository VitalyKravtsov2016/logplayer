unit ShtrihProtocol1;

interface

uses
  // VCL
  Windows, SysUtils;

const
  STX = #2;
  ENQ = #5;
  ACK = #6;
  NAK = #21;

type
  { TShtrihProtocol1 }

  TShtrihProtocol1 = class
  public
    class function GetCRC(const Data: AnsiString): Byte;
    class function Encode(const Data: AnsiString): AnsiString;
    class function Decode(var Frame, Data: AnsiString): Boolean;
  end;

implementation

{ Вычисление CRC кадра }

class function TShtrihProtocol1.GetCRC(const Data: AnsiString): Byte;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(Data) do
    Result := Result xor Ord(Data[i]);
end;

class function TShtrihProtocol1.Encode(const Data: AnsiString): AnsiString;
var
  DataLen: Integer;
begin
  DataLen := Length(Data);
  Result := AnsiChar(DataLen) + Data;
  Result := STX + Result + AnsiChar(GetCRC(Result));
end;

class function TShtrihProtocol1.Decode(var Frame, Data: AnsiString): Boolean;
var
  CRC: Word;
  DataLen: Integer;
begin
  Result := Frame[1] = STX;
  if not Result then Exit;

  DataLen := Ord(Frame[2]);
  Data := Copy(Frame, 2, DataLen + 1);
  CRC := GetCRC(Data);
  Result := CRC = Ord(Frame[DataLen + 3]);
  if not Result then Exit;

  Data := Copy(Data, 2, Length(Data));
  Frame := Copy(Frame, DataLen + 4, Length(Frame));
end;

end.

