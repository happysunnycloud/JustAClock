unit TextBoardFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TTextBoardFrame = class(TFrame)
    TextTimeLayout: TLayout;
    TextHoursLayout: TLayout;
    HHText: TText;
    HLText: TText;
    TextHoursDelimLayout: TLayout;
    HDelimText: TText;
    TextMinutesLayout: TLayout;
    MHText: TText;
    MLText: TText;
    TextSecondsDelimLayout: TLayout;
    SDelimText: TText;
    TextSecondsLayout: TLayout;
    SHText: TText;
    SLText: TText;
    BackgroundLayout: TLayout;
    BackgroundRectangle: TRectangle;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
