unit uBaseClasses;

interface

uses
  System.Classes, Data.DB, System.Generics.Collections, System.SysUtils, uInterface,
  uSpetechDrawGrid,  System.Generics.Defaults, IBX.IBSQL, IBX.IBDatabase;

type
  TSQLKind = (skInsert, skUpdate, skSelect, skOnlyFields, skDelete);

  TDBBaseObject = class;

  TOnCondition = procedure(AOwner: TDBBaseObject; var ACondition: string) of object;

  TOnSaveError = procedure(AOwner: TDBBaseObject; AException: Exception; var AShow: Boolean) of object;

  TDBObjectList<T: class> = class(TObjectList<T>, IGridList)
  private
    FId: Integer;
    FDisableCount: Integer;
    FOnListChange: TListChange;
    FRemovedList: TObjectList<T>;
    function GetOnListChange: TListChange;
    procedure SetOnListChange(const Value: TListChange);
    function GetRemovedList: TObjectList<T>;
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure Notify(const Value: T; Action: TCollectionNotification); override;
    procedure DoInit(); virtual;
  public
    // IInterface
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    //
    destructor Destroy; override;
    constructor Create(AOwnsObjects: Boolean = True); overload;
    constructor Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean = True); overload;
    constructor Create(Collection: TEnumerable<T>; AOwnsObjects: Boolean = True); overload;
    //
    property Id: Integer read FId write FId;
    property RemovedList: TObjectList<T> read GetRemovedList write FRemovedList;
    procedure prClear(); virtual;
    procedure DisableControls;
    procedure EnableControls;

    // IGridList
    function GetCount: Integer;
    function GetClassType: TClass;
    function GetItemFieldValue(AIndex: Integer; AFieldName: string; AFormat: String): string;
    function GetItemFieldBool(AIndex: Integer; AFieldName: string): Boolean;
    function GetItem(AIndex: Integer): TObject;
    function GetIndex(AObject: TObject): Integer;
    property OnListChange: TListChange read GetOnListChange write SetOnListChange;
  end;


  TDBFieldInfo = class(TCustomAttribute)
  private
    FFieldName: String;
    FReadOnly: Boolean;
    FPrimaryKey: Boolean;
    FForeignKey: Boolean;
  public
    constructor Create(const AFieldName:string; const AReadOnly: Boolean = False; const APrimaryKey: Boolean = False; const AForeignKey: Boolean = False);
    property FieldName: String read FFieldName;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property PrimaryKey: Boolean read FPrimaryKey write FPrimaryKey;
    property ForeignKey: Boolean read FForeignKey write FForeignKey;
  end;

  TDBTableInfo = class(TCustomAttribute)
  private
    FTableName: String;
    FOrderBy: string;
  public
    constructor Create(const ATableName: string; const AOrderBy: string = '');
    property TableName: String read FTableName;
    property OrderBy: string read FOrderBy write FOrderBy;
  end;

  TDefaultFieldValue = class(TCustomAttribute)
  private
    FValue: Variant;
  public
    constructor Create(const Value: Integer); reintroduce; overload;
    constructor Create(const Value: string); reintroduce; overload;
    constructor Create(const Value: Double); reintroduce; overload;
    property Value: Variant read FValue write FValue;
  end;

  TCanceledFilterField = class(TCustomAttribute);

  TCustomAttributeClass = class of TCustomAttribute;

  TDBBaseObject = class(TInterfacedPersistent, IDBSQLObject)
  private
    FId: Integer;
    FSQL: TObjectDictionary<TSQLKind, TStringList>;
    FModified: Boolean;
    FOnSaveError: TOnSaveError;
    function GetTransaction: TIBTransaction;
    function GetUserId: Integer;
    //
    function fnFindAttribute(AList: TArray<TCustomAttribute>; AAttrClass: TCustomAttributeClass): TCustomAttribute;
    procedure prSetDefaultValue();
  protected
    FTransaction: TIBTransaction;
    FUserId: Integer;
    FOwner: TObject;
    //
    function GetId: Integer; virtual;
    procedure SetId(const Value: Integer); virtual;
    //
    procedure Change(); dynamic;
    procedure DoBeforeSave(); dynamic;
    procedure DoAfterSave(); dynamic;
    //list
    procedure prSetRootObject(AOwner: TDBBaseObject);
    procedure prLoadList<T: class, constructor>(AList: TDBObjectList<T>; AIdFieldName: string; AId: Integer; ACanceled: Boolean = False);
    function fnGetCanceledCondition(): String;
  public
    destructor Destroy; override;
    // IDBSQLObject
    property Transaction: TIBTransaction read GetTransaction;
    property UserId: Integer read GetUserId write FUserId;
    //
    property Modified: Boolean read FModified write FModified;
    //
    procedure Assign(Source: TPersistent); override;

    procedure prSave(); virtual;
    procedure prLoad(); virtual;
    procedure prDelete(); virtual;
    //
    constructor Create(AOwnerInterface: IDBSQLObject); virtual;
    class function CreateInstance<T>(AOwnerInterface: IDBSQLObject): T;
    //
    function fnSQL(AKind: TSQLKind; AParamList: TDictionary<string, Variant>; ACondition: String = ''; AFieldPrefix: string = ''): string;

    function fnTableName(AWithPrefix: Boolean = True): String;
    class procedure prLoadObjectList<T: class, constructor>(AOwnerInterface: IDBSQLObject; AList: TDBObjectList<T>; ACanceled: Boolean = False; AOnCondition: TOnCondition = nil);
    //
    function GetFieldValue(AFieldName: string; AFormat: String): string;
    //
    property OnSaveError: TOnSaveError read FOnSaveError write FOnSaveError;
  published
    [TDBFieldInfo('ID', False, True)]
    property Id: Integer read GetId write SetId;
    //[TDBFieldInfo('OLD_ID', False, False)]
    //property OldId: string read GetOldId write SetOldId;
  end;

  function IfThenVar(ACondition: Boolean; ATrueVal: Variant; AFalseVal: Variant): Variant;

