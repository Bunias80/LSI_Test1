inherited fmBaseGridForm: TfmBaseGridForm
  Caption = 'fmBaseGridForm'
  PixelsPerInch = 96
  TextHeight = 13
  inherited p1: TPanel
    object btnOK1: TButton
      Left = 12
      Top = 9
      Width = 75
      Height = 25
      Action = aAdd
      Anchors = [akLeft, akBottom]
      Images = fmMain.ilSmall
      TabOrder = 2
    end
    object btnEdit: TButton
      Left = 93
      Top = 9
      Width = 75
      Height = 25
      Action = aEdit
      Anchors = [akLeft, akBottom]
      Images = fmMain.ilSmall
      TabOrder = 3
    end
    object btnDelete: TButton
      Left = 174
      Top = 9
      Width = 75
      Height = 25
      Action = aDelete
      Anchors = [akLeft, akBottom]
      Images = fmMain.ilSmall
      TabOrder = 4
    end
  end
  inherited pBG: TPanel
    object sdgBaseGrid: TSpetechDrawGrid
      Left = 0
      Top = 0
      Width = 645
      Height = 227
      Align = alClient
      DefaultRowHeight = 18
      DrawingStyle = gdsGradient
      ColCount = 4
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goFixedRowClick]
      TabOrder = 0
      OnDblClick = sdgBaseGridDblClick
      ColumnsData = <>
      ColWidths = (
        8
        64
        64
        64)
      RowHeights = (
        18
        18)
    end
  end
  inherited alForm: TActionList
    inherited aOK: TAction
      Caption = 'Wybierz'
      Enabled = False
      Visible = False
    end
    object aAdd: TAction
      Caption = 'Dodaj'
      ImageIndex = 9
      OnExecute = aAddExecute
    end
    object aEdit: TAction
      Caption = 'Modyfikuj'
      ImageIndex = 10
      OnExecute = aEditExecute
    end
    object aDelete: TAction
      Caption = 'Usu'#324
      ImageIndex = 1
      Visible = False
      OnExecute = aDeleteExecute
    end
  end
end
