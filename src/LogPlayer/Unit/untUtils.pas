unit untUtils;

interface
uses
  Windows, SysUtils, Forms, Classes, Controls, Registry, Consts, ComObj, Math;

type
  TVersionInfo = record
    MajorVersion: WORD;
    MinorVersion: WORD;
    ProductRelease: WORD;
    ProductBuild: WORD;
  end;

function HexToStr(const Data: string): AnsiString;
function GetFileVersionInfo: TVersionInfo;
function GetFileVersionInfoStr: string;
function ReadFileData(const FileName: string): AnsiString;
function BinToInt(const S: AnsiString; Index, Count: Integer): Int64;


implementation

function HexToStr(const Data: string): AnsiString;
var
  S: string;
  i: Integer;
  V, Code: Integer;
begin
  S := '';
  Result := '';
  for i := 1 to Length(Data) do
  begin
    S := Trim(S + Data[i]);
    if (Length(S) <> 0)and((Length(S) = 2)or(Data[i] = ' ')) then
    begin
      Val('$' + S, V, Code);
      if Code <> 0 then Exit;
      Result := Result + AnsiChar(V);
      S := '';
    end;
  end;
  // последний символ
  if Length(S) <> 0 then
  begin
    Val('$' + S, V, Code);
    if Code <> 0 then Exit;
    Result := Result + AnsiChar(V);
  end;
end;


function GetFileVersionInfo: TVersionInfo;
var
  hVerInfo: THandle;
  hGlobal: THandle;
  AddrRes: pointer;
  Buf: array[0..7]of byte;
begin
  Result.MajorVersion := 0;
  Result.MinorVersion := 0;
  Result.ProductRelease := 0;
  Result.ProductBuild := 0;

  hVerInfo:= FindResource(hInstance, '#1', RT_VERSION);
  if hVerInfo <> 0 then
  begin
    hGlobal := LoadResource(hInstance, hVerInfo);
    if hGlobal <> 0 then
    begin
      AddrRes:= LockResource(hGlobal);
      try
        CopyMemory(@Buf, Pointer(Integer(AddrRes)+48), 8);
        Result.MinorVersion := Buf[0] + Buf[1]*$100;
        Result.MajorVersion := Buf[2] + Buf[3]*$100;
        Result.ProductBuild := Buf[4] + Buf[5]*$100;
        Result.ProductRelease := Buf[6] + Buf[7]*$100;
      finally
        FreeResource(hGlobal);
      end;
    end;
  end;
end;

function GetFileVersionInfoStr: string;
var
  vi: TVersionInfo;
begin
  vi := GetFileVersionInfo;
  Result := Format('%d.%d.%d.%d', [vi.MajorVersion, vi.MinorVersion,
    vi.ProductRelease, vi.ProductBuild]);
end;

function ReadFileData(const FileName: string): AnsiString;
var
  Stream: TFileStream;
begin
  Result := '';
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    if Stream.Size > 0 then
    begin
      SetLength(Result, Stream.Size);
      Stream.Read(Result[1], Stream.Size);
    end;
  finally
    Stream.Free;
  end;
end;

function BinToInt(const S: AnsiString; Index, Count: Integer): Int64;
var
  N: Integer;
begin
  Result := 0;
  if (Index > 0)and(Index <= Length(S)) then
  begin
    N := Min(Length(S)-Index + 1, 8);
    if Count <= N then
    begin
      Move(S[Index], Result, Count);
    end;
  end;
end;


end.