implementation

uses
  System.Rtti, System.TypInfo, Forms, Winapi.Windows, IBX.IBHeader, MMSystem, System.Variants;

function IfThenVar(ACondition: Boolean; ATrueVal: Variant; AFalseVal: Variant): Variant;
begin
  Result := AFalseVal;
  if (ACondition) then
    Result := ATrueVal;
end;

{ TDBBaseObject }

procedure TDBBaseObject.Assign(Source: TPersistent);
  function _fnAttr(AList: TArray<TCustomAttribute>): TDBFieldInfo;
  var
    oTmp: TCustomAttribute;
  begin
    Result := nil;
    for oTmp in AList do
      if oTmp is TDBFieldInfo then
        Result := TDBFieldInfo(oTmp);
  end;
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oProps: TArray<TRttiProperty>;
  oProp: TRttiProperty;
  oColAttr: TDBFieldInfo;
  oVal: TValue;
  iFieldIndex: Integer;
  iVal: Integer;
begin
  (*if (Source is Self.ClassType) then begin
    oRttiContext := TRttiContext.Create();
    try
      oRttiType := oRttiContext.GetType(Self.ClassType);
      oProps := oRttiType.GetProperties;
      for oProp in oProps do begin
        oColAttr := _fnAttr(oProp.GetAttributes);
        if (not Assigned(oColAttr)) then
          Continue;

        case oProp.PropertyType.TypeKind of
          tkUString:
          begin
            oVal := TDataSet(Source).Fields[iFieldIndex].AsString;
            oProp.SetValue(Self, oVal);
          end;
          tkInteger:
          begin
            if (Source is TIBSQL) then
              oVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
            else
              oVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;
            oProp.SetValue(Self, oVal);
          end;
          tkFloat:
          begin
            if (Source is TIBSQL) then begin
              case TIBSQL(Source).Fields[iFieldIndex].SQLType of
                SQL_TIMESTAMP, SQL_TYPE_TIME, SQL_TYPE_DATE: oVal := TIBSQL(Source).Fields[iFieldIndex].AsDateTime;
              else
                oVal := TIBSQL(Source).Fields[iFieldIndex].AsDouble;
              end;
            end
            else
              oVal := TDataSet(Source).Fields[iFieldIndex].AsFloat;
            oProp.SetValue(Self, oVal);
          end;
          tkEnumeration:
          begin
            if (Source is TIBSQL) then
              iVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
            else
              iVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;

            if oProp.PropertyType.Handle = TypeInfo(Boolean) then
              oProp.SetValue(Self, TValue.FromOrdinal(TypeInfo(Boolean), iVal));
          end;
        else
              //
        end;
      end;
    finally
      oRttiContext.Free;
    end;
  end
  else *)
  if (Source is TDataSet) or (Source is TIBSQL) then begin
    oRttiContext := TRttiContext.Create();
    try
      oRttiType := oRttiContext.GetType(Self.ClassType);
      oProps := oRttiType.GetProperties;
      for oProp in oProps do begin
        oColAttr := _fnAttr(oProp.GetAttributes);
        if (not Assigned(oColAttr)) then
          Continue;

        if (Source is TIBSQL) then
          iFieldIndex := TIBSQL(Source).FieldIndex[oColAttr.FieldName]
        else
          iFieldIndex := TDataSet(Source).FieldList.IndexOf(oColAttr.FieldName);

        if (iFieldIndex < 0) then
          Continue;
        case oProp.PropertyType.TypeKind of
          tkUString:
          begin
            if (Source is TIBSQL) then
              oVal := TIBSQL(Source).Fields[iFieldIndex].AsString
            else
              oVal := TDataSet(Source).Fields[iFieldIndex].AsString;
            oProp.SetValue(Self, oVal);
          end;
          tkInteger:
          begin
            if (Source is TIBSQL) then
              oVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
            else
              oVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;
            oProp.SetValue(Self, oVal);
          end;
          tkFloat:
          begin
            if (Source is TIBSQL) then begin
              case TIBSQL(Source).Fields[iFieldIndex].SQLType of
                SQL_TIMESTAMP, SQL_TYPE_TIME, SQL_TYPE_DATE: oVal := TIBSQL(Source).Fields[iFieldIndex].AsDateTime;
              else
                oVal := TIBSQL(Source).Fields[iFieldIndex].AsDouble;
              end;
            end
            else
              oVal := TDataSet(Source).Fields[iFieldIndex].AsFloat;
            oProp.SetValue(Self, oVal);
          end;
          tkEnumeration:
          begin
            if (Source is TIBSQL) then
              iVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
            else
              iVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;

            if oProp.PropertyType.Handle = TypeInfo(Boolean) then
              oProp.SetValue(Self, TValue.FromOrdinal(TypeInfo(Boolean), iVal));
          end;
        else
              //
        end;
      end;
    finally
      oRttiContext.Free;
    end;
    Exit;
  end;
  inherited;

