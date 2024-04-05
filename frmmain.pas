unit frmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, DBGrids, ExtCtrls, DBCtrls, MaskEdit, uGetCurrencyThread,
  uDataModule, frmLoginDialog, frmHistory;

type

  { TMainForm }

  TMainForm = class(TForm)
    HistoryBitBtn: TBitBtn;
    BtnUpdate: TBitBtn;
    BanksAndCurrencyDBGrid: TDBGrid;
    CurrencyComboBox: TComboBox;
    BanksDBLookupComboBox: TDBLookupComboBox;
    DBGrid1: TDBGrid;
    Label6: TLabel;
    ResultEdit: TEdit;
    BankCourseEdit: TEdit;
    Label4: TLabel;
    CalculatorGroupBox: TGroupBox;
    BuyRadioButton: TRadioButton;
    Label3: TLabel;
    Label5: TLabel;
    BankCurrencyLabel: TLabel;
    SumMaskEdit: TMaskEdit;
    SellRadioButton: TRadioButton;
    StatisticDBGrid: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    StatusBar1: TStatusBar;
    CurrencyNamesTabControl: TTabControl;
    procedure BanksDBLookupComboBoxChange(Sender: TObject);
    procedure BtnUpdateClick(Sender: TObject);
    procedure CurrencyComboBoxChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CurrencyNamesTabControlChange(Sender: TObject);
    procedure HistoryBitBtnClick(Sender: TObject);
    procedure SumMaskEditChange(Sender: TObject);
  private
    FGetCurrencyThread: TGetCurrencyThread;
    FFirstActivate: Boolean;
    procedure updateBanksCurrenciesTable;
    procedure showStatus(Sender: TObject; progressAction: TAction);
    procedure enableControls(enable: boolean);
    procedure calcCourses;
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.BtnUpdateClick(Sender: TObject);
begin
  enableControls(false);
  FGetCurrencyThread := TGetCurrencyThread.Create(DataModule1.ZConnection1);
  FGetCurrencyThread.OnShowStatus := @showStatus;
  FGetCurrencyThread.Start;
end;

procedure TMainForm.CurrencyComboBoxChange(Sender: TObject);
begin
  with CurrencyComboBox do
  begin
    DataModule1.getBankListWithCourses(Items[ItemIndex]);
    BankCurrencyLabel.Caption := Items[ItemIndex];
  end;
  BanksDBLookupComboBox.ItemIndex := BanksDBLookupComboBox.Items.Count - 1;
  BanksDBLookupComboBoxChange(BanksDBLookupComboBox);
end;

procedure TMainForm.BanksDBLookupComboBoxChange(Sender: TObject);
begin
  calcCourses;
end;

procedure TMainForm.FormActivate(Sender: TObject);
var
  LoginForm: TLoginDialog;
begin
  if FFirstActivate then
  begin
    LoginForm := TLoginDialog.Create(self);
    try
      while true do
      begin
        if LoginForm.ShowModal = mrOk then
        begin
          if DataModule1.connectToDb(LoginForm.LoginEdit.Text,
                  LoginForm.PasswordEdit.Text) then
          begin
            enableControls(true);
            DataModule1.StatisticTable.Open;
            updateBanksCurrenciesTable;
            break;
          end;
        end else
        begin
          break;
        end;
      end;
    finally
      FFirstActivate := false;
      LoginForm.Free;
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FFirstActivate := true;
  enableControls(false);
end;

procedure TMainForm.CurrencyNamesTabControlChange(Sender: TObject);
begin
  with CurrencyNamesTabControl do
    DataModule1.getCurrencies(Tabs[TabIndex]);
end;

procedure TMainForm.HistoryBitBtnClick(Sender: TObject);
begin
  THistoryForm.Create(self).ShowModal;
end;

procedure TMainForm.SumMaskEditChange(Sender: TObject);
begin
  calcCourses;
end;

procedure TMainForm.updateBanksCurrenciesTable;
begin
  with CurrencyNamesTabControl do
  begin
    Tabs.Clear;
    Tabs := DataModule1.getCurrencies;
    TabIndex := 0;
    CurrencyNamesTabControlChange(CurrencyNamesTabControl);
  end;
  with CurrencyComboBox do
  begin
    Items := CurrencyNamesTabControl.Tabs;
    ItemIndex := 0;
    CurrencyComboBoxChange(CurrencyComboBox);
  end;
end;

procedure TMainForm.showStatus(Sender: TObject; progressAction: TAction);
begin
  if (progressAction = acCompleted) then
  begin
    enableControls(true);
    updateBanksCurrenciesTable;
    DataModule1.StatisticTable.Refresh;
  end;
end;

procedure TMainForm.enableControls(enable: boolean);
begin
  BtnUpdate.Enabled := enable;
  CalculatorGroupBox.Enabled := enable;
  HistoryBitBtn.Enabled := enable;
end;

procedure TMainForm.calcCourses;
var
  userSum, courseSum, resultSum: Single;
begin
  try
    userSum := StrToFloat(SumMaskEdit.Text);
    if (BuyRadioButton.Checked = true) then
    begin
      courseSum := DataModule1.getSellSum(BanksDBLookupComboBox.ItemIndex);
      DataModule1.getCompareTable('buy', BankCurrencyLabel.Caption, userSum);
    end else
    begin
      courseSum := DataModule1.getBuySum(BanksDBLookupComboBox.ItemIndex);
      DataModule1.getCompareTable('sell', BankCurrencyLabel.Caption, userSum);
    end;
    resultSum := userSum * courseSum;
    BankCourseEdit.text := FloatToStr(courseSum);
    ResultEdit.text := FloatToStr(resultSum);
  except
    //on E: Exception do
      //ShowMessage(E.Message);
  end;
end;

end.

