unit uBankAndCurrency;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, contnrs, fgl;

type



  { TCurrency }

  TCurrency = class
  strict private
    FBankId: Integer;
    FBuyCurrency: Single;
    FSellCurrency: Single;
  public
    property BankId: Integer read FBankId;
    property Buy: Single read FBuyCurrency;
    property Sell: Single read FSellCurrency;
    constructor Create(ABankId: Integer; ABuyCurrency: Single; ASellCurrency: Single);
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

constructor TCurrency.Create(ABankId: Integer; ABuyCurrency: Single;
  ASellCurrency: Single);
begin
  FBankId := ABankId;
  FBuyCurrency := ABuyCurrency;
  FSellCurrency := ASellCurrency;
end;

{ TBank }

constructor TBank.Create(ABankId: Integer; ABankName: String; ABankCountry: String);
begin
  FBankId := ABankId;
  FBankName := ABankName;
  FBankCountry := ABankCountry;
end;

end.