end;

procedure TDBBaseObject.Change;
begin
  //
end;

constructor TDBBaseObject.Create(AOwnerInterface: IDBSQLObject);
begin
  inherited Create();
  Assert(AOwnerInterface <> nil, 'Owner can''t be nil');

  FTransaction := AOwnerInterface.Transaction;
  FUserId := AOwnerInterface.UserId;
  Assert(FTransaction <> nil);
  if (AOwnerInterface is TObject) then
    FOwner := TObject(AOwnerInterface);
  FSQL := TObjectDictionary<TSQLKind, TStringList>.Create([doOwnsValues]);

  prSetDefaultValue();
  FModified := True;
end;

class function TDBBaseObject.CreateInstance<T>(AOwnerInterface: IDBSQLObject): T;
var
  oValue: TValue;
  oContex: TRttiContext;
  oType: TRttiType;
  oMethCreate: TRttiMethod;
  oMethParam: TArray<TRttiParameter>;
  oInstanceType: TRttiInstanceType;
  oInf: IDBSQLObject;
  oArgs: TArray<TValue>;
begin
  Result := TValue.Empty.AsType<T>;
  oContex := TRttiContext.Create;
  try
    oType := oContex.GetType(TypeInfo(T));
    for oMethCreate in oType.GetMethods do begin
      if (oMethCreate.IsConstructor) then begin
        oMethParam := oMethCreate.GetParameters;

        // check is interface implement
        if (Length(oMethParam) = 1) and (oMethParam[0].ParamType.TypeKind = tkInterface) then begin
        //(oMethParam[0].GetInterface(IDBSQLObject, oInf))
          oInstanceType := oType.AsInstance;
          SetLength(oArgs, 1);
          oArgs[0] := TValue.From<IDBSQLObject>(AOwnerInterface);
          oValue := oMethCreate.Invoke(oInstanceType.MetaclassType, oArgs);
          Result := oValue.AsType<T>;
          Exit;
        end;
      end;
    end;
  finally
    oContex.Free;
  end;

end;

destructor TDBBaseObject.Destroy;
begin
  FreeAndNil(FSQL);
  inherited;
end;

procedure TDBBaseObject.DoAfterSave;
begin
  //
end;

procedure TDBBaseObject.DoBeforeSave;
begin
  //
end;

function TDBBaseObject.fnFindAttribute(AList: TArray<TCustomAttribute>;
  AAttrClass: TCustomAttributeClass): TCustomAttribute;
var
  oTmp: TCustomAttribute;
begin
  Result := nil;
  for oTmp in AList do
    if oTmp is AAttrClass then
      Result := oTmp;
end;

function TDBBaseObject.fnGetCanceledCondition: String;
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oProps: TArray<TRttiProperty>;
  oProp: TRttiProperty;
  oCancelAttr: TCanceledFilterField;
  oColAttr: TDBFieldInfo;
begin
  Result := '';
  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(Self.ClassType);

    oProps := oRttiType.GetProperties;
    for oProp in oProps do begin
      oCancelAttr := fnFindAttribute(oProp.GetAttributes, TCanceledFilterField) as TCanceledFilterField;
      if (not Assigned(oCancelAttr)) then
        Continue;
      oColAttr := fnFindAttribute(oProp.GetAttributes, TDBFieldInfo) as TDBFieldInfo;
      if (not Assigned(oColAttr)) then
        Continue;
      if (not Result.Trim.IsEmpty) then
        Result := Result + ' and ';

      Result := Result + oColAttr.FieldName + ' = 0'

    end;
  finally
    oRttiContext.Free;
  end;
end;

