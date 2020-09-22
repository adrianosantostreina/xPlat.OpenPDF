unit SmartPoint;

interface

//adicionar uses
uses
  Server.Connection;


type
  TSmartPointer<T : class, constructor> = record
    strict private
      FValue: T;
      FFreeTheValue : IInterface;
      function GetValue: T;
    public
      class operator Implicit(Smart: TSmartPointer<T>): T;
      class operator Implicit(AValue: T): TSmartPointer<T>;
      constructor Create(AValue: T);
      property Value: T read GetValue;
  end;

  TFreeTheValue = class(TInterfacedObject)
    private
      FObjectToFree: TObject;
    public
      constructor Create(anObjectToFree: TObject);
      destructor Destroy; override;
  end;

implementation

{ TSmartPointer<T> }

constructor TSmartPointer<T>.Create(AValue: T);
begin
  FValue := AValue;
  FFreeTheValue := TFreeTheValue.Create(FValue);
end;

function TSmartPointer<T>.GetValue: T;
begin
  if not Assigned(FFreeTheValue) then
    Self := TSmartPointer<T>.Create(T.Create);
  Result := FValue;
end;

class operator TSmartPointer<T>.Implicit(AValue: T): TSmartPointer<T>;
begin
  Result := TSmartPointer<T>.Create(AValue);
end;

class operator TSmartPointer<T>.Implicit(Smart: TSmartPointer<T>): T;
begin
  Result := Smart.Value;
end;

{ TFreeTheValue }

constructor TFreeTheValue.Create(anObjectToFree: TObject);
begin
  FObjectToFree := anObjectToFree;
end;


destructor TFreeTheValue.Destroy;
begin
  if Assigned(FObjectToFree) then
  begin
    //alteração feita para não ficar várias conexões
    //abertas com o banco de dados
    if FObjectToFree.ClassName =  TConnectionData.ClassName then
    begin
      (FObjectToFree as TConnectionData).Connection.Connected := False;
    end;
    FObjectToFree.Free;
  end;
  inherited;
end;

end.
