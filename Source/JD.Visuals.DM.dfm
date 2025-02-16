object dmJDVisualsScript: TdmJDVisualsScript
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 347
  Width = 531
  object DWSUnit: TdwsUnit
    Script = DWS
    Classes = <
      item
        Name = 'TRect'
        Properties = <
          item
            Name = 'Left'
            DataType = 'Integer'
          end
          item
            Name = 'Top'
            DataType = 'Integer'
          end
          item
            Name = 'Right'
            DataType = 'Integer'
          end
          item
            Name = 'Bottom'
            DataType = 'Integer'
          end>
      end
      item
        Name = 'TPen'
      end
      item
        Name = 'TCanvas'
        Methods = <
          item
            Name = 'DrawLine'
            Kind = mkProcedure
          end>
      end>
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