function TDBBaseObject.fnSQL(AKind: TSQLKind; AParamList: TDictionary<string, Variant>; ACondition: String; AFieldPrefix: string): string;
var
  slTemp: TStringList;
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oProps: TArray<TRttiProperty>;
  oProp: TRttiProperty;
  oColAttr: TDBFieldInfo;
  sFields: string;
  sParam: string;
  sTableName: string;
  oTabAttr: TDBTableInfo;
  vVal: Variant;
  sOrderBy: string;
  iPos: Integer;
begin
  {if (FSQL.TryGetValue(AKind, slTemp)) and (Assigned(slTemp)) then begin
    Result := slTemp.Text;
    Exit;
  end;}
  slTemp := TStringList.Create;
  case AKind of
    skInsert: slTemp.Add('insert into ');
    skUpdate: slTemp.Add('update ');
    skSelect,
    skOnlyFields: slTemp.Add('select ');
    skDelete: slTemp.Add('delete from ');
  end;
  if not AFieldPrefix.IsEmpty then
    AFieldPrefix := AFieldPrefix + '.';

  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(Self.ClassType);
    oTabAttr := fnFindAttribute(oRttiType.GetAttributes, TDBTableInfo) as TDBTableInfo;
    sTableName := oTabAttr.TableName;
    sOrderBy := oTabAttr.OrderBy;

    oProps := oRttiType.GetProperties;
    for oProp in oProps do begin
      oColAttr := fnFindAttribute(oProp.GetAttributes, TDBFieldInfo) as TDBFieldInfo;
      if (not Assigned(oColAttr)) then
        Continue;
      if (oColAttr.ReadOnly) then
        Continue;
      if (oColAttr.PrimaryKey) and (AKind = skUpdate) then
        Continue;


      case AKind of
        skInsert:
        begin
          sFields := sFields + oColAttr.FieldName + ', ';
          sParam := sParam + ':I_' + oColAttr.FieldName + ', ';
        end;
        skUpdate: sFields := sFields + oColAttr.FieldName + ' = :I_' + oColAttr.FieldName + ',' ;
        skSelect,
        skOnlyFields: sFields := sFields + AFieldPrefix + oColAttr.FieldName + ',' ;
      end;

      if (Assigned(AParamList)) and ((oColAttr.PrimaryKey) or (AKind in [skInsert, skUpdate])) then begin
        case oProp.PropertyType.TypeKind of
          tkUString:
            AParamList.Add('I_' + oColAttr.FieldName, oProp.GetValue(Self).AsString);
          tkInteger:
          begin
            vVal := oProp.GetValue(Self).AsInteger;
            if ((oColAttr.ForeignKey) and (AKind in [skInsert, skUpdate]) and (vVal = 0)) then
              AParamList.Add('I_' + oColAttr.FieldName, Null)
            else
              AParamList.Add('I_' + oColAttr.FieldName, vVal);
          end;
          tkFloat:
            AParamList.Add('I_' + oColAttr.FieldName, oProp.GetValue(Self).AsExtended);
          tkEnumeration:
          begin
            if oProp.PropertyType.Handle = TypeInfo(Boolean) then
              AParamList.Add('I_' + oColAttr.FieldName, oProp.GetValue(Self).AsOrdinal);
          end
        else
          AParamList.Add('I_' + oColAttr.FieldName, oProp.GetValue(Self).AsVariant);
        end;
      end;
    end;
  finally
    oRttiContext.Free;
  end;

  case AKind of
    skInsert: 
    begin
      sFields := sFields + 'INSERT_USER_ID, UPDATE_USER_ID, ' ;
      sParam := sParam + ':I_INSERT_USER_ID, :I_UPDATE_USER_ID, ' ;
      AParamList.Add('I_INSERT_USER_ID', FUserId);
      AParamList.Add('I_UPDATE_USER_ID', FUserId);
    end;
    skUpdate: 
    begin
      sFields := sFields + 'UPDATE_USER_ID = :I_UPDATE_USER_ID, UPDATE_DATETIME = :I_UPDATE_DATETIME, ' ;
      AParamList.Add('I_UPDATE_USER_ID', FUserId);
      AParamList.Add('I_UPDATE_DATETIME', Now);
    end;    

  end;  

  if (not sFields.Trim.IsEmpty) then
    sFields := sFields.TrimRight([',', ' ']);
  if (not sParam.Trim.IsEmpty) then
    sParam := sParam.TrimRight([',', ' ']);

  case AKind of
    skInsert:
    begin
      iPos := Pos(' ', sTableName);
      if (iPos > 1) then
        sTableName := Copy(sTableName, 1, iPos - 1);
      slTemp.Add(sTableName + ' ( ' + sFields + ') values (' + sParam + ')');
    end;
    skUpdate: 
    begin
      slTemp.Add(sTableName + ' set ' + sFields + ' where ID = :I_ID');
      AParamList.Add('I_ID', Id);
    end;
    skSelect,
    skOnlyFields:
    begin
      slTemp.Add(sFields + ' from ' + sTableName);
      if (AKind = skSelect) then
        slTemp.Add(' where ID = :I_ID')
      else
      begin
        if (not ACondition.Trim.IsEmpty) then
          slTemp.Add(ACondition);
        if (not sOrderBy.Trim.IsEmpty) then
          slTemp.Add('order by ' + sOrderBy.Trim);
      end;
    end;
    skDelete:
    begin
      slTemp.Add(sTableName + ' where ID = :I_ID');
    end;
  end;
  FSQL.AddOrSetValue(AKind, slTemp);
  Result := slTemp.Text;
