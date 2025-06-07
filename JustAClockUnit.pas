unit JustAClockUnit;

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
  , BorderFrameUnit, FMX.Gestures
  {$ENDIF}
  {$IFDEF ANDROID}
  , FMX.Platform, FMX.Gestures
  {$ENDIF}
  ;

const
  AUTO_ORIENTATION_ON_MENU_ITEM_NAME = 'AutoOrientationOnMenuItem';
  AUTO_ORIENTATION_OFF_MENU_ITEM_NAME = 'AutoOrientationOffMenuItem';
  ELECTRONIC_BOARD_MEUN_ITEM_NAME = 'ElectronicBoardMenuItem';
  TEXT_BOARD_MEUN_ITEM_NAME = 'TextBoardMenuItem';
  COLORED_NUMBER_BOARD_MENU_ITEM_NAME = 'ColoredNumbersMenuItem';
  VERTICAL_ORIENTATION_MENU_ITEM_NAME = 'VerticalOrientationMenuItem';
  HORIZONTAL_ORIENTATION_MENU_ITEM_NAME = 'HorizontalOrientationMenuItem';
  COLOR_MENU_ITEM_NAME_PREFIX = 'ColorMenuItem';
  CUSTOM_COLOR_MENU_ITEM_NAME_PREFIX = 'CustomColorMenuItem';

type
  TMenuItemsArray = TArray<String>;
  TElectronicBoardColorArray = TArray<String>;
  TElectronicBoardColorArrayHelper = record helper for TElectronicBoardColorArray
  public
    function FirstValue: String;
    function LastValue: String;
    function NextValue(const ACurrentValue: String): String;
  end;

  TFrameClass = class of TFrame;

  TMainForm = class(TFormExt)
    TimeText: TText;
    ContentLayout: TLayout;
    TimeLayout: TLayout;
    SignalRectangle: TRectangle;
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
    GestureManager: TGestureManager;
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
    procedure ContentLayoutGesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
  strict private
    FTimeThread: TTimeThread;

    FElectronicBoardFrame: TElectronicBoardFrame;
    FTextBoardFrame: TTextBoardFrame;
    FCurrentElectronicBoardColor: String;
    FElectronicBoardColorArray: TElectronicBoardColorArray;
    FSettingsPopupMenuExt: TPopupMenuExt;
    FToolsPopupMenuExt: TPopupMenuExt;

    { MenuItems }

    FBoardsMenuItem: TItem;
    FImageBoardMenuItem: TItem;
    FOrientationMenuItem: TItem;
    FColorsMenuItem: TItem;
    FCustomColorsMenuItem: TItem;
    {$IFDEF ANDROID}
    FAutoOrientation: TItem;
    FAutoOrientationMenuItem: TItem;
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    FTrayPopupMenuExt: TPopupMenuExt;
    FBorderFrame: TBorderFrame;

    procedure TrayIconMouseRightButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TrayIconMouseLeftButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnCloseTrayItemHandler(Sender: TObject);
    {$ENDIF}

    procedure BuildPopupMenues;

    procedure MenuColorItemClickHandler(Sender: TObject);
    procedure MenuTextBoardItemClickHandler(Sender: TObject);
    procedure MenuElectronicBoardItemClickHandler(Sender: TObject);
    procedure MenuImageBoardItemClickHandler(Sender: TObject);
    procedure MenuCountDownItemClickHandler(Sender: TObject);
    procedure MenuCancelTimerItemClickHandler(Sender: TObject);
    procedure MenuSetCustomColorItemClickHandler(Sender: TObject);
    procedure MenuGetCustomColorItemClickHandler(Sender: TObject);

    procedure MenuHorizontalOrientationItemClickHandler(Sender: TObject);
    procedure MenuVerticalOrientationItemClickHandler(Sender: TObject);
    {$HINTS OFF}
    procedure MenuAutoOrientationOnItemClickHandler(Sender: TObject);
    procedure MenuAutoOrientationOffItemClickHandler(Sender: TObject);
    {$HINTS ON}
    procedure SetTimerFormOkButtonClickHandler(Sender: TObject);
    procedure SetTimerFormCancelButtonClickHandler(Sender: TObject);

    procedure SetCustomColorOkButtonClickHandler(Sender: TObject);
    procedure SetCustomColorCancelButtonClickHandler(Sender: TObject);

    procedure TimeVoidEditOnChangeHandler(Sender: TObject);

    procedure GestureHandler(const EventInfo: TGestureEventInfo);

    procedure RunTime;
    procedure RunTimer(const ATimerTime: TTime);

    procedure StartMotionSensorDataThread;
    procedure StopMotionSensorDataThread;

    procedure VerticalDetectedProc;
    procedure HorizontalDetectedProc;

