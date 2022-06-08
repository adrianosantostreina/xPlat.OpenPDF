<p align="center">
  <a href="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/logo.png">
    <img alt="xPlat.OpenPDF" src="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/logo.png">
  </a>
</p>

# xPlat.OpenPDF
Classe para facilitar a criação de Threads Anônimos em seu projeto

## Instalação
Basta cadastrar no Library Path do seu Delphi o caminho da pasta SOURCE da biblioteca, ou se preferir, você pode usar o Boss (gerenciador de dependências do Delphi) para realizar a instalação:
```
chefe instale github.com/adrianosantostreina/xPlat.OpenPDF
```

## ⚠ Requisitos
Android: é necessário ajustar as permissões no app para que seja possível ler e gravar arquivos no dispositivo

###### AndroidManifest.xml

```xml
      android:grantUriPermissions="true"
      android:requestLegacyExternalStorage="true"
```
###### Assim
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

e essas permissões

<b>ReadExternalStorage</b><br>
<b>WriteExternalStorage</b><br>

É recomendável usar o componente MobilePermissions
[Mobile Permissions](http://github.com/adrianosantostreina/MobilePermissions)

ou instale pelo <b>Get It Package Manager</b> em seu Delphi IDE.

Marque <b>Compartilhamento seguro de arquivos</b> em <i>Projeto > Opções > Aplicativo > Lista de direitos</i> como na imagem abaixo. (Perfil do Android)

<p align="center">
  <a href="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/securefilesharing.png">
    <img alt="xPlat.OpenPDF" src="https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/image/securefilesharing.png">
  </a>
</p>


## ⚡️ Início rápido
Crie um novo projeto

<ul>
  <li>Arraste um TButtom para o formulário</li>
  <li>Arraste um TMobilePermissions para o formulário</li>
  <li>No evento OnCreate digite</li>
</ul>

```delphi
procedure TForm1.FormCreate(Sender: TObject);
begin
  MobilePermissions1.Dangerous.ReadExternalStorage  := True;
  MobilePermissions1.Dangerous.WriteExternalStorage := True;

  MobilePermissions1.Apply;
end;

```

> Se você não estiver usando o componente MobilePermissions, não se esqueça de definir as permissões para ReadExternalStorage e WriteExternalStorage usando seu método. <br>

> Pode ser necessário adicionar o caminho de origem do componente MobilePermissions ao Caminho da biblioteca em Projeto > Opções.


## Usar
Declare xPlat.OpenPDF na seção Uses da unidade onde você deseja fazer a chamada para o método da classe.
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

## Outro uso

Neste exemplo estamos usando um componente Switch para definir se vamos baixar o arquivo ou usar um arquivo local (Projeto > Implantação)

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

## Idiomas da documentação
[Inglês (en)](https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/README.md)<br>
[Português (pt-BR)](https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/README-ptBR.md)<br>

## ⚠️ Licença
`xPlat.OpenPDF` é uma biblioteca gratuita e de código aberto licenciada sob a [Licença MIT](https://github.com/adrianosantostreina/xPlat.OpenPDF/blob/master/LICENSE.md).