end;

function TDBBaseObject.fnTableName(AWithPrefix: Boolean): String;
  function _fnAttr(AList: TArray<TCustomAttribute>; AAttrClass: TCustomAttributeClass): TCustomAttribute;
  var
    oTmp: TCustomAttribute;
  begin
    Result := nil;
    for oTmp in AList do
      if oTmp is AAttrClass then
        Result := oTmp;
  end;
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oTabAttr: TDBTableInfo;
  iPos: Integer;
begin
  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(Self.ClassType);
    oTabAttr := _fnAttr(oRttiType.GetAttributes, TDBTableInfo) as TDBTableInfo;
    if (not Assigned(oTabAttr)) then
      Exit;
    Result := oTabAttr.TableName;
    if (not AWithPrefix) then begin
      iPos := Pos(' ', Result);
      if (iPos > 1) then
        Result := Copy(Result, 1, iPos - 1);

    end;

  finally
    oRttiContext.Free;
  end;    

end;


function TDBBaseObject.GetFieldValue(AFieldName: string; AFormat: String): string;
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oRttiProp: TRttiProperty;
begin
  Result := '';
  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(Self.ClassType);
    oRttiProp := oRttiType.GetProperty(AFieldName);
    if (oRttiProp = nil) then
      Exit;

    case oRttiProp.PropertyType.TypeKind of
      tkUString: Result := oRttiProp.GetValue(Self).AsString;
      tkInteger: Result := IntToStr(oRttiProp.GetValue(Self).AsInteger);
      tkFloat:
      begin
        if oRttiProp.PropertyType.Handle = TypeInfo(TDate) then
          Result := FormatDateTime('dd-MM-yyyy', oRttiProp.GetValue(Self).AsExtended)
        else if oRttiProp.PropertyType.Handle = TypeInfo(TTime) then
          Result := FormatDateTime('HH:nn:ss', oRttiProp.GetValue(Self).AsExtended)
        else if oRttiProp.PropertyType.Handle = TypeInfo(TDateTime) then
          Result := FormatDateTime('dd-MM-yyyy HH:nn:ss', oRttiProp.GetValue(Self).AsExtended)
        else if oRttiProp.PropertyType.Handle = TypeInfo(Currency) then
          Result := FloatToStrF(oRttiProp.GetValue(Self).AsExtended, ffCurrency, 15, 2)
        else
        begin
          if (AFormat <> '') then
            Result := FormatFloat(AFormat, oRttiProp.GetValue(Self).AsExtended)
          else
            Result := FloatToStrF(oRttiProp.GetValue(Self).AsExtended, ffNumber, 15, 4);
        end;
      end;
      tkEnumeration:
        if oRttiProp.PropertyType.Handle = TypeInfo(Boolean) then
          Result := IfThenVar(oRttiProp.GetValue(Self).AsBoolean, 'T', 'F');
    else
      Result := oRttiProp.GetValue(Self).AsString;
    end;

  finally
    oRttiContext.Free;
  end;
end;

function TDBBaseObject.GetId: Integer;
begin
  Result := FId;
end;

function TDBBaseObject.GetTransaction: TIBTransaction;
begin
  Result := FTransaction;
end;

function TDBBaseObject.GetUserId: Integer;
begin
  Result := FUserId;
end;

procedure TDBBaseObject.prDelete;
var
  oIBSql: TIBSQL;
  oParamList: TDictionary<string, Variant>;
  oParam: TPair<string, Variant>;
  oSqlParam: TIBXSQLVAR;
begin
  oParamList := nil;
  oIBSql := nil;
  try
    oIBSql := TIBSQL.Create(nil);
    oIBSql.Transaction := FTransaction;

    oParamList := TDictionary<string, Variant>.Create();
    try
      if (not oIBSql.Transaction.InTransaction) then
        oIBSql.Transaction.StartTransaction();

      oIBSql.SQL.Text := fnSQL(skDelete, oParamList);


      for oParam in oParamList do begin
        oSqlParam := oIBSql.ParamByName(oParam.Key);

        case oSqlParam.SQLType of
          SQL_TIMESTAMP, SQL_TYPE_TIME, SQL_TYPE_DATE: oSqlParam.AsDateTime := oParam.Value;
        else
          oSqlParam.Value := oParam.Value;
        end;
      end;

      oIBSql.ExecQuery;
      oIBSql.Transaction.Commit;
    except
      on e: Exception do begin
        Application.MessageBox( PChar('OldId: ' + Self.Id.ToString + ', error: ' + e.Message), 'Error', MB_OK + MB_ICONSTOP);
        oIBSql.Transaction.Rollback;
      end;
    end;

  finally
    FreeAndNil(oParamList);
    FreeAndNil(oIBSql);
  end;
