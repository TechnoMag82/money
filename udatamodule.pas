unit uDataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, ZConnection, ZDataset,
  Dialogs, Generics.Collections, uBankAndCurrency, IniFiles, lazfileutils
  {$IFOPT D+}, MultiLog, ipcchannel{$ENDIF};

const
  ConfigFileName : String = 'TechnoMag/money.conf';

type
  TConnectionStatus = (csLoginError, csDbPathError, csConnectionError, csNone, csOk);
  { TDataModule1 }

  TMinMaxDate = specialize TPair<TDateTime, TDateTime>;

  TDataModule1 = class(TDataModule)
    BankListQuerybank_id: TLongintField;
    BankListQuerybank_name: TStringField;
    BankListQuerychecked: TBooleanField;
    BanksAndCurrencyDataSource: TDataSource;
    BanksDataSource: TDataSource;
    BanksQueryavg_buy: TFloatField;
    BanksQueryavg_sell: TFloatField;
    BanksQuerybank_id: TLongintField;
    BanksQuerybank_name: TStringField;
    BanksQuerybuy: TFloatField;
    BanksQuerysell: TFloatField;
    CompareCalcByBanksDataSource: TDataSource;
    BanksListDataSource: TDataSource;
    StatistecDataSource: TDataSource;
    ZConnection1: TZConnection;
    BanksAndCurrencyQuery: TZQuery;
    BankListQuery: TZQuery;
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
    FCoursesQuery: TZReadOnlyQuery;
    FAppConfigPath: String;
  public
    function loadConnectionSettings: Boolean;
    function getCurrencies(currentValue: Boolean = false): TStringList;
    function connectToDb(const login, password: String) : Boolean;
    function getBuySum(index: Integer): Single;
    function getSellSum(index:Integer): Single;
    function getMinMaxDateOfHistory: TMinMaxDate;
    procedure getBankCourseList(bankId: Integer; currencyName: String;
                fromDate, toDate: TDateTime; var currencyList: TCurrencyList);
    procedure getSelectedBanksIds(var banksIdsList: TBankList);
    procedure getBankListWithCourses(currencyName: String);
    procedure getCurrencies(currencyName: String);
    procedure getCompareTable(operation: String; currencyName: String; userSum: Single);
    procedure saveSettings(hostName: String; port: Integer; database, driverPath: String);
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

{ TDataModule1 }

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  FAppConfigPath := ExtractFilePath(ChompPathDelim(GetAppConfigDir(False))) + ConfigFileName;
  FNames := TStringList.Create;
  {$IFOPT D+}Logger.Channels.Add(TIPCChannel.Create){$ENDIF};
end;

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
  ZConnection1.Disconnect;
  FNames.Free;
end;

function TDataModule1.loadConnectionSettings: Boolean;
begin
  if FileExists(FAppConfigPath) then
  begin
    with (TIniFile.Create(FAppConfigPath)) do
    begin
      try
        ZConnection1.Port := ReadInteger('Connection', 'port', 5432);
        ZConnection1.HostName := ReadString('Connection', 'host', 'localhost');
        ZConnection1.Database := ReadString('Connection', 'database', 'currencies');
        ZConnection1.LibraryLocation := ReadString('Connection', 'driver', '/usr/lib/x86_64-linux-gnu/libpq.so.5');
      finally
        Free;
      end;
    end;
    Result := true;
  end
  else
    Result := false;
end;

function TDataModule1.getCurrencies(currentValue: Boolean = false): TStringList;
var
  i: LongInt;
begin
  if (currentValue = true) then
  begin
    Result := FNames;
    exit;
  end;
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

procedure TDataModule1.saveSettings(hostName: String; port: Integer; database,
  driverPath: String);
begin
  with (TIniFile.Create(FAppConfigPath)) do
  begin
    try
      WriteInteger('Connection', 'port', port);
      WriteString('Connection', 'host', hostName);
      WriteString('Connection', 'database', dataBase);
      WriteString('Connection', 'driver', driverPath);
    finally
      Free;
    end;
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

function TDataModule1.getMinMaxDateOfHistory: TMinMaxDate;
var
  query: TZReadOnlyQuery;
begin
  query := TZReadOnlyQuery.Create(nil);
  query.Connection := ZConnection1;
  try
     query.SQL.Text := 'SELECT min(date_get), max(date_get) FROM currencies';
     query.Open;
     Result := TMinMaxDate.Create(query.FieldByName('min').AsDateTime, query.FieldByName('min').AsDateTime);
     {$IFOPT D+}Logger.Send(query.FieldByName('min').AsString);{$ENDIF}
  finally
    query.close;
    query.Free;
  end;
end;

procedure TDataModule1.getBankCourseList(bankId: Integer; currencyName: String;
  fromDate, toDate: TDateTime; var currencyList: TCurrencyList);
var
  i: Integer;
begin
  if not Assigned(FCoursesQuery) then
    begin
      FCoursesQuery := TZReadOnlyQuery.Create(self);
      FCoursesQuery.Connection := ZConnection1;
      FCoursesQuery.SQL.Add('SELECT buy, sell, date_get FROM currencies cur');
      FCoursesQuery.SQL.Add('JOIN currency_names gcn ON cur.currency_name_id = gcn.id');
      FCoursesQuery.SQL.Add('WHERE gcn.currency_name = :CUR_NAME AND');
      FCoursesQuery.SQL.Add('date_get BETWEEN :FROM_DATE AND :TO_DATE AND bank_id = :BANK_ID');
    end;
  with FCoursesQuery do
  begin
    try
      ParamByName('CUR_NAME').AsString := currencyName;
      ParamByName('FROM_DATE').AsDateTime := fromDate;
      ParamByName('TO_DATE').AsDateTime := toDate;
      ParamByName('BANK_ID').AsInteger := bankId;
      Open;
      currencyList.Clear;
      First;
      for i := 0 to RecordCount - 1 do
      begin
        currencyList.Add(TCurrency.create(0, '',
          FieldByName('buy').AsFloat,
          FieldByName('sell').AsFloat,
          FieldByName('date_get').AsDateTime));
        Next;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TDataModule1.getSelectedBanksIds(var banksIdsList: TBankList);
var
  i: integer;
begin
  banksIdsList.clear;
  with BankListQuery do
  begin
    First;
    for i := 0 to RecordCount - 1 do
    begin
      if (FieldByName('checked').AsBoolean = true) then
      begin
        banksIdsList.Add(TBank.Create(FieldByName('bank_id').AsInteger, FieldByName('bank_name').AsString, ''));
      end;
      Next;
    end;
  end;
end;

end.