//    procedure SetIsCheckedMenuItem(
//      const AMenuItemsArray: TMenuItemsArray;
//      const Sender: TObject);
//    procedure SetIsCheckedColorMenuItem(
//      const Sender: TObject);
//    procedure SetIsCheckedCustomColorMenuItem(
//      const Sender: TObject);
//    procedure SetIsCheckedImageMenuItem(
//      const Sender: TObject);

    procedure SetIsCheckedForChildrenMenuItems(
      const AParentMenuItem: TItem;
      const AIsChecked: Boolean);
  private
    {$IFDEF ANDROID}
    function HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    {$ENDIF}
    procedure OpenBoard(
      const ABoard: TBoardKind;
      const AImageName: String;
      const AColor: TAlphaColor;
      const AOrientation: TOrientationKind = TOrientationKind.okHorizontal); overload;
    procedure CloseBoard;

    function SetBoardOrientation(const AClass: TFrameClass): Pointer;
    {$IFDEF MSWINDOWS}
    procedure SetBoardSize(
      const AMinWidth: Integer;
      const AMinHeight: Integer;
      const ALastOrientationIsEqual: Boolean);
    {$ENDIF}
    procedure GetElectronicBoard(
      const AOrientation: TOrientationKind;
      const AMinWidth: Integer;
      const AMinHeight: Integer;
      const AColor: TAlphaColor;
      const ALastOrientationIsEqual: Boolean);
    procedure GetTextBoard(
      const AOrientation: TOrientationKind;
      const AMinWidth: Integer;
      const AMinHeight: Integer;
      const AColor: TAlphaColor;
      const ALastOrientationIsEqual: Boolean);
    procedure GetImageBoard(
      const AImageName: String;
      const AOrientation: TOrientationKind;
      const AMinWidth: Integer;
      const AMinHeight: Integer;
      const AColor: TAlphaColor;
      const ALastOrientationIsEqual: Boolean);
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
  , FMX.Platform.Win,
  {$ENDIF}
    ShowTimeUnit
  , ShowTextTimeUnit
  , ThreadFactoryUnit
  , NumScrollUnit
  , SetTimerFormUnit
  , SetCustomColorUnit
  , VerticalElectronicBoardFrameUnit
  , VerticalTextBoardFrameUnit
  , ProportionUnit
  , MotionSensorDataThreadUnit
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
procedure TMainForm.OnCloseTrayItemHandler(Sender: TObject);
begin
  MainForm.BorderFrame.CloseButtonRectangle.
    OnClick(MainForm.BorderFrame.CloseButtonRectangle);
end;

procedure TMainForm.TrayIconMouseRightButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  GetCurPos(X, Y);

  FTrayPopupMenuExt.Open(Trunc(X), Trunc(Y));
end;

procedure TMainForm.TrayIconMouseLeftButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ShowWindow(ApplicationHWND, SW_HIDE);
end;
{$ENDIF}

procedure TMainForm.ContentLayoutGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  GestureHandler(EventInfo);
end;

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

procedure TMainForm.BuildPopupMenues;
var
  MenuItem: TItem;
  SetCustomColorsMenuItem: TItem;
  ColorIdent: String;
  i: Integer;
  ImageFileName: String;
  ImageFileNameList: TStringList;
  FileName: String;
  FileExtention: String;
