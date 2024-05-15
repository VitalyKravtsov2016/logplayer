program LogPlayer;

uses
  Vcl.Forms,
  fmuMain in 'Fmu\fmuMain.pas' {fmMain},
  untLogPlayer in 'Unit\untLogPlayer.pas',
  DrvFRLib_TLB in 'Unit\DrvFRLib_TLB.pas',
  untCommand in 'Unit\untCommand.pas',
  LogParser in 'Unit\LogParser.pas',
  DriverCommands in 'Unit\DriverCommands.pas',
  BinUtils in 'Unit\BinUtils.pas',
  NotifyThread in 'Unit\NotifyThread.pas',
  VersionInfo in 'Unit\VersionInfo.pas',
  CommandParser in 'Unit\CommandParser.pas',
  Fp.PrinterTypes in 'Unit\Fp.PrinterTypes.pas',
  Utils.BinStream in 'Unit\Utils.BinStream.pas',
  TLVTags in 'Unit\TLVTags.pas',
  Parser in 'Unit\Parser.pas',
  untUtils in 'Unit\untUtils.pas',
  FormatTLV in 'Unit\FormatTLV.pas',
  TLVParser in 'Unit\TLVParser.pas',
  ParserCommandFF45 in 'Unit\Commands\ParserCommandFF45.pas',
  ParserCommandFF46 in 'Unit\Commands\ParserCommandFF46.pas',
  ParserCommandFF0C in 'Unit\Commands\ParserCommandFF0C.pas',
  ParserCommand17 in 'Unit\Commands\ParserCommand17.pas',
  ParserCommand2F in 'Unit\Commands\ParserCommand2F.pas',
  ParserCommand11 in 'Unit\Commands\ParserCommand11.pas',
  PrinterTypes in '..\drvfr5\Source\DrvFR\Units\PrinterTypes.pas',
  DriverTypes in '..\drvfr5\Source\Shared\DriverTypes.pas',
  GlobalConst in '..\drvfr5\Source\Shared\GlobalConst.pas',
  TextEncoding in '..\drvfr5\Source\DrvFR\Units\TextEncoding.pas',
  LangUtils in '..\drvfr5\Source\DrvFRTst\Units\LangUtils.pas',
  FileUtils in '..\drvfr5\Source\Shared\FileUtils.pas',
  ParserCommand10 in 'Unit\Commands\ParserCommand10.pas',
  ParserCommandFC in 'Unit\Commands\ParserCommandFC.pas',
  ParserCommand8D in 'Unit\Commands\ParserCommand8D.pas',
  ParserCommand1E in 'Unit\Commands\ParserCommand1E.pas',
  ParserCommand1F in 'Unit\Commands\ParserCommand1F.pas',
  ParserCommand2D in 'Unit\Commands\ParserCommand2D.pas',
  ParserCommand2E in 'Unit\Commands\ParserCommand2E.pas',
  ParserCommand6B in 'Unit\Commands\ParserCommand6B.pas',
  ParserCommand80 in 'Unit\Commands\ParserCommand80.pas',
  ParserCommand81 in 'Unit\Commands\ParserCommand81.pas',
  ParserCommand82 in 'Unit\Commands\ParserCommand82.pas',
  ParserCommand83 in 'Unit\Commands\ParserCommand83.pas',
  ParserCommand85 in 'Unit\Commands\ParserCommand85.pas',
  ParserCommand89 in 'Unit\Commands\ParserCommand89.pas',
  ParserCommand8E in 'Unit\Commands\ParserCommand8E.pas',
  ParserCommandFF67 in 'Unit\Commands\ParserCommandFF67.pas',
  ParserCommandFF61 in 'Unit\Commands\ParserCommandFF61.pas',
  ParserCommandFF69 in 'Unit\Commands\ParserCommandFF69.pas',
  LogFile in '..\drvfr5\Source\Shared\LogFile.pas',
  untFileUtil in 'Unit\untFileUtil.pas',
  ParserCommandFF01 in 'Unit\Commands\ParserCommandFF01.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