end;

procedure TDBBaseObject.prLoad;
var
  oIBSql: TIBSQL;
  oParamList: TDictionary<string, Variant>;
  oParam: TPair<string, Variant>;
  oSqlParam: TIBXSQLVAR;
begin
  try
    oIBSql := TIBSQL.Create(nil);
    oIBSql.Transaction := FTransaction;

    oParamList := TDictionary<string, Variant>.Create();
    try
      if (not oIBSql.Transaction.InTransaction) then
        oIBSql.Transaction.StartTransaction();


      oIBSql.SQL.Text := fnSQL(skSelect, oParamList);

      for oParam in oParamList do begin
        oSqlParam := oIBSql.ParamByName(oParam.Key);
        case oSqlParam.SQLType of
          SQL_TIMESTAMP, SQL_TYPE_TIME, SQL_TYPE_DATE: oSqlParam.AsDateTime := oParam.Value;
        else
          oSqlParam.Value := oParam.Value;
        end;
      end;

      oIBSql.ExecQuery;
      if (not oIBSql.Eof) then begin
        Self.Assign(oIBSql);
        FModified := False;
      end;
      oIBSql.Transaction.Commit;
    except
      on e: Exception do begin
        Application.MessageBox(PChar(e.Message), 'Error', MB_OK + MB_ICONSTOP);
        oIBSql.Transaction.Rollback;
      end;
    end;
  finally
    FreeAndNil(oParamList);
    FreeAndNil(oIBSql);
  end;

end;

procedure TDBBaseObject.prLoadList<T>(AList: TDBObjectList<T>; AIdFieldName: string; AId: Integer; ACanceled: Boolean);
var
  oObj: T;
  oIbSql: TIBSQL;
  oAdd: TDBBaseObject;
  sCondition: string;
begin
  oObj := TDBBaseObject.CreateInstance<T>(Self);
  try
    if (not (oObj is TDBBaseObject)) then
      Exit;
    try
      oIBSql := TIBSQL.Create(nil);
      oIBSql.Transaction := FTransaction;
      if (not oIBSql.Transaction.InTransaction) then
        oIBSql.Transaction.StartTransaction();

      sCondition := '';
      if (not ACanceled) then begin

        sCondition := TDBBaseObject(oObj).fnGetCanceledCondition();
        if (not sCondition.IsEmpty) then
          sCondition := ' and ' + sCondition;
      end;

      oIbSql.SQL.Text := TDBBaseObject(oObj).fnSQL(skOnlyFields, nil, ' where ' + AIdFieldName + ' = ' + IntToStr(AId) + sCondition);
      oIbSql.ExecQuery;
      while not oIbSql.Eof do begin
        oAdd := TDBBaseObject.CreateInstance<T>(Self) as TDBBaseObject;
        oAdd.Assign(oIbSql);
        oAdd.prSetRootObject(Self);
        AList.Add(oAdd);
        oIbSql.Next;
      end;
    finally
      FreeAndNil(oIbSql);
    end;
  finally
    FreeAndNil(oObj);
  end;
  AList.Id := AId;
end;

class procedure TDBBaseObject.prLoadObjectList<T>(AOwnerInterface: IDBSQLObject; AList: TDBObjectList<T>; ACanceled: Boolean; AOnCondition: TOnCondition);
var
  oObj: T;
  oIbSql: TIBSQL;
  oAdd: TDBBaseObject;
  sCondition: string;
begin
  AList.Clear();
  oObj := TDBBaseObject.CreateInstance<T>(AOwnerInterface);
  try
    if (not (oObj is TDBBaseObject)) then
      Exit;
    try
      oIBSql := TIBSQL.Create(nil);
      oIBSql.Transaction := AOwnerInterface.Transaction;
      if (not oIBSql.Transaction.InTransaction) then
        oIBSql.Transaction.StartTransaction();

      sCondition := '';
      if (not ACanceled) then begin

        sCondition := TDBBaseObject(oObj).fnGetCanceledCondition();
        if (Assigned(AOnCondition)) then
          AOnCondition(TDBBaseObject(oObj), sCondition);

        if (not sCondition.IsEmpty) then
          sCondition := ' where ' + sCondition;
      end;
      oIbSql.SQL.Text := Trim(TDBBaseObject(oObj).fnSQL(skOnlyFields, nil) + sCondition);
      oIbSql.ExecQuery;
      while not oIbSql.Eof do begin
        oAdd := TDBBaseObject.CreateInstance<T>(AOwnerInterface) as TDBBaseObject;
        oAdd.Assign(oIbSql);
        AList.Add(oAdd);
        oIbSql.Next;
      end;
    finally
      FreeAndNil(oIbSql);
    end;
  finally
    FreeAndNil(oObj);
  end;