begin
  { SettingsPopupMenu }

  FSettingsPopupMenuExt := TPopupMenuExt.Create(Self);
  TState.MenuTheme.CopyTo(FSettingsPopupMenuExt.Theme);

  FBoardsMenuItem := TItem.Create;
  FBoardsMenuItem.Text := 'Boards';
  FSettingsPopupMenuExt.Add(FBoardsMenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := ELECTRONIC_BOARD_MEUN_ITEM_NAME;
  MenuItem.Parent := FBoardsMenuItem;
  MenuItem.Text := 'Electronic';
  MenuItem.OnClick := MenuElectronicBoardItemClickHandler;
  MenuItem.IsChecked := TState.Board = bkElectronic;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := TEXT_BOARD_MEUN_ITEM_NAME;
  MenuItem.Parent := FBoardsMenuItem;
  MenuItem.Text := 'Text';
  MenuItem.OnClick := MenuTextBoardItemClickHandler;
  MenuItem.IsChecked := TState.Board = bkText;
  FSettingsPopupMenuExt.Add(MenuItem);

  FImageBoardMenuItem := TItem.Create;
  FImageBoardMenuItem.Parent := FBoardsMenuItem;
  FImageBoardMenuItem.Text := 'Image';

  FSettingsPopupMenuExt.Add(FImageBoardMenuItem);

  ImageFileNameList := TStringList.Create;
  try
    GetImagesPackFileList(ImageFileNameList);
    i := 0;
    for ImageFileName in ImageFileNameList do
    begin
      FileExtention := ExtractFileExt(ImageFileName);
      FileName :=
        StringReplace(
          ExtractFileName(ImageFileName),
          FileExtention,
          '',
          [rfReplaceAll, rfIgnoreCase]);

      if FileName = 'Digits' then
        Continue;

      MenuItem := TItem.Create;
      MenuItem.Name := COLORED_NUMBER_BOARD_MENU_ITEM_NAME + i.ToString;
      MenuItem.Parent := FImageBoardMenuItem;
      MenuItem.Text := FileName;
      MenuItem.Tag := 0;
      MenuItem.OnClick := MenuImageBoardItemClickHandler;
      MenuItem.IsChecked := TState.Board = bkImage;
      FSettingsPopupMenuExt.Add(MenuItem);

      Inc(i);
    end;
  finally
    FreeAndNil(ImageFileNameList);
  end;

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  FOrientationMenuItem := TItem.Create;
  FOrientationMenuItem.Text := 'Orientation';
  FSettingsPopupMenuExt.Add(FOrientationMenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := HORIZONTAL_ORIENTATION_MENU_ITEM_NAME;
  MenuItem.Parent := FOrientationMenuItem;
  MenuItem.Text := 'Horizontal';
  MenuItem.Tag := 0;
  MenuItem.OnClick := MenuHorizontalOrientationItemClickHandler;
  MenuItem.IsChecked := TState.Orientation = okHorizontal;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := VERTICAL_ORIENTATION_MENU_ITEM_NAME;
  MenuItem.Parent := FOrientationMenuItem;
  MenuItem.Text := 'Vertical';
  MenuItem.Tag := 1;
  MenuItem.OnClick := MenuVerticalOrientationItemClickHandler;
  MenuItem.IsChecked := TState.Orientation = okVertical;
  FSettingsPopupMenuExt.Add(MenuItem);

  {$IFDEF ANDROID}
  MenuItem := TItem.Create;
  MenuItem.Parent := FOrientationMenuItem;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  FAutoOrientation := TItem.Create;
  FAutoOrientation.Parent := FOrientationMenuItem;
  FAutoOrientation.Text := 'Auto';
  FAutoOrientation.Tag := 0;
  FSettingsPopupMenuExt.Add(FAutoOrientation);

  MenuItem := TItem.Create;
  MenuItem.Name := AUTO_ORIENTATION_ON_MENU_ITEM_NAME;
  MenuItem.Parent := FAutoOrientation;
  MenuItem.Text := 'On';
  MenuItem.Tag := 0;
  MenuItem.OnClick := MenuAutoOrientationOnItemClickHandler;
  MenuItem.IsChecked := TState.AutoOrientation;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := AUTO_ORIENTATION_OFF_MENU_ITEM_NAME;
  MenuItem.Parent := FAutoOrientation;
  MenuItem.Text := 'Off';
  MenuItem.Tag := 1;
  MenuItem.OnClick := MenuAutoOrientationOffItemClickHandler;
  MenuItem.IsChecked := not TState.AutoOrientation;
  FSettingsPopupMenuExt.Add(MenuItem);
  {$ENDIF}
  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  FColorsMenuItem := TItem.Create;
  FColorsMenuItem.Text := 'Colors';
  FSettingsPopupMenuExt.Add(FColorsMenuItem);

  for i := 0 to Pred(Length(FElectronicBoardColorArray)) do
  begin
    ColorIdent := FElectronicBoardColorArray[i];
    MenuItem := TItem.Create;
    MenuItem.Name := COLOR_MENU_ITEM_NAME_PREFIX + Cardinal(ColorByIdent(ColorIdent)).ToString;
    MenuItem.Parent := FColorsMenuItem;
    MenuItem.Text := ColorIdent;
    MenuItem.Tag := i;
//    MenuItem.IsChecked := TState.Color = ColorByIdent(ColorIdent);
    MenuItem.OnClick := MenuColorItemClickHandler;
    FSettingsPopupMenuExt.Add(MenuItem);
  end;

  FCustomColorsMenuItem := TItem.Create;
  FCustomColorsMenuItem.Text := 'Custom color';
  FCustomColorsMenuItem.Tag := 0;
  FSettingsPopupMenuExt.Add(FCustomColorsMenuItem);

  for i := 0 to Pred(CUSTOM_COLOR_COUNT) do
  begin
    MenuItem := TItem.Create;
    MenuItem.Name := CUSTOM_COLOR_MENU_ITEM_NAME_PREFIX + i.ToString;
    MenuItem.Parent := FCustomColorsMenuItem;
    MenuItem.Text := 'Custom color ' + (i + 1).ToString;
    MenuItem.Tag := i;
    MenuItem.OnClick := MenuGetCustomColorItemClickHandler;
//    MenuItem.IsChecked := (TState.CustomColorNumber = i) and (TState.CustomColorNumber > 0);
    FSettingsPopupMenuExt.Add(MenuItem);
  end;

//  SetIsCheckedColorMenuItem(nil);
//  SetIsCheckedCustomColorMenuItem(nil);
//  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);
  //SetIsCheckedImageMenuItem(nil);

  if TState.CustomColorNumber >= 0 then
  begin
    MenuItem := FSettingsPopupMenuExt.
      FindItem(CUSTOM_COLOR_MENU_ITEM_NAME_PREFIX + TState.CustomColorNumber.ToString);
    if Assigned(MenuItem) then
      MenuItem.IsChecked := true;
  end
  else
  begin
    MenuItem := FSettingsPopupMenuExt.
      FindItem(COLOR_MENU_ITEM_NAME_PREFIX + Cardinal(TState.Color).ToString);
    if Assigned(MenuItem) then
      MenuItem.IsChecked := true;
  end;

  MenuItem := TItem.Create;
  MenuItem.Parent := FCustomColorsMenuItem;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  SetCustomColorsMenuItem := TItem.Create;
  SetCustomColorsMenuItem.Parent := FCustomColorsMenuItem;
  SetCustomColorsMenuItem.Text := 'Set';
  SetCustomColorsMenuItem.Tag := 0;
  FSettingsPopupMenuExt.Add(SetCustomColorsMenuItem);

  for i := 0 to 3 do
  begin
    MenuItem := TItem.Create;
    MenuItem.Parent := SetCustomColorsMenuItem;
    MenuItem.Text := 'Set custom color ' + (i + 1).ToString;
    MenuItem.Tag := i;
    MenuItem.OnClick := MenuSetCustomColorItemClickHandler;
    FSettingsPopupMenuExt.Add(MenuItem);
  end;

  { ToolsPopupMenu }

  FToolsPopupMenuExt := TPopupMenuExt.Create(Self);
  TState.MenuTheme.CopyTo(FToolsPopupMenuExt.Theme);

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

  {$IFDEF MSWINDOWS}
  FTrayPopupMenuExt := TPopupMenuExt.Create(Self);
  TState.MenuTheme.CopyTo(FTrayPopupMenuExt.Theme);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Close';
  MenuItem.OnClick := OnCloseTrayItemHandler;
  FTrayPopupMenuExt.Add(MenuItem);
  {$ENDIF}
end;

procedure TMainForm.FormCreate(Sender: TObject);
const
  SCALE_VALUE = 1;
{$IFDEF ANDROID}
var
  aFMXApplicationEventService: IFMXApplicationEventService;
{$ENDIF}
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

  { MenuTheme}

  TState.MenuTheme.BackgroundColor := $FF2A001A;//TAlphaColorRec.Black;
  TState.MenuTheme.LightBackgroundColor := TAlphaColorRec.Black;//$FFE0E0E0;
  TState.MenuTheme.DarkBackgroundColor := TAlphaColorRec.Cornflowerblue;

  TState.MenuTheme.TextControl.Align := TAlignLayout.Client;
  TState.MenuTheme.TextControl.HitTest := false;
  TState.MenuTheme.TextControl.TextSettings.FontColor :=
    TAlphaColorRec.White;
  TState.MenuTheme.TextControl.TextSettings.HorzAlign :=
    TTextAlign.Leading;
  TState.MenuTheme.TextControl.TextSettings.VertAlign :=
    TTextAlign.Center;
  TState.MenuTheme.TextControl.Margins.Left := 5;
  TState.MenuTheme.TextControl.WordWrap := false;

  FCurrentElectronicBoardColor := FElectronicBoardColorArray.LastValue;

  BuildPopupMenues;

  {$IFDEF MSWINDOWS}
  ShowWindow(ApplicationHWND, SW_HIDE);

  FBorderFrame :=
    TBorderFrame.Create(
      Self,
      ContentLayout,
      'Just a clock',
      Trunc(ContentLayout.Width),
      Trunc(ContentLayout.Height),
      $FF8D003A,
      $FF2A001A,
      TAlphaColorRec.Lime,
      $FFADADAD);

  FBorderFrame.TrayIconMouseRightButtonDown := TrayIconMouseRightButtonDown;
  FBorderFrame.TrayIconMouseLeftButtonDown := TrayIconMouseLeftButtonDown;

  Self.Left := TState.FormLeft;
  Self.Top  := TState.FormTop;

  {$ELSE IFDEF ANDROID}
  Self.FullScreen := true;
  {$ENDIF}
  FElectronicBoardFrame := nil;

  RunTime;

  OpenBoard(TState.Board, 'Colored numbers', TState.Color, TState.Orientation);

  if TState.AutoOrientation then
    StartMotionSensorDataThread;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TShowTextTime.UnInit;

  CloseBoard;
end;

procedure TMainForm.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  PaintRects(ARect);
  {$IFDEF MSWINDOWS}
  TState.FormLeft     := Self.Left;
  TState.FormTop      := Self.Top;
  TState.FormWidth    := FBorderFrame.ClientWidth;
  TState.FormHeight   := FBorderFrame.ClientHeight;
  {$ENDIF}
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if TState.Orientation = okHorizontal then
  begin
    SettingsLayout.Width := ContentLayout.Width / 2;
    SettingsLayout.Height := ContentLayout.Height;
    SettingsLayout.Position.X := ContentLayout.Position.X;
    SettingsLayout.Position.Y := ContentLayout.Position.Y;

    ToolsLayout.Width := ContentLayout.Width / 2;
    ToolsLayout.Height := ContentLayout.Height;
    ToolsLayout.Position.X := ContentLayout.Width / 2;
    ToolsLayout.Position.Y := ContentLayout.Position.Y;
  end
  else
  if TState.Orientation = okVertical then
  begin
    SettingsLayout.Width := ContentLayout.Width;
    SettingsLayout.Height := ContentLayout.Height / 2;
    SettingsLayout.Position.X := ContentLayout.Position.X;
    SettingsLayout.Position.Y := ContentLayout.Position.Y;

    ToolsLayout.Width := ContentLayout.Width;
    ToolsLayout.Height := ContentLayout.Height / 2;
    ToolsLayout.Position.X := ContentLayout.Position.X;
    ToolsLayout.Position.Y := ContentLayout.Height / 2;
  end;

  TProportion.Resize;
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

procedure TMainForm.GestureHandler(const EventInfo: TGestureEventInfo);
begin
  case EventInfo.GestureID of
    sgiDown,
    sgiLeftDown,
    sgiRightDown,
    sgiDownLeft,
    sgiDownRight,
    sgiDownLeftLong,
    sgiDownRightLong:
      Close;
  end;
end;

procedure TMainForm.ToolsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  // Для Андроида специально должно глушиться,
  // иначе не обработает собития жестов OnGesture
  {$IFDEF MSWINDOWS}
  GetCurPos(X, Y);
  FToolsPopupMenuExt.Open(X, Y);
  {$ENDIF}
end;

procedure TMainForm.ToolsLayoutTap(Sender: TObject; const Point: TPointF);
begin
  FToolsPopupMenuExt.Open(Point.X, Point.Y);
end;

function TMainForm.SetBoardOrientation(const AClass: TFrameClass): Pointer;
begin
  Result := AClass.Create(nil);
end;
{$IFDEF MSWINDOWS}
// Привордим размеры к дефолтным только когда меняем ориентацию экрана
procedure TMainForm.SetBoardSize(
  const AMinWidth: Integer;
  const AMinHeight: Integer;
  const ALastOrientationIsEqual: Boolean);
begin
  FBorderFrame.MinClientWidth := AMinWidth;
  FBorderFrame.MinClientHeight := AMinHeight;

  if not ALastOrientationIsEqual then
  begin
    FBorderFrame.ClientWidth := FBorderFrame.MinClientWidth;
    FBorderFrame.ClientHeight := FBorderFrame.MinClientHeight;
  end
  else
  begin
    FBorderFrame.ClientWidth  := TState.FormWidth;
    FBorderFrame.ClientHeight := TState.FormHeight;
  end;
end;
{$ENDIF}
procedure TMainForm.GetElectronicBoard(
  const AOrientation: TOrientationKind;
  const AMinWidth: Integer;
  const AMinHeight: Integer;
  const AColor: TAlphaColor;
  const ALastOrientationIsEqual: Boolean);
var
  BoardFrameClass: TFrameClass;
begin
  if TState.Orientation = okHorizontal then
    BoardFrameClass := TElectronicBoardFrame
  else
  if TState.Orientation = okVertical then
    BoardFrameClass := TVerticalElectronicBoardFrame
  else
    raise Exception.Create('TMainForm.GetElectronicBoard: Unknown orientation kind');

  FElectronicBoardFrame := SetBoardOrientation(BoardFrameClass);

  FElectronicBoardFrame.Parent := TimeLayout;
  FElectronicBoardFrame.Align := TAlignLayout.Contents;
  FElectronicBoardFrame.HitTest := false;

  FElectronicBoardFrame.Width := AMinWidth;
  FElectronicBoardFrame.Height := AMinHeight;
  FElectronicBoardFrame.RecalcSize;

  TProportion.Init(
    TState.Orientation,
    ContentLayout,
    AMinWidth,
    AMinHeight,
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

  TShowTime.Init(
    GetDigitsPackFile,
    '',
    AColor,
    FElectronicBoardFrame.HHImage,
    FElectronicBoardFrame.HLImage,
    FElectronicBoardFrame.HDelimImage,
    FElectronicBoardFrame.MHImage,
    FElectronicBoardFrame.MLImage,
    FElectronicBoardFrame.SDelimImage,
    FElectronicBoardFrame.SHImage,
    FElectronicBoardFrame.SLImage,
    TState.Orientation);
end;

procedure TMainForm.GetImageBoard(
  const AImageName: String;
  const AOrientation: TOrientationKind;
  const AMinWidth: Integer;
  const AMinHeight: Integer;
  const AColor: TAlphaColor;
  const ALastOrientationIsEqual: Boolean);
var
  BoardFrameClass: TFrameClass;
begin
  if TState.Orientation = okHorizontal then
    BoardFrameClass := TElectronicBoardFrame
  else
  if TState.Orientation = okVertical then
    BoardFrameClass := TVerticalElectronicBoardFrame
  else
    raise Exception.Create('TMainForm.GetImageBoard: Unknown orientation kind');

  FElectronicBoardFrame := SetBoardOrientation(BoardFrameClass);

  TProportion.Init(
    TState.Orientation,
    ContentLayout,
    AMinWidth,
    AMinHeight,
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

  TShowTime.Init(
    GetImagesPackFile(AImageName),
    '',
    NO_REPCALE_COLOR,
    FElectronicBoardFrame.HHImage,
    FElectronicBoardFrame.HLImage,
    FElectronicBoardFrame.HDelimImage,
    FElectronicBoardFrame.MHImage,
    FElectronicBoardFrame.MLImage,
    FElectronicBoardFrame.SDelimImage,
    FElectronicBoardFrame.SHImage,
    FElectronicBoardFrame.SLImage,
    TState.Orientation);

  FElectronicBoardFrame.Parent := TimeLayout;
  FElectronicBoardFrame.Align := TAlignLayout.Contents;
  FElectronicBoardFrame.HitTest := false;
end;

procedure TMainForm.GetTextBoard(
  const AOrientation: TOrientationKind;
  const AMinWidth: Integer;
  const AMinHeight: Integer;
  const AColor: TAlphaColor;
  const ALastOrientationIsEqual: Boolean);
var
  BoardFrameClass: TFrameClass;
begin
  if TState.Orientation = okHorizontal then
    BoardFrameClass := TTextBoardFrame
  else
  if TState.Orientation = okVertical then
    BoardFrameClass := TVerticalTextBoardFrame
  else
    raise Exception.Create('TMainForm.GetTextBoard: Unknown orientation kind');

  FTextBoardFrame := SetBoardOrientation(BoardFrameClass);

  TProportion.Init(
    TState.Orientation,
    ContentLayout,
    AMinWidth,
    AMinHeight,
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

procedure TMainForm.OpenBoard(
  const ABoard: TBoardKind;
  const AImageName: String;
  const AColor: TAlphaColor;
  const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);

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

var
  MinWidth: Integer;
  MinHeight: Integer;
  LastOrientationIsEqual: Boolean;
begin
  TimeVoidEdit.OnChange := nil;
  if Assigned(FTimeThread) then
    FTimeThread.OutputControl := nil;

  CloseBoard;

  TState.Board := ABoard;
  TState.Color := AColor;
  TState.ImageName := AImageName;

  if AOrientation = okNone then
  begin
    LastOrientationIsEqual := false;
    TState.Orientation := okHorizontal;
  end
  else
  begin
    LastOrientationIsEqual := true;
    if TState.Orientation <> AOrientation then
      LastOrientationIsEqual := false;

    TState.Orientation := AOrientation;
  end;

  if TState.Orientation = okHorizontal then
  begin
    MinWidth := HORIZONTAL_MIN_WIDTH;
    MinHeight := HORIZONTAL_MIN_HEIGHT;
    {$IFDEF ANDROID}
    _SetAndroidScreenOrientation(TScreenOrientation.Landscape);
    {$ENDIF}
  end
  else
  if TState.Orientation = okVertical then
  begin
    MinWidth := VERTICAL_MIN_WIDTH;
    MinHeight := VERTICAL_MIN_HEIGHT;
    {$IFDEF ANDROID}
    _SetAndroidScreenOrientation(TScreenOrientation.Portrait);
    {$ENDIF}
  end
  else
    raise Exception.Create('TMainForm.OpenBoard: Unknown orientation kind');

  case TState.Board of
    bkElectronic:
    begin
      GetElectronicBoard(
        TState.Orientation,
        MinWidth,
        MinHeight,
        AColor,
        LastOrientationIsEqual);
    end;
    bkText:
    begin
      GetTextBoard(
        TState.Orientation,
        MinWidth,
        MinHeight,
        AColor,
        LastOrientationIsEqual);
    end;
    bkImage:
    begin
      GetImageBoard(
        AImageName,
        TState.Orientation,
        MinWidth,
        MinHeight,
        AColor,
        LastOrientationIsEqual);
    end
    else
      raise Exception.Create('TMainForm.OpenBoard: Unknown board kind');
  end;

  {$IFDEF MSWINDOWS}
  // Выставлять размеры нужно в конце,
  // иначе уйдет на Resize формы до инициализации табло
  SetBoardSize(
    MinWidth,
    MinHeight,
    LastOrientationIsEqual);
  {$ENDIF}

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
  MenuItem: TItem absolute Sender;
begin
  TState.CustomColorNumber := -1;

  //SetIsCheckedCustomColorMenuItem(nil);
  //SetIsCheckedColorMenuItem(Sender);
  //SetIsCheckedImageMenuItem(nil);

  SetIsCheckedForChildrenMenuItems(FColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FCustomColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);

  MenuItem.IsChecked := true;

  TState.ColorIdent := FElectronicBoardColorArray[MenuItem.Tag];
  OpenBoard(
    TState.Board,
    TState.ImageName,
    ColorByIdent(TState.ColorIdent),
    TState.Orientation);
end;

procedure TMainForm.MenuTextBoardItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedForChildrenMenuItems(FBoardsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);

  MenuItem.IsChecked := true;

//  SetIsCheckedMenuItem(
//    [
//      ELECTRONIC_BOARD_MEUN_ITEM_NAME,
//      TEXT_BOARD_MEUN_ITEM_NAME
//      //, COLORED_NUMBER_BOARD_MENU_ITEM_NAME
//    ], Sender);

  OpenBoard(bkText, TState.ImageName, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuElectronicBoardItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedForChildrenMenuItems(FBoardsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);

  MenuItem.IsChecked := true;

//  SetIsCheckedMenuItem(
//    [
//      ELECTRONIC_BOARD_MEUN_ITEM_NAME,
//      TEXT_BOARD_MEUN_ITEM_NAME
//      //, COLORED_NUMBER_BOARD_MENU_ITEM_NAME
//    ], Sender);

  OpenBoard(bkElectronic, TState.ImageName, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuImageBoardItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
//  SetIsCheckedColorMenuItem(nil);
//  SetIsCheckedCustomColorMenuItem(nil);
  SetIsCheckedForChildrenMenuItems(FBoardsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);
  //SetIsCheckedImageMenuItem(Sender);
  MenuItem.IsChecked := true;

  OpenBoard(bkImage, MenuItem.Text, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuCountDownItemClickHandler(Sender: TObject);
begin
  StopSignal;

  SetTimerForm := TSetTimerForm.Create(Self);
  SetTimerForm.OkButtonRectangle.OnClick := SetTimerFormOkButtonClickHandler;
  SetTimerForm.CancelButtonRectangle.OnClick := SetTimerFormCancelButtonClickHandler;
  {$IFDEF MSWINDOWS}
  SetTimerForm.ShowModal;
  {$ELSE IFDEF ANDROID}
  SetTimerForm.Show;
  {$ENDIF}
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
  SetCustomColorForm.CancelButtonRectangle.OnClick := SetCustomColorCancelButtonClickHandler;
  {$IFDEF MSWINDOWS}
  SetCustomColorForm.ShowModal;
  {$ELSE IFDEF ANDROID}
  SetCustomColorForm.Show;
  {$ENDIF}
end;

procedure TMainForm.MenuGetCustomColorItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
  CustomColorNumber: Byte;
  Color: TAlphaColor;
begin
  TState.CustomColorNumber := TItem(Sender).Tag;
  CustomColorNumber := TState.CustomColorNumber;
  Color := CustomColorByNumber(CustomColorNumber);

  //SetIsCheckedColorMenuItem(nil);
  //SetIsCheckedCustomColorMenuItem(Sender);
  //SetIsCheckedImageMenuItem(nil);

  SetIsCheckedForChildrenMenuItems(FColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FCustomColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);

  MenuItem.IsChecked := true;

  CloseBoard;

  OpenBoard(TState.Board, TState.ImageName, Color, TState.Orientation);
end;

procedure TMainForm.MenuVerticalOrientationItemClickHandler(Sender: TObject);
begin
//  SetIsCheckedMenuItem(
//    [
//      VERTICAL_ORIENTATION_MENU_ITEM_NAME,
//      HORIZONTAL_ORIENTATION_MENU_ITEM_NAME
//    ], Sender);

  OpenBoard(TState.Board, TState.ImageName, TState.Color, okVertical);
end;

procedure TMainForm.MenuHorizontalOrientationItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);

  MenuItem.IsChecked := true;

//  SetIsCheckedMenuItem(
//    [
//      VERTICAL_ORIENTATION_MENU_ITEM_NAME,
//      HORIZONTAL_ORIENTATION_MENU_ITEM_NAME
//    ], Sender);

  OpenBoard(TState.Board, TState.ImageName, TState.Color, okHorizontal);
end;

procedure TMainForm.MenuAutoOrientationOnItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);
  {$IFDEF ANDROID}
  SetIsCheckedForChildrenMenuItems(FAutoOrientationMenuItem, false);
  {$ENDIF}
  MenuItem.IsChecked := true;

//  SetIsCheckedMenuItem(
//    [
//      AUTO_ORIENTATION_ON_MENU_ITEM_NAME,
//      AUTO_ORIENTATION_OFF_MENU_ITEM_NAME
//    ], Sender);

  TState.AutoOrientation := true;
  StartMotionSensorDataThread;
end;

procedure TMainForm.MenuAutoOrientationOffItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);
  {$IFDEF ANDROID}
  SetIsCheckedForChildrenMenuItems(FAutoOrientationMenuItem, false);
  {$ENDIF}
  MenuItem.IsChecked := true;

//  SetIsCheckedMenuItem(
//    [
//      AUTO_ORIENTATION_ON_MENU_ITEM_NAME,
//      AUTO_ORIENTATION_OFF_MENU_ITEM_NAME
//    ], Sender);

  TState.AutoOrientation := false;
  StopMotionSensorDataThread;
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

procedure TMainForm.SetTimerFormCancelButtonClickHandler(Sender: TObject);
begin
  SetTimerForm.Close;
end;

procedure TMainForm.SettingsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  // Для Андроида специально должно глушиться,
  // иначе не обработает собития жестов OnGesture
  {$IFDEF MSWINDOWS}
  GetCurPos(X, Y);
  FSettingsPopupMenuExt.Open(X, Y);
  {$ENDIF}
end;

procedure TMainForm.SettingsLayoutTap(Sender: TObject; const Point: TPointF);
begin
  FSettingsPopupMenuExt.Open(Point.X, Point.Y);
end;

procedure TMainForm.SetCustomColorOkButtonClickHandler(Sender: TObject);
var
  CustomColorNumber: Byte;
  Color: TAlphaColor;
  MenuItem: TItem;
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

  MenuItem := FSettingsPopupMenuExt.
    FindItem(CUSTOM_COLOR_MENU_ITEM_NAME_PREFIX + CustomColorNumber.ToString);

//  SetIsCheckedColorMenuItem(nil);
//  SetIsCheckedCustomColorMenuItem(MenuItem);
//  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);
  //SetIsCheckedImageMenuItem(nil);

  SetIsCheckedForChildrenMenuItems(FColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FCustomColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);

  MenuItem.IsChecked := true;

  CloseBoard;

  OpenBoard(TState.Board, TState.ImageName, TState.Color, TState.Orientation);
end;

procedure TMainForm.SetCustomColorCancelButtonClickHandler(Sender: TObject);
begin
  SetCustomColorForm.Close;
end;

procedure TMainForm.VerticalDetectedProc;
begin
  if TState.Orientation = okHorizontal then
    MenuVerticalOrientationItemClickHandler(nil);
end;

procedure TMainForm.HorizontalDetectedProc;
begin
  if TState.Orientation = okVertical then
    MenuHorizontalOrientationItemClickHandler(nil);
end;

//procedure TMainForm.SetIsCheckedMenuItem(
//  const AMenuItemsArray: TMenuItemsArray;
//  const Sender: TObject);
//var
//  i: Integer;
//  Item: TItem;
//begin
//  for i := 0 to Pred(Length(AMenuItemsArray)) do
//  begin
//    Item := FSettingsPopupMenuExt.FindItem(AMenuItemsArray[i]);
//    Item.IsChecked := false;
//  end;
//
//  if Assigned(Sender) then
//  begin
//    TItem(Sender).IsChecked := true;
//  end;
//end;

//procedure TMainForm.SetIsCheckedColorMenuItem(
//  const Sender: TObject);
//var
//  i: Integer;
//  MenuItemsArray: TMenuItemsArray;
//begin
//  SetLength(MenuItemsArray, Length(FElectronicBoardColorArray));
//  for i := 0 to Pred(Length(FElectronicBoardColorArray)) do
//    MenuItemsArray[i] := COLOR_MENU_ITEM_NAME_PREFIX +
//      Cardinal(ColorByIdent(FElectronicBoardColorArray[i])).ToString;
//
//  SetIsCheckedMenuItem(MenuItemsArray, Sender);
//end;

//procedure TMainForm.SetIsCheckedCustomColorMenuItem(
//  const Sender: TObject);
//var
//  i: Integer;
//  MenuItemsArray: TMenuItemsArray;
//begin
//  SetLength(MenuItemsArray, CUSTOM_COLOR_COUNT);
//  for i := 0 to Pred(CUSTOM_COLOR_COUNT) do
//    MenuItemsArray[i] := CUSTOM_COLOR_MENU_ITEM_NAME_PREFIX + i.ToString;
//
//  SetIsCheckedMenuItem(MenuItemsArray, Sender);
//end;

//procedure TMainForm.SetIsCheckedImageMenuItem(
//  const Sender: TObject);
//var
//  i: Integer;
//  MenuItem: TItem;
//begin
//  for i := 0 to Pred(FImageBoardMenuItem.Children.Count) do
//  begin
//    MenuItem := FImageBoardMenuItem.Children[i];
//    MenuItem.IsChecked := false;
//  end;
//
//  if Assigned(Sender) then
//    TItem(Sender).IsChecked := true;
//end;

procedure TMainForm.SetIsCheckedForChildrenMenuItems(
  const AParentMenuItem: TItem;
  const AIsChecked: Boolean);
var
  MenuItem: TItem;
begin
  for MenuItem in AParentMenuItem.Children do
    MenuItem.IsChecked := AIsChecked;
end;

procedure TMainForm.StartMotionSensorDataThread;
begin
  TMotionSensorDataThread.Init(Self, VerticalDetectedProc, HorizontalDetectedProc);
end;

procedure TMainForm.StopMotionSensorDataThread;
begin
  TMotionSensorDataThread.UnInit;
end;

end.
