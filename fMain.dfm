object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Raport'
  ClientHeight = 561
  ClientWidth = 961
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pHeader: TPanel
    Left = 0
    Top = 0
    Width = 961
    Height = 89
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      961
      89)
    object cxbtnConnect: TcxButton
      Left = 874
      Top = 56
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Connect'
      TabOrder = 0
      OnClick = cxbtnConnectClick
    end
    object cxteConnection: TcxTextEdit
      Left = 16
      Top = 29
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = 
        'SERVER=LAP-GORAK\SQLEXPRESS;OSAuthent=Yes;ApplicationName=Enterp' +
        'rise/Architect/Ultimate;Workstation=LAP-GORAK;DATABASE=LSI_Expor' +
        't;MARS=yes;DriverID=MSSQL'
      Width = 933
    end
    object cxlConnection: TcxLabel
      Left = 18
      Top = 6
      Caption = 'Connection string'
    end
  end
  object pFilter: TPanel
    Left = 0
    Top = 89
    Width = 185
    Height = 472
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    ExplicitTop = 78
    ExplicitHeight = 480
    object cxcbPlace: TcxComboBox
      Left = 16
      Top = 29
      Enabled = False
      Properties.DropDownListStyle = lsEditFixedList
      TabOrder = 0
      Width = 161
    end
    object cxbtnFiltr: TcxButton
      Left = 16
      Top = 440
      Width = 75
      Height = 25
      Caption = 'Zatwierd'#378
      Enabled = False
      TabOrder = 1
      OnClick = cxbtnFiltrClick
    end
    object cxlPlace: TcxLabel
      Left = 16
      Top = 6
      Caption = 'Lokal'
    end
    object cxdeDateFrom: TcxDateEdit
      Left = 16
      Top = 79
      Enabled = False
      Properties.DateButtons = [btnToday]
      Properties.SaveTime = False
      Properties.ShowTime = False
      Properties.ShowToday = False
      TabOrder = 3
      Width = 161
    end
    object cxlDateFrom: TcxLabel
      Left = 16
      Top = 56
      Caption = 'Data od'
    end
    object cxdeDateTo: TcxDateEdit
      Left = 18
      Top = 129
      Enabled = False
      Properties.DateButtons = [btnToday]
      Properties.SaveTime = False
      Properties.ShowTime = False
      Properties.ShowToday = False
      TabOrder = 5
      Width = 161
    end
    object cxlDateTo: TcxLabel
      Left = 18
      Top = 106
      Caption = 'Data do'
    end
  end
  object cxg1: TcxGrid
    Left = 185
    Top = 89
    Width = 776
    Height = 472
    Align = alClient
    TabOrder = 2
    ExplicitTop = 81
    ExplicitHeight = 480
    object cxdbgtvGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      object cxdbgtvGrid1DBTableView1Column1: TcxGridDBColumn
        DataBinding.IsNullValueType = True
      end
    end
    object cxdbgtvcxg1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.First.Visible = True
      Navigator.Buttons.PriorPage.Visible = True
      Navigator.Buttons.Prior.Visible = True
      Navigator.Buttons.Next.Visible = True
      Navigator.Buttons.NextPage.Visible = True
      Navigator.Buttons.Last.Visible = True
      Navigator.Buttons.Insert.Visible = True
      Navigator.Buttons.Append.Visible = False
      Navigator.Buttons.Delete.Visible = True
      Navigator.Buttons.Edit.Visible = True
      Navigator.Buttons.Post.Visible = True
      Navigator.Buttons.Cancel.Visible = True
      Navigator.Buttons.Refresh.Visible = True
      Navigator.Buttons.SaveBookmark.Visible = True
      Navigator.Buttons.GotoBookmark.Visible = True
      Navigator.Buttons.Filter.Visible = True
      FilterBox.Visible = fvNever
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataModeController.SyncMode = False
      DataController.DataSource = dsExport
      DataController.KeyFieldNames = 'ID'
      DataController.MultiThreadedOptions.Filtering = bFalse
      DataController.MultiThreadedOptions.Sorting = bFalse
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      OptionsView.HeaderFilterButtonShowMode = fbmSmartTag
      OptionsView.ShowColumnFilterButtons = sfbWhenSelected
      object cxgrdbclmncxg1DBTableView1EXPORT_NAME: TcxGridDBColumn
        Caption = 'Nazwa'
        DataBinding.FieldName = 'EXPORT_NAME'
        Width = 200
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_DATE: TcxGridDBColumn
        Caption = 'Data'
        DataBinding.FieldName = 'EXPORT_DATE'
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_TIME: TcxGridDBColumn
        Caption = 'Godzina'
        DataBinding.FieldName = 'EXPORT_TIME'
        Width = 87
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_USER: TcxGridDBColumn
        Caption = 'U'#380'ytkownik'
        DataBinding.FieldName = 'EXPORT_USER'
        Width = 200
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_PLACE: TcxGridDBColumn
        Caption = 'Lokal'
        DataBinding.FieldName = 'EXPORT_PLACE'
        Width = 200
      end
    end
    object cxdbgtvcxg1DBTableView11: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.First.Visible = True
      Navigator.Buttons.PriorPage.Visible = True
      Navigator.Buttons.Prior.Visible = True
      Navigator.Buttons.Next.Visible = True
      Navigator.Buttons.NextPage.Visible = True
      Navigator.Buttons.Last.Visible = True
      Navigator.Buttons.Insert.Visible = True
      Navigator.Buttons.Append.Visible = False
      Navigator.Buttons.Delete.Visible = True
      Navigator.Buttons.Edit.Visible = True
      Navigator.Buttons.Post.Visible = True
      Navigator.Buttons.Cancel.Visible = True
      Navigator.Buttons.Refresh.Visible = True
      Navigator.Buttons.SaveBookmark.Visible = True
      Navigator.Buttons.GotoBookmark.Visible = True
      Navigator.Buttons.Filter.Visible = True
      FilterBox.Visible = fvNever
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataModeController.SyncMode = False
      DataController.DataSource = dsExport
      DataController.KeyFieldNames = 'ID'
      DataController.MultiThreadedOptions.Filtering = bFalse
      DataController.MultiThreadedOptions.Sorting = bFalse
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      OptionsView.HeaderFilterButtonShowMode = fbmSmartTag
      OptionsView.ShowColumnFilterButtons = sfbWhenSelected
      object cxgrdbclmncxg1DBTableView1EXPORT_NAME1: TcxGridDBColumn
        DataBinding.FieldName = 'EXPORT_NAME'
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_DATE1: TcxGridDBColumn
        DataBinding.FieldName = 'EXPORT_DATE'
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_TIME1: TcxGridDBColumn
        DataBinding.FieldName = 'EXPORT_TIME'
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_USER1: TcxGridDBColumn
        DataBinding.FieldName = 'EXPORT_USER'
      end
      object cxgrdbclmncxg1DBTableView1EXPORT_PLACE1: TcxGridDBColumn
        DataBinding.FieldName = 'EXPORT_PLACE'
      end
    end
    object cxglcxg1Level1: TcxGridLevel
      Caption = 'cxg1Level1'
      GridView = cxdbgtvcxg1DBTableView1
    end
  end
  object fdcMain: TFDConnection
    Params.Strings = (
      'SERVER=LAP-GORAK\SQLEXPRESS'
      'OSAuthent=Yes'
      'ApplicationName=Enterprise/Architect/Ultimate'
      'Workstation=LAP-GORAK'
      'DATABASE=LSI_Export'
      'MARS=yes'
      'DriverID=MSSQL')
    Connected = True
    LoginPrompt = False
    Left = 344
    Top = 128
  end
  object fdqTemp: TFDQuery
    Connection = fdcMain
    Left = 392
    Top = 128
  end
  object fdphysmsqldrvrlnk1: TFDPhysMSSQLDriverLink
    Left = 496
    Top = 224
  end
  object fdqExport: TFDQuery
    Connection = fdcMain
    SQL.Strings = (
      'SELECT TOP (1000) [ID]'
      '      ,[EXPORT_NAME]'
      '      ,CONVERT(date, [EXPORT_DATETIME]) as EXPORT_DATE'
      #9'  ,CONVERT(time, [EXPORT_DATETIME]) as EXPORT_TIME'
      '      ,[EXPORT_USER]'
      '      ,[EXPORT_PLACE]'
      '  FROM [LSI_Export].[dbo].[EXPORT]')
    Left = 632
    Top = 120
    object lrgntfldExportID: TLargeintField
      AutoGenerateValue = arAutoInc
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object wdstrngfldExportEXPORT_NAME: TWideStringField
      FieldName = 'EXPORT_NAME'
      Origin = 'EXPORT_NAME'
      FixedChar = True
      Size = 255
    end
    object dtfldExportEXPORT_DATE: TDateField
      FieldName = 'EXPORT_DATE'
      Origin = 'EXPORT_DATE'
      ReadOnly = True
    end
    object tmfldExportEXPORT_TIME: TTimeField
      FieldName = 'EXPORT_TIME'
      Origin = 'EXPORT_TIME'
      ReadOnly = True
    end
    object wdstrngfldExportEXPORT_USER: TWideStringField
      FieldName = 'EXPORT_USER'
      Origin = 'EXPORT_USER'
      FixedChar = True
      Size = 255
    end
    object wdstrngfldExportEXPORT_PLACE: TWideStringField
      FieldName = 'EXPORT_PLACE'
      Origin = 'EXPORT_PLACE'
      FixedChar = True
      Size = 255
    end
  end
  object dsExport: TDataSource
    DataSet = fdqExport
    Left = 688
    Top = 120
  end
end
