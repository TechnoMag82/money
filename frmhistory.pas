unit frmHistory;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, DBCtrls, DBGrids, TAGraph, uDataModule,
  uBankAndCurrency, TASeries;

const
  TColors : array of TColor =
    ($9A7154, $1BD9A8, $68641D, $243CAF, $1BD978,
     $246BAF, $8324AF, $56D90C, $AF2488, $0875FF,
     $AF2432, $24AF35, $1F0FC4, $24ABAF, $D9D40C,
     $2484AF, $0CD9D9, $AFA824, $A70FC4, $C13400);
  ColorsLength : Byte = 19;

type

  { THistoryForm }
  THistoryForm = class(TForm)
    Chart1LineSeries1: TLineSeries;
    BuyRadioButton: TRadioButton;
    SellRadioButton: TRadioButton;
    UpdateButton: TButton;
    Chart1: TChart;
    CurrenciesComboBox: TComboBox;
    DBGrid1: TDBGrid;
    FromDatePicker: TDateEdit;
    ToDatePicker: TDateEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    procedure Chart1AxisList1MarkToText(var AText: String; AMark: Double);
    procedure UpdateButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FSelectedBanksIds: TBankList;
    FCurrencyList: TCurrencyList;
    procedure buildChart(title: String; seriesColor: TColor);
  public

  end;

//var
  //HistoryForm: THistoryForm;

implementation

{$R *.lfm}

{ THistoryForm }

procedure THistoryForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FSelectedBanksIds.Free;
  FCurrencyList.Free;
  DataModule1.BankListQuery.Close;
  CloseAction := caFree;
end;

procedure THistoryForm.UpdateButtonClick(Sender: TObject);
var
  bank: TBank;
  i: Integer;
  chartConfigured: boolean;
begin
  i := 0;
  chartConfigured := false;
  DataModule1.getSelectedBanksIds(FSelectedBanksIds);
  if (FSelectedBanksIds.Count = 0) then
  begin
    ShowMessage('Выберите банк.');
    exit;
  end;
  Chart1.ClearSeries;
  for bank in FSelectedBanksIds do
  begin
    DataModule1.getBankCourseList(bank.BankId,
      CurrenciesComboBox.Items[CurrenciesComboBox.ItemIndex],
      FromDatePicker.Date,
      ToDatePicker.Date,
      FCurrencyList);
    if chartConfigured = false then
    begin
      Chart1.BottomAxis.Range.Min := 0;
      Chart1.BottomAxis.Range.Max := FCurrencyList.Count - 1;
      chartConfigured := true;
    end;
    if (i > ColorsLength) then
      i := 0;
    buildChart(bank.BankName, TColors[i]);
    Inc(i);
  end;
end;

procedure THistoryForm.Chart1AxisList1MarkToText(var AText: String;
  AMark: Double);
begin
  AText := FormatDateTime('DD.MM.yyyy', AMark);
end;

procedure THistoryForm.FormCreate(Sender: TObject);
var
  minMaxDate: TMinMaxDate;
begin
  FSelectedBanksIds := TBankList.Create;
  FCurrencyList := TCurrencyList.Create;
  CurrenciesComboBox.Items := DataModule1.getCurrencies(true);
  CurrenciesComboBox.ItemIndex := 0;
  minMaxDate := DataModule1.getMinMaxDateOfHistory;
  FromDatePicker.MinDate := minMaxDate.key;
  FromDatePicker.MaxDate := minMaxDate.value;
  FromDatePicker.Date := now;
  ToDatePicker.Date := now;
  ToDatePicker.MinDate := minMaxDate.key;
  ToDatePicker.MaxDate := minMaxDate.value;
  DataModule1.BankListQuery.Open;
end;

procedure THistoryForm.buildChart(title: String; seriesColor: TColor);
var
  currency: TCurrency;
  lineSeries: TLineSeries;
  i: Integer;
begin
  lineSeries := TLineSeries.Create(Chart1);
  lineSeries.SeriesColor := seriesColor;
  lineSeries.ShowPoints := true;
  lineSeries.Title := title;
  lineSeries.BeginUpdate;
  try
    i := 0;
    for currency in FCurrencyList do
    begin
      if BuyRadioButton.Checked = true then
        lineSeries.AddXY(currency.Date, currency.Buy, '', seriesColor)
      else
        lineSeries.AddXY(currency.Date, currency.Sell, '', seriesColor);
      Inc(i);
    end;
  finally
    lineSeries.EndUpdate;
  end;
  Chart1.AddSeries(lineSeries);
end;

end.

