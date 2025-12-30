unit ProportionUnit;

interface

uses
    FMX.Layouts
  , FMX.Controls
  , CommonUnit
  ;

type
  TProportion = class
  strict private
    class var FOrientation: TOrientationKind;
    class var FOrigin: TLayout;
    class var FDigitsLayout: TLayout;
    class var FHoursLayout: TLayout;
    class var FHoursDelimLayout: TLayout;
    class var FMinutesLayout: TLayout;
    class var FSecondsDelimLayout: TLayout;
    class var FSecondsLayout: TLayout;
    class var FHHControl: TControl;
    class var FHLControl: TControl;
    class var FHDelimControl: TControl;
    class var FMHControl: TControl;
    class var FMLControl: TControl;
    class var FSDelimControl: TControl;
    class var FSHControl: TControl;
    class var FSLControl: TControl;
  private
//    class function ClientWidth: Single;
//    class function ClientHeight: Single;
  public
    class procedure Init(
      const AOrientation: TOrientationKind;
      const AOrigin: TLayout;
      const AMinWidth: Integer;
      const AMinHeight: Integer;
      const ADigitsLayout: TLayout;
      const AHoursLayout: TLayout;
      const AHoursDelimLayout: TLayout;
      const AMinutesLayout: TLayout;
      const ASecondsDelimLayout: TLayout;
      const ASecondsLayout: TLayout;
      const AHHControl: TControl;
      const AHLControl: TControl;
      const AHDelimControl: TControl;
      const AMHControl: TControl;
      const AMLControl: TControl;
      const ASDelimControl: TControl;
      const ASHControl: TControl;
      const ASLControl: TControl);
    class procedure Resize;
  end;

implementation

uses
    FMX.Types
  , FMX.Forms
  , System.SysUtils
  , FMX.Objects
  , FMX.ControlToolsUnit
  {$IFDEF MSWINDOWS}
  , BorderFrameUnit
  {$ELSE IFDEF ANDROID}
  , System.Types
  , FMX.Platform
  {$ENDIF}
  ;

class procedure TProportion.Init(
  const AOrientation: TOrientationKind;
  const AOrigin: TLayout;
  const AMinWidth: Integer;
  const AMinHeight: Integer;
  const ADigitsLayout: TLayout;
  const AHoursLayout: TLayout;
  const AHoursDelimLayout: TLayout;
  const AMinutesLayout: TLayout;
  const ASecondsDelimLayout: TLayout;
  const ASecondsLayout: TLayout;
  const AHHControl: TControl;
  const AHLControl: TControl;
  const AHDelimControl: TControl;
  const AMHControl: TControl;
  const AMLControl: TControl;
  const ASDelimControl: TControl;
  const ASHControl: TControl;
  const ASLControl: TControl);
begin
  FOrientation := AOrientation;
  FOrigin := AOrigin;
  FDigitsLayout := ADigitsLayout;
  FHoursLayout := AHoursLayout;
  FHoursDelimLayout := AHoursDelimLayout;
  FMinutesLayout := AMinutesLayout;
  FSecondsDelimLayout := ASecondsDelimLayout;
  FSecondsLayout := ASecondsLayout;
  FHHControl := AHHControl;
  FHLControl := AHLControl;
  FHDelimControl := AHDelimControl;
  FMHControl := AMHControl;
  FMLControl := AMLControl;
  FSDelimControl := ASDelimControl;
  FSHControl := ASHControl;
  FSLControl := ASLControl;
end;

//class function TProportion.ClientWidth: Single;
//begin
//  Result := FOrigin.Width;
//end;
//
//class function TProportion.ClientHeight: Single;
//begin
//  Result := FOrigin.Height;
//end;

