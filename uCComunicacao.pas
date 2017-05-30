unit uCComunicacao;


interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Generics.Collections,
  System.Types,
  System.JSON,
  Data.DBXJSONReflect,
  REST.Client,
  REST.Types,
  REST.JSON,
  REST.Response.Adapter,
  FireDAC.Comp.Client,
  IPPeerClient,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP,
  System.Net.HttpClient;

const
  _API_USUARIO = '/logindelphi/.json';
  _API_OBJETOS = '/tdevrocks-80dcb/.json';
  _API_OS = '/beaconCelSOS/IMEI_CELULAR/.json';

type
  TComunicacao = class
  private
    FBaseURL: string;
    FResponseJson: string;
    FRESTResponse: TRESTResponse;

    FRESTClient: TRESTClient;
    FRESTRequest: TRESTRequest;

    FRESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
    FMemTable: TFDMemTable;
  public
    constructor Create(ABaseURL: string = '');
    function ObtemDados(APIResource: string): Boolean;overload;
    function ObtemDados(AMemTable: TFDMemTable; APIResource: string): Boolean; overload;
    function ObtemDados(APIResource: string; Carregar: Boolean): String; overload;
    function GravaDados(APIResource: string; AJson: string): Boolean;

    property BaseURL: string read FBaseURL write FBaseURL;
    property Response: TFDMemTable read FMemTable write FMemTable;
    property ResponseJson: string read FResponseJson;
  end;

implementation

{ TSincronismo }

constructor TComunicacao.Create(ABaseURL: string);
begin
  FRESTRequest := TRESTRequest.Create(nil);
  FRESTResponse := TRESTResponse.Create(FRESTRequest);
  FRESTClient := TRESTClient.Create('');

  FRESTClient.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  FRESTClient.AcceptCharset := 'UTF-8, *;q=0.8';
  FRESTClient.AcceptEncoding := 'identity';

  FRESTRequest.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  FRESTRequest.AcceptCharset := 'UTF-8, *;q=0.8';
  FRESTRequest.AcceptEncoding := 'identity';
  FRESTRequest.Client := FRESTClient;

  FRESTRequest.Response := FRESTResponse;

  FMemTable := TFDMemTable.Create(FRESTRequest);
  FRESTResponseDataSetAdapter := TRESTResponseDataSetAdapter.Create(FRESTRequest);
  FRESTResponseDataSetAdapter.Dataset := FMemTable;
  FRESTResponseDataSetAdapter.Response := FRESTResponse;

  FBaseURL := ABaseURL;
end;

function TComunicacao.GravaDados(APIResource, AJson: string): Boolean;
{$Region}
(*var
  lJsonStream: TStringStream;
  lIdHTTP: TIdHTTP;
  lResponse: string;
  lUrl: string;
begin
  try
    lJsonStream := TStringStream.Create(Utf8Encode(AJson));

    lIdHTTP := TIdHTTP.Create(nil);
    lIdHTTP.Request.Method := 'PUT';
    lIdHTTP.Request.ContentType := 'application/json';
    lIdHTTP.Request.CharSet := 'utf-8';

    lUrl := FBaseURL + APIResource;
    lResponse := lIdHTTP.Put(lUrl, lJsonStream);
    result := true;
  except
    result := false;
  end;
*)
{$EndRegion}
var
  lJsonStream: TStringStream;
  lIdHTTP: THTTPClient;
  lResponse: string;
  lUrl: string;
  AResponseContent : TStringStream;
begin
  try
    lJsonStream := TStringStream.Create(Utf8Encode(AJson));

    lIdHTTP := THTTPClient.Create;
    lIdHTTP.CustomHeaders['auth'] := 'anonymous';
    lIdHTTP.CustomHeaders['uid'] := '769d853d-393d-4228-94ca-592f6a9c563a';
    lIdHTTP.ContentType := 'application/json';

    lUrl := FBaseURL + APIResource;
    AResponseContent := TStringStream.Create();
    lIdHTTP.Put(lUrl, lJsonStream, AResponseContent);
    result := true;
  except
    result := false;
  end;


end;

function TComunicacao.ObtemDados(APIResource: string; Carregar: Boolean): String;
begin
  try
    FRESTClient.BaseURL := FBaseURL;
    FRESTRequest.Method := rmGET;
    FRESTRequest.resource := APIResource;
    FRESTRequest.Execute;

    FResponseJson := FRESTResponse.Content;

    FRESTResponseDataSetAdapter.Active := true;
    FMemTable.Active := True;

    result := FRESTResponse.Content;
  except
    result := 'erro';
  end;
end;

function TComunicacao.ObtemDados(AMemTable: TFDMemTable;
  APIResource: string): Boolean;
begin
  try
    FRESTClient.BaseURL := FBaseURL;
    FRESTRequest.Method := rmGET;
    FRESTRequest.resource := APIResource;
    FRESTRequest.Execute;

    FResponseJson := FRESTResponse.Content;

    FRESTResponseDataSetAdapter.Active := true;
    FMemTable.Active := True;

    AMemTable.Data := FMemTable.Data;
    result := True;
  except
    result := false;
  end;
end;

function TComunicacao.ObtemDados(APIResource: string): Boolean;
begin
  try
    FRESTClient.BaseURL := FBaseURL;
    FRESTRequest.Method := rmGET;
    FRESTRequest.resource := APIResource;
    FRESTRequest.Execute;

    FResponseJson := FRESTResponse.Content;

    FRESTResponseDataSetAdapter.Active := true;
    FMemTable.Active := true;
    result := true;
  except
    result := false;
  end;

end;

end.
