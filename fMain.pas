unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxSkinsCore, dxSkinBasic, dxSkinBlack,
  dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkroom,
  dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinOffice2019Black, dxSkinOffice2019Colorful, dxSkinOffice2019DarkGray,
  dxSkinOffice2019White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringtime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, Vcl.StdCtrls, cxButtons, Vcl.ExtCtrls, cxLabel,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Phys.MSSQLDef, FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, Vcl.ComCtrls, dxCore, cxDateUtils,
  cxCalendar;

type
  TfmMain = class(TForm)
    pHeader: TPanel;
    cxbtnConnect: TcxButton;
    pFilter: TPanel;
    cxcbPlace: TcxComboBox;
    cxbtnFiltr: TcxButton;
    cxlPlace: TcxLabel;
    fdcMain: TFDConnection;
    fdqTemp: TFDQuery;
    fdphysmsqldrvrlnk1: TFDPhysMSSQLDriverLink;
    fdqExport: TFDQuery;
    dsExport: TDataSource;
    lrgntfldExportID: TLargeintField;
    wdstrngfldExportEXPORT_NAME: TWideStringField;
    dtfldExportEXPORT_DATE: TDateField;
    tmfldExportEXPORT_TIME: TTimeField;
    wdstrngfldExportEXPORT_USER: TWideStringField;
    wdstrngfldExportEXPORT_PLACE: TWideStringField;
    cxdbgtvGrid1DBTableView1: TcxGridDBTableView;
    cxgExport: TcxGrid;
    cxdbgtvExportTV: TcxGridDBTableView;
    cxglExportLvl: TcxGridLevel;
    cxgrdbclmncxg1DBTableView1EXPORT_NAME: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_DATE: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_TIME: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_USER: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_PLACE: TcxGridDBColumn;
    cxdbgtvcxg1DBTableView11: TcxGridDBTableView;
    cxgrdbclmncxg1DBTableView1EXPORT_NAME1: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_DATE1: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_TIME1: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_USER1: TcxGridDBColumn;
    cxgrdbclmncxg1DBTableView1EXPORT_PLACE1: TcxGridDBColumn;
    cxdbgtvGrid1DBTableView1Column1: TcxGridDBColumn;
    cxdeDateFrom: TcxDateEdit;
    cxlDateFrom: TcxLabel;
    cxdeDateTo: TcxDateEdit;
    cxlDateTo: TcxLabel;
    cxteConnection: TcxTextEdit;
    cxlConnection: TcxLabel;
    procedure cxbtnConnectClick(Sender: TObject);
    procedure cxbtnFiltrClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

const
  C_EXPORT = 'SELECT [ID], [EXPORT_NAME], CONVERT(date, [EXPORT_DATETIME]) as EXPORT_DATE, ' +
	           'CONVERT(time, [EXPORT_DATETIME]) as EXPORT_TIME, [EXPORT_USER], [EXPORT_PLACE] ' +
	           'FROM [dbo].[EXPORT]';


implementation

uses
  System.Math, System.DateUtils;

{$R *.dfm}

procedure TfmMain.cxbtnConnectClick(Sender: TObject);
begin
  if (not fdcMain.Connected) then begin
    try
      fdcMain.Open(cxteConnection.Text);
    except
      on e: Exception do begin
        ShowMessage('DB error: ' + e.Message);
        Exit;
      end;
    end;

  end;
  cxbtnConnect.Enabled := False;
  cxteConnection.Enabled := False;
  cxcbPlace.Enabled := True;
  cxbtnFiltr.Enabled := True;
  cxdeDateTo.Enabled := True;
  cxdeDateFrom.Enabled := True;
  try
    cxcbPlace.Properties.Items.Add('*WSZYSTKIE*');
    fdqTemp.Close;
    fdqTemp.SQL.Text := 'SELECT DISTINCT EXPORT_PLACE FROM EXPORT ORDER BY EXPORT_PLACE';
    fdqTemp.Open();
    while not fdqTemp.Eof do begin
      cxcbPlace.Properties.Items.Add(fdqTemp.FieldByName('EXPORT_PLACE').AsString);
      fdqTemp.Next;
    end;
  except
    on e: Exception do begin
      ShowMessage('SQL error: ' + e.Message);
      Exit;
    end;
  end;
  cxcbPlace.ItemIndex := 0;
end;

procedure TfmMain.cxbtnFiltrClick(Sender: TObject);
begin
  if (cxdeDateTo.Date < cxdeDateFrom.Date) then begin
    ShowMessage('Nieporawna data!');
    Exit;
  end;

  try
    fdqExport.Close;
    fdqExport.SQL.Text := C_EXPORT;

    fdqExport.SQL.Add(' where (convert(date, [EXPORT_DATETIME]) between :I_DATE_FROM and :I_DATE_TO) ');
    fdqExport.ParamByName('I_DATE_FROM').AsDate := Trunc(cxdeDateFrom.Date);
    fdqExport.ParamByName('I_DATE_TO').AsDate := Trunc(cxdeDateTo.Date) + 1;


    if (cxcbPlace.ItemIndex > 0) then begin
      fdqExport.SQL.Add(' and (EXPORT_PLACE = :I_EXPORT_PLACE) ');
      fdqExport.ParamByName('I_EXPORT_PLACE').AsString := cxcbPlace.Text;
    end;
    fdqExport.Open();
  except
    on e: Exception do begin
      ShowMessage('SQL error: ' + e.Message);
      Exit;
    end;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  cxdeDateFrom.Date := IncMonth(Now, -1);
  cxdeDateTo.Date := Now;
end;

end.