end;

procedure TDBBaseObject.prSave;
var
  oIBSql: TIBSQL;
  oParamList: TDictionary<string, Variant>;
  oParam: TPair<string, Variant>;
  oSqlParam: TIBXSQLVAR;
  bError: Boolean;
  bShow: Boolean;
begin
  bError := False;
  DoBeforeSave();
  oParamList := nil;
  oIBSql := nil;
  try
    if (FModified) or (FId < 1) then begin
      oIBSql := TIBSQL.Create(nil);
      oIBSql.Transaction := FTransaction;

      oParamList := TDictionary<string, Variant>.Create();
      try
        if (not oIBSql.Transaction.InTransaction) then
          oIBSql.Transaction.StartTransaction();
        if (Id > 0) then
          oIBSql.SQL.Text := fnSQL(skUpdate, oParamList)
        else
        begin
          oIBSql.SQL.Text := 'select GEN_ID(GEN_' + fnTableName(False) + '_ID, 1) from RDB$DATABASE';
          oIBSql.ExecQuery;
          Id := oIBSql.Fields[0].AsInteger;
          oIBSql.Close;

          oIBSql.SQL.Text := fnSQL(skInsert, oParamList);
        end;

        for oParam in oParamList do begin
          oSqlParam := oIBSql.ParamByName(oParam.Key);

          case oSqlParam.SQLType of
            SQL_TIMESTAMP, SQL_TYPE_TIME, SQL_TYPE_DATE: oSqlParam.AsDateTime := oParam.Value;
            SQL_LONG:
              if (oParam.Value < 0) then
                oSqlParam.Value := Null
              else
                oSqlParam.AsInteger := oParam.Value;
          else
            oSqlParam.Value := oParam.Value;
          end;
        end;

        oIBSql.ExecQuery;
        oIBSql.Transaction.Commit;
      except
        on e: Exception do begin
          bShow := True;

          if (Assigned(FOnSaveError)) then
            FOnSaveError(Self, e, bShow);

          if (bShow) then begin
            bError := True;
            Application.MessageBox( PChar('Id: ' + Self.Id.ToString + ', error: ' + e.Message), 'Error', MB_OK + MB_ICONSTOP);
          end;
          try
            oIBSql.Transaction.Rollback;
          except
          end;
        end;
      end;
      FModified := False;
    end;
  finally
    FreeAndNil(oParamList);
    FreeAndNil(oIBSql);
  end;
  if (not bError) then
    DoAfterSave();
end;

procedure TDBBaseObject.prSetDefaultValue;
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oProps: TArray<TRttiProperty>;
  oProp: TRttiProperty;
  oDefAttr: TDefaultFieldValue;
begin
  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(Self.ClassType);

    oProps := oRttiType.GetProperties;
    for oProp in oProps do begin
      oDefAttr := fnFindAttribute(oProp.GetAttributes, TDefaultFieldValue) as TDefaultFieldValue;
      if (not Assigned(oDefAttr)) then
        Continue;

      case oProp.PropertyType.TypeKind of
        tkUString:
          oProp.SetValue(Self, TValue.From<string>(VarToStrDef(oDefAttr.Value, '')));
        tkInteger:
          oProp.SetValue(Self, TValue.From<Integer>(Integer(oDefAttr.Value)));
        tkFloat:
          oProp.SetValue(Self, TValue.From<Double>(double(oDefAttr.Value)));
      else
        oProp.SetValue(Self, TValue.FromVariant(oDefAttr.Value));
      end;
    end;
  finally
    oRttiContext.Free;
  end;
end;

procedure TDBBaseObject.prSetRootObject(AOwner: TDBBaseObject);
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oFields: TArray<TRttiField>;
  oField: TRttiField;
begin
  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(Self.ClassType);
    oFields := oRttiType.GetFields;
    for oField in oFields do begin

      if (oField.FieldType.IsInstance) and (oField.FieldType.AsInstance.MetaclassType = AOwner.ClassType) then begin
        oField.SetValue(Self, TValue.From<TDBBaseObject>(AOwner));
        Exit;
      end;
    end;
  finally
    oRttiContext.Free;
  end;
end;

procedure TDBBaseObject.SetId(const Value: Integer);
begin
  if (Value <> FId) then begin
    FId := Value;
    Change;
  end;
end;

{ TDBFieldInfo }

constructor TDBFieldInfo.Create(const AFieldName: string; const AReadOnly: Boolean; const APrimaryKey: Boolean; const AForeignKey: Boolean);
begin
  inherited Create;
  FFieldName := AFieldName;
  FReadOnly := AReadOnly;
  FPrimaryKey := APrimaryKey;
  FForeignKey := AForeignKey;
