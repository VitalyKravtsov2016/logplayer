unit Fp.PrinterTypes;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

type

  { TPrinterDate }

  TPrinterDate = packed record
    Day: Byte;
    Month: Byte;
    Year: Byte;
  end;

  { TPrinterTime }

  TPrinterTime = packed record
    Hour: Byte;
    Min: Byte;
    Sec: Byte;
  end;

  { TPrinterDateTime }

  TPrinterDateTime = packed record
    Day: Byte;
    Month: Byte;
    Year: Byte;
    Hour: Byte;
    Min: Byte;
    Sec: Byte;
  end;


  { TCommandRec }

  TCommandRec = packed record
    Name: AnsiString;
    Command: AnsiString;
    Answer: AnsiString;
    Timeout: Integer;
    TxData: AnsiString;
    RxData: AnsiString;
  end;


implementation

end.
