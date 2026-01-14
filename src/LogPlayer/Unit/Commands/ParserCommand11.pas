unit ParserCommand11;

interface
uses
  CommandParser;
type
  // GetECRStatus
  TParserCommand11 = class(TParserCommand)
  public
    procedure CreateFields; override;
    procedure CreateAnswerFields; override;
    function GetShortValue: string; override;
  end;

implementation

{ TParserCommand11 }

procedure TParserCommand11.CreateAnswerFields;
begin
 // MinLen := 46;
{  if PrinterModel.CapCashCore then
    Inc(MinLen, 2);
  if PrinterModel.CapSKNO then
    Inc(MinLen, 2);
  if (PrinterModel.LongSerialDigitCount > 0) and ((UMajorProtocolVersion > 1) or ((UMinorProtocolVersion >= 13) and (UMajorProtocolVersion = 1))) then
    Inc(MinLen, 2);
  CheckMinLength(Data, MinLen); }
  AddAnswerField('OperatorNumber', ftByte);
  AddAnswerField('FECRSoftVersion', ftSoftVersion);
  //OperatorNumber := Ord(Data[1]);
  //FECRSoftVersion := Data[2] + '.' + Data[3];
  AddAnswerField('ECRBuild', ftUint16);
  AddAnswerField('FECRSoftDate', ftDate);
  //ECRBuild := BinToInt(Data, 4, 2);
  //FECRSoftDate := Str2Date(Data, 6);
  //ECRSoftDateInt := Str2EcrDate(Data, 6);
  AddAnswerField('LogicalNumber', ftByte);
  //FLogicalNumber := Ord(Data[9]);
  AddAnswerField('DocumentNumber', ftUInt16);
  //DocumentNumber := BinToInt(Data, 10, 2);
  AddAnswerField('ECRFlags', ftECRFlags);
  //SetECRFlags(BinToInt(Data, 12, 2));
  AddAnswerField('ECRMode', ftECRMode);
  //SetECRMode(Ord(Data[14]));
  AddAnswerField('ECRAdvancedMode', ftECRAdvancedMode);
  //ECRAdvancedMode := Ord(Data[15]);
  AddAnswerField('PortNumber', ftPortNumber);
  //PortNumber := Ord(Data[16]);
  AddAnswerField('FMSoftVersion (Old)', ftSoftVersion);
  //FFMSoftVersion := Data[17] + '.' + Data[18];
  AddAnswerField('FMBuild (Old)', ftUInt16);
  //FFMBuild := BinToInt(Data, 19, 2);
  AddAnswerField('FMSoftDate (Old)', ftDate);
  //FFMSoftDate := Str2Date(Data, 21);
  AddAnswerField('ECRDate', ftDate);
  //ECRDate := Str2Date(Data, 24);
  AddAnswerField('ECRTime', ftTime);
  //ECRTime := Str2Time(Data, 27);
  AddAnswerField('FMFlags (Old)', ftByte);
  //SetFMFlags(Ord(Data[30]));
  // Serial
  AddAnswerField('ECRSerial', ftUInt32);
  //ECRSerial := BinToInt(Data, 31, 4);
  //SerialNumber := '';
  //if IsValidValue(ECRSerial, 4) then
  //  SerialNumber := Format('%.8d', [ECRSerial]);
  //if PrinterModel.CapFN then
  //begin
  //  SerialNumber := Copy(SerialNumber, Length(SerialNumber) - 5, Length(SerialNumber));
  //end;
  // SessionNumber
  AddAnswerField('SessionNumber', ftUInt16);
  //SessionNumber := BinToInt(Data, 35, 2);
  AddAnswerField('FreeRecordInFM (Old)', ftUInt16);
  //FFreeRecordInFM := BinToInt(Data, 37, 2);
  AddAnswerField('RegistrationNumber', ftByte);
  //RegistrationNumber := Ord(Data[39]);
  AddAnswerField('FreeRegistration', ftByte);
  //FreeRegistration := Ord(Data[40]);
  AddAnswerField('INN', ftINN);
  // INN
  //ECRINN := BinToInt(Data, 41, 6);
end;

procedure TParserCommand11.CreateFields;
begin
  AddField('Password', ftUInt32);
end;

function TParserCommand11.GetShortValue: string;
begin
  Result := GetAnswerFieldValue('ECRMode') + ' ' + GetAnswerFieldValue('ECRAdvancedMode');
end;

end.

