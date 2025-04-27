unit ElectronicBoardFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  TElectronicBoardFrame = class(TFrame)
    BackgroundLayout: TLayout;
    BackgroundRectangle: TRectangle;
    DigitsLayout: TLayout;
    HHImage: TImage;
    MHImage: TImage;
    HLImage: TImage;
    MLImage: TImage;
    SLImage: TImage;
    SHImage: TImage;
    HDelimImage: TImage;
    SDelimImage: TImage;
    HoursLayout: TLayout;
    MinutesLayout: TLayout;
    SecondsLayout: TLayout;
    HoursDelimLayout: TLayout;
    SecondsDelimLayout: TLayout;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