end;

{ TDBTableInfo }

constructor TDBTableInfo.Create(const ATableName: string; const AOrderBy: string);
begin
  FTableName := ATableName;
  FOrderBy := AOrderBy;
end;

{ TDBObjectList<T> }

constructor TDBObjectList<T>.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
  DoInit();
end;

constructor TDBObjectList<T>.Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean);
begin
  inherited Create(AComparer, AOwnsObjects);
  DoInit();
end;

constructor TDBObjectList<T>.Create(Collection: TEnumerable<T>; AOwnsObjects: Boolean);
begin
  inherited Create(Collection, AOwnsObjects);
  DoInit();
end;

destructor TDBObjectList<T>.Destroy;
begin
  FreeAndNil(FRemovedList);

  inherited;
end;

procedure TDBObjectList<T>.DisableControls;
begin
  Inc(FDisableCount);
end;

procedure TDBObjectList<T>.DoInit;
begin
  FRemovedList := TObjectList<T>.Create(OwnsObjects);
  FDisableCount := 0;
  FOnListChange := nil;
end;

procedure TDBObjectList<T>.EnableControls;
begin
  if (FDisableCount > 0) then begin
    Dec(FDisableCount);
    if (Assigned(FOnListChange)) then
      FOnListChange(Self, cnAdded);
  end;
end;

function TDBObjectList<T>.GetClassType: TClass;
var
  oContex: TRttiContext;
begin
  oContex := TRttiContext.Create;
  try
    Result := oContex.GetType(TypeInfo(T)).AsInstance.MetaclassType;
  finally
    oContex.Free;
  end;
end;

function TDBObjectList<T>.GetCount: Integer;
begin
  Result := Count;
end;

function TDBObjectList<T>.GetIndex(AObject: TObject): Integer;
begin
  Result := Self.IndexOf(AObject);

end;

function TDBObjectList<T>.GetItem(AIndex: Integer): TObject;
begin
  Result := nil;
  if (AIndex < 0) or (AIndex >= Count) then
    Exit;
  Result := TDBBaseObject(Self.Items[AIndex]);
end;

function TDBObjectList<T>.GetItemFieldBool(AIndex: Integer;
  AFieldName: string): Boolean;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= Count) then
    Exit;
  Result := TDBBaseObject(Self.Items[AIndex]).GetFieldValue(AFieldName, '') = 'T';
end;

function TDBObjectList<T>.GetItemFieldValue(AIndex: Integer; AFieldName: string; AFormat: String): string;
begin
  Result := '';
  if (AIndex < 0) or (AIndex >= Count) then
    Exit;
  Result := TDBBaseObject(Self.Items[AIndex]).GetFieldValue(AFieldName, AFormat);
end;

function TDBObjectList<T>.GetOnListChange: TListChange;
begin
  Result := FOnListChange;
end;

function TDBObjectList<T>.GetRemovedList: TObjectList<T>;
begin
  Result := FRemovedList;
end;

procedure TDBObjectList<T>.Notify(const Value: T; Action: TCollectionNotification);
begin
  //inherited;
  if (Action = cnRemoved) then begin
    if (OwnsObjects) and (Value is TDBBaseObject)  and (TDBBaseObject(Value).Id > 0) and (Assigned(FRemovedList)) then
      FRemovedList.Add(Value)
    else
    if (OwnsObjects) then
      Value.Free;


    if (Assigned(FOnListChange)) and (FDisableCount = 0) then
      FOnListChange(Self, cnRemoved);
  end
  else
  if (Action = cnAdded) then begin

    if (Assigned(FOnListChange)) and (FDisableCount = 0) then
      FOnListChange(Self, cnAdded);
  end;

  if Assigned(OnNotify) then
    OnNotify(Self, Value, Action);
end;

procedure TDBObjectList<T>.prClear;
begin
  DisableControls();
  Clear;
  FRemovedList.Clear();
  EnableControls();
end;

function TDBObjectList<T>.QueryInterface(const IID: TGUID; out Obj): HRESULT;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then Result := 0 else Result := E_NOINTERFACE;
end;

procedure TDBObjectList<T>.SetOnListChange(const Value: TListChange);
begin
  FOnListChange := Value;
end;

function TDBObjectList<T>._AddRef: Integer;
begin
  Result := -1;
end;

function TDBObjectList<T>._Release: Integer;
begin
  Result := -1;
end;

{ TDefaultFieldValue }

constructor TDefaultFieldValue.Create(const Value: Integer);
begin
  FValue := Value;
end;

constructor TDefaultFieldValue.Create(const Value: string);
begin
  FValue := Value;
end;

constructor TDefaultFieldValue.Create(const Value: Double);
begin
  FValue := Value;
end;

end.

