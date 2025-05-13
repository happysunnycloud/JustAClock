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
    class var FBeginProportion: Single;
    class var FBottomMargin: Single;
    class var FWidthRatio: Single;
    class var FHeightRatio: Single;

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
    class function ClientWidth: Single;
    class function ClientHeight: Single;
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

var
{$IFDEF ANDROID}
  ScreenService: IFMXScreenService;
  sScreenSize: TPoint;
{$ENDIF}
  MinWidth: Integer;
  MinHeight: Integer;
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

  MinWidth := AMinWidth;
  MinHeight := AMinHeight;

  if FOrientation = okVertical then
  begin
    {$IFDEF MSWINDOWS}
    FDigitsLayout.Position.X := 5;//MinWidth / 10;
    FDigitsLayout.Position.Y := 5;//MinHeight / 20;
    {$ELSE IFDEF ANDROID}
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenService)) then
    begin
      sScreenSize := ScreenService.GetScreenSize.Round;

      if (sScreenSize.Y / sScreenSize.X) < (16 / 9) then
      begin
        FDigitsLayout.Position.X := MinWidth / 6;
        FDigitsLayout.Position.Y := MinHeight / 14;
      end
      else
      begin
        FDigitsLayout.Position.X := MinWidth / 6;
        FDigitsLayout.Position.Y := MinHeight / 14;
      end;
    end;
    {$ENDIF}
    FDigitsLayout.Width := MinWidth - (FDigitsLayout.Position.X * 2);
    FDigitsLayout.Height := MinHeight - (FDigitsLayout.Position.Y * 2);

    FWidthRatio := FDigitsLayout.Width / AMinWidth;
    FHeightRatio := FDigitsLayout.Width / FDigitsLayout.Height;
    FBottomMargin := MinHeight - (FDigitsLayout.Position.Y + FDigitsLayout.Height);

    FBeginProportion := FDigitsLayout.Width / FDigitsLayout.Height;

    FDigitsLayout.Align := TAlignLayout.Center;
  end
  else
  if FOrientation = okHorizontal then
  begin
    {$IFDEF MSWINDOWS}
    FDigitsLayout.Position.X := 5;//MinWidth / 64;
    FDigitsLayout.Position.Y := 10;//MinHeight / 12;
    {$ELSE IFDEF ANDROID}
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenService)) then
    begin
      sScreenSize := ScreenService.GetScreenSize.Round;

      if (sScreenSize.Y / sScreenSize.X) < (16 / 9) then
      begin
        FDigitsLayout.Position.X := MinWidth / 6;
        FDigitsLayout.Position.Y := MinHeight / 14;
      end
      else
      begin
        FDigitsLayout.Position.X := MinWidth / 6;
        FDigitsLayout.Position.Y := MinHeight / 14;
      end;
    end;
    {$ENDIF}
    FDigitsLayout.Width := AMinWidth - (FDigitsLayout.Position.X * 2);
    FDigitsLayout.Height := AMinHeight - (FDigitsLayout.Position.Y * 2);

    FWidthRatio := FDigitsLayout.Width / AMinWidth;
    FHeightRatio := FDigitsLayout.Height / FDigitsLayout.Width;
    FBottomMargin := FDigitsLayout.Position.Y;

    FBeginProportion := FDigitsLayout.Height / FDigitsLayout.Width;

    FDigitsLayout.Align := TAlignLayout.Center;
  end;
end;

class function TProportion.ClientWidth: Single;
begin
  Result := Trunc(FOrigin.Width);
end;

class function TProportion.ClientHeight: Single;
begin
  Result := FOrigin.Height;
end;

class procedure TProportion.Resize;

  procedure ResizeVerticalBoardFrame;
  var
    W0: Single;
    H0: Single;
    H1: Single;
  begin
    FDigitsLayout.Align  := TAlignLayout.None;

    W0 := FDigitsLayout.Width  / 2;
    H0 := FDigitsLayout.Height / 4;
    H1 := FDigitsLayout.Height / 8;

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
    FHDelimControl.Width := W0;
    FMHControl.Width     := W0;
    FMLControl.Width     := W0;
    FSDelimControl.Width := W0;
    FSHControl.Width     := W0;
    FSLControl.Width     := W0;

    FDigitsLayout.Position.X := (TProportion.ClientWidth / 2) - (FDigitsLayout.Width / 2);
    FDigitsLayout.Position.Y := (TProportion.ClientHeight / 2) - (FDigitsLayout.Height / 2);

    FDigitsLayout.Align  := TAlignLayout.Center;
  end;

  procedure ResizeHorizontalBoardFrame;
    procedure _HorizontalAlign(const AControl: TControl; const AWidth: Single);
    begin
      AControl.Width := AWidth;
      AControl.Align := TAlignLayout.Left;
    end;
  var
    W0: Single;
    W1: Single;
  begin
    FDigitsLayout.Align  := TAlignLayout.None;

    W0 := FDigitsLayout.Width / 4;
    W1 := FDigitsLayout.Width / 4 / 2;

    _HorizontalAlign(FHoursLayout, W0);
    _HorizontalAlign(FHHControl, W0 / 2);
    _HorizontalAlign(FHLControl, W0 / 2);
    _HorizontalAlign(FHoursDelimLayout , W1);
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

    FDigitsLayout.Position.X := (TProportion.ClientWidth / 2) - (FDigitsLayout.Width / 2);
    FDigitsLayout.Position.Y := (TProportion.ClientHeight / 2) - (FDigitsLayout.Height / 2);

    FDigitsLayout.Align  := TAlignLayout.Center;
  end;

  procedure _ProportionalAligment(
    const AClientFormWidth: Single;
    const AClientFormHeight: Single);

    procedure _ResizeBoardFrame(const AOrientation: TOrientationKind);
    begin
      if AOrientation = okVertical then
      begin
        ResizeVerticalBoardFrame;
      end
      else
      if AOrientation = okHorizontal then
      begin
        ResizeHorizontalBoardFrame;
      end;
    end;

  var
    H, W: Single;
    NewProportion: Single;
  begin
    if FOrientation = okVertical then
    begin
      W := AClientFormWidth * FWidthRatio;
      H := W / FHeightRatio;

      FDigitsLayout.Width := W;
      FDigitsLayout.Height := H;

      _ResizeBoardFrame(FOrientation);

      if FDigitsLayout.Position.Y < FBottomMargin then
      begin
        FDigitsLayout.Height := TProportion.ClientHeight - (FBottomMargin * 2);

        _ResizeBoardFrame(FOrientation);
      end;

      NewProportion := FDigitsLayout.Width / FDigitsLayout.Height;

      if NewProportion > FBeginProportion then
      begin
        FDigitsLayout.Width := FDigitsLayout.Height * FBeginProportion;

        _ResizeBoardFrame(FOrientation);
      end;
    end
    else
    if FOrientation = okHorizontal then
    begin
      W := AClientFormWidth * FWidthRatio;
      H := W * FHeightRatio;

      FDigitsLayout.Width := W;
      FDigitsLayout.Height := H;

      _ResizeBoardFrame(FOrientation);

      if FDigitsLayout.Position.Y < FBottomMargin then
      begin
        FDigitsLayout.Height := TProportion.ClientHeight - (FBottomMargin * 2);
        FDigitsLayout.Width := FDigitsLayout.Height / FHeightRatio;

        _ResizeBoardFrame(FOrientation);
      end;
    end;
  end;

begin
  FDigitsLayout.Align := TAlignLayout.None;

  _ProportionalAligment(
    TProportion.ClientWidth,
    TProportion.ClientHeight);
end;

end.
