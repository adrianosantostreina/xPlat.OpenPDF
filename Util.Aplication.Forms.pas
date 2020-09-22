unit Util.Aplication.Forms;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.MultiView, FMX.ListBox,FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.TabControl,FMX.Edit, FMX.Ani, TypInfo, System.Rtti;

  procedure ShowFormGeneric(oFormClass: TComponentClass);

implementation

procedure ShowFormGeneric(oFormClass: TComponentClass);
begin
  if(not(Assigned(TForm(oFormClass))))then
  begin
    Application.CreateForm(oFormClass, TForm(oFormClass));
  end;
end;

end.
