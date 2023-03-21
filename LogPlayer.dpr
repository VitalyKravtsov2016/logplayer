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
  TLVParser in 'Unit\TLVParser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
