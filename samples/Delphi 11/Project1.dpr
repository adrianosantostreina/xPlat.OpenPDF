program Project1;
<<<<<<< master

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in '..\Unit1.pas' {Form1},
  xPlat.OpenPDF in '..\..\xPlat.OpenPDF.pas';

{$R *.res}

=======
uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in '..\Delphi 10\Unit1.pas' {Form1};

{$R *.res}
>>>>>>> Adjust
begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
