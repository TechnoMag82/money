unit uDataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, ZConnection, ZDataset, ZAbstractConnection,
  ZSqlMonitor, ZSqlProcessor, Dialogs
  {$IFOPT D+}, MultiLog, ipcchannel{$ENDIF};

type
  TConnectionStatus = (csLoginError, csDbPathError, csConnectionError, csNone, csOk);
  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    BanksAndCurrencyDataSource: TDataSource;
    BanksDataSource: TDataSource;
    BanksQueryavg_buy: TFloatField;
    BanksQueryavg_sell: TFloatField;
    BanksQuerybank_id: TLongintField;
    BanksQuerybank_name: TStringField;
    BanksQuerybuy: TFloatField;
    BanksQuerysell: TFloatField;
    CompareCalcByBanksDataSource: TDataSource;
    StatistecDataSource: TDataSource;
    ZConnection1: TZConnection;
    BanksAndCurrencyQuery: TZQuery;
    ZQuery1Bank: TStringField;
    ZQuery1Buy: TFloatField;
    BanksAndCurrencyQuerysell: TFloatField;
    StatisticTable: TZTable;
    BanksQuery: TZReadOnlyQuery;
    CompareCalcByBanksQuery: TZReadOnlyQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FNames: TStringList;
  public
    function getCurrencies: TStringList;
    function connectToDb(const login, password: String) : Boolean;
    function getBuySum(index: Integer): Single;
    function getSellSum(index:Integer): Single;
    procedure getBankListWithCourses(currencyName: String);
    procedure getCurrencies(currencyName: String);
    procedure getCompareTable(operation: String; currencyName: String; userSum: Single);
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

{ TDataModule1 }

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  FNames := TStringList.Create;
  {$IFOPT D+}Logger.Channels.Add(TIPCChannel.Create){$ENDIF};
end;

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
  ZConnection1.Disconnect;
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

procedure TDataModule1.getBankListWithCourses(currencyName: String);
begin
  with BanksQuery do
  begin
    if (Active = true) then
      Close;
    ParamByName('CUR_NAME').AsString := currencyName;
    Open;
  end;
end;

procedure TDataModule1.getCurrencies(currencyName: String);
begin
  with BanksAndCurrencyQuery do
  begin
    if (Active = true) then
      Close;
    ParamByName('CUR_NAME').AsString := currencyName;
    Open;
  end;
end;

procedure TDataModule1.getCompareTable(operation: String; currencyName: String; userSum: Single);
begin
  if (userSum = 0) then
    exit;
  with CompareCalcByBanksQuery do
  begin
    if (Active = true) then
      Close;
    SQL.Text := 'SELECT bank_name, :OPERATION * :USER_SUM AS :CUR_NAME FROM get_banks_currency gbc WHERE currency_name=:CUR_STRING AND gbc.date_get = current_date ORDER BY :CUR_NAME DESC';
    SQL.Text := SQL.Text.Replace(':OPERATION', operation, [rfReplaceAll]);
    SQL.Text := SQL.Text.Replace(':USER_SUM', FloatToStr(userSum), [rfReplaceAll]);
    SQL.Text := SQL.Text.Replace(':CUR_NAME', currencyName, [rfReplaceAll]);
    SQL.Text := SQL.Text.Replace(':CUR_STRING', '''' + currencyName + '''', [rfReplaceAll]);
    Open;
    (CompareCalcByBanksQuery.Fields[1] as TFloatField).DisplayFormat := '######.0000';
  end;
end;

function TDataModule1.connectToDb(const login, password: String): Boolean;
begin
  if (NOT ZConnection1.Connected) then
  begin
    try
      ZConnection1.User := login;
      ZConnection1.Password := password;
      ZConnection1.Connect;
    except
      on E: Exception do
      begin
         {$IFOPT D+}Logger.Send('Connection error (' + E.ClassName + '): ' + E.Message);{$ENDIF}
         ShowMessage(E.Message);
      end;
    end;
  end;
  Result := ZConnection1.Connected;
end;

function TDataModule1.getBuySum(index: Integer): Single;
begin
  BanksQuery.RecNo := index + 1;
  Result := BanksQuery.FieldByName('buy').AsFloat;
  if (Result = 0) then
    Result := BanksQuery.FieldByName('avg_buy').AsFloat;
end;

function TDataModule1.getSellSum(index: Integer): Single;
begin
  BanksQuery.RecNo := index + 1;
  Result := BanksQuery.FieldByName('sell').AsFloat;
  if (Result = 0) then
    Result := BanksQuery.FieldByName('avg_sell').AsFloat;
end;

end.

