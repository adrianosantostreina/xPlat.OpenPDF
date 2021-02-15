unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.WebBrowser,

  {$IFDEF ANDROID}
    Androidapi.JNI.GraphicsContentViewText,
    Androidapi.JNI.provider,
    Androidapi.JNI.JavaTypes,
    Androidapi.JNI.Net,
    Androidapi.JNI.App,
    AndroidAPI.jNI.OS,
    Androidapi.JNIBridge,
    FMX.Helpers.Android,
    IdUri,
    Androidapi.Helpers,
    FMX.Platform.Android,
  {$ENDIF}

  System.Net.URLClient,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,

  MobilePermissions.Model.Signature,
  MobilePermissions.Model.Dangerous,
  MobilePermissions.Model.Standard,
  MobilePermissions.Component, FMX.Layouts;


type
{$IFDEF ANDROID}
  JFileProvider = interface;
  JFileProviderClass = interface(JContentProviderClass)
    ['{33A87969-5731-4791-90F6-3AD22F2BB822}']
    {class} function getUriForFile(context: JContext; authority: JString; _file: JFile): Jnet_Uri; cdecl;
    {class} function init: JFileProvider; cdecl;
  end;

  [JavaSignature('android/support/v4/content/FileProvider')]
  JFileProvider = interface(JContentProvider)
    ['{12F5DD38-A3CE-4D2E-9F68-24933C9D221B}']
    procedure attachInfo(context: JContext; info: JProviderInfo); cdecl;
    function delete(uri: Jnet_Uri; selection: JString; selectionArgs: TJavaObjectArray<JString>): Integer; cdecl;
    function getType(uri: Jnet_Uri): JString; cdecl;
    function insert(uri: Jnet_Uri; values: JContentValues): Jnet_Uri; cdecl;
    function onCreate: Boolean; cdecl;
    function openFile(uri: Jnet_Uri; mode: JString): JParcelFileDescriptor; cdecl;
    function query(uri: Jnet_Uri; projection: TJavaObjectArray<JString>; selection: JString; selectionArgs: TJavaObjectArray<JString>;
      sortOrder: JString): JCursor; cdecl;
    function update(uri: Jnet_Uri; values: JContentValues; selection: JString; selectionArgs: TJavaObjectArray<JString>): Integer; cdecl;
  end;

  TJFileProvider = class(TJavaGenericImport<JFileProviderClass, JFileProvider>) end;

{$ENDIF}

  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Imagens: TButton;
    Button2: TButton;
    http: TNetHTTPClient;
    Memo1: TMemo;
    Switch1: TSwitch;
    MobilePermissions1: TMobilePermissions;
    WebBrowser1: TWebBrowser;
    Label1: TLabel;
    Layout1: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure ImagensClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    {$IFDEF ANDROID}
    function GetFileUri(aFile: String): JNet_Uri;
    {$ENDIF}
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  MobilePermissions1.Dangerous.ReadExternalStorage  := True;
  MobilePermissions1.Dangerous.WriteExternalStorage := True;

  MobilePermissions1.Apply;
end;

procedure TForm1.ImagensClick(Sender: TObject);
(*
Var
  Intent : JIntent;
  URI    : JNet_Uri;
  URIs   : JArrayList;
  Path   : String;
*)
begin
(*
  Path := System.IOUtils.TPath.GetSharedDocumentsPath+PathDelim;

  Image1.Bitmap.SaveToFile(Path+'1.png');
  Image2.Bitmap.SaveToFile(Path+'2.png');
  Image3.Bitmap.SaveToFile(Path+'3.png');

  URIs   := TJArrayList.Create;
  Intent := TJIntent.JavaClass.init(TJintent.JavaClass.ACTION_SEND);
  Intent.setPackage(StringToJString('com.whatsapp'));
  Intent.setType(StringToJString('text/plain'));
  Intent.putExtra(TJintent.JavaClass.EXTRA_TEXT, StringToJString('Texto de teste'));

  Uri := TJNet_uri.JavaClass.parse(StringToJString(Path+'1.png'));
  Uris.add(Uri);
  Intent.setDataAndType(Uri, StringToJString('image/png'));

  Uri := TJNet_uri.JavaClass.parse(StringToJString(Path+'2.png'));
  Uris.add(Uri);
  Intent.setDataAndType(Uri, StringToJString('image/png'));

  Uri := TJNet_uri.JavaClass.parse(StringToJString(Path+'3.png'));
  Uris.add(Uri);
  Intent.setDataAndType(Uri, StringToJString('image/png'));

  Intent.putParcelableArrayListExtra(TJintent.JavaClass.EXTRA_STREAM, Uris);
  Intent.setFlags(TJintent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(Intent);
*)
end;

{$IFDEF ANDROID}
function TForm1.GetFileUri(aFile: String): JNet_Uri;
var
  FileAtt      : JFile;
  Auth         : JString;
  PackageName  : String;
begin
  PackageName := JStringToString(SharedActivityContext.getPackageName);
  FileAtt     := TJFile.JavaClass.init(StringToJString(aFile));
  Auth        := StringToJString(Packagename+'.fileprovider');
  Result      := TJFileProvider.JavaClass.getUriForFile(TAndroidHelper.Context, Auth, FileAtt);
end;
{$ENDIF}

procedure TForm1.Button2Click(Sender: TObject);
Var
  Str    : TStringStream;
  path   : String;
  {$IFDEF ANDROID}
  Intent : JIntent;
  URIs   : JArrayList;
  URI    : JNet_Uri;
  {$ENDIF}

  SPathDocs : string;
  SFile  : string;
begin
  {$IFDEF MSWINDOWS}
    Path := 'C:\Temp' + PathDelim + 'tmp' + PathDelim;
  {$ELSE}
    SPathDocs := System.IOUtils.TPath.GetDocumentsPath + PathDelim;
    Path := System.IOUtils.TPath.GetSharedDocumentsPath + PathDelim + 'tmp' + PathDelim;

    if not TDirectory.Exists(Path) then
      TDirectory.CreateDirectory(Path);
  {$ENDIF}

  if Switch1.IsChecked then
  begin
    SFile := 'Motorola_One.pdf';

    {$IFDEF MSWINDOWS}

    {$ELSE}
      TFile.Copy(SPathDocs + SFile, Path + SFile, True);
    {$ENDIF}
  end
  else
  begin
    SFile := 'teste.pdf';
    Str  := TStringStream.Create;
    Http.Get('https://app.jusimperium.com.br/teste.pdf', Str);

    Str.Position := 0;
    Str.SaveToFile(Path + SFile);
    Str.DisposeOf;
  end;

  {$IFDEF MSWINDOWS}
    WebBrowser1.Navigate(Path + SFile);
  {$ELSE}
    Intent := TJIntent.JavaClass.init(TJintent.JavaClass.ACTION_VIEW);
    Uri    := GetFileURI(Path + SFile {'teste.pdf'});
    Intent.setDataAndType(Uri, StringToJString('application/pdf'));
    Intent.setFlags(TJintent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
    TAndroidHelper.Activity.startActivity(Intent);
  {$ENDIF}
end;

end.
