object frmVisual: TfrmVisual
  Left = 0
  Top = 0
  Caption = 'JD Visuals'
  ClientHeight = 540
  ClientWidth = 969
  Color = clBlack
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  StyleElements = [seFont, seBorder]
  OnCreate = FormCreate
  OnMouseMove = ViewMouseMove
  OnResize = FormResize
  DesignSize = (
    969
    540)
  PixelsPerInch = 96
  TextHeight = 13
  object View: TJDVisualView
    Left = 0
    Top = 0
    Width = 969
    Height = 465
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Visual = RaindropVisual1
    OnMouseMove = ViewMouseMove
    ExplicitTop = 1
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 969
    Height = 46
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    DoubleBuffered = False
    ParentBackground = False
    ParentColor = True
    ParentDoubleBuffered = False
    TabOrder = 0
    OnExit = pTopExit
    object Panel1: TPanel
      Tag = -1
      Left = 0
      Top = 0
      Width = 153
      Height = 46
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 1
        Width = 147
        Height = 12
        Margins.Top = 1
        Align = alClient
        Caption = 'Visualization'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 71
        ExplicitHeight = 13
      end
      object cboVisual: TComboBox
        AlignWithMargins = True
        Left = 3
        Top = 19
        Width = 147
        Height = 24
        Align = alBottom
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = cboVisualClick
      end
    end
    object btnFullScreen: TButton
      Tag = -2
      Left = 840
      Top = 0
      Width = 129
      Height = 46
      Action = actFullScreen
      Align = alRight
      DropDownMenu = popFullScreen
      Style = bsSplitButton
      TabOrder = 1
    end
  end
  object tmrMain: TTimer
    Enabled = False
    Interval = 25
    OnTimer = tmrMainTimer
    Left = 32
    Top = 488
  end
  object Acts: TActionList
    Left = 88
    Top = 488
    object actFullScreen: TAction
      Category = 'View'
      Caption = 'Enter Full Screen'
      ShortCut = 122
      OnExecute = btnFullScreenClick
    end
  end
  object FibonacciVisual1: TFibonacciVisual
    Thickness = 8.000000000000000000
    Zoom = 0.100000000000000000
    Count = 30
    ShowBoxes = True
    ShowSpiral = True
    Left = 248
    Top = 488
  end
  object FinalFrontierVisual1: TFinalFrontierVisual
    Speed = 0.473437219858169500
    MinSpeed = 0.000199999994947575
    MaxSpeed = 1.000000000000000000
    Left = 368
    Top = 488
  end
  object SpiralOutVisual1: TSpiralOutVisual
    ColorFrequency = 15
    Spacing = 2.000000000000000000
    SpeedFactor = 0.010000000000000000
    Thickness = 2.000000000000000000
    Left = 488
    Top = 488
  end
  object popFullScreen: TPopupMenu
    Left = 792
    Top = 8
    object mFullCurrent: TMenuItem
      Caption = 'Current Monitor'
      Checked = True
      Default = True
      RadioItem = True
      OnClick = mFullAllClick
    end
    object mFullMain: TMenuItem
      Caption = 'Main Monitor'
      RadioItem = True
      OnClick = mFullAllClick
    end
    object mFullAll: TMenuItem
      Caption = 'All Monitors'
      RadioItem = True
      OnClick = mFullAllClick
    end
  end
  object RaindropVisual1: TRaindropVisual
    Left = 584
    Top = 488
  end
end
