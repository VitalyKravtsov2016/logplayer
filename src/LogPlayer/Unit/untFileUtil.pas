unit untFileUtil;

interface

uses
  System.Classes, System.SysUtils;

procedure LoadFromFile2v1(filename: string; myencoding: TEncoding; MyStringList: TStringlist);

procedure LoadFromFile2v2(filename: string; myencoding: TEncoding; MyStringList: TStringlist);

implementation

// Version2

procedure LoadFromFile2v1(filename: string; myencoding: TEncoding; MyStringList: TStringlist);
var
  FS: TFileStream;
  SR: TStreamReader;
begin
  //MyStringList.LoadFromFile(filename); // Maximum 35526 line!!!
  FS := TFileStream.Create(filename, fmOpenRead or fmShareDenyNone);
  try
    SR := TStreamReader.Create(FS, myencoding, true);
    try
      MyStringList.BeginUpdate;
      try
        MyStringList.Clear;
        while not SR.EndOfStream do
          MyStringList.Add(SR.ReadLine);
      finally
        MyStringList.EndUpdate;
      end;
    finally
      SR.Free;
    end;
  finally
    FS.Free;
  end;
end;

// Version1
procedure LoadFromFile2v2(filename: string; myencoding: TEncoding; MyStringList: TStringlist);
var
  Reader: TStreamReader;
begin
  //MyStringList.LoadFromFile(filename); // Maximum 35526 line!!!
  Reader := TStreamReader.Create(filename, myencoding, true);
  try
    MyStringList.BeginUpdate;
    try
      //MyStringList.Clear;
      while not Reader.EndOfStream do
        MyStringList.Add(Reader.ReadLine);
    finally
      MyStringList.EndUpdate;
    end;
  finally
    Reader.Free;
  end;
end;

end.

