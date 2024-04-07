unit uBankAndCurrency;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl;

type



  { TCurrency }

  TCurrency = class
  strict private
    FBankId: Integer;
    FCurrency: String;
    FBuyCurrency: Single;
    FSellCurrency: Single;
    FDate: TDateTime;
  public
    property BankId: Integer read FBankId;
    property Buy: Single read FBuyCurrency;
    property Sell: Single read FSellCurrency;
    property Currency: String read FCurrency;
    property Date: TDateTime read FDate;
    constructor Create(ABankId: Integer; ACurrency: String; ABuyCurrency: Single; ASellCurrency: Single; ADate: TDateTime = 0);
  end;

  { TBank }

  TBank = class(TObject)
  strict private
    FBankId: Integer;
    FBankName: String;
    FBankCountry: String;
  public
    property BankId: Integer read FBankId;
    property BankName: String read FBankName;
    property BankCountry: String read FBankCountry;
    constructor Create(ABankId: Integer; ABankName: String; ABankCountry: String);
  end;

  TCurrencyList = specialize TFPGObjectList<TCurrency>;
  TBankList = specialize TFPGObjectList<TBank>;

implementation

{ TCurrency }

constructor TCurrency.Create(ABankId: Integer; ACurrency: String; ABuyCurrency: Single;
  ASellCurrency: Single; ADate: TDateTime = 0);
begin
  FBankId := ABankId;
  FBuyCurrency := ABuyCurrency;
  FSellCurrency := ASellCurrency;
  FCurrency := ACurrency;
  FDate := ADate;
end;

{ TBank }

constructor TBank.Create(ABankId: Integer; ABankName: String; ABankCountry: String);
begin
  FBankId := ABankId;
  FBankName := ABankName;
  FBankCountry := ABankCountry;
end;

end.

