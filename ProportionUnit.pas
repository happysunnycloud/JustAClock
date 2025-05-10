unit ProportionUnit;

interface

uses
    FMX.Layouts
  , FMX.Controls
  ;

type
  TProportion = class
  const
    DISIGN_TIME_FORM_CLIENT_WIDTH = 120;
    DISIGN_TIME_FORM_CLIENT_HEIGHT = 280;
  strict private
    class var FBeginProportion: Single;
    class var FBottomMargin: Single;
    class var FWidthRatio: Single;
    class var FHeightRatio: Single;

    class var FOrigin: TObject;
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
    class function ClientFormWidth: Integer;
    class function ClientFormHeight: Integer;
  public
    class procedure Init(
      const AOrigin: TObject;
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
  , BorderFrameUnit
{$IFDEF ANDROID}
  , FMX.Platform
{$ENDIF}
  ;

class procedure TProportion.Init(
  const AOrigin: TObject;
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

  {$IFDEF MSWINDOWS}
  FDigitsLayout.Position.X := MinWidth / 10;
  FDigitsLayout.Position.Y := MinHeight / 20;
  {$ELSE IFDEF ANDROID}
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenService)) then
  begin
    sScreenSize := ScreenService.GetScreenSize.Round;

    if (sScreenSize.Y / sScreenSize.X) < (16 / 9) then
    begin
      FDigitsLayout.Position.X := MinWidth / 3;
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
end;

//class procedure TProportion.Init(
//  const AOriginForm: TForm;
//  const AMinWidth: Integer;
//  const AMinHeight: Integer;
//  const ADigitsLayout: TLayout;
//  const AHoursLayout: TLayout;
//  const AHoursDelimLayout: TLayout;
//  const AMinutesLayout: TLayout;
//  const ASecondsDelimLayout: TLayout;
//  const ASecondsLayout: TLayout;
//  const AHHControl: TControl;
//  const AHLControl: TControl;
//  const AHDelimControl: TControl;
//  const AMHControl: TControl;
//  const AMLControl: TControl;
//  const ASDelimControl: TControl;
//  const ASHControl: TControl;
//  const ASLControl: TControl);
//
//{$IFDEF ANDROID}
//var
//  ScreenService: IFMXScreenService;
//  sScreenSize: TPoint;
//{$ENDIF}
//var
//  H: Integer;
//  W: Integer;
//begin
//  FOriginForm := AOriginForm;
//  H := FOriginForm.ClientHeight;
//  W := FOriginForm.ClientWidth;
//
//  FDigitsLayout := ADigitsLayout;
//  FHoursLayout := AHoursLayout;
//  FHoursDelimLayout := AHoursDelimLayout;
//  FMinutesLayout := AMinutesLayout;
//  FSecondsDelimLayout := ASecondsDelimLayout;
//  FSecondsLayout := ASecondsLayout;
//  FHHControl := AHHControl;
//  FHLControl := AHLControl;
//  FHDelimControl := AHDelimControl;
//  FMHControl := AMHControl;
//  FMLControl := AMLControl;
//  FSDelimControl := ASDelimControl;
//  FSHControl := ASHControl;
//  FSLControl := ASLControl;
//
//  {$IFDEF MSWINDOWS}
//  FDigitsLayout.Position.X := TProportion.ClientFormWidth / 10;
//  FDigitsLayout.Position.Y := TProportion.ClientFormHeight / 14;
//  {$ELSE IFDEF ANDROID}
//  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenService)) then
//  begin
//    sScreenSize := ScreenService.GetScreenSize.Round;
//
//    if (sScreenSize.Y / sScreenSize.X) < (16 / 9) then
//    begin
//      FDigitsLayout.Position.X := TProportion.ClientFormWidth / 3;
//      FDigitsLayout.Position.Y := TProportion.ClientFormHeight / 14;
//    end
//    else
//    begin
//      FDigitsLayout.Position.X := TProportion.ClientFormWidth / 6;
//      FDigitsLayout.Position.Y := TProportion.ClientFormHeight / 14;
//    end;
//  end;
//  {$ENDIF}
//  FDigitsLayout.Width := TProportion.ClientFormWidth - (FDigitsLayout.Position.X * 2);
//  FDigitsLayout.Height := TProportion.ClientFormHeight - (FDigitsLayout.Position.Y * 2);
//
//  FWidthRatio := FDigitsLayout.Width / TProportion.ClientFormWidth;
//  FHeightRatio := FDigitsLayout.Width / FDigitsLayout.Height;
//  FBottomMargin := TProportion.ClientFormHeight - (FDigitsLayout.Position.Y + FDigitsLayout.Height);
//
//  FBeginProportion := FDigitsLayout.Width / FDigitsLayout.Height;
//
//  FDigitsLayout.Align := TAlignLayout.Center;
//end;

class function TProportion.ClientFormWidth: Integer;
begin
  if FOrigin is TForm then
    Result := TForm(FOrigin).ClientWidth
  else
  if FOrigin is TBorderFrame then
    Result := TBorderFrame(FOrigin).ClientWidth
  else
    raise Exception.Create('TProportion.ClientFormWidth: Unknown origin type');
end;

class function TProportion.ClientFormHeight: Integer;
begin
  if FOrigin is TForm then
    Result := TForm(FOrigin).ClientHeight
  else
  if FOrigin is TBorderFrame then
    Result := TBorderFrame(FOrigin).ClientHeight
  else
    raise Exception.Create('TProportion.ClientFormHeight: Unknown origin type');
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

    FDigitsLayout.Position.X := (TProportion.ClientFormWidth / 2) - (FDigitsLayout.Width / 2);
    FDigitsLayout.Position.Y := (TProportion.ClientFormHeight / 2) - (FDigitsLayout.Height / 2);
//    FDigitsLayout.InvalidateRect(FDigitsLayout.ClipRect);

    FDigitsLayout.Align  := TAlignLayout.Center;
  end;

  procedure _ProportionalAligment(
    const AClientFormWidth: Integer;
    const AClientFormHeight: Integer);
  var
    H, W: Single;
//    NewBottomMargin: Single;
    NewProportion: Single;
  begin
    W := AClientFormWidth * FWidthRatio;
    H := W / FHeightRatio;

    FDigitsLayout.Width := W;
    FDigitsLayout.Height := H;

    ResizeVerticalBoardFrame;

//    NewBottomMargin := AClientFormHeight - (FDigitsLayout.Position.Y + FDigitsLayout.Height);
//    if NewBottomMargin < 0 then
//      NewBottomMargin := NewBottomMargin * -1;
//    if NewBottomMargin < FBottomMargin then
    if FDigitsLayout.Position.Y < FBottomMargin then
    begin
      FDigitsLayout.Height := TProportion.ClientFormHeight - (FBottomMargin * 2);
//      FDigitsLayout.Height := FDigitsLayout.Height - (FBottomMargin - NewBottomMargin) * 2;

      ResizeVerticalBoardFrame;
    end;

    NewProportion := FDigitsLayout.Width / FDigitsLayout.Height;

    if NewProportion > FBeginProportion then
    begin
      FDigitsLayout.Width := FDigitsLayout.Height * FBeginProportion;

      ResizeVerticalBoardFrame;
    end;
  end;

begin
  FDigitsLayout.Align := TAlignLayout.None;

  _ProportionalAligment(
    TProportion.ClientFormWidth,
    TProportion.ClientFormHeight);
end;

end.
