unit uClasses;

interface

uses
  uBaseClasses, System.SysUtils, System.Generics.Collections, System.Classes, uInterface, System.StrUtils;
   //
type
  TPersons = class;

  [TDBTableInfo('T_USER')]
  TUser = class(TDBBaseObject)
  private
    FPassword: string;
    FLogin: string;
    FUserName: string;
    FTitle: string;
    FActive: Boolean;
    FPrivileges: Integer;
    function GetIsAdmin: Boolean;
    function GetIsIsRecived: Boolean;
    function GetCanEditConfirm: Boolean;
  public
    function ToString: string; override;

    property IsAdmin: Boolean read GetIsAdmin;
    property IsRecived: Boolean read GetIsIsRecived;
    property CanEditConfirm: Boolean read GetCanEditConfirm;
  published
    [TDBFieldInfo('LOGIN')]
    property Login: string read FLogin write FLogin;
    [TDBFieldInfo('PASSWORD')]
    property Password: string read FPassword write FPassword;
    [TDBFieldInfo('USER_NAME')]
    property UserName: string read FUserName write FUserName;
    [TDBFieldInfo('TITLE')]
    property Title: string read FTitle write FTitle;
    [TDBFieldInfo('ACTIVE')]
    property Active: Boolean read FActive write FActive;
    [TDBFieldInfo('PRIVILEGES')]
    property Privileges: Integer read FPrivileges write FPrivileges;
  end;

  [TDBTableInfo('T_VOIVODESHIP')]
  TVoivodeship = class(TDBBaseObject)
  private
    FVoivodeshipName: String;
    //
    //FShopsList: TDBObjectList<TShops>;
    //
  protected
  public
    function ToString(): string; override;
    destructor Destroy; override;
    //
    //property ShopsList: TDBObjectList<TShops> read GetShopsList;
  published
    [TDBFieldInfo('VOIVODESHIP_NAME')]
    property VoivodeshipName: String read FVoivodeshipName write FVoivodeshipName;
  end;

  [TDBTableInfo('T_SHOPS s')]
  TShops = class(TDBBaseObject)
  private
    FShopName: String;
    FCity: String;
    FAddress: String;
    FPostCode: String;
    FVoivodeshipId: Integer;
    //
    FVoivodeship: TVoivodeship;
    //
    function GetVoivodeship(): TVoivodeship;
    function GetFullAddress: string;
  protected
  public

    function ToString(): string; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    //
    property Voivodeship: TVoivodeship read GetVoivodeship;
    property FullAddress: string read GetFullAddress;
  published
    [TDBFieldInfo('SHOP_NAME')]
    property ShopName: String read FShopName write FShopName;
    [TDBFieldInfo('CITY')]
    property City: String read FCity write FCity;
    [TDBFieldInfo('ADDRESS')]
    property Address: String read FAddress write FAddress;
    [TDBFieldInfo('POST_CODE')]
    property PostCode: String read FPostCode write FPostCode;
    [TDBFieldInfo('VOIVODESHIP_ID')]
    property VoivodeshipId: Integer read FVoivodeshipId write FVoivodeshipId;
  end;

  [TDBTableInfo('T_FUNDRAISING f')]
  TFundraising = class(TDBBaseObject, IDeletedObject)
  private
    FTitle: String;
    FPerson: String;
    FActive: Boolean;
  protected
  public
    function ToString(): string; override;
    procedure Assign(Source: TPersistent); override;
    procedure prInActive();
  published
    [TDBFieldInfo('TITLE')]
    property Title: String read FTitle write FTitle;
    [TDBFieldInfo('PERSON')]
    property Person: String read FPerson write FPerson;
    [TDBFieldInfo('ACTIVE')]
    property Active: Boolean read FActive write FActive;
  end;

  [TDBTableInfo('T_MONEYBOX m')]
  TMoneybox = class(TDBBaseObject)
  private
    FBoxColor: String;
    FBoxSize: String;
    FBoxType: String;
    FNotice: String;
    function GetBoxTypeTxt: String;
  protected

  public
    function ToString(): string; override;
    procedure Assign(Source: TPersistent); override;

  published
    [TDBFieldInfo('BOX_COLOR')]
    property BoxColor: String read FBoxColor write FBoxColor;
    [TDBFieldInfo('BOX_SIZE')]
    property BoxSize: String read FBoxSize write FBoxSize;
    [TDBFieldInfo('BOX_TYPE')]
    property BoxType: String read FBoxType write FBoxType;
    [TDBFieldInfo('NOTICE')]
    property Notice: String read FNotice write FNotice;
    //
    property BoxTypeTxt: String read GetBoxTypeTxt;
  end;

  [TDBTableInfo('T_COLLECTION c')]
  TCollection = class(TDBBaseObject, IDeletedObject)
  private
    FShopId: Integer;
    FFundraisingId: Integer;
    FPlaceDate: TDate;
    FPlanReceivedDate: TDate;
    FBoxId: Integer;
    FBoxNumber: String;
    FReceivedDate: TDate;
    FAmount: Currency;
    FKpNumber: String;
    FReceivedPeople: String;
    FNotice: String;
    //
    FShop: TShops;
    FFundraising: TFundraising;
    FBox: TMoneybox;
    //FPlacePerson: TPersons;
    FState: String;
    //FPlacePersonId: Integer;
    FActive: Boolean;
    FPlacePerson: String;
    //
    function GetFundraising(): TFundraising;
    function GetBox(): TMoneybox;
    //function GetPlaceUser(): TUser;
    //function GetPlaceUserTxt: string;
    function GetShopTxt: string;
    function GetShop: TShops;
    function GetBoxTxt: string;
    //function GetPlacePerson: TPersons;
    //function GetPlacePersonTxt: string;

  protected
  public
    destructor Destroy; override;
    constructor Create(AOwnerInterface: IDBSQLObject); override;
    function ToString(): string; override;
    procedure prInActive();
    //
    property Shop: TShops read GetShop;
    property Fundraising: TFundraising read GetFundraising;
    property Box: TMoneybox read GetBox;
    //property PlacePerson: TPersons read GetPlacePerson;

    class procedure prLoadAll(AOwnerInterface: IDBSQLObject; AList: TDBObjectList<TCollection>; ACanceled: Boolean = False; AOnCondition: TOnCondition = nil);
  published
    [TDBFieldInfo('SHOP_ID')]
    property ShopId: Integer read FShopId write FShopId;
    [TDBFieldInfo('FUNDRAISING_ID')]
    property FundraisingId: Integer read FFundraisingId write FFundraisingId;
    [TDBFieldInfo('PLACE_DATE')]
    property PlaceDate: TDate read FPlaceDate write FPlaceDate;
    [TDBFieldInfo('PLAN_RECEIVED_DATE')]
    property PlanReceivedDate: TDate read FPlanReceivedDate write FPlanReceivedDate;
    [TDBFieldInfo('BOX_ID')]
    property BoxId: Integer read FBoxId write FBoxId;
    [TDBFieldInfo('BOX_NUMBER')]
    property BoxNumber: String read FBoxNumber write FBoxNumber;
    //[TDBFieldInfo('PLACE_USER_ID')]
    //property PlaceUserId: Integer read FPlaceUserId write FPlaceUserId;
    //[TDBFieldInfo('PLACE_PERSON_ID')]
    //property PlacePersonId: Integer read FPlacePersonId write FPlacePersonId;
    [TDBFieldInfo('PLACE_PERSON')]
    property PlacePerson: String read FPlacePerson write FPlacePerson;
    [TDBFieldInfo('RECEIVED_DATE')]
    property ReceivedDate: TDate read FReceivedDate write FReceivedDate;
    [TDBFieldInfo('AMOUNT')]
    property Amount: Currency read FAmount write FAmount;
    [TDBFieldInfo('KP_NUMBER')]
    property KpNumber: String read FKpNumber write FKpNumber;
    [TDBFieldInfo('RECEIVED_PEOPLES')]
    property ReceivedPeople: String read FReceivedPeople write FReceivedPeople;
    [TDBFieldInfo('STATE')]
    property State: String read FState write FState;
    [TDBFieldInfo('NOTICE')]
    property Notice: String read FNotice write FNotice;
    [TDBFieldInfo('ACTIVE')]
    property Active: Boolean read FActive write FActive;
    //
    //property PlacePersonTxt: string read GetPlacePersonTxt;
    property ShopTxt: string read GetShopTxt;
    property BoxTxt: string read GetBoxTxt;
  end;

  [TDBTableInfo('T_GIFTS')]
  TGifts = class(TDBBaseObject)
  private
    FShopId: Integer;
    FUserId: Integer;
    FGiveDate: TDate;
    FGiftNotice: String;
    //
    FShop: TShops;
    FUser: TUser;
    FPerson: String;
    //
    function GetShop(): TShops;
    function GetUser(): TUser;
    function GetShopTxt: string;
    function GetUserTxt: string;
  protected
  public
    function ToString(): string; override;
    destructor Destroy; override;
    //
    property Shop: TShops read GetShop;
    property User: TUser read GetUser;
  published
    [TDBFieldInfo('SHOP_ID')]
    property ShopId: Integer read FShopId write FShopId;
    [TDBFieldInfo('PERSON')]
    property Person: String read FPerson write FPerson;
    [TDBFieldInfo('USER_ID')]
    property UserId: Integer read FUserId write FUserId;
    [TDBFieldInfo('GIVE_DATE')]
    property GiveDate: TDate read FGiveDate write FGiveDate;
    [TDBFieldInfo('GIFT_NOTICE')]
    property GiftNotice: String read FGiftNotice write FGiftNotice;
    //
    property UserTxt: string read GetUserTxt;
    property ShopTxt: string read GetShopTxt;
  end;

  [TDBTableInfo('T_PERSONS')]
  TPersons = class(TDBBaseObject)
  private
    FTitle: String;
  protected
  public
    function ToString(): string; override;
  published
    [TDBFieldInfo('TITLE')]
    property Title: String read FTitle write FTitle;
  end;

