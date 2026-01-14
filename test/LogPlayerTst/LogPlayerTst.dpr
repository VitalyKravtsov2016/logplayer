program LogPlayerTst;
uses
  Forms,
  TestFramework,
  GUITestRunner,
  duLogParser in 'Units\duLogParser.pas';

{$R *.RES}

begin
  TGUITestRunner.RunTest(RegisteredTests);
end.
