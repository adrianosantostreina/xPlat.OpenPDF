unit Util.Android;

interface

uses
  {$IF DEFINED(ANDROID)}
    Androidapi.Jni.Os,
    Androidapi.JNI.GraphicsContentViewText,
    Androidapi.Helpers,
    Androidapi.JNIBridge,

    FMX.VirtualKeyboard.Android,
    FMX.Controls.Android,
    FMX.Helpers.Android,
    FMX.Platform.Android,

    Androidapi.JNI.Util,
    Androidapi.JNI.Support,
  {$ENDIF}
  System.SysUtils,
  FMX.VirtualKeyboard,
  FMX.Objects,
  FMX.Types,
  FMX.Graphics,
  FMX.Platform.Common;


{$IF DEFINED(ANDROID)}
  procedure VibrarToque;
{$ENDIF}
  procedure Vibrar;
implementation

{$IF DEFINED(ANDROID)}
procedure VibrarToque;
var
  Vibrar: JVibrator;
begin
  Vibrar := TJVibrator.Wrap((SharedActivityContext.getSystemService(TJContext.JavaClass.VIBRATOR_SERVICE) as ILocalObject) .GetObjectID);
  Vibrar.Vibrate(20);
end;
{$ENDIF}

procedure Vibrar;
begin
  {$IF DEFINED(ANDROID)}
  VibrarToque;
  {$ENDIF}
end;

end.