const
  C_BIT_ADMIN = 1;
  C_BIT_RECIVED = 2;
  C_BIT_EDIT = 3;
  //
  C_BOXID_FUNDATION = 1;
  C_BOXID_PEOPLE = 2;

implementation

uses
  uGlobalHelper, IBX.IBSQL, IBX.IBDatabase;

{ TUser }

function TUser.GetCanEditConfirm: Boolean;
begin
  Result := TSpeetchBits.GetBit(Privileges, C_BIT_EDIT);
end;

function TUser.GetIsAdmin: Boolean;
begin
  Result := TSpeetchBits.GetBit(Privileges, C_BIT_ADMIN);
end;

function TUser.GetIsIsRecived: Boolean;
begin
  Result := TSpeetchBits.GetBit(Privileges, C_BIT_RECIVED);
end;

function TUser.ToString: string;
begin
  Result := Title;
end;

{ TVoivodeship }

destructor TVoivodeship.Destroy;
begin

  inherited;
end;

function TVoivodeship.ToString: string;
begin
  Result := VoivodeshipName;
end;

{ TShops }

procedure TShops.Assign(Source: TPersistent);
begin
  if (Source is TShops) then begin
    Self.Id := TShops(Source).Id;
    Self.ShopName := TShops(Source).ShopName;
    Self.City := TShops(Source).City;
    Self.Address := TShops(Source).Address;
    Self.PostCode := TShops(Source).PostCode;
    Self.VoivodeshipId := TShops(Source).VoivodeshipId;
    Exit;
  end;
  inherited;
