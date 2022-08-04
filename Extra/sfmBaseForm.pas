unit sfmBaseForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, JvExControls,
  JvGradientHeaderPanel, System.Actions, Vcl.ActnList, fMain, uBaseClasses, JvGradient, System.Generics.Collections,
  Vcl.ImgList, JvComponentBase, JvErrorIndicator, JvValidators, uInterface,
  System.ImageList;

type
  TfmBaseForm = class(TForm)
    p1: TPanel;
    bvl1: TBevel;
    alForm: TActionList;
    aOK: TAction;
    aCancel: TAction;
    btnCancel: TButton;
    btnOK: TButton;
    pBG: TPanel;
    pTop: TPanel;
    bvl2: TBevel;
    img1: TImage;
    JvGradient1: TJvGradient;
    lCaption: TLabel;
    ei1: TJvErrorIndicator;
    ilForm: TImageList;
    vs1: TJvValidationSummary;
    procedure aOKExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure prAfterShow(var AMessage: TMessage); message WM_AFTER_SHOW;
    function fnFindAttribute(AList: TArray<TCustomAttribute>; AAttrClass: TCustomAttributeClass): TCustomAttribute;
    function fnFindComponent(AParent: TWinControl; ACompName: string; ACompClass: TComponentClass): TComponent;
  protected
    FObj: TDBBaseObject;
    function DoAccept(): Boolean; virtual;
    procedure DoInit(); virtual;
    procedure DoResult(AResult: Boolean); virtual;
    procedure prAssignListToCombo<T: class>(AList: TObjectList<T>; ACombo: TComboBox; AId: Integer = -1); deprecated;
    function fnGetIdFromCombo(ACombo: TComboBox): Integer;
    procedure DoAfterShow(); virtual;
    procedure prAutoAssignFromObj();
    procedure prAutoAssignToObj();
    procedure prDisabledAllControls(AOwner: TWinControl);
    procedure prEnabledAllControls(AOwner: TWinControl);
  public
    class function fnCreateAndRun(AOwner: TComponent; AObj: TDBBaseObject): Boolean;
  end;

  TfmBaseFormClass = class of TfmBaseForm;

implementation

uses
  System.Rtti, System.TypInfo, uVCLDBClassesHelper, Vcl.ComCtrls, JvBaseEdits,
  Vcl.CheckLst, JvToolEdit;


{$R *.dfm}

procedure TfmBaseForm.aCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfmBaseForm.aOKExecute(Sender: TObject);
begin
  if (DoAccept()) then
    ModalResult := mrOk;
end;

procedure TfmBaseForm.prDisabledAllControls(AOwner: TWinControl);
var
  jj: Integer;
begin
  for jj := 0 to AOwner.ControlCount - 1 do begin
    if (AOwner.Controls[jj] is TEdit) then begin
      TEdit(AOwner.Controls[jj]).Enabled := False
    end
    else
    if (AOwner.Controls[jj] is TCustomComboBox) then
      TCustomComboBox(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TDateTimePicker) then
      TDateTimePicker(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TJvCalcEdit) then
      TJvCalcEdit(AOwner.Controls[jj]).ReadOnly := True
    else
    if (AOwner.Controls[jj] is TMemo) then
      TMemo(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TButtonedEdit) then
      TButtonedEdit(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TButton) then
      TButton(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TCheckBox) then
      TCheckBox(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TJvComboEdit) then
      TJvComboEdit(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TListBox) then
      TListBox(AOwner.Controls[jj]).Enabled := False
    else
    if (AOwner.Controls[jj] is TCheckListBox) then
      TCheckListBox(AOwner.Controls[jj]).Enabled := False;


    if (AOwner.Controls[jj] is TWinControl) then
      prDisabledAllControls(TWinControl(AOwner.Controls[jj]));



  end;
end;

procedure TfmBaseForm.prEnabledAllControls(AOwner: TWinControl);
var
  jj: Integer;
begin
  for jj := 0 to AOwner.ControlCount - 1 do begin
    if (AOwner.Controls[jj] is TEdit) then begin
      TEdit(AOwner.Controls[jj]).Enabled := True
    end
    else
    if (AOwner.Controls[jj] is TCustomComboBox) then
      TCustomComboBox(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TDateTimePicker) then
      TDateTimePicker(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TJvCalcEdit) then
      TJvCalcEdit(AOwner.Controls[jj]).ReadOnly := False
    else
    if (AOwner.Controls[jj] is TMemo) then
      TMemo(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TButtonedEdit) then
      TButtonedEdit(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TButton) then
      TButton(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TCheckBox) then
      TCheckBox(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TCheckListBox) then
      TCheckListBox(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TJvComboEdit) then
      TJvComboEdit(AOwner.Controls[jj]).Enabled := True
    else
    if (AOwner.Controls[jj] is TListBox) then
      TListBox(AOwner.Controls[jj]).Enabled := True;

    if (AOwner.Controls[jj] is TWinControl) then
      prEnabledAllControls(TWinControl(AOwner.Controls[jj]));

  end;
end;

function TfmBaseForm.DoAccept: Boolean;
begin
  Result := True;
end;

