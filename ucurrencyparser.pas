unit uCurrencyParser;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uBankAndCurrency, fpjson, jsonparser
  {$IFOPT D+}, MultiLog, ipcchannel{$ENDIF};

type
  
  { TCurrencyParser }

  TCurrencyParser = class
  private
    FBankList: TBankList;
    FCurrencyList: TCurrencyList;
    procedure parseJSONRates(const ARates: String);
    procedure parseBankNames(const ABankList: String);
    function IsolateText(const AInString: String; ATag1, ATag2:string): string;
  public
    property BankList: TBankList read FBankList;
    property CurrencyList: TCurrencyList read FCurrencyList;
    procedure parseDump(const ADump: String);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TCurrencyParser }

procedure TCurrencyParser.parseDump(const ADump: String);
begin
  parseJSONRates(IsolateText(ADump, 'converter.rates =', '</script>'));
  parseBankNames(IsolateText(ADump, '<select name="converter_bank" id="converter_bank">', '</select>'));
end;

constructor TCurrencyParser.Create;
begin
  inherited;
  {$IFOPT D+}Logger.Channels.Add(TIPCChannel.Create){$ENDIF};
  FBankList := TBankList.Create;
  FCurrencyList := TCurrencyList.Create;
end;

destructor TCurrencyParser.Destroy;
begin
  FBankList.Free;
  FCurrencyList.Free;
  inherited;
end;

procedure TCurrencyParser.parseJSONRates(const ARates: String);
var
  i, j: Integer;
  bankId, currencyName: String;
  jData: TJSONData;
  jObject : TJSONObject;
  jItem: TJSONData;
begin
  jData := GetJSON(ARates);
  for i := 0 to jData.Count - 1 do
  begin
    jItem := jData.Items[i];
    bankId := TJSONObject(jData).Names[i];
    for j := 0 to jItem.Count - 1 do
    begin
      currencyName := TJSONObject(jItem).Names[j];
      jObject := TJSONObject(jItem).Objects[currencyName];
      FCurrencyList.Add(TCurrency.Create(StrToInt(bankId), jObject.Get('buy'), jObject.Get('sell')));
      {$IFOPT D+}Logger.Send(bankId + ': ' + currencyName + ' buy: ' + FloatToStr(jObject.Get('buy')) + ' sell: ' + FloatToStr(jObject.Get('sell')));{$ENDIF}
    end;
  end;
end;

procedure TCurrencyParser.parseBankNames(const ABankList: String);
var
  htmlBankList: TStringList;
  item: String;
  id: Integer;
  bankName: String;
begin
  htmlBankList := TStringList.Create;
  try
    htmlBankList.Delimiter := #10;
    htmlBankList.Text := ABankList;
    for item in htmlBankList do
    begin
      try
        id := StrToInt(isolatetext(item, '"', '"'));
        bankName := isolatetext(item, '>', '<');
        FBankList.Add(TBank.Create(id, bankName, 'ua'));
        {$IFOPT D+}Logger.Send('id: ' + IntToStr(id) + ': ' + bankName);{$ENDIF}
      except
      end;
    end;
  finally
    htmlBankList.Free;
  end;
end;

function TCurrencyParser.IsolateText(const AInString: String; ATag1,
  ATag2: string): string;
Var
  pScan, pEnd, pTag1, pTag2: PChar;
  foundText: String;
begin
  pTag1 := PChar(ATag1);
  pTag2 := PChar(ATag2);
  pScan := PChar(AInString);
    pScan := StrPos( pScan, pTag1 );
    if pScan <> Nil then
    begin
      Inc(pScan, Length( ATag1 ));
      pEnd := StrPos( pScan, pTag2 );
      If pEnd <> Nil then
      Begin
        SetString( foundText,
                   Pchar(AInString) + (pScan - PChar(AInString)),
                   pEnd - pScan );
        Result := foundText;
        exit;
      end;
    end;
  Result := '';
end;

end.