end;

destructor TShops.Destroy;
begin
  if Assigned(FVoivodeship) and (FVoivodeship.FOwner = Self) then
    FreeAndNil(FVoivodeship);
  inherited;
end;

function TShops.GetFullAddress: string;
begin
  Result := PostCode + ' ' + City +  ', ' + Voivodeship.VoivodeshipName + ', ' + Address;
end;

function TShops.GetVoivodeship: TVoivodeship;
begin
  if (not Assigned(FVoivodeship)) then
    FVoivodeship := TVoivodeship.Create(Self);
  if ((FVoivodeship.Id <> VoivodeshipId) and (VoivodeshipId > 0)) then begin
    FVoivodeship.Id := VoivodeshipId;
    FVoivodeship.prLoad();
  end;
  Result := FVoivodeship;
end;

function TShops.ToString: string;
begin
  Result := ShopName + ' (' + City + ')';
end;

{ TFundraising }

procedure TFundraising.Assign(Source: TPersistent);
begin
  if (Source is TFundraising) then begin
    Self.Id := TFundraising(Source).Id;
    Self.Title := TFundraising(Source).Title;
    Self.Person := TFundraising(Source).Person;
    Self.Active := TFundraising(Source).Active;
    Exit;
  end;
  inherited;
end;

procedure TFundraising.prInActive;
begin
  Active := False;
  prSave();
