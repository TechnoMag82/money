unit uGetCurrencyThread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IdHTTP, uCurrencyParser;

type
  TAction = (acInProgress, acCompleted);
  TShowStatusEvent = procedure (Sender: TObject; Action: TAction) of object;

  { TGetCurrencyThread }

  TGetCurrencyThread = class(TThread)
  private
    FOnShowStatus: TShowStatusEvent;
    procedure sendEvent();
    procedure sendCompletedEvent();
  protected
    procedure execute; override;
  public
    property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
    constructor Create(); overload;
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
      { #todo : Add save currencies to DB }
    finally
      currencyParser.Free;
    end;
  finally
    stringStream.Free;
    FIdHttp1.Free;
    Synchronize(@SendCompletedEvent);
  end;
end;

constructor TGetCurrencyThread.Create();
begin
  FreeOnTerminate := true;
  inherited Create(true);
end;

end.

