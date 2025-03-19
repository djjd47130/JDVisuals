object frmVisual: TfrmVisual
  Left = 0
  Top = 0
  Caption = 'JD Visuals'
  ClientHeight = 555
  ClientWidth = 1027
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
    1027
    555)
  PixelsPerInch = 96
  TextHeight = 13
  object View: TJDVisualView
    Left = 128
    Top = 0
    Width = 899
    Height = 555
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBlack
    Interval = 10
    ParentColor = False
    Visual = SpiralOutVisual1
    OnMouseMove = ViewMouseMove
    ExplicitWidth = 852
    ExplicitHeight = 514
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 1027
    Height = 46
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    DoubleBuffered = False
    ParentBackground = False
    ParentColor = True
    ParentDoubleBuffered = False
    TabOrder = 0
    OnExit = pTopExit
    ExplicitWidth = 980
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
      Left = 898
      Top = 0
      Width = 129
      Height = 46
      Action = actFullScreen
      Align = alRight
      DropDownMenu = popFullScreen
      Style = bsSplitButton
      TabOrder = 1
      ExplicitLeft = 851
    end
  end
  object tmrMain: TTimer
    Enabled = False
    Interval = 25
    OnTimer = tmrMainTimer
    Left = 48
    Top = 104
  end
  object Acts: TActionList
    Left = 48
    Top = 56
    object actFullScreen: TAction
      Category = 'View'
      Caption = 'Enter Full Screen'
      ShortCut = 122
      OnExecute = btnFullScreenClick
    end
  end
  object FibonacciVisual1: TFibonacciVisual
    Thickness = 5.000000000000000000
    Zoom = 0.357500000000000000
    Count = 30
    ShowBoxes = False
    ShowSpiral = True
    Left = 48
    Top = 176
  end
  object FinalFrontierVisual1: TFinalFrontierVisual
    Speed = 0.952947020530700700
    MinSpeed = 0.000199999994947575
    MaxSpeed = 1.000000000000000000
    Left = 48
    Top = 224
  end
  object SpiralOutVisual1: TSpiralOutVisual
    Reset = False
    ColorFrequency = 15
    Spacing = 4.200000000000000000
    SpeedFactor = 0.030000000000000000
    Thickness = 6.900000000000000000
    Left = 48
    Top = 272
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
    Left = 48
    Top = 368
  end
  object TessellationVisual1: TTessellationVisual
    PatternType = ptHexagons
    ShapeSize = 64.000000000000000000
    LineWidth = 0.500000000000000000
    BackGradStart.Color = -11382408
    BackGradStart.UseStandardColor = False
    BackGradStart.Alpha = 255
    BackGradEnd.Color = -1269673608
    BackGradEnd.UseStandardColor = False
    BackGradEnd.Alpha = 180
    LineGradStart.Color = -1772990088
    LineGradStart.UseStandardColor = False
    LineGradStart.Alpha = 150
    LineGradEnd.Color = 5394808
    LineGradEnd.UseStandardColor = False
    LineGradEnd.Alpha = 0
    GradRange = 200
    Left = 48
    Top = 320
  end
end
