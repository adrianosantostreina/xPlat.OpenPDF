<<<<<<< master:xPlat.OpenPDF.pas
unit xPlat.OpenPDF;
interface
uses
  //Instruções:
  {
    Importantíssimo:
    #1.
      É necessária a inclusão das TAGs abaixo no AndroidManifest.Template.xml
      android:grantUriPermissions="true"
      android:requestLegacyExternalStorage="true"

    Exemplo:
    <application android:persistent="%persistent%"
      android:restoreAnyVersion="%restoreAnyVersion%"
      android:label="%label%"
      android:debuggable="%debuggable%"
      android:largeHeap="%largeHeap%"
      android:icon="%icon%"
      android:theme="%theme%"
      android:hardwareAccelerated="%hardwareAccelerated%"
      android:resizeableActivity="false"
      android:grantUriPermissions="true"
      android:requestLegacyExternalStorage="true"
    >
    #2. É importante dar acesso às opções
    READ_EXTERNAL_STORAGE
    WRITE_EXTERNAL_STORAGE
    Recomendo o uso componente MobilePermissions
    http://github.com/adrianosantostreina/MobilePermissions
    Uso:
    MobilePermissions1.DANGEROUS.ReadExternalStorage  := True;
    MobilePermissions1.DANGEROUs.WriteExternalStorage := True;
    MobilePermissions1.Aply;
    #3. Ative a opção Secure File Sharing em
      Project > Options > Application > Entitlement List
    Essa Unit não foi totalmente testa em macOS e iOS
  }
    System.SysUtils
  , System.Classes
  , System.IOUtils
  , FMX.Forms
  , FMX.WebBrowser
  , FMX.Types
  , FMX.StdCtrls
  , FMX.Dialogs
  {$IFDEF MSWindows}
  , System.UITypes
  {$ENDIF}
  {$IFDEF MACOS}
  , Posix.Stdlib
  {$ENDIF MACOS}
  {$IF DEFINED(IOS)}
    , iOSApi.Foundation
    , Macapi.Helpers
    , FMX.Helpers.iOS
  {$ENDIF}
  {$IFDEF ANDROID}
    {$IF CompilerVersion >= 34.0},Androidapi.JNI.Support{$ENDIF}
    , Androidapi.JNI.GraphicsContentViewText
    , Androidapi.JNI.provider
    , Androidapi.JNI.JavaTypes
    , Androidapi.JNI.Net
    , Androidapi.JNI.App
    , AndroidAPI.jNI.OS
    , Androidapi.JNIBridge
    , FMX.Helpers.Android
    , IdUri
    , Androidapi.Helpers
    , FMX.Platform.Android
  {$ENDIF}
  ;
type
{$IF defined(ANDROID) and (CompilerVersion < 34.0)}
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
  TCloseParentFormHelper = class
    public
     class procedure OnClickClose(Sender: TObject);
     {$IFDEF MSWindows}
     class procedure OnClose(Sender: TObject; var Action: TCloseAction);
     {$ENDIF}
  end;
  TOpenPDF = class
    protected
    {$IFDEF ANDROID}
      class function  GetFileUri(AFile: String): JNet_Uri;
    {$ENDIF}
      class procedure ShowPDFViewer(AFilename: string);
    private
      class var FFormHeight   : Integer;
      class var FFormWidth    : Integer;
      class var FFormPosition : TFormPosition;
    public
      class property FormHeight   : Integer       read FFormHeight   write FFormHeight;
      class property FormWidth    : Integer       read FFormWidth    write FFormWidth;
      class property FormPosition : TFormPosition read FFormPosition write FFormPosition;
      class procedure Open(AFilename: string);overload;
  end;
implementation
{ TOpenPDF }
class procedure TCloseParentFormHelper.OnClickClose(Sender: TObject);
begin
  TForm(TComponent(Sender).Owner).DisposeOf;
end;
class procedure TOpenPDF.ShowPDFViewer(AFilename: string);
var
  LForm       : TForm;
  WebBrowser  : TWebBrowser;
  LBtnClose   : TButton;
  LToolbar    : TToolBar;
