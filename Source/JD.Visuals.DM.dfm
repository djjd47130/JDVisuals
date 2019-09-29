object DataModule1: TDataModule1
  OldCreateOrder = False
  Height = 439
  Width = 775
  object DWSUnit: TdwsUnit
    Script = DWS
    Functions = <
      item
        Name = 'DrawLine'
        Parameters = <
          item
            Name = 'X1'
            DataType = 'Integer'
          end
          item
            Name = 'Y1'
            DataType = 'Integer'
          end
          item
            Name = 'X2'
            DataType = 'Integer'
          end
          item
            Name = 'Y2'
            DataType = 'Integer'
          end>
        OnEval = DWSUnitFunctionsDrawLineEval
      end>
    UnitName = ''
    StaticSymbols = False
    Left = 240
    Top = 64
  end
  inline DWSClasses: TdwsClassesLib
    OldCreateOrder = False
    Script = DWS
    Left = 184
    Top = 64
    Height = 0
    Width = 0
  end
  object DWS: TDelphiWebScript
    Left = 128
    Top = 64
  end
end
