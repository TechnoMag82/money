unit frmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, DBGrids, ExtCtrls, DBCtrls, uGetCurrencyThread, uDataModule;

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnUpdate: TBitBtn;
    BanksAndCurrencyDBGrid: TDBGrid;
    CourseComboBox: TComboBox;
    CurrencyComboBox: TComboBox;
    DBComboBox1: TDBComboBox;
    Label4: TLabel;
    SumEdit: TEdit;
    GroupBox1: TGroupBox;
    BuyRadioButton: TRadioButton;
    Label3: TLabel;
    SellRadioButton: TRadioButton;
    StatisticDBGrid: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    StatusBar1: TStatusBar;
    CurrencyNamesTabControl: TTabControl;
    procedure BtnUpdateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CurrencyNamesTabControlChange(Sender: TObject);
  private
    FGetCurrencyThread: TGetCurrencyThread;
    procedure updateBanksCurrenciesTable;
    procedure showStatus(Sender: TObject; progressAction: TAction);
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.BtnUpdateClick(Sender: TObject);
begin
  BtnUpdate.Enabled := false;
  FGetCurrencyThread := TGetCurrencyThread.Create(DataModule1.ZConnection1);
  FGetCurrencyThread.OnShowStatus := @showStatus;
  FGetCurrencyThread.Start;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DataModule1.StatisticTable.Open;
  updateBanksCurrenciesTable;
end;

procedure TMainForm.CurrencyNamesTabControlChange(Sender: TObject);
begin
  DataModule1.getCurrencies(CurrencyNamesTabControl.Tabs[CurrencyNamesTabControl.TabIndex]);
end;

procedure TMainForm.updateBanksCurrenciesTable;
begin
  CurrencyNamesTabControl.Tabs.Clear;
  CurrencyNamesTabControl.Tabs := DataModule1.getCurrencies;
  CurrencyNamesTabControl.TabIndex := 0;
  CurrencyNamesTabControlChange(CurrencyNamesTabControl);
end;

procedure TMainForm.showStatus(Sender: TObject; progressAction: TAction);
begin
  if (progressAction = acCompleted) then
  begin
    BtnUpdate.Enabled := true;
    updateBanksCurrenciesTable;
    DataModule1.StatisticTable.Refresh;
  end;
end;

end.

