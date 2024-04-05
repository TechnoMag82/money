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
  private

  public

  end;

//var
  //LoginDialog: TLoginDialog;

implementation

{$R *.lfm}

{ TLoginDialog }

end.