end;

function TFundraising.ToString: string;
begin
  Result := Title + IfThenVar(Person.Trim.IsEmpty, '', ' (' + Person + ')');
end;

{ TMoneybox }

procedure TMoneybox.Assign(Source: TPersistent);
begin
  if (Source is TMoneybox) then begin
    Self.Id := TMoneybox(Source).Id;
    Self.BoxColor := TMoneybox(Source).BoxColor;
    Self.BoxSize := TMoneybox(Source).BoxSize;
    Self.BoxType := TMoneybox(Source).BoxType;
    Self.Notice := TMoneybox(Source).Notice;
    Exit;
  end;
  inherited;
end;

function TMoneybox.GetBoxTypeTxt: String;
begin
  Result := IfThen(BoxType = 'P', 'Podopiecznych', 'Fundacji')
end;

function TMoneybox.ToString: string;
begin
  Result := BoxSize;
  if (not BoxColor.Trim.IsEmpty) then
    Result := Result + ' (' + BoxColor + ' )';
end;

{ TCollection }

function TCollection.ToString(): string;
begin
  Result := '';
end;

constructor TCollection.Create(AOwnerInterface: IDBSQLObject);
begin
  inherited;
  FActive := True;
end;

destructor TCollection.Destroy;
begin
  if Assigned(FShop) and (FShop.FOwner = Self) then
    FreeAndNil(FShop);
  if Assigned(FFundraising) and (FFundraising.FOwner = Self) then
    FreeAndNil(FFundraising);
  if Assigned(FBox) and (FBox.FOwner = Self) then
    FreeAndNil(FBox);
  //if Assigned(FPlacePerson) and (FPlacePerson.FOwner = Self) then
  //  FreeAndNil(FPlacePerson);
  inherited;
end;

function TCollection.GetShop(): TShops;
begin
  if (not Assigned(FShop)) then
    FShop := TShops.Create(Self);
  if ((FShop.Id <> ShopId) and (ShopId > 0)) then begin
    FShop.Id := ShopId;
    FShop.prLoad();
  end;
  Result := FShop;
end;

function TCollection.GetShopTxt: string;
begin
  Result := Shop.ShopName;
end;

procedure TCollection.prInActive;
begin
  Active := False;
  prSave();
end;

class procedure TCollection.prLoadAll(AOwnerInterface: IDBSQLObject; AList: TDBObjectList<TCollection>;
  ACanceled: Boolean; AOnCondition: TOnCondition);
var
  oObj: TCollection;

  oIbSql: TIBSQL;
  oAdd: TCollection;
  sCondition: string;
  sSql: string;
