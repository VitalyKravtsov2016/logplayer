unit Utils.BinStream;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  System.SysUtils,
{$ELSE}

{$ENDIF}
  Windows, Classes,
  Fp.PrinterTypes;

type

  { IBinStream }

  IBinStream = Interface
  ['{72E2C5D5-C088-4912-8635-92B9C8B4E0F8}']
    function GetData: TBytes;
    function GetSize: Int64;
    function GetStream: TMemoryStream;
    procedure SetData(const Value: TBytes);
    function GetDataAsStr: AnsiString;
    procedure SetDataAsStr(const Value: AnsiString);
    function GetRemaining: Int64;
    function ReadByte: Byte;
    function ReadUInt16: UInt16;
    function ReadUInt32: UInt32;
    function ReadChar: AnsiChar;
    function ReadDate: TDateTime;
    function ReadTime: TDateTime;
    function ReadString: AnsiString; overload;
    function ReadString(ASize: Integer): AnsiString; overload;
    function ReadInt(ASize: Integer): Int64; overload;
    function ReadIntRev(ASize: Integer): Int64;
    procedure WriteByte(AValue: Byte);
    procedure WriteUInt16(AValue: UInt16);
    procedure WriteUInt32(AValue: UInt32);
    procedure WriteInt(AValue: Int64; ASize: Integer); overload;
    procedure WriteIntRev(AValue: Int64; ASize: Integer);
    procedure WriteString(const AData: AnsiString); overload;
    procedure WriteBytes(const AData: TBytes);
    function ReadBytes(ASize: Integer): TBytes;
    procedure WriteDate(const AData: TPrinterDate);
    procedure WriteTime(const AData: TPrinterTime);
    procedure WriteStream(AStream: TStream);
    procedure Clear;
    property Data: TBytes read GetData write SetData;
    property DataAsStr: AnsiString read GetDataAsStr write SetDataAsStr;
    property Stream: TMemorystream read GetStream;
    property Size: Int64 read GetSize;
    property Remaining: Int64 read GetRemaining;
  end;


  { TBinStream }

  TBinStream = class(TInterfacedObject, IBinStream)
  private
    FStream: TMemoryStream;
    function GetData: TBytes;
    procedure SetData(const Value: TBytes);
    function GetDataAsStr: AnsiString;
    procedure SetDataAsStr(const Value: AnsiString);
    function GetStream: TMemoryStream;
    function GetSize: Int64;
    function GetRemaining: Int64;
  public
    constructor Create(const AData: TBytes);
    destructor Destroy; override;
    function ReadByte: Byte;
    function ReadUInt16:UInt16;
    function ReadUInt32: UInt32;
    function ReadChar: AnsiChar;
    function ReadDate: TDateTime;
    function ReadTime: TDateTime;
    function ReadString: AnsiString; overload;
    function ReadString(ASize: Integer): AnsiString; overload;
    function ReadInt(ASize: Integer): Int64; overload;
    function ReadIntRev(ASize: Integer): Int64;
    procedure WriteByte(AValue: Byte);
    procedure WriteUInt16(AValue: UInt16);
    procedure WriteUInt32(AValue: UInt32);
    procedure WriteInt(AValue: Int64; ASize: Integer); overload;
    procedure WriteIntRev(AValue: Int64; ASize: Integer);
    procedure WriteString(const AData: AnsiString); overload;
    procedure WriteBytes(const AData: TBytes);
    function ReadBytes(ASize: Integer): TBytes;
    procedure WriteDate(const AData: TPrinterDate);
    procedure WriteTime(const AData: TPrinterTime);
    procedure WriteStream(AStream: TStream);
    procedure Clear;
    property Data: TBytes read GetData write SetData;
    property DataAsStr: AnsiString read GetDataAsStr write SetDataAsStr;
    property Size: Int64 read GetSize;
    property Remaining: Int64 read GetRemaining;
  end;

implementation

function Swap64(Value: Int64): Int64;
begin
  Result := swap(word(value)) shl 16 + swap(word(value shr 16)) ;
  Result := (Result shl 32) or (swap(word(value shr 32)) shl 16 + swap(word((value shr 32) shr 16)))
end;

{ TBinStream }

constructor TBinStream.Create(const AData: TBytes);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  SetData(AData);
end;

destructor TBinStream.Destroy;
begin
  FStream.Free;
  inherited;
end;

function TBinStream.GetData:TBytes;
begin
  Result := [];
  FStream.Position := 0;
  if FStream.Size > 0 then
  begin
    SetLength(Result, FStream.Size);
    FStream.Read(Result[0], FStream.Size);
  end;
end;