procedure TfmBaseForm.DoAfterShow;
begin
  //
  {$IFDEF _DEMO_}
  Caption := Caption + ' - wersja DEMO';
  {$ENDIF}
end;

procedure TfmBaseForm.DoInit;
begin
  //
end;

procedure TfmBaseForm.DoResult(AResult: Boolean);
begin
//
end;

class function TfmBaseForm.fnCreateAndRun(AOwner: TComponent; AObj: TDBBaseObject): Boolean;
var
  oFrm: TfmBaseForm;
begin
  oFrm := Self.Create(AOwner);
  try
    oFrm.FObj := AObj;
    oFrm.DoInit();
    Result := oFrm.ShowModal = mrOk;
    oFrm.DoResult(Result);
  finally
    oFrm.Free;
  end;
end;

function TfmBaseForm.fnFindAttribute(AList: TArray<TCustomAttribute>;
  AAttrClass: TCustomAttributeClass): TCustomAttribute;
var
  oTmp: TCustomAttribute;
begin
  Result := nil;
  for oTmp in AList do
    if oTmp is AAttrClass then
      Result := oTmp;
end;

function TfmBaseForm.fnFindComponent(AParent: TWinControl; ACompName: string;
  ACompClass: TComponentClass): TComponent;
  var
    ii: Integer;
  begin
    Result := nil;
    for ii := 0 to AParent.ControlCount - 1 do begin
      if (AParent.Controls[ii].Name = ACompName) and (AParent.Controls[ii] is ACompClass) then begin
        Result := AParent.Controls[ii];
        Exit;
      end;
      if (AParent.Controls[ii] is TWinControl) then begin
        Result := fnFindComponent(TWinControl(AParent.Controls[ii]), ACompName, ACompClass);
        if (Assigned(Result)) then
          Exit;
      end;


    end;
end;

function TfmBaseForm.fnGetIdFromCombo(ACombo: TComboBox): Integer;
var
  oObj: TObject;
begin
  Result := -1;
  if (ACombo.ItemIndex = -1) then
    Exit;

  try
    oObj := ACombo.Items.Objects[ACombo.ItemIndex];
    if (oObj = nil) then
      Exit;
    Result := Integer(oObj);
  except

  end;
end;

procedure TfmBaseForm.FormShow(Sender: TObject);
begin
  PostMessage(Handle, WM_AFTER_SHOW, 0, 0);
end;

procedure TfmBaseForm.prAfterShow(var AMessage: TMessage);
begin
  DoAfterShow();
end;

procedure TfmBaseForm.prAssignListToCombo<T>(AList: TObjectList<T>; ACombo: TComboBox; AId: Integer);
var
  oObj: T;
  iIndex: Integer;
begin
  ACombo.Clear;
  if (not TClass(T).InheritsFrom(TDBBaseObject)) then
    Exit;

  for oObj in AList do begin
    iIndex := ACombo.Items.AddObject(TDBBaseObject(oObj).ToString, TObject(TDBBaseObject(oObj).Id));
    if (AId > 0) and (TDBBaseObject(oObj).Id = AId) then
      ACombo.ItemIndex := iIndex;

  end;
end;

procedure TfmBaseForm.prAutoAssignFromObj;
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oProps: TArray<TRttiProperty>;
  oProp: TRttiProperty;
  oColAttr: TDBFieldInfo;
  oComp: TComponent;
begin
  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(FObj.ClassType);
    oProps := oRttiType.GetProperties;
    for oProp in oProps do begin
      oColAttr := fnFindAttribute(oProp.GetAttributes, TDBFieldInfo) as TDBFieldInfo;
      if (not Assigned(oColAttr)) then
        Continue;


      case oProp.PropertyType.TypeKind of
        tkUString:
        begin
          oComp := fnFindComponent(Self.pBG, 'e' + oProp.Name, TCustomEdit);
          if (Assigned(oComp)) then
            TCustomEdit(oComp).Text := oProp.GetValue(FObj).AsString
          else
          begin
            oComp := fnFindComponent(Self.pBG, 'm' + oProp.Name, TMemo);
            if (Assigned(oComp)) then
              TMemo(oComp).Lines.Text := oProp.GetValue(FObj).AsString;
          end;
          //oProp.SetValue(Self, oVal);
        end;
        tkInteger:
        begin
          oComp := fnFindComponent(Self.pBG, 'cb' + oProp.Name, TCustomComboBox);
          if (Assigned(oComp)) then
            TAssignData.SetCombo<TDBBaseObject>(TCustomComboBox(oComp), oProp.GetValue(FObj).AsInteger);

          {if (Source is TIBSQL) then
            oVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
          else
            oVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;
          oProp.SetValue(Self, oVal);}
        end;
        tkFloat:
        begin
          oComp := fnFindComponent(Self.pBG, 'dtp' + oProp.Name, TDateTimePicker);
          if (Assigned(oComp)) then begin
            TDateTimePicker(oComp).DateTime := oProp.GetValue(FObj).AsExtended
            //oProp.SetValue(FObj, oVal);
          end
          else
          begin
            oComp := fnFindComponent(Self.pBG, 'ce' + oProp.Name, TJvCalcEdit);
            if (Assigned(oComp)) then begin
              TJvCalcEdit(oComp).Value := oProp.GetValue(FObj).AsExtended;
              //oVal := TJvCalcEdit(oComp).Value;
              //oProp.SetValue(FObj, oVal);
            end
          end;

          {
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
          }

          {if (Source is TIBSQL) then begin
            case TIBSQL(Source).Fields[iFieldIndex].SQLType of
              SQL_TIMESTAMP, SQL_TYPE_TIME, SQL_TYPE_DATE: oVal := TIBSQL(Source).Fields[iFieldIndex].AsDateTime;
            else
              oVal := TIBSQL(Source).Fields[iFieldIndex].AsDouble;
            end;
          end
          else
            oVal := TDataSet(Source).Fields[iFieldIndex].AsFloat;
          oProp.SetValue(Self, oVal);}
        end;
        tkEnumeration:
        begin
          {if (Source is TIBSQL) then
            iVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
          else
            iVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;

          if oProp.PropertyType.Handle = TypeInfo(Boolean) then
            oProp.SetValue(Self, TValue.FromOrdinal(TypeInfo(Boolean), iVal));}
        end;
      else
            //
      end;
    end;
  finally
    oRttiContext.Free;
  end;
