unit JustAClockUnit;
{ 85 * 230 }
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts,
  TimeThreadUnit,
  ElectronicBoardFrameUnit, FMX.Menus,
  FMX.FormExtUnit,
  CommonUnit, FMX.Controls.Presentation, FMX.Edit,
  TextBoardFrameUnit
  , FMX.PopupMenuExtUnit
  {$IFDEF MSWINDOWS}
  , BorderFrameUnit
  , FMX.Craft.PopupMenu.Win, FMX.Gestures
  {$ENDIF}
  {$IFDEF ANDROID}
  , FMX.Platform
  {$ENDIF}
  ;

type
  TElectronicBoardColorArray = TArray<String>;
  TElectronicBoardColorArrayHelper = record helper for TElectronicBoardColorArray
  public
    function FirstValue: String;
    function LastValue: String;
    function NextValue(const ACurrentValue: String): String;
  end;

  TMainForm = class(TFormExt)
    TimeText: TText;
    loContent: TLayout;
    TimeLayout: TLayout;
    SettingsPopupMenu: TPopupMenu;
    SignalRectangle: TRectangle;
    ToolsPopupMenu: TPopupMenu;
    TextTimeLayout: TLayout;
    TextHoursLayout: TLayout;
    TextHoursDelimLayout: TLayout;
    TextMinutesLayout: TLayout;
    TextSecondsDelimLayout: TLayout;
    TextSecondsLayout: TLayout;
    HHText: TText;
    HLText: TText;
    HDelimText: TText;
    MHText: TText;
    MLText: TText;
    SDelimText: TText;
    SHText: TText;
    SLText: TText;
    TimeVoidEdit: TEdit;
    SettingsLayout: TLayout;
    ToolsLayout: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SettingsLayoutTap(Sender: TObject; const Point: TPointF);
    procedure SettingsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ToolsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ToolsLayoutTap(Sender: TObject; const Point: TPointF);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  strict private
    FTimeThread: TTimeThread;

    FElectronicBoardFrame: TElectronicBoardFrame;
    FTextBoardFrame: TTextBoardFrame;
    FCurrentElectronicBoardColor: String;
    FElectronicBoardColorArray: TElectronicBoardColorArray;
    FSettingsPopupMenuExt: TPopupMenuExt;
    FToolsPopupMenuExt: TPopupMenuExt;

    {$IFDEF MSWINDOWS}
    FBorderFrame: TBorderFrame;
    FTrayPopupMenu: TCraftPopupMenu;
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    procedure TrayIconMouseRightButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TrayIconMouseLeftButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnCloseTrayItemHandler;
    {$ENDIF}
    procedure MenuColorItemClickHandler(Sender: TObject);
    procedure MenuTextBoardItemClickHandler(Sender: TObject);
    procedure MenuElectronicBoardItemClickHandler(Sender: TObject);
    procedure MenuCountDownItemClickHandler(Sender: TObject);
    procedure MenuCancelTimerItemClickHandler(Sender: TObject);
    procedure MenuSetCustomColorItemClickHandler(Sender: TObject);
    procedure MenuGetCustomColorItemClickHandler(Sender: TObject);

    procedure MenuHorizontalOrientationItemClickHandler(Sender: TObject);
    procedure MenuVerticalOrientationItemClickHandler(Sender: TObject);

    procedure SetTimerFormOkButtonClickHandler(Sender: TObject);
    procedure SetCustomColorOkButtonClickHandler(Sender: TObject);

    procedure TimeVoidEditOnChangeHandler(Sender: TObject);

    procedure RunTime;
    procedure RunTimer(const ATimerTime: TTime);

    procedure ResizeVerticalBoardFrame(
      const WidthCorrector: Single;
      const HeightCorrector: Single;
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

    procedure ResizeHorizontalBoardFrame(
      const WidthCorrector: Single;
      const HeightCorrector: Single;
      const WidthDigitsCorrector: Single;
      const WidthDelimiterCorrector: Single;
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
  private
    {$IFDEF ANDROID}
    function HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    {$ENDIF}
    procedure OpenBoard(
      const ABoard: TBoardKind;
      const AColor: TAlphaColor;
      const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
    procedure CloseBoard;
  public
    procedure StartSignal;
    procedure StopSignal;
    {$IFDEF MSWINDOWS}
    property BorderFrame: TBorderFrame read FBorderFrame;
    {$ENDIF}
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  {$IFDEF MSWINDOWS}
    Winapi.Windows
  , FMX.Platform.Win
  , FMX.Craft.PopupMenu.Structures
  , FMX.Craft.PopupMenu.Thread.Win
  ,
  {$ENDIF}
    ShowTimeUnit
  , ShowTextTimeUnit
  , ThreadFactoryUnit
  , NumScrollUnit
  , SetTimerFormUnit
  , SetCustomColorUnit
  , VerticalElectronicBoardFrameUnit
  , VerticalTextBoardFrameUnit
  ;

{ TElectronicBoardColorArrayHelper }

function TElectronicBoardColorArrayHelper.FirstValue: String;
begin
  Result := Self[0];
end;

function TElectronicBoardColorArrayHelper.LastValue: String;
begin
  Result := Self[High(Self)];
end;

function TElectronicBoardColorArrayHelper.NextValue(
  const ACurrentValue: String): String;
var
  Index: Integer;
  HighIndex: Integer;
begin
  HighIndex := High(Self);
  for Index := 0 to HighIndex do
    if Self[Index] = ACurrentValue then
      Break;

  if Index = HighIndex then
    Index := 0
  else
    Inc(Index);

  Result := Self[Index];
end;

{ TMainForm }
{$IFDEF MSWINDOWS}
procedure TMainForm.OnCloseTrayItemHandler;
begin
  if Assigned(MainForm) then
    MainForm.BorderFrame.CloseButtonRectangle.
      OnClick(MainForm.BorderFrame.CloseButtonRectangle);
end;

procedure TMainForm.TrayIconMouseRightButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  GetCurPos(X, Y);
  if Assigned(FTrayPopupMenu) then
    FTrayPopupMenu.Open(Trunc(X), Trunc(Y));
end;

procedure TMainForm.TrayIconMouseLeftButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ShowWindow(ApplicationHWND, SW_HIDE);
end;
{$ENDIF}
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
//{$IFDEF ANDROID}
//  Action := TCloseAction.caFree;
//{$ENDIF}
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FTimeThread := nil;
end;

{$IFDEF ANDROID}
function TMainForm.HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  Result := True;

  case AAppEvent of
    TApplicationEvent.FinishedLaunching:
    begin
    end;
    TApplicationEvent.BecameActive:
    begin
    end;
    TApplicationEvent.WillBecomeInactive:
    begin
    end;
    TApplicationEvent.EnteredBackground:
    begin
    end;
    TApplicationEvent.WillBecomeForeground:
    begin
    end;
//  case AAppEvent of
//    TApplicationEvent.FinishedLaunching:
//    begin
//      ShowMessage('FinishedLaunching');
//    end;
//    TApplicationEvent.BecameActive:
//    begin
//      ShowMessage('BecameActive');
//    end;
//    TApplicationEvent.WillBecomeInactive:
//    begin
//      ShowMessage('WillBecomeForeground');
//    end;
//    TApplicationEvent.EnteredBackground:
//    begin
//     ShowMessage('EnteredBackground');
//    end;
//    TApplicationEvent.WillBecomeForeground:
//    begin
//      ShowMessage('WillBecomeForeground');
//    end;
//    TApplicationEvent.WillTerminate: Memo1.Lines.Insert(0, 'Will Terminate');
//    TApplicationEvent.LowMemory: Memo1.Lines.Insert(0, 'Low Memory');
//    TApplicationEvent.TimeChange: Memo1.Lines.Insert(0, 'Time Change');
//    TApplicationEvent.OpenURL: Memo1.Lines.Insert(0, 'Open URL');
  end;
end;
{$ENDIF}

procedure TMainForm.FormCreate(Sender: TObject);
const
  SCALE_VALUE = 1;
var
  {$IFDEF ANDROID}
  aFMXApplicationEventService: IFMXApplicationEventService;
  {$ENDIF}
//  MenuItem: TMenuItem;
//
//  Colors: TMenuItem;
//  CustomColors: TMenuItem;
//  SetCustomColors: TMenuItem;
//  Boards: TMenuItem;
  ColorIdent: String;
  Boards: TItem;
  MenuItem: TItem;
  Colors: TItem;
  CustomColors: TItem;
  SetCustomColors: TItem;
  Orientation: TItem;
  i: Integer;
begin
  ReportMemoryLeaksOnShutdown := true;

  {$IFDEF ANDROID}
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(aFMXApplicationEventService)) then
    aFMXApplicationEventService.SetApplicationEventHandler(HandleAppEvent)
  else
    ShowMessage('Application Event Service is not supported');
  {$ENDIF}

  SetTimerForm := nil;
  SignalRectangle.Visible := false;

  FElectronicBoardColorArray := TElectronicBoardColorArray.Create(
    'Green',
    'Red',
    'Orange',
    'White',
    'Blue',
    'Violet');

  { SettingsPopupMenu }

  FSettingsPopupMenuExt := TPopupMenuExt.Create(Self);

  Boards := TItem.Create;
  Boards.Text := 'Boards';
  FSettingsPopupMenuExt.Add(Boards);

  MenuItem := TItem.Create;
  MenuItem.Parent := Boards;
  MenuItem.Text := 'Text';
  MenuItem.OnClick := MenuTextBoardItemClickHandler;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Parent := Boards;
  MenuItem.Text := 'Electronic';
  MenuItem.OnClick := MenuElectronicBoardItemClickHandler;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  Colors := TItem.Create;
  Colors.Text := 'Colors';
  FSettingsPopupMenuExt.Add(Colors);

  for i := 0 to Pred(Length(FElectronicBoardColorArray)) do
  begin
    ColorIdent := FElectronicBoardColorArray[i];
    MenuItem := TItem.Create;
    MenuItem.Parent := Colors;
    MenuItem.Text := ColorIdent;
    MenuItem.Tag := i;
    MenuItem.OnClick := MenuColorItemClickHandler;
    FSettingsPopupMenuExt.Add(MenuItem);
  end;

  CustomColors := TItem.Create;
  CustomColors.Text := 'Custom color';
  CustomColors.Tag := 0;
  FSettingsPopupMenuExt.Add(CustomColors);

  for i := 0 to 3 do
  begin
    MenuItem := TItem.Create;
    MenuItem.Parent := CustomColors;
    MenuItem.Text := 'Custom color ' + (i + 1).ToString;
    MenuItem.Tag := i;
    MenuItem.OnClick := MenuGetCustomColorItemClickHandler;
    FSettingsPopupMenuExt.Add(MenuItem);
  end;

  MenuItem := TItem.Create;
  MenuItem.Parent := CustomColors;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  SetCustomColors := TItem.Create;
  SetCustomColors.Parent := CustomColors;
  SetCustomColors.Text := 'Set';
  SetCustomColors.Tag := 0;
  FSettingsPopupMenuExt.Add(SetCustomColors);

  for i := 0 to 3 do
  begin
    MenuItem := TItem.Create;
    MenuItem.Parent := SetCustomColors;
    MenuItem.Text := 'Set custom color ' + (i + 1).ToString;
    MenuItem.Tag := i;
    MenuItem.OnClick := MenuSetCustomColorItemClickHandler;
    FSettingsPopupMenuExt.Add(MenuItem);
  end;

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  Orientation := TItem.Create;
  Orientation.Text := 'Orientation';
  FSettingsPopupMenuExt.Add(Orientation);

  MenuItem := TItem.Create;
  MenuItem.Parent := Orientation;
  MenuItem.Text := 'Horizontal';
  MenuItem.Tag := 0;
  MenuItem.OnClick := MenuHorizontalOrientationItemClickHandler;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Parent := Orientation;
  MenuItem.Text := 'Vertical';
  MenuItem.Tag := 0;
  MenuItem.OnClick := MenuVerticalOrientationItemClickHandler;
  FSettingsPopupMenuExt.Add(MenuItem);

//  Boards := TMenuItem.Create(SettingsPopupMenu);
//  Boards.Text := 'Boards';
//  SettingsPopupMenu.AddObject(Boards);
//
//  MenuItem := TMenuItem.Create(Boards);
//  MenuItem.Text := 'Text';
//  MenuItem.OnClick := MenuTextBoardItemClickHandler;
//  Boards.AddObject(MenuItem);
//
//  MenuItem := TMenuItem.Create(Boards);
//  MenuItem.Text := 'Electronic';
//  MenuItem.OnClick := MenuElectronicBoardItemClickHandler;
//  Boards.AddObject(MenuItem);
//
//  MenuItem := TMenuItem.Create(SettingsPopupMenu);
//  MenuItem.Text := '-';
//  MenuItem.Tag := -1;
//  SettingsPopupMenu.AddObject(MenuItem);
//
//  Colors := TMenuItem.Create(SettingsPopupMenu);
//  Colors.Text := 'Colors';
//  SettingsPopupMenu.AddObject(Colors);
//  for i := 0 to Pred(Length(FElectronicBoardColorArray)) do
//  begin
//    ColorIdent := FElectronicBoardColorArray[i];
//    MenuItem := TMenuItem.Create(Colors);
//    MenuItem.Text := ColorIdent;
//    MenuItem.Tag := i;
//    MenuItem.OnClick := MenuColorItemClickHandler;
//    Colors.AddObject(MenuItem);
//  end;
//
//  CustomColors := TMenuItem.Create(SettingsPopupMenu);
//  CustomColors.Text := 'Custom color';
//  CustomColors.Tag := 0;
//  SettingsPopupMenu.AddObject(CustomColors);
//
//  for i := 0 to 3 do
//  begin
//    MenuItem := TMenuItem.Create(CustomColors);
//    MenuItem.Text := 'Custom color ' + (i + 1).ToString;
//    MenuItem.Tag := i;
//    MenuItem.OnClick := MenuGetCustomColorItemClickHandler;
//    CustomColors.AddObject(MenuItem);
//  end;
//
//  MenuItem := TMenuItem.Create(CustomColors);
//  MenuItem.Text := '-';
//  MenuItem.Tag := -1;
//  CustomColors.AddObject(MenuItem);
//
//  SetCustomColors := TMenuItem.Create(CustomColors);
//  SetCustomColors.Text := 'Set';
//  SetCustomColors.Tag := 0;
//  CustomColors.AddObject(SetCustomColors);
//
//  for i := 0 to 3 do
//  begin
//    MenuItem := TMenuItem.Create(SetCustomColors);
//    MenuItem.Text := 'Set custom color ' + (i + 1).ToString;
//    MenuItem.Tag := i;
//    MenuItem.OnClick := MenuSetCustomColorItemClickHandler;
//    SetCustomColors.AddObject(MenuItem);
//  end;
//
//  MenuItem := TMenuItem.Create(SettingsPopupMenu);
//  MenuItem.Text := '-';
//  MenuItem.Tag := -1;
//  SettingsPopupMenu.AddObject(MenuItem);
//
//  Orientation := TMenuItem.Create(SettingsPopupMenu);
//  Orientation.Text := 'Orientation';
//  SettingsPopupMenu.AddObject(Orientation);
//
//  MenuItem := TMenuItem.Create(Orientation);
//  MenuItem.Text := 'Horizontal';
//  MenuItem.Tag := 0;
//  MenuItem.OnClick := MenuHorizontalOrientationItemClickHandler;
//  Orientation.AddObject(MenuItem);
//
//  MenuItem := TMenuItem.Create(Orientation);
//  MenuItem.Text := 'Vertical';
//  MenuItem.Tag := 0;
//  MenuItem.OnClick := MenuVerticalOrientationItemClickHandler;
//  Orientation.AddObject(MenuItem);

  { ToolsPopupMenu }

  FToolsPopupMenuExt := TPopupMenuExt.Create(Self);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Set timer';
  MenuItem.OnClick := MenuCountDownItemClickHandler;
  FToolsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FToolsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Cancel';
  MenuItem.OnClick := MenuCancelTimerItemClickHandler;
  FToolsPopupMenuExt.Add(MenuItem);

//  MenuItem := TMenuItem.Create(ToolsPopupMenu);
//  MenuItem.Text := 'Set timer';
//  MenuItem.OnClick := MenuCountDownItemClickHandler;
//  ToolsPopupMenu.AddObject(MenuItem);
//
//  MenuItem := TMenuItem.Create(ToolsPopupMenu);
//  MenuItem.Text := '-';
//  MenuItem.Tag := -1;
//  ToolsPopupMenu.AddObject(MenuItem);
//
//  MenuItem := TMenuItem.Create(ToolsPopupMenu);
//  MenuItem.Text := 'Cancel';
//  MenuItem.OnClick := MenuCancelTimerItemClickHandler;
//  ToolsPopupMenu.AddObject(MenuItem);

  FCurrentElectronicBoardColor := FElectronicBoardColorArray.LastValue;
  {$IFDEF MSWINDOWS}
  ShowWindow(ApplicationHWND, SW_HIDE);

  FBorderFrame :=
    TBorderFrame.Create(
      Self,
      loContent,
      'Just a clock',
      Trunc(loContent.Width),
      Trunc(loContent.Height),
      $FF8D003A,
      $FF2A001A,
      TAlphaColorRec.Lime,
      $FFADADAD);

  FBorderFrame.MinWidth := HORIZONTAL_MIN_WIDTH;
  FBorderFrame.MinHeight := HORIZONTAL_MIN_HEIGHT;

  FBorderFrame.TrayIconMouseRightButtonDown := TrayIconMouseRightButtonDown;
  FBorderFrame.TrayIconMouseLeftButtonDown := TrayIconMouseLeftButtonDown;

  FTrayPopupMenu := nil;
  FTrayPopupMenu := TCraftPopupMenu.Create('>>', 1000);
  FTrayPopupMenu.MenuItems.AddItem('Close', 'Close', true, OnCloseTrayItemHandler);
  FTrayPopupMenu.BuildMenu;
  {$ELSE IFDEF ANDROID}
  Self.FullScreen := true;
  {$ENDIF}
  FElectronicBoardFrame := nil;

  RunTime;

  OpenBoard(TState.Board, TState.Color, TState.Orientation);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  //FSettingsPopupMenuExt.Free;

  TShowTextTime.UnInit;
  {$IFDEF MSWINDOWS}
  if Assigned(FTrayPopupMenu) then
    FTrayPopupMenu.Free;
  {$ENDIF}
  CloseBoard;
end;

procedure TMainForm.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  PaintRects(ARect);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if TState.Orientation = okHorizontal then
  begin
    SettingsLayout.Width := loContent.Width / 2;
    SettingsLayout.Height := loContent.Height;
    SettingsLayout.Position.X := loContent.Position.X;
    SettingsLayout.Position.Y := loContent.Position.Y;

    ToolsLayout.Width := loContent.Width / 2;
    ToolsLayout.Height := loContent.Height;
    ToolsLayout.Position.X := loContent.Width / 2;
    ToolsLayout.Position.Y := loContent.Position.Y;
  end
  else
  if TState.Orientation = okVertical then
  begin
    SettingsLayout.Width := loContent.Width;
    SettingsLayout.Height := loContent.Height / 2;
    SettingsLayout.Position.X := loContent.Position.X;
    SettingsLayout.Position.Y := loContent.Position.Y;

    ToolsLayout.Width := loContent.Width;
    ToolsLayout.Height := loContent.Height / 2;
    ToolsLayout.Position.X := loContent.Position.X;
    ToolsLayout.Position.Y := loContent.Height / 2;
  end;

  if Assigned(FTextBoardFrame) then
  begin
    if FTextBoardFrame is TVerticalTextBoardFrame then
    begin
      ResizeVerticalBoardFrame(
        0.6,
        0.85,
        FTextBoardFrame.TextTimeLayout,
        FTextBoardFrame.TextHoursLayout,
        FTextBoardFrame.TextHoursDelimLayout,
        FTextBoardFrame.TextMinutesLayout,
        FTextBoardFrame.TextSecondsDelimLayout,
        FTextBoardFrame.TextSecondsLayout,
        FTextBoardFrame.HHText,
        FTextBoardFrame.HLText,
        FTextBoardFrame.HDelimText,
        FTextBoardFrame.MHText,
        FTextBoardFrame.MLText,
        FTextBoardFrame.SDelimText,
        FTextBoardFrame.SHText,
        FTextBoardFrame.SLText);
    end
    else
    if FTextBoardFrame is TTextBoardFrame then
    begin
      ResizeHorizontalBoardFrame(
        0.85,
        0.6,
        3.5,
        14,
        FTextBoardFrame.TextTimeLayout,
        FTextBoardFrame.TextHoursLayout,
        FTextBoardFrame.TextHoursDelimLayout,
        FTextBoardFrame.TextMinutesLayout,
        FTextBoardFrame.TextSecondsDelimLayout,
        FTextBoardFrame.TextSecondsLayout,
        FTextBoardFrame.HHText,
        FTextBoardFrame.HLText,
        FTextBoardFrame.HDelimText,
        FTextBoardFrame.MHText,
        FTextBoardFrame.MLText,
        FTextBoardFrame.SDelimText,
        FTextBoardFrame.SHText,
        FTextBoardFrame.SLText);
    end;
  end
  else
  if Assigned(FElectronicBoardFrame) then
  begin
    if FElectronicBoardFrame is TVerticalElectronicBoardFrame then
    begin
      ResizeVerticalBoardFrame(
        0.65,
        0.75,
        FElectronicBoardFrame.DigitsLayout,
        FElectronicBoardFrame.HoursLayout,
        FElectronicBoardFrame.HoursDelimLayout,
        FElectronicBoardFrame.MinutesLayout,
        FElectronicBoardFrame.SecondsDelimLayout,
        FElectronicBoardFrame.SecondsLayout,
        FElectronicBoardFrame.HHImage,
        FElectronicBoardFrame.HLImage,
        FElectronicBoardFrame.HDelimImage,
        FElectronicBoardFrame.MHImage,
        FElectronicBoardFrame.MLImage,
        FElectronicBoardFrame.SDelimImage,
        FElectronicBoardFrame.SHImage,
        FElectronicBoardFrame.SLImage);
    end
    else
    if FElectronicBoardFrame is TElectronicBoardFrame then
    begin
      ResizeHorizontalBoardFrame(
        0.85,
        0.45,
        4,
        8,
        FElectronicBoardFrame.DigitsLayout,
        FElectronicBoardFrame.HoursLayout,
        FElectronicBoardFrame.HoursDelimLayout,
        FElectronicBoardFrame.MinutesLayout,
        FElectronicBoardFrame.SecondsDelimLayout,
        FElectronicBoardFrame.SecondsLayout,
        FElectronicBoardFrame.HHImage,
        FElectronicBoardFrame.HLImage,
        FElectronicBoardFrame.HDelimImage,
        FElectronicBoardFrame.MHImage,
        FElectronicBoardFrame.MLImage,
        FElectronicBoardFrame.SDelimImage,
        FElectronicBoardFrame.SHImage,
        FElectronicBoardFrame.SLImage);
    end;
  end;
end;

procedure TMainForm.TimeVoidEditOnChangeHandler(Sender: TObject);
var
  Time: String;
begin
  Time := Trim(TEdit(Sender).Text);
  if TState.Board = bkText then
    TShowTextTime.ShowTextTime(Time)
  else
    TShowTime.ShowTime(Time);
end;

procedure TMainForm.ToolsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  GetCurPos(X, Y);
  FToolsPopupMenuExt.Open(X, Y);
end;

procedure TMainForm.ToolsLayoutTap(Sender: TObject; const Point: TPointF);
begin
  FToolsPopupMenuExt.Open(Point.X, Point.Y);
end;

procedure TMainForm.OpenBoard(
  const ABoard: TBoardKind;
  const AColor: TAlphaColor;
  const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);

  procedure _SetScreenOrientation(const AOrientationKind: TOrientationKind);
  {$IFDEF ANDROID}
    procedure _SetAndroidScreenOrientation(
      const AAndroidScreenOrientation: TScreenOrientation);
    var
      ScreenService: IFMXScreenService;
      OrientSet: TScreenOrientations;
    begin
      if TPlatformServices.Current.
        SupportsPlatformService(IFMXScreenService, IInterface(ScreenService))
      then
      begin
        OrientSet := [AAndroidScreenOrientation];
        ScreenService.SetSupportedScreenOrientations(OrientSet);
      end;
    end;
  {$ENDIF}
  begin
    if AOrientationKind = okHorizontal then
    begin
      {$IFDEF MSWINDOWS}
      FBorderFrame.MinWidth := HORIZONTAL_MIN_WIDTH;
      FBorderFrame.MinHeight := HORIZONTAL_MIN_HEIGHT;
      {$ELSE IFDEF ANDROID}
      _SetAndroidScreenOrientation(TScreenOrientation.Landscape);
      {$ENDIF}
      FElectronicBoardFrame := TElectronicBoardFrame.Create(nil);
    end
    else
    if AOrientationKind = okVertical then
    begin
      {$IFDEF MSWINDOWS}
      FBorderFrame.MinWidth := VERTICAL_MIN_WIDTH;
      FBorderFrame.MinHeight := VERTICAL_MIN_HEIGHT;
      {$ELSE IFDEF ANDROID}
      _SetAndroidScreenOrientation(TScreenOrientation.Portrait);
      {$ENDIF}
      FElectronicBoardFrame := TVerticalElectronicBoardFrame.Create(nil);
    end;
  end;
begin
  TimeVoidEdit.OnChange := nil;
  if Assigned(FTimeThread) then
    FTimeThread.OutputControl := nil;

  CloseBoard;

  TState.Board := ABoard;
  TState.Orientation := AOrientation;
  TState.Color := AColor;

  if TState.Board = bkElectronic then
  begin
    _SetScreenOrientation(TState.Orientation);

    //    if TState.Orientation = okHorizontal then
    //    begin
    //      {$IFDEF MSWINDOWS}
    //      FBorderFrame.MinWidth := HORIZONTAL_MIN_WIDTH;
    //      FBorderFrame.MinHeight := HORIZONTAL_MIN_HEIGHT;
    //      {$ELSE IFDEF ANDROID}
    //      _SetAndroidOrientation(TScreenOrientation.Landscape);
    //      {$ENDIF}
    //      FElectronicBoardFrame := TElectronicBoardFrame.Create(nil);
    //    end
    //    else
    //    if TState.Orientation = okVertical then
    //    begin
    //      {$IFDEF MSWINDOWS}
    //      FBorderFrame.MinWidth := VERTICAL_MIN_WIDTH;
    //      FBorderFrame.MinHeight := VERTICAL_MIN_HEIGHT;
    //      {$ELSE IFDEF ANDROID}
    //      _SetAndroidOrientation(TScreenOrientation.Portrait);
    //      {$ENDIF}
    //      FElectronicBoardFrame := TVerticalElectronicBoardFrame.Create(nil);
    //    end;

    TShowTime.Init(
      GetDigitsPackFile,
      AColor,
      FElectronicBoardFrame.HHImage,
      FElectronicBoardFrame.HLImage,
      FElectronicBoardFrame.HDelimImage,
      FElectronicBoardFrame.MHImage,
      FElectronicBoardFrame.MLImage,
      FElectronicBoardFrame.SDelimImage,
      FElectronicBoardFrame.SHImage,
      FElectronicBoardFrame.SLImage,
      AOrientation);

    FElectronicBoardFrame.Parent := TimeLayout;
    FElectronicBoardFrame.Align := TAlignLayout.Contents;
    FElectronicBoardFrame.HitTest := false;
  end
  else
  if TState.Board = bkText then
  begin
    if TState.Orientation = okHorizontal then
    begin
      {$IFDEF MSWINDOWS}
      FBorderFrame.MinWidth := HORIZONTAL_MIN_WIDTH;
      FBorderFrame.MinHeight := HORIZONTAL_MIN_HEIGHT;
      {$ENDIF}
      FTextBoardFrame := TTextBoardFrame.Create(nil);
    end
    else
    if TState.Orientation = okVertical then
    begin
      {$IFDEF MSWINDOWS}
      FBorderFrame.MinWidth := VERTICAL_MIN_WIDTH;
      FBorderFrame.MinHeight := VERTICAL_MIN_HEIGHT;
      {$ENDIF}
      FTextBoardFrame := TVerticalTextBoardFrame.Create(nil);
    end;

    TShowTextTime.Init(
      AColor,
      FTextBoardFrame.HHText,
      FTextBoardFrame.HLText,
      FTextBoardFrame.HDelimText,
      FTextBoardFrame.MHText,
      FTextBoardFrame.MLText,
      FTextBoardFrame.SDelimText,
      FTextBoardFrame.SHText,
      FTextBoardFrame.SLText,
      TState.Orientation);

    FTextBoardFrame.Parent := TimeLayout;
    FTextBoardFrame.Align := TAlignLayout.Contents;
    FTextBoardFrame.HitTest := false;
  end;

  FTimeThread.OutputControl := TimeVoidEdit;
  TimeVoidEdit.OnChange := TimeVoidEditOnChangeHandler;

  Self.Resize;
end;

procedure TMainForm.CloseBoard;
begin
  TimeVoidEdit.OnChange := nil;
  if Assigned(FTimeThread) then
    FTimeThread.OutputControl := nil;

  TShowTime.UnInit;
  TShowTextTime.UnInit;

  if Assigned(FElectronicBoardFrame) then
  begin
    FreeAndNil(FElectronicBoardFrame);
  end;

  if Assigned(FTextBoardFrame) then
  begin
    FreeAndNil(FTextBoardFrame);
  end
end;

procedure TMainForm.MenuColorItemClickHandler(Sender: TObject);
var
  MenuItem: TItem;
begin
  MenuItem := TItem(Sender);
  TState.ColorIdent := FElectronicBoardColorArray[MenuItem.Tag];
  OpenBoard(
    TState.Board,
    ColorByIdent(TState.ColorIdent),
    TState.Orientation);
end;

procedure TMainForm.MenuTextBoardItemClickHandler(Sender: TObject);
begin
  OpenBoard(bkText, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuElectronicBoardItemClickHandler(Sender: TObject);
begin
  OpenBoard(bkElectronic, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuCountDownItemClickHandler(Sender: TObject);
begin
  StopSignal;

  SetTimerForm := TSetTimerForm.Create(Self);
  SetTimerForm.OkButtonRectangle.OnClick := SetTimerFormOkButtonClickHandler;
  SetTimerForm.ShowModal;
end;

procedure TMainForm.MenuCancelTimerItemClickHandler(Sender: TObject);
begin
  StopSignal;

  RunTime;
end;

procedure TMainForm.MenuSetCustomColorItemClickHandler(Sender: TObject);
var
  CustomColorNumber: Byte;
begin
  CustomColorNumber := TItem(Sender).Tag;
  SetCustomColorForm := TSetCustomColorForm.Create(Self);
  SetCustomColorForm.Tag := CustomColorNumber;
  SetCustomColorForm.Color := CustomColorByNumber(SetCustomColorForm.Tag);
  SetCustomColorForm.OkButtonRectangle.OnClick := SetCustomColorOkButtonClickHandler;
  {$IFDEF MSWINDOWS}
  SetCustomColorForm.ShowModal;
  {$ELSE IFDEF ANDROID}
  SetCustomColorForm.Show;
  {$ENDIF}
end;

procedure TMainForm.MenuGetCustomColorItemClickHandler(Sender: TObject);
var
  CustomColorNumber: Byte;
  Color: TAlphaColor;
begin
  CustomColorNumber := TItem(Sender).Tag;
  Color := CustomColorByNumber(CustomColorNumber);

  CloseBoard;
  OpenBoard(TState.Board, Color, TState.Orientation);
end;

procedure TMainForm.MenuVerticalOrientationItemClickHandler(Sender: TObject);
begin
  OpenBoard(TState.Board, TState.Color, okVertical);
end;

procedure TMainForm.MenuHorizontalOrientationItemClickHandler(Sender: TObject);
begin
  OpenBoard(TState.Board, TState.Color, okHorizontal);
end;

procedure TMainForm.RunTime;
var
  OutputControl: TControl;
begin
  OutputControl := TimeVoidEdit;

  if Assigned(FTimeThread) then
    FTimeThread.Terminate;

  ThreadFactory.CreateRegistredThread(
    procedure (
      const AThreadFactory: TThreadFactory)
    begin
      FTimeThread :=
        TTimeThread.Create(
          AThreadFactory,
          StrToTime('00:00:00'),
          TTimeKind.tkTime,
          Self,
          OutputControl);
    end);
end;

procedure TMainForm.RunTimer(const ATimerTime: TTime);
var
  OutputControl: TControl;
begin
  OutputControl := TimeVoidEdit;
  if Assigned(FElectronicBoardFrame) then
    OutputControl := TimeVoidEdit;

  if Assigned(FTimeThread) then
    FTimeThread.Terminate;

  ThreadFactory.CreateRegistredThread(
    procedure (
      const AThreadFactory: TThreadFactory)
    begin
      FTimeThread :=
        TTimeThread.Create(
          AThreadFactory,
          ATimerTime,
          TTimeKind.tkTimer,
          Self,
          OutputControl);
    end);
end;

procedure TMainForm.StartSignal;
begin
  ThreadFactory.CreateFreeOnTerminateThread('SignalThread',
    procedure (const AThread: TThreadExt)
    begin
      TThread.ForceQueue(nil,
        procedure
        begin
          Self.Show;
        end);

      while not AThread.Terminated do
      begin
        TThread.ForceQueue(nil,
          procedure
          begin
            SignalRectangle.Visible := true;
          end);

        Sleep(400);

        TThread.ForceQueue(nil,
          procedure
          begin
            SignalRectangle.Visible := false;
          end);

        Sleep(400);
      end;
    end,
    false);
end;

procedure TMainForm.StopSignal;
var
  Thread: TThreadExt;
begin
  Thread := ThreadFactory.GetThreadByName('SignalThread');
  if Assigned(Thread) then
  begin
    Thread.Terminate;

    FTimeThread := nil;
  end;
end;

procedure TMainForm.SetTimerFormOkButtonClickHandler(Sender: TObject);
var
  TimerTime: TTime;
begin
  StopSignal;

  TimerTime := SetTimerForm.GetTime;

  SetTimerForm.Close;

  RunTimer(TimerTime);
end;

procedure TMainForm.SettingsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  GetCurPos(X, Y);
  FSettingsPopupMenuExt.Open(X, Y);
end;

procedure TMainForm.SettingsLayoutTap(Sender: TObject; const Point: TPointF);
begin
  FSettingsPopupMenuExt.Open(Point.X, Point.Y);
end;

procedure TMainForm.SetCustomColorOkButtonClickHandler(Sender: TObject);
var
  CustomColorNumber: Byte;
  Color: TAlphaColor;
begin
  CustomColorNumber := SetCustomColorForm.Tag;
  Color := SetCustomColorForm.Color;
  case CustomColorNumber of
    0: TState.CustomColor0 := Color;
    1: TState.CustomColor1 := Color;
    2: TState.CustomColor2 := Color;
    3: TState.CustomColor3 := Color;
  end;
  SetCustomColorForm.Close;

  TState.Color := Color;

  CloseBoard;
  OpenBoard(TState.Board, TState.Color, TState.Orientation);
end;

procedure TMainForm.ResizeVerticalBoardFrame(
  const WidthCorrector: Single;
  const HeightCorrector: Single;
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
  W0: Single;
  H0: Single;
  H1: Single;
begin
  ADigitsLayout.Align  := TAlignLayout.None;
  ADigitsLayout.Width  := Self.Width * WidthCorrector;
  ADigitsLayout.Height := Self.Height * HeightCorrector;
  ADigitsLayout.Align  := TAlignLayout.Center;

  W0 := ADigitsLayout.Width  / 2;
  H0 := ADigitsLayout.Height / 4;
  H1 := ADigitsLayout.Height / 8;

  AHoursLayout.Align         := TAlignLayout.None;
  AHoursDelimLayout.Align    := TAlignLayout.None;
  AMinutesLayout.Align       := TAlignLayout.None;
  ASecondsDelimLayout.Align  := TAlignLayout.None;
  ASecondsLayout.Align       := TAlignLayout.None;

  AHoursLayout.Height        := H0;
  AHoursDelimLayout.Height   := H1;
  AMinutesLayout.Height      := H0;
  ASecondsDelimLayout.Height := H1;
  ASecondsLayout.Height      := H0;

  ASecondsLayout.Align       := TAlignLayout.Bottom;
  ASecondsDelimLayout.Align  := TAlignLayout.Bottom;
  AMinutesLayout.Align       := TAlignLayout.Bottom;
  AHoursDelimLayout.Align    := TAlignLayout.Bottom;
  AHoursLayout.Align         := TAlignLayout.Bottom;

  AHoursLayout.Align         := TAlignLayout.Top;
  AHoursDelimLayout.Align    := TAlignLayout.Top;
  AMinutesLayout.Align       := TAlignLayout.Top;
  ASecondsDelimLayout.Align  := TAlignLayout.Top;
  ASecondsLayout.Align       := TAlignLayout.Top;

  AHHControl.Width     := W0;
  AHLControl.Width     := W0;
  AHDelimControl.Width := W0;
  AMHControl.Width     := W0;
  AMLControl.Width     := W0;
  ASDelimControl.Width := W0;
  ASHControl.Width     := W0;
  ASLControl.Width     := W0;
end;

procedure TMainForm.ResizeHorizontalBoardFrame(
  const WidthCorrector: Single;
  const HeightCorrector: Single;
  const WidthDigitsCorrector: Single;
  const WidthDelimiterCorrector: Single;
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

  procedure _HorizontalAlign(const AControl: TControl; const AWidth: Single);
  begin
    AControl.Width := AWidth;
    AControl.Align := TAlignLayout.Left;
  end;

var
  W0: Single;
  W1: Single;
begin
  ADigitsLayout.Align  := TAlignLayout.None;
  ADigitsLayout.Width  := Self.Width * WidthCorrector;
  ADigitsLayout.Height := Self.Height * HeightCorrector;
  ADigitsLayout.Align  := TAlignLayout.Center;

  W0 := ADigitsLayout.Width / WidthDigitsCorrector;
  W1 := ADigitsLayout.Width / WidthDelimiterCorrector;

  AHoursLayout.Align := TAlignLayout.Right;
  AHoursDelimLayout.Align := TAlignLayout.Right;
  AMinutesLayout.Align := TAlignLayout.Right;
  ASecondsDelimLayout.Align := TAlignLayout.Right;
  ASecondsLayout.Align := TAlignLayout.Right;

  _HorizontalAlign(AHoursLayout, W0);
  _HorizontalAlign(AHHControl, W0 / 2);
  _HorizontalAlign(AHLControl, W0 / 2);
  _HorizontalAlign(AHoursDelimLayout , W1);
  _HorizontalAlign(AHDelimControl, W1);
  _HorizontalAlign(AMinutesLayout, W0);
  _HorizontalAlign(AMHControl, W0 / 2);
  _HorizontalAlign(AMLControl, W0 / 2);
  _HorizontalAlign(ASecondsDelimLayout, W1);
  _HorizontalAlign(ASDelimControl, W1);
  _HorizontalAlign(ASecondsLayout, W0);
  _HorizontalAlign(ASHControl, W0 / 2);
  _HorizontalAlign(ASLControl, W0 / 2);

  AHoursLayout.Align := TAlignLayout.Left;
  AHoursDelimLayout.Align := TAlignLayout.Left;
  AMinutesLayout.Align := TAlignLayout.Left;
  ASecondsDelimLayout.Align := TAlignLayout.Left;
  ASecondsLayout.Align := TAlignLayout.Left;
end;

end.