procedure TBinStream.SetData(const Value: TBytes);
begin
  FStream.Clear;
  if Length(Value) > 0 then
  begin
    FStream.Write(Value[0], Length(Value));
    FStream.Position := 0;
  end;
end;

function TBinStream.ReadInt(ASize: Integer): Int64;
begin
  Result := 0;
  FStream.Read(Result, ASize);
end;

function TBinStream.ReadIntRev(ASize: Integer): Int64;
begin
  Result := ReadInt(ASize);
  Result := Swap64(Result) shr ((8 - ASize) * 8);
end;

procedure TBinStream.SetDataAsStr(const Value: AnsiString);
begin
  FStream.Clear;
  if Length(Value) > 0 then
  begin
    FStream.Write(Value[1], Length(Value));
    FStream.Position := 0;
  end;
end;

function TBinStream.GetDataAsStr: AnsiString;
begin
  Result := '';
  FStream.Position := 0;
  if FStream.Size > 0 then
  begin
    SetLength(Result, FStream.Size);
    FStream.Read(Result[1], FStream.Size);
  end;
end;

function TBinStream.GetStream: TMemoryStream;
begin
  Result := FStream;
end;

function TBinStream.GetSize: Int64;
begin
  Result := FStream.Size;
end;

function TBinStream.GetRemaining: Int64;
begin
  Result := Size - FStream.Position - 1;
end;

function TBinStream.ReadByte: Byte;
begin
  FStream.Read(Result, 1);
end;

function TBinStream.ReadBytes(ASize: Integer): TBytes;
//var
  //Len: Integer;
begin
  Result := [];
  //Len := FStream.Size - FStream.Position;
  if ASize > 0 then
  begin
    SetLength(Result, ASize);
    FStream.Read(Result[0], ASize);
  end;
end;

function TBinStream.ReadUInt16: UInt16;
begin
  FStream.Read(Result, 2);
end;

function TBinStream.ReadUInt32: UInt32;
begin
  FStream.Read(Result, 4);
end;

function TBinStream.ReadChar: AnsiChar;
begin
  FStream.Read(Result, 1);
end;

function TBinStream.ReadDate: TDateTime;
var
  D: TPrinterDate;
begin
  FStream.Read(D, Sizeof(D));
  Result := EncodeDate(D.Year + 2000, D.Month, D.Day);
end;

function TBinStream.ReadTime: TDateTime;
var
  T: TPrinterTime;
begin
  FStream.Read(T, Sizeof(T));
  Result := EncodeTime(T.Hour, T.Min, T.Sec, 0);
end;

procedure TBinStream.WriteByte(AValue: Byte);
begin
  FStream.Write(AValue, 1);
end;

procedure TBinStream.WriteBytes(const AData:TBytes);
begin
  if Length(AData) > 0 then
    FStream.Write(AData[0], Length(AData));
end;

procedure TBinStream.WriteUInt16(AValue: UInt16);
begin
  FStream.Write(AValue, 2);
end;

procedure TBinStream.WriteUInt32(AValue: UInt32);
begin
  FStream.Write(AValue, 4);
end;

procedure TBinStream.WriteInt(AValue: Int64; ASize: Integer);
begin
  FStream.Write(AValue, ASize);
end;

procedure TBinStream.WriteString(const AData:AnsiString);
begin
  if Length(AData) > 0 then
    FStream.Write(AData[1], Length(AData));
end;

function TBinStream.ReadString(ASize: Integer): AnsiString;
begin
  Result := '';
  if FStream.Size > 0 then
  begin
    SetLength(Result, ASize);
    FStream.Read(Result[1], ASize);
  end;
end;

function TBinStream.ReadString: AnsiString;
var
  Len: Integer;
begin
  Result := '';
  Len := FStream.Size - FStream.Position;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FStream.Read(Result[1], Len);
  end;
end;

procedure TBinStream.WriteDate(const AData:TPrinterDate);
begin
  FStream.Write(AData, Sizeof(AData));
end;

procedure TBinStream.WriteTime(const AData:TPrinterTime);
begin
  FStream.Write(AData, Sizeof(AData));
end;

procedure TBinStream.WriteIntRev(AValue: Int64; ASize: Integer);
begin
  AValue := Swap64(AValue) shr ((8 - ASize) * 8);
  FStream.Write(AValue, ASize);
end;

procedure TBinStream.WriteStream(AStream: TStream);
var
  LData:TBytes;
begin
  if AStream.Size > 0 then
  begin
    AStream.Position := 0;
    SetLength(LData, AStream.Size);
    AStream.Read(LData[1], AStream.Size);
    WriteBytes(LData);
  end;
end;

procedure TBinStream.Clear;
begin
  FStream.Clear;
end;

end.

