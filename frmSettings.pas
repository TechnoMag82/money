unit frmSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, ExtCtrls, StdCtrls, Classes, Dialogs;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    CancelButton: TButton;
    OkButton: TButton;
    DataBasePathButton: TButton;
    HostnameEdit: TLabeledEdit;
    DriverPathEdit: TLabeledEdit;
    PortEdit: TLabeledEdit;
    DatabaseNameEdit: TLabeledEdit;
    procedure DataBasePathButtonClick(Sender: TObject);
  private

  public

  end;

//var
//  SettingsForm: TSettingsForm;

implementation

{$R *.lfm}

{ TSettingsForm }

procedure TSettingsForm.DataBasePathButtonClick(Sender: TObject);
begin
  with (TOpenDialog.Create(self)) do
  begin
    Filter := 'All files|*.*';
    if (Execute) then
      DriverPathEdit.Text := FileName;
    Free;
  end;
end;

end.