begin
  LForm                    := TForm.CreateNew(nil);
  LForm.Position           := FFormPosition;
  {$IFDEF MSWindows}
  LForm.OnClose            := TCloseParentFormHelper.OnClose;
  {$ENDIF}
  if FFormHeight > 0 then  LForm.Height := FFormHeight;
  if FFormWidth  > 0 then  LForm.Width  := FFormWidth;
  LToolbar                 := TToolBar.Create(LForm);
  LToolbar.Align           := TAlignLayout.Top;
  LToolbar.StyleLookup     := 'toolbarstyle';
  LToolbar.Parent          := LForm;
  {Botão Back}
  LBtnClose                := TButton.Create(LForm);
  LBtnClose.Align          := TAlignLayout.Left;
  LBtnClose.Margins.Left   := 8;
  LBtnClose.StyleLookup    := 'backtoolbutton';
  LBtnClose.Text           := 'Voltar';
  LBtnClose.Parent         := LToolbar;
  WebBrowser               := TWebBrowser.Create(LForm);
  WebBrowser.Parent        := LForm;
  WebBrowser.Align         := TAlignLayout.Client;
  LBtnClose.OnClick        := TCloseParentFormHelper.OnClickClose;
  WebBrowser.Navigate(AFilename);
  LForm.Show();
end;
{$IFDEF ANDROID}
class function TOpenPDF.GetFileUri(AFile: String): JNet_Uri;
var
  FileAtt      : JFile;
  Auth         : JString;
  PackageName  : String;
begin
  PackageName := JStringToString(SharedActivityContext.getPackageName);
  FileAtt     := TJFile.JavaClass.init(StringToJString(AFile));
  Auth        := StringToJString(Packagename + '.fileprovider');
  Result      := {$IF CompilerVersion >= 34.0}TJcontent_FileProvider{$ELSE}TJFileProvider{$ENDIF}.JavaClass.getUriForFile(TAndroidHelper.Context, Auth, FileAtt);
end;
{$ENDIF}
{$IFDEF ANDROID}
class procedure TOpenPDF.Open(AFilename: string);
var
  LIntent        : JIntent;
  LURI           : JNet_Uri;
  LSharedPath    : String;       //Shared path on Android
  LPathDocs      : string;       //Documents path on Android
  LCompletePath  : string;
