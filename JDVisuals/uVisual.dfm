object frmVisual: TfrmVisual
  Left = 0
  Top = 0
  Caption = 'JD Visuals'
  ClientHeight = 633
  ClientWidth = 1133
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
  OnMouseMove = ViewMouseMove
  OnResize = FormResize
  DesignSize = (
    1133
    633)
  PixelsPerInch = 96
  TextHeight = 13
  object View: TJDVisualView
    Left = 0
    Top = 0
    Width = 1133
    Height = 633
    Align = alClient
    Color = clBlack
    ParentColor = False
    VisualIndex = 0
    OnMouseMove = ViewMouseMove
    ExplicitTop = 1
    ExplicitWidth = 897
    ExplicitHeight = 522
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 1133
    Height = 46
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    DoubleBuffered = False
    ParentBackground = False
    ParentColor = True
    ParentDoubleBuffered = False
    TabOrder = 0
    OnExit = pTopExit
    ExplicitWidth = 897
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
      Left = 1031
      Top = 0
      Width = 102
      Height = 46
      Align = alRight
      Caption = 'Enter Full Screen'
      TabOrder = 1
      OnClick = btnFullScreenClick
      ExplicitLeft = 795
    end
  end
  object tmrMain: TTimer
    Interval = 25
    OnTimer = tmrMainTimer
    Left = 32
    Top = 64
  end
end