class procedure TProportion.Resize;

  procedure _SetTextSize(const AControl: TControl);
  begin
    TText(AControl).TextSettings.Font.Size :=
      Trunc((FHHControl.Height * 50) / 60);
  end;

  procedure ResizeVerticalBoardFrame(const AParentFrame: TFrame);
  var
    W0: Single;
    H0: Single;
    H1: Single;
    H: Single;
  begin
    FDigitsLayout.Width := AParentFrame.Width - 10;
    FDigitsLayout.Height := AParentFrame.Height - 10;

    if (FDigitsLayout.Height / FDigitsLayout.Width) >= 4 then
      W0 := FDigitsLayout.Width / 2
    else
      W0 := FDigitsLayout.Height / 8;

    H0 := W0 * 2;
    H1 := H0 / 2;

    FHoursLayout.Align         := TAlignLayout.None;
    FHoursDelimLayout.Align    := TAlignLayout.None;
    FMinutesLayout.Align       := TAlignLayout.None;
    FSecondsDelimLayout.Align  := TAlignLayout.None;
    FSecondsLayout.Align       := TAlignLayout.None;

    FHoursLayout.Height        := H0;
    FHoursDelimLayout.Height   := H1;
    FMinutesLayout.Height      := H0;
    FSecondsDelimLayout.Height := H1;
    FSecondsLayout.Height      := H0;

    FSecondsLayout.Align       := TAlignLayout.Bottom;
    FSecondsDelimLayout.Align  := TAlignLayout.Bottom;
    FMinutesLayout.Align       := TAlignLayout.Bottom;
    FHoursDelimLayout.Align    := TAlignLayout.Bottom;
    FHoursLayout.Align         := TAlignLayout.Bottom;

    FHoursLayout.Align         := TAlignLayout.Top;
    FHoursDelimLayout.Align    := TAlignLayout.Top;
    FMinutesLayout.Align       := TAlignLayout.Top;
    FSecondsDelimLayout.Align  := TAlignLayout.Top;
    FSecondsLayout.Align       := TAlignLayout.Top;

    FHHControl.Width     := W0;
    FHLControl.Width     := W0;
    FHDelimControl.Width := FHHControl.Height;
    FMHControl.Width     := W0;
    FMLControl.Width     := W0;
    FSDelimControl.Width := FHHControl.Height;
    FSHControl.Width     := W0;
    FSLControl.Width     := W0;

    FHHControl.Position.X := (FHoursLayout.Width / 2) - FHHControl.Width;
    FHLControl.Position.X := (FHoursLayout.Width / 2);

    FMHControl.Position.X := (FHoursLayout.Width / 2) - FMHControl.Width;
    FMLControl.Position.X := (FHoursLayout.Width / 2);

    FSHControl.Position.X := (FHoursLayout.Width / 2) - FSHControl.Width;
    FSLControl.Position.X := (FHoursLayout.Width / 2);

    FHDelimControl.Position.X := (FHoursLayout.Width / 2) - (FHDelimControl.Width / 2);
    FSDelimControl.Position.X := (FHoursLayout.Width / 2) - (FSDelimControl.Width / 2);

    H :=
      FHoursLayout.Height +
      FHoursDelimLayout.Height +
      FMinutesLayout.Height +
      FSecondsDelimLayout.Height +
      FSecondsLayout.Height;

    FHoursLayout.Margins.Top := (FDigitsLayout.Height - H) / 2;
  end;

  procedure ResizeHorizontalBoardFrame(const AParentFrame: TFrame);

    procedure _HorizontalAlign(
      const AControl: TControl;
      const AWidth: Single);
    begin
      AControl.Width := AWidth;
      AControl.Align := TAlignLayout.Left;
    end;

  var
    W: Single;
    H: Single;
    W0: Single;
    W1: Single;
  begin
    if AParentFrame.Height / AParentFrame.Width >= 0.25 then
    begin
      W := AParentFrame.Width - 10;
      FDigitsLayout.Width := W;
      FDigitsLayout.Height := W / 4;
    end
    else
    begin
      H := AParentFrame.Height - 10;
      W := H / 2;
      FDigitsLayout.Height := H;
      FDigitsLayout.Width := (W * 6) + (W * 2);
    end;

    W0 := FDigitsLayout.Width / 4;
    W1 := FDigitsLayout.Width / 8;

    _HorizontalAlign(FHoursLayout, W0);
    _HorizontalAlign(FHHControl, W0 / 2);
    _HorizontalAlign(FHLControl, W0 / 2);
    _HorizontalAlign(FHoursDelimLayout, W1);
    _HorizontalAlign(FHDelimControl, W1);
    _HorizontalAlign(FMinutesLayout, W0);
    _HorizontalAlign(FMHControl, W0 / 2);
    _HorizontalAlign(FMLControl, W0 / 2);
    _HorizontalAlign(FSecondsDelimLayout, W1);
    _HorizontalAlign(FSDelimControl, W1);
    _HorizontalAlign(FSecondsLayout, W0);
    _HorizontalAlign(FSHControl, W0 / 2);
    _HorizontalAlign(FSLControl, W0 / 2);

    FSecondsLayout.Align := TAlignLayout.Right;
    FSecondsDelimLayout.Align := TAlignLayout.Right;
    FMinutesLayout.Align := TAlignLayout.Right;
    FHoursDelimLayout.Align := TAlignLayout.Right;
    FHoursLayout.Align := TAlignLayout.Right;

    FHoursLayout.Align := TAlignLayout.Left;
    FHoursDelimLayout.Align := TAlignLayout.Left;
    FMinutesLayout.Align := TAlignLayout.Left;
    FSecondsDelimLayout.Align := TAlignLayout.Left;
    FSecondsLayout.Align := TAlignLayout.Left;
  end;

var
  ParentFrame: TFrame;
begin
  FDigitsLayout.Align := TAlignLayout.None;

  ParentFrame := TControlTools.FindParentFrame(FDigitsLayout);

  if FOrientation = okVertical then
  begin
    ResizeVerticalBoardFrame(ParentFrame);
  end
  else
  if FOrientation = okHorizontal then
  begin
    ResizeHorizontalBoardFrame(ParentFrame);
  end;

  if FHDelimControl is TText then
  begin
    _SetTextSize(FHHControl);
    _SetTextSize(FHLControl);
    _SetTextSize(FHDelimControl);
    _SetTextSize(FMHControl);
    _SetTextSize(FMLControl);
    _SetTextSize(FSDelimControl);
    _SetTextSize(FSHControl);
    _SetTextSize(FSLControl);
  end;

  FDigitsLayout.Align  := TAlignLayout.Center;
end;

end.
