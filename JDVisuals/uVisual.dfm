object frmVisual: TfrmVisual
  Left = 0
  Top = 0
  Caption = 'JD Visuals'
  ClientHeight = 522
  ClientWidth = 897
  Color = clBlack
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  StyleElements = [seFont, seBorder]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseMove = ViewMouseMove
  OnResize = FormResize
  DesignSize = (
    897
    522)
  PixelsPerInch = 96
  TextHeight = 13
  object View: TJDVisualView
    Left = 0
    Top = 0
    Width = 897
    Height = 522
    Align = alClient
    Color = clBlack
    ParentColor = False
    VisualIndex = -1
    OnMouseMove = ViewMouseMove
    ExplicitLeft = 80
    ExplicitTop = 72
    ExplicitWidth = 729
    ExplicitHeight = 377
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 897
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
        Height = 15
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
      Left = 795
      Top = 0
      Width = 102
      Height = 46
      Align = alRight
      Caption = 'Enter Full Screen'
      TabOrder = 1
      OnClick = btnFullScreenClick
    end
  end
  object tmrMain: TTimer
    Interval = 25
    OnTimer = tmrMainTimer
    Left = 32
    Top = 64
  end
end
