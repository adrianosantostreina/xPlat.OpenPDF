<p align="center">
  <a href="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/logo.png">
    <img alt="xPlat.OpenPDF" src="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/logo.png">
  </a>
</p>

# xPlat.OpenPDF
Class to facilitate the creation of Anonymous Threads in your project

## Installation
Just register in the Library Path of your Delphi the path of the SOURCE folder of the library, or if you prefer, you can use Boss (dependency manager for Delphi) to perform the installation:
```
boss install github.com/adrianosantostreina/xPlat.OpenPDF
```

## ⚠ Requirements
Android: It is necessary to adjust the permissions in the app so that it is possible to read and write files on the device

###### AndroidManifest.xml

```xml
      android:grantUriPermissions="true"
      android:requestLegacyExternalStorage="true"
```
###### Like this
```xml
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
      android:requestLegacyExternalStorage="true">
```

and this permissions

<b>ReadExternalStorage</b><br>
<b>WriteExternalStorage</b><br>

It's recommend using MobilePermissions component
[Mobile Permissions](http://github.com/adrianosantostreina/MobilePermissions)

or install by <b>Get It Package Manager</b> into your Delphi IDE.

Mark <b>Secure File Sharing</b> on <i>Project > Options > Application > Entitlement List</i> like a image below. (Android Profile)

<p align="center">
  <a href="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/securefilesharing.png">
    <img alt="xPlat.OpenPDF" src="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/securefilesharing.png">
  </a>
</p>


##  ⚡️ Quickstart
Create a new project

<ul>
  <li>Drag a TButtom onto form</li>
  <li>Drag a TMobilePermissions onto form</li>
  <li>In the OnCreate event of the Form type</li>
</ul>

```delphi
procedure TForm1.FormCreate(Sender: TObject);
begin
  MobilePermissions1.Dangerous.ReadExternalStorage  := True;
  MobilePermissions1.Dangerous.WriteExternalStorage := True;

  MobilePermissions1.Apply;
end;

```

> If you don't using then MobilePermissions component, don't forget to setting a permissions to ReadExternalStorage and WriteExternalStorage using your method. <br>

> It may be necessary to add the source path of the MobilePermissions component to the Library Path under Project > Options.


## Use
Declare xPlat.OpenPDF in the Uses section of the unit where you want to make the call to the class's method.
```delphi
uses
  xPlat.OpenPDF,

```

```delphi
procedure TForm1.Button1Click(Sender: TObject);
var
  LFile : string;       //File that will be open
begin
  LFile  := 'Your_PDF_File.pdf';
  TOpenPDF.Open(LFile);
end;
```

## Other use

In this example we are using a Switch component to set if we go to download file or use a local file (Project > Deployment)

```delphi
procedure TForm1.Button1Click(Sender: TObject);
var
  LStream        : TStringStream;
  LSharedPath    : String;       //Shared path on Android
  LPathDocs      : string;       //Documents path on Android
  LFile          : string;       //File that will be open
  LCompletePath  : string;
begin
  LFile  := 'printid.pdf';

  {$IFDEF MSWINDOWS}
    //It's possible set size and position for form
    TOpenPDF.FormHeight   := 800;
    TOpenPDF.FormWidth    := 600;
    TOpenPDF.FormPosition := TFormPosition.DesktopCenter;

    //If you are going to use it on Windows, you need to set the full path
    LSharedPath := 'C:\Temp' + PathDelim + 'tmp' + PathDelim;
    ForceDirectories(LSharedPath);
    LCompletePath := Format('%s%s', [LSharedPath, LFile]);
  {$ENDIF}

  {$IFDEF IOS}
    TOpenPDF.FormHeight   := Self.ClientHeight;
    TOpenPDF.FormWidth    := Self.ClientWidth;
    TOpenPDF.FormPosition := TFormPosition.ScreenCenter;
  {$ENDIF}

  if not swtOpenLocalFile.IsChecked then
  begin
    //Download file
    LStream  := TStringStream.Create;
    idHttp.Get(Format('%s%s',['https://www.controlid.com.br/userguide/', LFile]), LStream);

    LStream.Position := 0;
    {$IFDEF MSWINDOWS}
      LStream.SaveToFile(LCompletePath);
    {$ELSE}
      LStream.SaveToFile(Format('%s%s', [TPath.GetSharedDownloadsPath + '/', LFile]));
    {$ENDIF}
    LStream.DisposeOf;
  end;

  {$IFDEF MSWINDOWS}
    TOpenPDF.Open(LCompletePath);
  {$ELSE}
    TOpenPDF.Open(LFile);
  {$ENDIF}
end;
```

## Documentation Languages
[English (en)](https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/README.md)<br>
[Português (ptBR)](https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/README-ptBR.md)<br>

## ⚠️ License
`xPlat.OpenPDF` is free and open-source library licensed under the [MIT License](https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/LICENSE.md). 