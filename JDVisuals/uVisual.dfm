object frmVisual: TfrmVisual
  Left = 0
  Top = 0
  Caption = 'JD Visuals'
  ClientHeight = 570
  ClientWidth = 1025
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
    1025
    570)
  PixelsPerInch = 96
  TextHeight = 13
  object View: TJDVisualView
    Left = 0
    Top = 0
    Width = 1025
    Height = 425
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBlack
    Interval = 15
    ParentColor = False
    Visual = SpiralOutVisual1
    OnMouseMove = ViewMouseMove
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 1025
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
      Left = 896
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
    Left = 24
    Top = 440
  end
  object Acts: TActionList
    Left = 80
    Top = 440
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
    Left = 240
    Top = 440
  end
  object FinalFrontierVisual1: TFinalFrontierVisual
    Speed = 0.888469696044921900
    MinSpeed = 0.000199999994947575
    MaxSpeed = 1.000000000000000000
    Left = 360
    Top = 440
  end
  object SpiralOutVisual1: TSpiralOutVisual
    Reset = False
    ColorFrequency = 15
    Spacing = 4.200000000000000000
    SpeedFactor = 0.030000000000000000
    Thickness = 69.000000000000000000
    Left = 480
    Top = 440
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
    Left = 576
    Top = 440
  end
  object TessellationVisual1: TTessellationVisual
    PatternType = ptHexagons
    ShapeSize = 64.000000000000000000
    LineWidth = 0.500000000000000000
    BackGradStart.Color = -4042376
    BackGradStart.UseStandardColor = False
    BackGradStart.Alpha = 255
    BackGradEnd.Color = -1262333576
    BackGradEnd.UseStandardColor = False
    BackGradEnd.Alpha = 180
    LineGradStart.Color = -1765650056
    LineGradStart.UseStandardColor = False
    LineGradStart.Alpha = 150
    LineGradEnd.Color = 12734840
    LineGradEnd.UseStandardColor = False
    LineGradEnd.Alpha = 0
    GradRange = 200
    Left = 672
    Top = 440
  end
end
