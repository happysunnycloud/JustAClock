unit VerticalElectronicBoardFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ElectronicBoardFrameUnit, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.Edit;

type
  TVerticalElectronicBoardFrame = class(TElectronicBoardFrame)
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VerticalElectronicBoardFrame: TVerticalElectronicBoardFrame;

implementation

{$R *.fmx}

end.
