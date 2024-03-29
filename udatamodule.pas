unit uDataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, ZConnection, ZDataset;

type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    BanksAndCurrencyDataSource: TDataSource;
    StatistecDataSource: TDataSource;
    ZConnection1: TZConnection;
    BanksAndCurrencyQuery: TZQuery;
    ZQuery1Bank: TStringField;
    ZQuery1Buy: TFloatField;
    BanksAndCurrencyQuerysell: TFloatField;
    StatisticTable: TZTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FNames: TStringList;
  public
    function getCurrencies: TStringList;
    procedure getCurrencies(currencyName: String);
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

{ TDataModule1 }

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  FNames := TStringList.Create;
end;

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
  FNames.Free;
end;

function TDataModule1.getCurrencies: TStringList;
var
  i: LongInt;
begin
  FNames.Clear;
  with TZQuery.Create(self) do
  begin
    Connection := ZConnection1;
    ReadOnly := true;
    try
      SQL.Text := 'SELECT * FROM get_currency_names;';
      Open;
      First;
      for i := 0 to RecordCount - 1 do
      begin
        if (FieldByName('currency_name').AsString <> 'UAH') then
          FNames.Add(FieldByName('currency_name').AsString);
        Next;
      end;
    finally
      Close;
      Free;
    end;
  end;
  Result := FNames;
end;

procedure TDataModule1.getCurrencies(currencyName: String);
begin
  with BanksAndCurrencyQuery do
  begin
    if (Active = true) then
      Close;
    SQL.Text := 'SELECT * FROM get_banks_currency WHERE currency_name = :CUR_NAME AND date_get = current_date;';
    ParamByName('CUR_NAME').AsString := currencyName;
    Open;
  end;
end;

end.

