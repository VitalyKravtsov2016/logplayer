object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'LogPlayer'
  ClientHeight = 584
  ClientWidth = 802
  Color = clBtnFace
  Constraints.MinWidth = 694
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnl: TPanel
    Left = 0
    Top = 0
    Width = 802
    Height = 584
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object spl1: TSplitter
      Left = 0
      Top = 363
      Width = 802
      Height = 5
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 376
      ExplicitWidth = 717
    end
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 802
      Height = 363
      Align = alClient
      BevelOuter = bvNone
      Constraints.MinHeight = 200
      TabOrder = 0
      DesignSize = (
        802
        363)
      object lbl: TLabel
        Left = 683
        Top = 97
        Width = 116
        Height = 13
        Anchors = [akTop, akRight]
        Caption = #1050#1086#1084#1072#1085#1076#1099'-'#1080#1089#1082#1083#1102#1095#1077#1085#1080#1103':'
        ExplicitLeft = 591
      end
      object lblFileName: TLabel
        Left = 8
        Top = 97
        Width = 3
        Height = 13
      end
      object btnCloseSession: TButton
        Left = 488
        Top = 8
        Width = 144
        Height = 25
        Caption = #1047#1072#1082#1088#1099#1090#1100' '#1089#1084#1077#1085#1091
        TabOrder = 0
        OnClick = btnCloseSessionClick
      end
      object btnGetStatus: TButton
        Left = 344
        Top = 8
        Width = 105
        Height = 25
        Caption = #1047#1072#1087#1088#1086#1089' '#1089#1086#1089#1090#1086#1103#1085#1080#1103
        TabOrder = 1
        OnClick = btnGetStatusClick
      end
      object btnOpen: TButton
        Left = 8
        Top = 8
        Width = 137
        Height = 25
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083' '#1083#1086#1075#1072
        Default = True
        ImageIndex = 0
        ImageName = 'open'
        ImageMargins.Left = 4
        Images = pngmglstButtons
        TabOrder = 2
        OnClick = btnOpenClick
      end
      object btnOpenSession: TButton
        Left = 340
        Top = 8
        Width = 144
        Height = 25
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1089#1084#1077#1085#1091
        TabOrder = 3
        OnClick = btnOpenSessionClick
      end
      object btnSettings: TButton
        Left = 149
        Top = 8
        Width = 187
        Height = 25
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1074#1086#1081#1089#1090#1074' ...'
        ImageIndex = 1
        ImageName = 'settings'
        ImageMargins.Left = 4
        Images = pngmglstButtons
        TabOrder = 4
        OnClick = btnSettingsClick
      end
      object btnStart: TButton
        Left = 8
        Top = 39
        Width = 137
        Height = 25
        Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
        ImageIndex = 2
        ImageName = 'right-chevron'
        ImageMargins.Left = 4
        Images = pngmglstButtons
        TabOrder = 5
        OnClick = btnStartClick
      end
      object btnStartFromPosition: TButton
        Left = 149
        Top = 39
        Width = 187
        Height = 25
        Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' c '#1090#1077#1082#1091#1097#1077#1081' '#1089#1090#1088#1086#1082#1080
        ImageIndex = 2
        ImageName = 'right-chevron'
        ImageMargins.Left = 4
        Images = pngmglstButtons
        TabOrder = 6
        OnClick = btnStartFromPositionClick
      end
      object btnStop: TButton
        Left = 636
        Top = 39
        Width = 144
        Height = 25
        Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
        Enabled = False
        ImageIndex = 3
        ImageName = 'cancel'
        ImageMargins.Left = 4
        Images = pngmglstButtons
        TabOrder = 7
        OnClick = btnStopClick
      end
      object edtStatus: TEdit
        Left = 8
        Top = 70
        Width = 676
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 8
      end
      object lvCommands: TListView
        Left = 8
        Top = 116
        Width = 676
        Height = 246
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'Time'
            Width = 140
          end
          item
            Caption = 'Thread'
            Width = 70
          end
          item
            Caption = 'Command'
            Width = 240
          end
          item
            AutoSize = True
            Caption = 'Data'
          end>
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        MultiSelect = True
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        PopupMenu = pmMain
        StateImages = pngmglst
        TabOrder = 9
        ViewStyle = vsReport
        OnAdvancedCustomDrawItem = lvCommandsAdvancedCustomDrawItem
        OnAdvancedCustomDrawSubItem = lvCommandsAdvancedCustomDrawSubItem
        OnSelectItem = lvCommandsSelectItem
      end
      object memCommandExceptions: TMemo
        Left = 690
        Top = 116
        Width = 107
        Height = 246
        Anchors = [akTop, akRight, akBottom]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'FF 0A')
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 10
      end
      object progress: TProgressBar
        Left = 690
        Top = 72
        Width = 107
        Height = 17
        Anchors = [akTop, akRight]
        TabOrder = 11
      end
      object btnStartCurrentLine: TButton
        Left = 340
        Top = 39
        Width = 144
        Height = 25
        Caption = #1058#1077#1082#1091#1097#1072#1103' '#1089#1090#1088#1086#1082#1072
        ImageIndex = 2
        ImageName = 'right-chevron'
        ImageMargins.Left = 4
        Images = pngmglstButtons
        TabOrder = 12
        OnClick = btnStartCurrentLineClick
      end
      object btnStartSelected: TButton
        Left = 488
        Top = 39
        Width = 144
        Height = 25
        Caption = #1042#1099#1076#1077#1083#1077#1085#1085#1086#1077
        ImageIndex = 2
        ImageName = 'right-chevron'
        ImageMargins.Left = 4
        Images = pngmglstButtons
        TabOrder = 13
        OnClick = btnStartSelectedClick
      end
      object btnFindError: TButton
        Left = 636
        Top = 8
        Width = 144
        Height = 25
        Caption = #1053#1072#1081#1090#1080' '#1086#1096#1080#1073#1082#1091
        TabOrder = 14
        OnClick = btnFindErrorClick
      end
    end
    object pnlBottom: TPanel
      Left = 0
      Top = 368
      Width = 802
      Height = 216
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MinHeight = 50
      TabOrder = 1
      object memInfo: TMemo
        Left = 8
        Top = 0
        Width = 789
        Height = 216
        Align = alCustom
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object dlgOpen: TOpenDialog
    DefaultExt = '*.*'
    Filter = '*.log;*.txt|*.log;*.txt|*.log|*.log|*.txt|*.txt|*.*|*.*'
    Left = 152
    Top = 136
  end
  object formStorage: TJvFormStorage
    AppStorage = xmlStorage
    AppStoragePath = '%FORM_NAME%\'
    AfterRestorePlacement = formStorageAfterRestorePlacement
    StoredProps.Strings = (
      'memCommandExceptions.Lines'
      'dlgOpen.FileName'
      'dlgOpen.InitialDir'
      'dlgSave.InitialDir'
      'dlgSave.FileName'
      'spl1.Top')
    StoredValues = <
      item
      end>
    Left = 40
    Top = 136
  end
  object xmlStorage: TJvAppXMLFileStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    StorageOptions.InvalidCharReplacement = '_'
    FileName = 'SHTRIH-M\LogPlayer\settings.xml'
    Location = flUserFolder
    RootNodeName = 'Configuration'
    SubStorages = <>
    Left = 96
    Top = 136
  end
  object pngmglst: TPngImageList
    PngImages = <
      item
        Background = clWindow
        Name = 'Play'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C086488000000097048597300000059000000
          5901AA9DA9860000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A0000014B4944415478DA63640002BF1BF73D181918
          D23FB233441E5054FCC10005BE37EE9703C5853669289633E0008C20CD407A3D
          107300F18E4FEC0C81204380E265407E27545D172E4318FD6EDE5FC0F09F211E
          21C2B88589ED7FECBF9F0CFB813C0398F0FFFF0C4D9B3515EB310C08FDFF9FF9
          E7CD870B804A6290C4773008722530BCFFBE05286E82248EE11246104189218C
          3006B98630223B871C43500C20C7100C03B4AF5E65FBF6E0E78D0F5F7E28C2C4
          78B958DF88F0F33ABFFAF0F9D8D7EFBFB961E222025C271829D17CDBDDC09291
          12CDF040245733D8004A34830D50DA76E6CEFBCFBF9461027C5C6CAF4424394D
          5F3CF97AE3DBCF3F9C70CDFC1C876E7B18D9A3073AA3F6DE0B35CFDF7D6FFEFF
          EF3FD866211E16D50B8E861FD4769DDFFAFAFD772F5C36A3A444ADBD171BBE7D
          FF9DCA22F247F38E85C52798A4DACEF3FBFE03D305369B61000044BDF914D2F0
          75E50000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'Error'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C086488000000097048597300000076000000
          76014E7B26080000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000001DF4944415478DA63644003FFD3FC75191819
          52814C672096FFF2F01E372333CB4F2656D61BCC6C5C0DECAB0E6C4056CF08D7
          181ACAC620F4AB1FC8CC00622698F8E70777512C60E6E4BECCC5CA69C5B8FAC0
          17B80110CDBFB703594EE82E4237000498D8D8DF7173F0CA830C811890E1378D
          E13F63265C052B1B03C3EF5FA80670F330307CFD82E212EE0D27F518A17EBE00
          77B6890D03435C2E03C3DC3E06868B27C106B0874632B0057931FC3E788AE1C7
          8CC97043D879F90218FFA7FB4F02B273E136F72D81D07FFE3030CCEC60F8C5CD
          CAC0E6E7067227D0C34C0C9F5332E12E61E1E43A0F72C135A00B34E1C6EA9A30
          30A45700655920867CBA0CD10C54F46BD32E869F2B9620C28285F527C80520E3
          B8514249DB081817151097BC3B07D1BC792FC3CFE50B5194313231FD0719F019
          C8E64191D13182B802D9802D400396A119C0083280622F64F84F04CAE7911588
          5C9CE7800604EA30FCFF078A4666B0A8B13503433CD0BC39BD0C0C974E41A231
          04188DC1C0683C7092E1C7CC297017B0F10BF8411252BA3F48341B7F420286F3
          D7AF70252C5C5C17B9D69F32404ACABFB6413310E94919C9903E686662C66500
          C8664E162E1B94CC840CFEA7FA6A33303103B3F37F172057019C9D59587E0043
          FC3A131B5B3DC7AA239B91D503001283C9F0914746F80000000049454E44AE42
          6082}
      end
      item
        Background = clWindow
        Name = 'close'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C08648800000009704859730000007C000000
          7C01150FEDE40000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000001374944415478DA8593B14BC34014877FBFCB
          665A1174D5C1459C149480638D487170EAE27FE8602717A156C545884271E9D6
          A5BB084935436DCE77319523E6CE0781CBBB7CDFDDBD77617E72B0B5D0C11580
          160A5CB4EE93577862D689F6405E823A0BB8E871164723C9EF57F36F22895D92
          125618CA70BD4A8D8C602A834DEBBB4649036C62CACF383A2A801B795975491C
          70AA802ECDA85142BC9338D55F980B7C2B990D0BFED05A9FB5EF9E1FB9CC3876
          92CA2369AC35C13FEB58E190C005FF11FC4A34063213D6A67281BB36DC28A80A
          F650DBB6898C0AC7E12079710A2AB85E30FBEBB2B0B6847E9839A1E544D6716A
          127A562E0B169073578B8D843E785930DF3D61164713D9C6B6DD7B73C35686C9
          D37F2D166E62FE85B18C777DB0473266DA39DC514A5D033A5460CF05D7247DD3
          D6A228CEBF01D895B08C03C3895A0000000049454E44AE426082}
      end>
    Left = 208
    Top = 136
  end
  object pngmglstButtons: TPngImageList
    PngImages = <
      item
        Background = clWindow
        Name = 'open'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C086488000000097048597300000076000000
          76014E7B26080000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000001F24944415478DA6364200234EC6F60F9CA25
          E2C1C4C8A8FC8F81F142B759D641981C2321CDE56766F233FCFBBD0BA8F42503
          C3FFF30CFF199D80C22FEE3D148D581D16F697A00115A7A64EFCCFF0FF43A759
          4E3DD835FF1B98BE9F16DD0164AE6660625945D805A7A66E636662496E33497F
          0EE2579E9C62F98F91712F90F905882F31DACD7ADC81A9EDFF9BB7029F275D0D
          D3FE85D555A7A7B9005D15F1FF274721A3EDAC47FF71587E9491E1FFA47F4095
          E8127F9999F61E4F917D070E443C06E004FFFF335A1C49973D8961002F1B1383
          86182B160D0C0CCF3FFF053B051868DF79D998D7B130337C050ABC4731404384
          8DC1508A1DC380975FFF32BCFAF217D36006863528063828723148F2326328BC
          F3EE37C3F7DF587CCAC8900E370098CA1882B57918589850D5000391E1DAEB5F
          606FA00366C6FF4A7003C47958189C943831147DFAF98FE1E1873FD8C2F2CE74
          7F7155B801FA12EC0C5A626C18AA9E7EFAC3F0EEFB3F6C013B6D46807836DC00
          0F552E06414E66863F40B577817E86819B6F7EFDFFFDF73F38C54A005DC9C701
          F5231343E0745FF10D2003BE73B030720468F230304213F65FA87F7F0119375F
          231223289CA06A7EB1FF63139F1028F881D17AD6634F4D615637197E1601210E
          E6FB2CCC8C3F611A3EFFFEC7FFF0E39F4FFFD152E3BFFFFFCFCDF417DF0D6203
          0035D3C83A0E43E8FE0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'settings'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C086488000000097048597300000076000000
          76014E7B26080000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000002054944415478DAA5534D4F135114BD77663A
          33957EA4687465DCE88A4459B9944442654174414413FF827161E2820FDB2668
          E2CA6214080BF805C61D2198E842E50790146C896141CA42D3D2DAD2E98CCCBC
          EB7D638BC3970678C964DE3BF7BDF3EE39F75D847D23B3625FCE7499DF800853
          05AB5ACE9D894E0E820688E2F1C79DDE9737431F82FB31B848E5AD27FC7BC1E8
          2402D59963A4B41C063DE62E212A11A7A65C3312DE7CB64F1B3894E069DE7AC4
          C0AB20260982C348B8EFB2C9D0E01E0279330138BC78C0CBEB7E8401CF51E0FB
          8A01BAF697403345430D8B459664C84C706CD5BEA228E22BC7D4F6267B4B6D6E
          6FEA2E0888AE9738A0029D8D004442818C7916EA74933E902E58AF89E0A17FB8
          CC878BBACC5BF0F7B95885EE5F2EC465EC7C1CA84D62C4C572B65FED46DFED35
          EB39100ECBB4CBB9708D0444987060FA3E2EC8CD43B394A9D9905615A04B9D7F
          08A4B113FDDA0D4CE51B3F399F98043D5B814AC190D34F53F7B02768DE9D19AA
          3A9CC9C504A7DE128B2CEDF40452427ACD7A266B2E259472661D047670E4F6F4
          10CEFB12E668BCD684B13D12E2EE97895B5ACF01139D8ADAAC6FB44C4458DAAC
          C055A765E285185087BECFC4A3CAD828EA3B4C1AF3CBC8379FE332B60F1F28E3
          D10F09E1C7AAB9AB590ED5A46D2DECBDDF7D48C77FCADEDB6C52BBFBCF6662F0
          0D71337178D46F26360C4189FEB7994ED2CEBF01BBB9081E9BE7F07E00000000
          49454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'right-chevron'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C086488000000097048597300000059000000
          5901AA9DA9860000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A0000014B4944415478DA63640002BF1BF73D181918
          D23FB233441E5054FCC10005BE37EE9703C5853669289633E0008C20CD407A3D
          107300F18E4FEC0C81204380E265407E27545D172E4318FD6EDE5FC0F09F211E
          21C2B88589ED7FECBF9F0CFB813C0398F0FFFF0C4D9B3515EB310C08FDFF9FF9
          E7CD870B804A6290C4773008722530BCFFBE05286E82248EE11246104189218C
          3006B98630223B871C43500C20C7100C03B4AF5E65FBF6E0E78D0F5F7E28C2C4
          78B958DF88F0F33ABFFAF0F9D8D7EFBFB961E222025C271829D17CDBDDC09291
          12CDF040245733D8004A34830D50DA76E6CEFBCFBF9461027C5C6CAF4424394D
          5F3CF97AE3DBCF3F9C70CDFC1C876E7B18D9A3073AA3F6DE0B35CFDF7D6FFEFF
          EF3FD866211E16D50B8E861FD4769DDFFAFAFD772F5C36A3A444ADBD171BBE7D
          FF9DCA22F247F38E85C52798A4DACEF3FBFE03D305369B61000044BDF914D2F0
          75E50000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'cancel'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C086488000000097048597300000076000000
          76014E7B26080000001974455874536F667477617265007777772E696E6B7363
          6170652E6F72679BEE3C1A000001DF4944415478DA63644003FFD3FC75191819
          52814C672096FFF2F01E372333CB4F2656D61BCC6C5C0DECAB0E6C4056CF08D7
          181ACAC620F4AB1FC8CC00622698F8E70777512C60E6E4BECCC5CA69C5B8FAC0
          17B80110CDBFB703594EE82E4237000498D8D8DF7173F0CA830C811890E1378D
          E13F63265C052B1B03C3EF5FA80670F330307CFD82E212EE0D27F518A17EBE00
          77B6890D03435C2E03C3DC3E06868B27C106B0874632B0057931FC3E788AE1C7
          8CC97043D879F90218FFA7FB4F02B273E136F72D81D07FFE3030CCEC60F8C5CD
          CAC0E6E7067227D0C34C0C9F5332E12E61E1E43A0F72C135A00B34E1C6EA9A30
          30A45700655920867CBA0CD10C54F46BD32E869F2B9620C28285F527C80520E3
          B8514249DB081817151097BC3B07D1BC792FC3CFE50B5194313231FD0719F019
          C8E64191D13182B802D9802D400396A119C0083280622F64F84F04CAE7911588
          5C9CE7800604EA30FCFF078A4666B0A8B13503433CD0BC39BD0C0C974E41A231
          04188DC1C0683C7092E1C7CC297017B0F10BF8411252BA3F48341B7F420286F3
          D7AF70252C5C5C17B9D69F32404ACABFB6413310E94919C9903E686662C66500
          C8664E162E1B94CC840CFEA7FA6A33303103B3F37F172057019C9D59587E0043
          FC3A131B5B3DC7AA239B91D503001283C9F0914746F80000000049454E44AE42
          6082}
      end>
    Left = 264
    Top = 136
  end
  object pmMain: TPopupMenu
    Left = 336
    Top = 136
    object Pfdfa1: TMenuItem
      Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1101#1090#1091' '#1089#1090#1088#1086#1082#1091
      OnClick = Pfdfa1Click
    end
    object pmMain1: TMenuItem
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1089' '#1101#1090#1086#1081' '#1089#1090#1088#1086#1082#1080
      OnClick = pmMain1Click
    end
    object N3: TMenuItem
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1077
      OnClick = N3Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083'...'
      OnClick = N2Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100' '#1080#1079' '#1073#1091#1092#1077#1088#1072' '#1086#1073#1084#1077#1085#1072
      OnClick = N5Click
    end
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'txt'
    FileName = 'Log'
    Filter = '*.txt|*.txt|*.*|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 392
    Top = 136
  end
end
