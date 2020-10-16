unit Utils.DataSet.JSON.Helper;

interface

uses
  System.SysUtils,
  System.JSON,
  System.NetEncoding,
  Data.DB,
  REST.Json;


type
  TDataSetHelper = class Helper for TDataSet
  public
    function  DataSetToJSON(const ASelectedRec: Boolean = False) : TJSONArray;
    procedure SaveToJSON(AFileName : string);
  end;

implementation

uses
  System.Classes;

{ TDataSetHelper }

function TDataSetHelper.DataSetToJSON(const ASelectedRec: Boolean = False) : TJSonArray;
var
  lRow      : integer;
  lJO       : TJSONObject;

  StreamIn  : TStream;
  StreamOut : TStringStream;

  procedure Executar;
  var
    lCol : integer;
  begin
    for lCol := 0 to FieldCount - 1 do
    begin
      if Fields[lCol].IsNull then
        lJO.AddPair(Fields[lCol].FieldName, 'null')
      else
      begin
        if Fields[lCol].IsBlob then
        begin
          StreamIn := CreateBlobStream(Fields[lCol], bmRead);
          StreamOut := TStringStream.Create;
          TNetEncoding.Base64.Encode(StreamIn, StreamOut);
          StreamOut.Position := 0;
          lJO.AddPair(Fields[lCol].DisplayName, StreamOut.DataString);
        end
        else
        begin
          if Fields[lCol].DataType in [ftCurrency, ftFloat, ftInteger, ftSmallint, ftSingle, ftFMTBcd] then
            lJO.AddPair(Fields[lCol].FieldName, TJSONNumber.Create(Fields[lcol].Value))
          else if Fields[lCol].DataType in [ftDate, ftDateTime, ftTime, ftTimeStamp] then
            lJO.AddPair(Fields[lCol].FieldName, FormatDateTime('YYYY-MM-DD HH:NN:SS.zzz', Fields[lcol].Value))

          else
            lJO.AddPair(fields[lcol].FieldName, fields[lcol].Value);
        end;
      end;
    end;
  end;

begin
  Result := TJSONArray.Create;
  if ASelectedRec then
  begin
    lJO := TJSONObject.Create;
    Executar;
    Result.AddElement(lJO);
  end
  else
  begin
    First;
    for lRow := 0 to Pred(RecordCount) do
    begin
      lJO := TJSONObject.Create;
      Executar;
      Result.AddElement(lJO);
      Next;
    end;
  end;
end;


procedure TDataSetHelper.SaveToJSON(aFileName: string);
var
  S : TStringList;
begin
  S  := TStringList.Create;
  S.Clear;
  S.Add(TJSON.Format(DataSetToJSON));
  S.SaveToFile(aFileName);
end;

end.

