unit LangUtils;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Registry, IniFiles, ShlObj,
  // gnugettext
  jvgnugettext,
  // This
  FileUtils;

function GetLanguage: string;
function GetRes(Value: PResStringRec): WideString;
procedure SetLanguage(const Language: string);
function GetText(Value: PResStringRec): WideString;
function GetLanguageParamsFileName: string;
function GetUserPath: string;

implementation
var
  GLanguage: string = '';

const
  LangParamsFileName = 'locale.ini';

// Посколько resourcestrings в Delphi 7 не юникодные,
// получаем таким способом
function GetRes(Value: PResStringRec): WideString;
begin
  Result := LoadResStringW(Value);
end;

function GetUserPath: string;
begin
  SetLength(Result, MAX_PATH);
  ShlObj.SHGetSpecialFolderPath(0, @Result[1], CSIDL_APPDATA, false);
  SetLength(Result, Pos(#0, Result)-1);

  Result := IncludeTrailingBackSlash(Result) + 'TorgBalance';
  if not DirectoryExists(Result) then
    CreateDir(Result);
  Result := Result + '\DrvFR';
  if not DirectoryExists(Result) then
    CreateDir(Result);
end;

function GetLanguageParamsFileName: string;
begin
  Result := IncludeTrailingBackslash(GetUserPath) + LangParamsFileName;
end;

function GetText(Value: PResStringRec): WideString;
begin
  Result := LoadResStringW(Value);
end;

function GetModuleFileName: string;
var
  Buffer: array[0..261] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFileName(HInstance,
    Buffer, SizeOf(Buffer)));
end;

function GetLanguage: string;
var
  F: TIniFile;
begin
  if GLanguage <> '' then
  begin
    Result := GLanguage;
    Exit;
  end;
  if FileExists(GetLanguageParamsFileName) then
  begin
    F := TIniFile.Create(GetLanguageParamsFileName);
    try
      Result := F.ReadString('Locale', 'Lang', 'RU');
    finally
      F.Free;
    end;
    if (Result <> 'RU') and (Result <> 'EN') then
      Result := 'RU';
  end
  else
    Result := 'RU';
  GLanguage := Result;
end;

procedure SetLanguage(const Language: string);
var
  F: TIniFile;
begin
  F := TIniFile.Create(GetLanguageParamsFileName);
  try
  finally
    F.WriteString('Locale', 'Lang', Language);
  end;
end;

end.
