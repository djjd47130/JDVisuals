object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Fibonacci Test'
  ClientHeight = 620
  ClientWidth = 1071
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Log: TMemo
    Left = 0
    Top = 0
    Width = 169
    Height = 620
    Align = alLeft
    Lines.Strings = (
      'Log')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    Visible = False
    ExplicitLeft = 8
    ExplicitTop = 24
    ExplicitHeight = 513
  end
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Left = 400
    Top = 40
  end
end
