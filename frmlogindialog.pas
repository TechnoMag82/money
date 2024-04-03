unit frmLoginDialog;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, LCLType;

type

  { TLoginDialog }

  TLoginDialog = class(TForm)
    OkButton: TButton;
    CancelButton: TButton;
    PasswordEdit: TLabeledEdit;
    LoginEdit: TLabeledEdit;
    procedure PasswordEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

  public

  end;

//var
  //LoginDialog: TLoginDialog;

implementation

{$R *.lfm}

{ TLoginDialog }

procedure TLoginDialog.PasswordEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (KEY = VK_RETURN) then
    ModalResult := mrOk;
end;

end.