begin
  AList.Clear();
  oObj := TCollection.Create(AOwnerInterface);
  try
    try
      oIBSql := TIBSQL.Create(nil);
      oIBSql.Transaction := AOwnerInterface.Transaction;
      if (not oIBSql.Transaction.InTransaction) then
        oIBSql.Transaction.StartTransaction();

      sCondition := '';
      if (not ACanceled) then begin

        sCondition := oObj.fnGetCanceledCondition();
        if (Assigned(AOnCondition)) then
          AOnCondition(oObj, sCondition);

        if (not sCondition.IsEmpty) then
          sCondition := ' where ' + sCondition;
      end;
      sSql := 'select c.ID, c.SHOP_ID, c.FUNDRAISING_ID, c.PLACE_DATE, c.PLAN_RECEIVED_DATE, ' +
              'c.BOX_ID, c.BOX_NUMBER, c.PLACE_PERSON_ID, c.PLACE_PERSON, c.RECEIVED_DATE, ' +
              'c.AMOUNT, c.KP_NUMBER, c.RECEIVED_PEOPLES, c.NOTICE, c.STATE, c.LOCK_TIME, c.LOCK_USER_ID, c.ACTIVE, ' +
              's.SHOP_NAME, s.CITY, s.ADDRESS, s.POST_CODE, s.VOIVODESHIP_ID, ' +
              'b.BOX_COLOR,b .BOX_SIZE, b.BOX_TYPE, b.NOTICE, f.TITLE, f.PERSON ' +
              'from T_COLLECTION c ' +
              'left join T_SHOPS s on (s.ID = c.SHOP_ID) ' +
              'left join T_MONEYBOX b on (b.ID = c.BOX_ID) ' +
              'left join T_FUNDRAISING f on (f.ID = c.FUNDRAISING_ID)' + sCondition;

      oIbSql.SQL.Text := sSql;
      oIbSql.ExecQuery;
      while not oIbSql.Eof do begin
        oAdd := TCollection.Create(AOwnerInterface);
        oAdd.Shop.Assign(oIbSql);
        oAdd.Shop.Id := oIbSql.FieldByName('SHOP_ID').AsInteger;
        oAdd.Box.Assign(oIbSql);
        oAdd.Box.Id := oIbSql.FieldByName('BOX_ID').AsInteger;
        oAdd.Fundraising.Assign(oIbSql);
        oAdd.Fundraising.Id := oIbSql.FieldByName('FUNDRAISING_ID').AsInteger;
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

function TCollection.GetFundraising(): TFundraising;
begin
  if (not Assigned(FFundraising)) then
    FFundraising := TFundraising.Create(Self);
  if ((FFundraising.Id <> FundraisingId) and (FundraisingId > 0)) then begin
    FFundraising.Id := FundraisingId;
    FFundraising.prLoad();
  end;
  Result := FFundraising;
end;

function TCollection.GetBox(): TMoneybox;
begin
  if (not Assigned(FBox)) then
    FBox := TMoneybox.Create(Self);
  if ((FBox.Id <> BoxId) and (BoxId > 0)) then begin
    FBox.Id := BoxId;
    FBox.prLoad();
  end;
  Result := FBox;
end;

function TCollection.GetBoxTxt: string;
begin
  Result := Box.ToString;
end;

(*
function TCollection.GetPlacePersonTxt: string;
begin
  Result := PlacePerson.ToString;
end;

function TCollection.GetPlacePerson(): TPersons;
begin
  if (not Assigned(FPlacePerson)) then
    FPlacePerson := TPersons.Create(Self);
  if ((FPlacePerson.Id <> PlacePersonId) and (PlacePersonId > 0)) then begin
    FPlacePerson.Id := PlacePersonId;
    FPlacePerson.prLoad();
  end;
  Result := FPlacePerson;
end;
*)

{ TGifts }

destructor TGifts.Destroy;
begin
  if Assigned(FShop) and (FShop.FOwner = Self) then
    FreeAndNil(FShop);
  if Assigned(FUser) and (FUser.FOwner = Self) then
    FreeAndNil(FUser);
  inherited;
end;

function TGifts.GetShop: TShops;
begin
  if (not Assigned(FShop)) then
    FShop := TShops.Create(Self);
  if ((FShop.Id <> ShopId) and (ShopId > 0)) then begin
    FShop.Id := ShopId;
    FShop.prLoad();
  end;
  Result := FShop;
end;

function TGifts.GetShopTxt: string;
begin
  Result := Person + ' ' + Shop.ShopName;
end;

function TGifts.GetUser: TUser;
begin
  if (not Assigned(FUser)) then
    FUser := TUser.Create(Self);
  if ((FUser.Id <> UserId) and (UserId > 0)) then begin
    FUser.Id := UserId;
    FUser.prLoad();
  end;
  Result := FUser;
end;

function TGifts.GetUserTxt: string;
begin
  Result := User.Title;
end;

function TGifts.ToString: string;
begin
  Result := Person + ' ' + GiftNotice;
end;

{ TPersons }

function TPersons.ToString: string;
begin
  Result := Title.Trim;
end;

end.
