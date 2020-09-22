unit Util.Metodos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, untFormBase, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.Effects, FMX.MultiView, FMX.ListBox;

  procedure ConfiguraMenu(var Menu: TRectangle;var ListBox: TListBox);
  procedure RecolheMenu(var Menu: TRectangle);
  procedure ExibeMenu(var Menu: TRectangle;var ListBox: TListBox);

implementation

procedure RecolheMenu(var Menu: TRectangle);
begin
  Menu.Visible := False;
end;

procedure ExibeMenu(var Menu: TRectangle;var ListBox: TListBox);
begin
  ConfiguraMenu(Menu, ListBox);
  Menu.Visible := True;
end;

procedure ConfiguraMenu(var Menu: TRectangle;var ListBox: TListBox);
begin
  Menu.Height            := (ListBox.ItemHeight * ListBox.Items.Count) + 6;
  ListBox.ItemIndex      := -1;
end;

end.
