unit uGetCurrencyThread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IdHTTP, DB, ZConnection, ZDataset,
  uCurrencyParser,
  uBankAndCurrency
  {$IFOPT D+}, MultiLog, ipcchannel{$ENDIF};

type
  TAction = (acInProgress, acCompleted);
  TShowStatusEvent = procedure (Sender: TObject; Action: TAction) of object;

  { TGetCurrencyThread }

  TGetCurrencyThread = class(TThread)
  private
    FOnShowStatus: TShowStatusEvent;
    FZConnection: TZConnection;
    FZQuery: TZQuery;
    procedure sendEvent();
    procedure sendCompletedEvent();
    procedure updateCurrencyNamesInDB(currencyList: TCurrencyList);
    procedure updateCurrency(currencyList: TCurrencyList);
    procedure updateBanksInDB(bankList: TBankList);
    procedure updateDB(var currencyParser: TCurrencyParser);
  protected
    procedure execute; override;
  public
    property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
    constructor Create(var AZConnection: TZConnection); overload;
  end;

implementation

{ TGetCurrencyThread }

procedure TGetCurrencyThread.sendEvent();
begin
  if Assigned(FOnShowStatus) then
    FOnShowStatus(self, acInProgress);
end;

procedure TGetCurrencyThread.sendCompletedEvent();
begin
  if Assigned(FOnShowStatus) then
    FOnShowStatus(self, acCompleted);
end;

procedure TGetCurrencyThread.updateCurrencyNamesInDB(
  currencyList: TCurrencyList);
var
  currency: TCurrency;
begin
  FZQuery.SQL.Text := 'INSERT INTO currency_names (currency_name) VALUES (:CURRENCY_NAME) ON CONFLICT (currency_name) DO NOTHING;';
  FZQuery.ParamCheck := true;
  for currency in currencyList do
  begin
    try
      FZQuery.ParamByName('CURRENCY_NAME').AsString := currency.Currency;
      FZQuery.ExecSQL;
    except
      on E:Exception do
        {$IFOPT D+}Logger.Send('UpdateCurrencyNames error: ' + E.Message);{$ENDIF}
    end;
  end;
end;

procedure TGetCurrencyThread.updateCurrency(currencyList: TCurrencyList);
var
  currency: TCurrency;
begin
  FZQuery.SQL.Clear;
  FZQuery.SQL.Add('INSERT INTO currencies (currency_name_id, bank_id, buy, sell, date_get)');
  FZQuery.SQL.Add(' VALUES ((SELECT id FROM currency_names WHERE currency_name=:CURRENCY_NAME), :BANK_ID, :BUY, :SELL, current_date)');
  FZQuery.SQL.Add(' ON CONFLICT (date_get, bank_id, currency_name_id)');
  FZQuery.SQL.Add(' DO UPDATE SET buy = EXCLUDED.buy, sell = EXCLUDED.sell;');
  FZQuery.ParamCheck := true;
  for currency in currencyList do
  begin
    try
      FZQuery.ParamByName('CURRENCY_NAME').AsString := currency.Currency;
      FZQuery.ParamByName('BANK_ID').AsInteger := currency.BankId;
      FZQuery.ParamByName('BUY').AsFloat := currency.Buy;
      FZQuery.ParamByName('SELL').AsFloat := currency.Sell;
      FZQuery.ExecSQL;
    except
      on E:Exception do
        {$IFOPT D+}Logger.Send('Insert currencies error: ' + E.Message);{$ENDIF}
    end;
  end;
end;

procedure TGetCurrencyThread.updateBanksInDB(bankList: TBankList);
var
  bank: TBank;
begin
  FZQuery.SQL.Text := 'INSERT INTO banks (bank_id, country, bank_name) VALUES (:BANK_ID, :BANK_COUNTRY, :BANK_NAME) ON CONFLICT (bank_id, bank_name) DO NOTHING;';
  FZQuery.ParamCheck := true;
  for bank in bankList do
  begin
    try
      FZQuery.ParamByName('BANK_ID').AsInteger := bank.BankId;
      FZQuery.ParamByName('BANK_NAME').AsString:= bank.BankName;
      FZQuery.ParamByName('BANK_COUNTRY').AsString := bank.BankCountry;
      FZQuery.ExecSQL;
    except
      on E:Exception do
        {$IFOPT D+}Logger.Send('Insert banks error: ' + E.Message);{$ENDIF}
    end;
  end;
end;

procedure TGetCurrencyThread.updateDB(var currencyParser: TCurrencyParser);
begin
  FZQuery := TZQuery.Create(nil);
  FZQuery.Connection := FZConnection;
  try
    updateBanksInDB(currencyParser.BankList);
    updateCurrencyNamesInDB(currencyParser.CurrencyList);
    updateCurrency(currencyParser.CurrencyList);
  finally
    FZQuery.Free;
  end;
end;

procedure TGetCurrencyThread.execute;
var
  FIdHTTP1: TIdHTTP;
  stringStream: TStringStream;
  currencyParser: TCurrencyParser;
begin
  Synchronize(@SendEvent);
  stringStream := TStringStream.Create;
  FIdHTTP1 := TIdHTTP.Create;
  FIdHTTP1.AllowCookies := false;
  FIdHTTP1.Request.CharSet := 'utf-8';
  FIdHTTP1.Request.Accept := 'text/html';
  FIdHTTP1.Request.AcceptCharSet := 'utf-8';
  FIdHTTP1.Request.ContentType := 'text/html';
  try
    FIdHttp1.Get('http://finance.i.ua/', stringStream);
    currencyParser := TCurrencyParser.Create;
    try
      currencyParser.parseDump(stringStream.DataString);
      updateDB(currencyParser);
    finally
      currencyParser.Free;
    end;
  finally
    stringStream.Free;
    FIdHttp1.Free;
    Synchronize(@SendCompletedEvent);
  end;
end;

constructor TGetCurrencyThread.Create(var AZConnection: TZConnection);
begin
  inherited Create(true);
  FreeOnTerminate := true;
  FZConnection := AZConnection;
  {$IFOPT D+}Logger.Channels.Add(TIPCChannel.Create){$ENDIF};
end;

end.