end;

procedure TfmBaseForm.prAutoAssignToObj;
var
  oRttiContext: TRttiContext;
  oRttiType: TRttiType;
  oProps: TArray<TRttiProperty>;
  oProp: TRttiProperty;
  oColAttr: TDBFieldInfo;
  oVal: TValue;
  oComp: TComponent;
begin
  oRttiContext := TRttiContext.Create();
  try
    oRttiType := oRttiContext.GetType(FObj.ClassType);
    oProps := oRttiType.GetProperties;
    for oProp in oProps do begin
      oColAttr := fnFindAttribute(oProp.GetAttributes, TDBFieldInfo) as TDBFieldInfo;
      if (not Assigned(oColAttr)) then
        Continue;


      case oProp.PropertyType.TypeKind of
        tkUString:
        begin
          oComp := fnFindComponent(Self.pBG, 'e' + oProp.Name, TCustomEdit);
          if (Assigned(oComp)) then begin
            oVal := TCustomEdit(oComp).Text;
            oProp.SetValue(FObj, oVal);
          end
          else
          begin
            oComp := fnFindComponent(Self.pBG, 'm' + oProp.Name, TMemo);
            if (Assigned(oComp)) then begin
              oVal := TMemo(oComp).Lines.Text;
              oProp.SetValue(FObj, oVal);
            end
          end;
          //oProp.SetValue(Self, oVal);
        end;
        tkInteger:
        begin
          oComp := fnFindComponent(Self.pBG, 'cb' + oProp.Name, TCustomComboBox);
          if (Assigned(oComp)) then begin
            oVal := TAssignData.GetIdCombo<TDBBaseObject>(TCustomComboBox(oComp));
            oProp.SetValue(FObj, oVal);
          end
          else
          begin
            oComp := fnFindComponent(Self.pBG, 'be' + oProp.Name, TButtonedEdit);
            if (Assigned(oComp)) then begin
              oVal := TButtonedEdit(oComp).Tag;
              oProp.SetValue(FObj, oVal);
            end
          end;

          {if (Source is TIBSQL) then
            oVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
          else
            oVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;
          oProp.SetValue(Self, oVal);}
        end;
        tkFloat:
        begin
          oComp := fnFindComponent(Self.pBG, 'dtp' + oProp.Name, TDateTimePicker);
          if (Assigned(oComp)) then begin
            oVal := TDateTimePicker(oComp).DateTime;
            oProp.SetValue(FObj, oVal);
          end
          else
          begin
            oComp := fnFindComponent(Self.pBG, 'ce' + oProp.Name, TJvCalcEdit);
            if (Assigned(oComp)) then begin
              oVal := TJvCalcEdit(oComp).Value;
              oProp.SetValue(FObj, oVal);
            end
          end;
          {if (Source is TIBSQL) then begin
            case TIBSQL(Source).Fields[iFieldIndex].SQLType of
              SQL_TIMESTAMP, SQL_TYPE_TIME, SQL_TYPE_DATE: oVal := TIBSQL(Source).Fields[iFieldIndex].AsDateTime;
            else
              oVal := TIBSQL(Source).Fields[iFieldIndex].AsDouble;
            end;
          end
          else
            oVal := TDataSet(Source).Fields[iFieldIndex].AsFloat;
          oProp.SetValue(Self, oVal);}
        end;
        tkEnumeration:
        begin
          {if (Source is TIBSQL) then
            iVal := TIBSQL(Source).Fields[iFieldIndex].AsInteger
          else
            iVal := TDataSet(Source).Fields[iFieldIndex].AsInteger;

          if oProp.PropertyType.Handle = TypeInfo(Boolean) then
            oProp.SetValue(Self, TValue.FromOrdinal(TypeInfo(Boolean), iVal));}
        end;
      else
            //
      end;
    end;
  finally
    oRttiContext.Free;
  end;

end;

end.
