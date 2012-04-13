object Form65: TForm65
  Left = 0
  Top = 0
  Caption = 'Form65'
  ClientHeight = 602
  ClientWidth = 643
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
  object Edit1: TEdit
    Left = 89
    Top = 8
    Width = 561
    Height = 21
    TabOrder = 0
    Text = '3*cos(2*3.14159*5*t)+10*sin(2*3.14159*12*t)'
  end
  object Button1: TButton
    Left = 8
    Top = 75
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit_start: TEdit
    Left = 96
    Top = 48
    Width = 35
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object Edit_stop: TEdit
    Left = 184
    Top = 48
    Width = 35
    Height = 21
    TabOrder = 3
    Text = '5'
  end
  object Chart1: TChart
    Left = 0
    Top = 106
    Width = 643
    Height = 496
    Legend.Visible = False
    Title.Text.Strings = (
      'TChart')
    View3D = False
    Align = alBottom
    TabOrder = 4
    Anchors = [akLeft, akTop, akRight, akBottom]
    ExplicitLeft = 8
    object Series1: TFastLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      LinePen.Color = clRed
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
end
