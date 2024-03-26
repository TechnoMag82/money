unit frmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, uGetCurrencyThread;

type

  { TMainForm }

  TMainForm = class(TForm)
    BitBtn1: TBitBtn;
    StatusBar1: TStatusBar;
    procedure BitBtn1Click(Sender: TObject);
  private
    FGetCurrencyThread: TGetCurrencyThread;
    procedure showStatus(Sender: TObject; progressAction: TAction);
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
  BitBtn1.Enabled := false;
  FGetCurrencyThread := TGetCurrencyThread.Create;
  FGetCurrencyThread.OnShowStatus := @showStatus;
  FGetCurrencyThread.Start;
end;

procedure TMainForm.showStatus(Sender: TObject; progressAction: TAction);
begin
  if (progressAction = acCompleted) then
    BitBtn1.Enabled := true;
end;

end.

