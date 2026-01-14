duLogParser;

interface

uses
  // VCL
  Windows, ActiveX, ComObj, SysUtils,
  // DUnit
  TestFramework;

type
  { TLogParserTest }

  TLogParserTest = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestParseProtocol3;
  end;

implementation

{ TLogParserTest }

procedure TLogParserTest.SetUp;
begin
end;

procedure TLogParserTest.TearDown;
begin
end;


initialization
  RegisterTest('', TLogParserTest.Suite);
end.
