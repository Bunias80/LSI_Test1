unit sfmBaseGridForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, sfmBaseForm, JvValidators,
  System.ImageList, Vcl.ImgList, JvComponentBase, JvErrorIndicator,
  System.Actions, Vcl.ActnList, Vcl.StdCtrls, Vcl.ExtCtrls, JvExControls,
  JvGradient, Vcl.Grids, uSpetechDrawGrid, uBaseClasses;

type
  TfmBaseGridForm = class(TfmBaseForm)
    sdgBaseGrid: TSpetechDrawGrid;
    btnOK1: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    aDelete: TAction;
    procedure aAddExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
    procedure aDeleteExecute(Sender: TObject);
    procedure sdgBaseGridDblClick(Sender: TObject);
  private

  protected
    FEditFormClass: TfmBaseFormClass;
    procedure DoInit; override;
    procedure DoResult(AResult: Boolean); override;
    procedure prReload(); virtual; abstract;
    procedure prFiltr(); virtual;
    procedure prEdit(AObject: TDBBaseObject); virtual;
  public

  end;


implementation

{$R *.dfm}

uses
  uInterface, System.UITypes;

{ TfmBaseGridForm }

procedure TfmBaseGridForm.aAddExecute(Sender: TObject);
begin
  inherited;
  if (FEditFormClass.fnCreateAndRun(Self, nil)) then begin
    //TDBObjectList<TDBBaseObject>(sdgBaseGrid.DataLinkList).Add()
    prReload();
    prFiltr();;
  end;
end;

procedure TfmBaseGridForm.aDeleteExecute(Sender: TObject);
var
  oInf: IDeletedObject;
begin
  inherited;
  if (sdgBaseGrid.SelectObject <> nil) and (sdgBaseGrid.SelectObject.GetInterface(IDeletedObject, oInf)) then begin

    if (Application.MessageBox('Czy chcesz usun¹æ wybrany rekord ?', 'Usuwanie', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) <> mrYes) then
      Exit;
    oInf.prInActive();
    prReload();
    prFiltr();
  end;
end;

procedure TfmBaseGridForm.aEditExecute(Sender: TObject);
begin
  inherited;
  prEdit(sdgBaseGrid.SelectObject as TDBBaseObject);
end;

procedure TfmBaseGridForm.DoInit;
begin
  inherited;
  if (Assigned(FObj)) then begin
    aOK.Enabled := True;
    aOK.Visible := True;
  end;
end;

procedure TfmBaseGridForm.DoResult(AResult: Boolean);
begin
  inherited;
  if (Assigned(FObj)) and (Assigned(sdgBaseGrid.SelectObject)) and
    (sdgBaseGrid.SelectObject.ClassType = FObj.ClassType) then
    FObj.Assign(sdgBaseGrid.SelectObject as TDBBaseObject);
end;

procedure TfmBaseGridForm.prEdit(AObject: TDBBaseObject);
begin
  if (Assigned(AObject)) then begin
    if (FEditFormClass.fnCreateAndRun(Self, AObject)) then begin
      sdgBaseGrid.Invalidate;
    end;
  end;
end;

procedure TfmBaseGridForm.prFiltr;
begin
  //
end;

procedure TfmBaseGridForm.sdgBaseGridDblClick(Sender: TObject);
begin
  inherited;
  aOK.Execute;
end;

end.
