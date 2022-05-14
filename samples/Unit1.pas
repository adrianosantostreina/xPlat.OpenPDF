unit Unit1;

{
  Apply any config on All Configuration targets

  Requiriments:
  Project-Options-Entitlement List-Secure File Sharing = True
  For Delphi 10.4+ there is no need to exchange the provider_paths.xml, while
  checking TRUE "Secure File Sharing" Delphi will create its own provider_paths.xml,
  doesn't matter if you exchange it or not

  Permissions:
  Internet
  Read and Write external storage

  WARNING
  Since Android10* (newer) the Android file manager was changed, so we are
  using now System.IOUtils.TPath.GetPublicPath instead the old version
  the path on your Cellphone is on /storage/emulated/0/Android/data/<Project PackageName>/files
  It is a public path which can be reached through APP File Manager OR your own PC

  Tests on:
  Delphi 11 + 2 Patchs: Android 10, 12
}

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  FMX.WebBrowser,

  MobilePermissions.Component,
  MobilePermissions.Model.Dangerous,
  MobilePermissions.Model.Signature,
  MobilePermissions.Model.Standard,

  System.Classes,
  System.IOUtils,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,

  xPlat.OpenPDF;

type
  TForm1 = class(TForm)
    idHttp: TNetHTTPClient;
    swtOpenLocalFile: TSwitch;
    MobilePermissions1: TMobilePermissions;
    WebBrowser1: TWebBrowser;
    Label1: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    Button1: TButton;
    Layout3: TLayout;
    Layout4: TLayout;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  LStream        : TStringStream;
  LSharedPath    : String;       //Shared path on Android
  LPathDocs      : string;       //Documents path on Android
  LFile          : string;       //File that will be open
  LCompletePath  : string;
begin
  LFile  := 'printid.pdf';

  {$IF defined(MSWINDOWS)}
    //É possível informar tamanho do form e posição
    TOpenPDF.FormHeight   := 800;
    TOpenPDF.FormWidth    := 600;
    TOpenPDF.FormPosition := TFormPosition.DesktopCenter;

    //Se Windows informar o caminho completo do arquivo
    LSharedPath := 'C:\Temp' + PathDelim + 'tmp' + PathDelim;
    ForceDirectories(LSharedPath);
    LCompletePath := Format('%s%s', [LSharedPath, LFile]);
  {$IFEND}
    
  {$IFDEF IOS}
    TOpenPDF.FormHeight   := Self.ClientHeight;
    TOpenPDF.FormWidth    := Self.ClientWidth;
    TOpenPDF.FormPosition := TFormPosition.ScreenCenter;
  {$ENDIF}

  if not swtOpenLocalFile.IsChecked then
  begin
    //Baixa o arquivo
    LStream  := TStringStream.Create;
    try
      idHttp.Get(Format('%s%s',['https://www.controlid.com.br/userguide/', LFile]), LStream);

      LStream.Position := 0;
      {$IFDEF MSWINDOWS}
        LStream.SaveToFile(LCompletePath);
      {$ELSE}
        LStream.SaveToFile(Format('%s%s', [TPath.GetDocumentsPath, LFile]));
      {$ENDIF}
    finally
      FreeAndNil(LStream);
    end;    
  end;

  {$IFDEF MSWINDOWS}
    TOpenPDF.Open(LCompletePath);
  {$ELSE}
    TOpenPDF.Open(LFile);
  {$ENDIF}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MobilePermissions1.Dangerous.ReadExternalStorage  := True;
  MobilePermissions1.Dangerous.WriteExternalStorage := True;

  MobilePermissions1.Apply;
end;

end.
