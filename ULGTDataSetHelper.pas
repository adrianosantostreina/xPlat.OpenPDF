{*******************************************************}
{                                                       }
{                    Landerson Gomes                    }
{                                                       }
{*       Class Helper para Classes TDataSet            *}
{                                                       }
{*******************************************************}


unit ULGTDataSetHelper;

interface

uses
  Data.DB, System.JSON, REST.Json, System.NetEncoding;

  Type
    TDataSetHelper = class Helper for TDataSet
    public
      function  DataSetToJSON(const ARegistroAtual: Boolean = False) : TJSonArray;
      procedure SaveToJSON(aFileName : string);
    end;

implementation

uses
  System.Classes;

{ TDataSetHelper }

function TDataSetHelper.DataSetToJSON(const ARegistroAtual: Boolean = False): TJSonArray;
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
          if Fields[lCol].DataType in [ftCurrency, ftFloat, ftInteger, ftSmallint, ftSingle ] then
            lJO.AddPair(Fields[lCol].FieldName,
                        TJSONNumber.Create(Fields[lcol].Value))
          else
            lJO.AddPair(fields[lcol].FieldName, fields[lcol].Value);
        end;
      end;
    end;
  end;

begin
  Result := TJSONArray.Create;
  if ARegistroAtual then
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
      (*
      lJO := TJSONObject.Create;
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
            if Fields[lCol].DataType in [ftCurrency, ftFloat, ftInteger, ftSmallint, ftSingle ] then
              lJO.AddPair(Fields[lCol].FieldName,
                          TJSONNumber.Create(Fields[lcol].Value))
            else
              lJO.AddPair(fields[lcol].FieldName, fields[lcol].Value);
          end;
        end;
      end;
      *)
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

