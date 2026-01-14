unit ParserCommand10;

interface
uses
  CommandParser;
type
  // GetShortECRStatus
  TParserCommand10 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand11 }

procedure TParserCommand10.CreateAnswerFields;
begin
  {

   OperatorNumber := Ord(Data[1]);
  SetECRFlags(BinToInt(Data, 2, 2));
  SetECRMode(Ord(Data[4]));
  ECRAdvancedMode := Ord(Data[5]);
  QuantityOfOperations := (Ord(Data[11]) shl 8) + Ord(Data[6]);
  BatteryState := Ord(Data[7]);
  FXState := Ord(Data[8]);
  FMResultCode := Ord(Data[9]);
  EKLZResultCode := Ord(Data[10]);
  UpdateKeysResultCode := Ord(Data[10]);
  PrinterHeadTemperature := Ord(Data[12]);
  PreviousECRMode := Ord(Data[13]);
  UpdateKeysStatus := Ord(Data[14]);
  FBatteryVoltage := Round2(BatteryState / 255 * 100 * 5) / 100;
  FPowerSourceVoltage := Round2(XState * 24 / $D8 * 100) / 100;

  LastPrintResult := 0;
  if PrinterModel.CapLastPrintResult then
  begin
    LastPrintResult := Ord(Data[15]);
  end;
  }



  AddAnswerField('OperatorNumber', ftByte);
  AddAnswerField('ECRFlags', ftECRFlags);
  AddAnswerField('ECRMode', ftECRMode);
  AddAnswerField('ECRAdvancedMode', ftECRAdvancedMode);
  AddAnswerField('QuantityOfOperations (lo)', ftByte);
  AddAnswerField('BatteryVoltage', ftBatteryVoltage);
  AddAnswerField('PowerSourceVoltage', ftPowerSourceVoltage);
  AddAnswerField('FMResultCode (old)', ftByte);
  AddAnswerField('EKLZResultCode (old)', ftByte);
  AddAnswerField('UpdateKeysResultCode', ftByte);
  AddAnswerField('PrinterHeadTemperature', ftByte);
  AddAnswerField('PreviousECRMode', ftECRMode)

end;

procedure TParserCommand10.CreateFields;
begin
  AddField('Password', ftUInt32);
end;

function TParserCommand10.GetShortValue: string;
begin
  Result := GetAnswerFieldValue('ECRMode') + ' ' + GetAnswerFieldValue('ECRAdvancedMode');
end;

end.