begin
  LPathDocs     := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, AFilename);
  if not TFile.Exists(LPathDocs) then
    raise Exception.Create('Arquivo não existe.' +#13#10 + LPathDocs);
  LSharedPath := System.IOUtils.TPath.GetPublicPath;
  if not TDirectory.Exists(LSharedPath) then
    TDirectory.CreateDirectory(LSharedPath);
  LCompletePath := System.IOUtils.TPath.Combine(LSharedPath, AFilename);
  if FileExists(LCompletePath) then
    DeleteFile(LCompletePath);
  TFile.Copy(LPathDocs,   //source
             LCompletePath, //target
             True);
  LIntent       := TJIntent.JavaClass.init(TJintent.JavaClass.ACTION_VIEW);
  LURI          := GetFileURI(LCompletePath);
  LIntent.setDataAndType(LURI, StringToJString('application/pdf'));
  LIntent.setFlags(TJintent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(LIntent);
end;
{$ENDIF}
{$IFDEF IOS}
class procedure TOpenPDF.Open(AFilename: string);
begin
  if not TFile.Exists(AFilename) then
    raise Exception.Create('Arquivo não existe.' +#13#10 + AFilename);
  ForceDirectories(ExtractFilePath(AFilename));
  ShowPDFViewer(AFilename);
end;
{$ENDIF}
{$IFDEF MSWINDOWS}
class procedure TOpenPDF.Open(AFilename: string);
begin
  if not TFile.Exists(AFilename) then
    raise Exception.Create('Arquivo não existe.' +#13#10 + AFilename);
  ForceDirectories(ExtractFilePath(AFilename));
  ShowPDFViewer(AFilename);
end;
{$ENDIF}
{$IFDEF MACOS}
class procedure TOpenPDF.Open(AFileName: string);
begin
  //_system(PAnsiChar('open '+'"'+AnsiString(APDFFileName)+'"'));
end;
{$ENDIF MACOS}
{$IFDEF MSWindows}
class procedure TCloseParentFormHelper.OnClose(Sender: TObject;
 var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;
{$ENDIF}

end.
=======
unit xPlat.OpenPDF;

interface

uses
  //Instruções:
  {
    Importantíssimo:

    #1.
      É necessária a inclusão das TAGs abaixo no AndroidManifest.Template.xml
      android:grantUriPermissions="true"
      android:requestLegacyExternalStorage="true"


    Exemplo:
    <application android:persistent="%persistent%"
      android:restoreAnyVersion="%restoreAnyVersion%"
      android:label="%label%"
      android:debuggable="%debuggable%"
      android:largeHeap="%largeHeap%"
      android:icon="%icon%"
      android:theme="%theme%"
      android:hardwareAccelerated="%hardwareAccelerated%"
      android:resizeableActivity="false"

      android:grantUriPermissions="true"
      android:requestLegacyExternalStorage="true"
    >

    #2. É importante dar acesso às opções
    READ_EXTERNAL_STORAGE
    WRITE_EXTERNAL_STORAGE

    Recomendo o uso componente MobilePermissions
    http://github.com/adrianosantostreina/MobilePermissions

    Uso:
    MobilePermissions1.DANGEROUS.ReadExternalStorage  := True;
    MobilePermissions1.DANGEROUs.WriteExternalStorage := True;
    MobilePermissions1.Aply;

    #3. Ative a opção Secure File Sharing em
      Project > Options > Application > Entitlement List

    Essa Unit não foi totalmente testa em macOS e iOS
  }
    System.SysUtils
  , System.Classes
  , System.IOUtils

  , FMX.Forms
  , FMX.WebBrowser
  , FMX.Types
  , FMX.StdCtrls
  , FMX.Dialogs

  {$IFDEF MSWindows}
  , System.UITypes
  {$ENDIF}

  {$IFDEF MACOS}
  , Posix.Stdlib
  {$ENDIF MACOS}

  {$IF DEFINED(IOS)}
    , iOSApi.Foundation
    , Macapi.Helpers
    , FMX.Helpers.iOS
  {$ENDIF}

  {$IFDEF ANDROID}
    , Androidapi.JNI.GraphicsContentViewText
    , Androidapi.JNI.provider
    , Androidapi.JNI.JavaTypes
    , Androidapi.JNI.Net
    , Androidapi.JNI.App
    , AndroidAPI.jNI.OS
    , Androidapi.JNIBridge
    , FMX.Helpers.Android
    , IdUri
    , Androidapi.Helpers
    , FMX.Platform.Android
  {$ENDIF}
  ;

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

  TCloseParentFormHelper = class
    public
     class procedure OnClickClose(Sender: TObject);
     {$IFDEF MSWindows}
     class procedure OnClose(Sender: TObject; var Action: TCloseAction);
     {$ENDIF}
  end;

  TOpenPDF = class
    protected
    {$IFDEF ANDROID}
      class function  GetFileUri(AFile: String): JNet_Uri;
    {$ENDIF}
      class procedure ShowPDFViewer(AFilename: string);
    private
      class var FFormHeight   : Integer;
      class var FFormWidth    : Integer;
      class var FFormPosition : TFormPosition;
    public
      class property FormHeight   : Integer       read FFormHeight   write FFormHeight;
      class property FormWidth    : Integer       read FFormWidth    write FFormWidth;
      class property FormPosition : TFormPosition read FFormPosition write FFormPosition;

      class procedure Open(AFilename: string);overload;
  end;

implementation

{ TOpenPDF }

class procedure TCloseParentFormHelper.OnClickClose(Sender: TObject);
begin
  TForm(TComponent(Sender).Owner).DisposeOf;
end;

class procedure TOpenPDF.ShowPDFViewer(AFilename: string);
var
  LForm       : TForm;
  WebBrowser  : TWebBrowser;
  LBtnClose   : TButton;
  LToolbar    : TToolBar;
begin
  LForm                    := TForm.CreateNew(nil);
  LForm.Position           := FFormPosition;

  {$IFDEF MSWindows}
  LForm.OnClose            := TCloseParentFormHelper.OnClose;
  {$ENDIF}

  if FFormHeight > 0 then  LForm.Height := FFormHeight;
  if FFormWidth  > 0 then  LForm.Width  := FFormWidth;

  LToolbar                 := TToolBar.Create(LForm);
  LToolbar.Align           := TAlignLayout.Top;
  LToolbar.StyleLookup     := 'toolbarstyle';
  LToolbar.Parent          := LForm;

  {Botão Back}
  LBtnClose                := TButton.Create(LForm);
  LBtnClose.Align          := TAlignLayout.Left;
  LBtnClose.Margins.Left   := 8;
  LBtnClose.StyleLookup    := 'backtoolbutton';
  LBtnClose.Text           := 'Voltar';
  LBtnClose.Parent         := LToolbar;

  WebBrowser               := TWebBrowser.Create(LForm);
  WebBrowser.Parent        := LForm;
  WebBrowser.Align         := TAlignLayout.Client;

  LBtnClose.OnClick        := TCloseParentFormHelper.OnClickClose;

  WebBrowser.Navigate(AFilename);

  LForm.Show();
end;

{$IFDEF ANDROID}
class function TOpenPDF.GetFileUri(AFile: String): JNet_Uri;
var
  FileAtt      : JFile;
  Auth         : JString;
  PackageName  : String;
begin
  PackageName := JStringToString(SharedActivityContext.getPackageName);
  FileAtt     := TJFile.JavaClass.init(StringToJString(AFile));
  Auth        := StringToJString(Packagename + '.fileprovider');
  Result      := TJFileProvider.JavaClass.getUriForFile(TAndroidHelper.Context, Auth, FileAtt);
end;
{$ENDIF}

{$IFDEF ANDROID}
class procedure TOpenPDF.Open(AFilename: string);
var
  LIntent        : JIntent;
  LURI           : JNet_Uri;
  LSharedPath    : String;       //Shared path on Android
  LPathDocs      : string;       //Documents path on Android
  LCompletePath  : string;
begin
  LPathDocs     := System.IOUtils.TPath.GetDocumentsPath + PathDelim;
  if not TFile.Exists(Format('%s%s', [LPathDocs, AFilename])) then
    raise Exception.Create('Arquivo não existe.' +#13#10 + Format('%s%s', [LPathDocs, AFilename]));

  LSharedPath   := System.IOUtils.TPath.GetSharedDocumentsPath + PathDelim;

  if not TDirectory.Exists(LSharedPath) then
    TDirectory.CreateDirectory(LSharedPath);

  LCompletePath := Format('%s%s', [LSharedPath, AFilename]);

  TFile.Copy(Format('%s%s', [LPathDocs, AFilename]),   //source
             Format('%s%s', [LSharedPath, AFilename]), //target
             True);

  LIntent       := TJIntent.JavaClass.init(TJintent.JavaClass.ACTION_VIEW);
  LURI          := GetFileURI(LCompletePath);

  LIntent.setDataAndType(LURI, StringToJString('application/pdf'));
  LIntent.setFlags(TJintent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(LIntent);
end;
{$ENDIF}

{$IFDEF IOS}
class procedure TOpenPDF.Open(AFilename: string);
begin
  if not TFile.Exists(AFilename) then
    raise Exception.Create('Arquivo não existe.' +#13#10 + AFilename);

  ForceDirectories(ExtractFilePath(AFilename));
  ShowPDFViewer(AFilename);
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
class procedure TOpenPDF.Open(AFilename: string);
begin
  if not TFile.Exists(AFilename) then
    raise Exception.Create('Arquivo não existe.' +#13#10 + AFilename);

  ForceDirectories(ExtractFilePath(AFilename));
  ShowPDFViewer(AFilename);
end;
{$ENDIF}

{$IFDEF MACOS}
class procedure TOpenPDF.Open(AFileName: string);
begin
  //_system(PAnsiChar('open '+'"'+AnsiString(APDFFileName)+'"'));
end;
{$ENDIF MACOS}

{$IFDEF MSWindows}
class procedure TCloseParentFormHelper.OnClose(Sender: TObject;
 var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;
{$ENDIF}

end.
>>>>>>> Adjust:source/xPlat.OpenPDF.pas
