unit JustAClockUnit;
// Поля циферблата можно выставлять через TimeLayout.Margins
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
  , FMX.PopupMenuExt
  , FMX.SingleSoundUnit
  , FMX.Gestures
  , PopupMenuExt.Item
  , TypesUnit
  , ThreadFactoryUnit
  {$IFDEF ANDROID}
  , FMX.Platform
  {$ENDIF}
  ;

const
  AUTO_ORIENTATION_ON_MENU_ITEM_NAME = 'AutoOrientationOnMenuItem';
  AUTO_ORIENTATION_OFF_MENU_ITEM_NAME = 'AutoOrientationOffMenuItem';
  ELECTRONIC_BOARD_MENU_ITEM_NAME = 'ElectronicBoardMenuItem';
  TEXT_BOARD_MEUN_ITEM_NAME = 'TextBoardMenuItem';
  PATTERN_BOARD_MENU_ITEM_NAME = 'PatternMenuItem';
  IMAGE_BOARD_MENU_ITEM_NAME = 'ImageMenuItem';
  RING_MENU_ITEM_NAME = 'RingMenuItem';
  VIBRO_MENU_ITEM_NAME = 'VibroMenuItem';
  VERTICAL_ORIENTATION_MENU_ITEM_NAME = 'VerticalOrientationMenuItem';
  HORIZONTAL_ORIENTATION_MENU_ITEM_NAME = 'HorizontalOrientationMenuItem';
  // Мы не будем управлять состоянием кнопки отмены будильника
  // На андроиде нельзя отследить выставлен будильник или нет
  // Отслеживать можно только по локальному флагу - это не обосо имеет смысл
  CANCEL_MENU_ITEM_NAME = 'CancelMenuItem';
  COLOR_MENU_ITEM_NAME_PREFIX = 'ColorMenuItem';
  CUSTOM_COLOR_MENU_ITEM_NAME_PREFIX = 'CustomColorMenuItem';

//  SIGNAL_THREAD = 'SignalThread';
//  VIBRO_THREAD = 'VibroThread';

  VIBRO_NAME_OFF = 'Off';
  VIBRO_NAME_ON = 'On';

type
  TMenuItemsArray = TArray<String>;

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
    ScreenLockerLayout: TLayout;
    AlarmLayout: TLayout;
    AlarmRectangle: TRectangle;
    AlarmTimeText: TText;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure SettingsLayoutTap(Sender: TObject; const Point: TPointF);
    procedure SettingsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ToolsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ToolsLayoutTap(Sender: TObject; const Point: TPointF);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure ContentLayoutGesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure ScreenLockerLayoutGesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure SettingsLayoutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ToolsLayoutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormDestroy(Sender: TObject);
  strict private
    FOpeningBoard: TBoardKind;
    FTimeThread: TTimeThread;
    FSignalThread: TInlineThreadExt;
    FVibroThread: TInlineThreadExt;
    FElectronicBoardFrame: TElectronicBoardFrame;
    FTextBoardFrame: TTextBoardFrame;
    FCurrentColorIdent: String;
    FSettingsPopupMenuExt: TPopupMenuExt;
    FToolsPopupMenuExt: TPopupMenuExt;
    FSingleSound: TSingleSound;

    { MenuItems }

    FBoardsMenuItem: TItem;
    FPatternBoardMenuItem: TItem;
    FImageBoardMenuItem: TItem;
    FOrientationMenuItem: TItem;
    FColorsMenuItem: TItem;
    FCustomColorsMenuItem: TItem;
    FHorizontalOrientationMenuItem: TItem;
    FVerticalOrientationMenuItem: TItem;
    FRingMenuItem: TItem;
    FRingsMenuItem: TItem;
    {$IFDEF ANDROID}
    FVibroMenuItem: TItem;
    FAutoOrientationMenuItem: TItem;
    //FIsJsonReceived: Boolean;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    FBorderFrameOff: TItem;
    FBorderFrameOn: TItem;
    FTrayPopupMenuExt: TPopupMenuExt;
    //FBorderFrame: TBorderFrame;
    procedure TrayIconMouseRightButtonDownHandler(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TrayIconMouseLeftButtonDownHandler(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnCloseTrayItemHandler(Sender: TObject);
    procedure WindowsDelayedBoardOpen(
      const ABoardKind: TBoardKind);
    procedure SetBorderFrameOff(const AForceSet: Boolean);
    procedure SetBorderFrameOn(const AForceSet: Boolean);
    {$ENDIF}

    procedure BuildPopupMenues;

    procedure MenuColorItemClickHandler(Sender: TObject);
    procedure MenuTextBoardItemClickHandler(Sender: TObject);
    procedure MenuElectronicBoardItemClickHandler(Sender: TObject);
    procedure MenuImageBoardItemClickHandler(Sender: TObject);
    procedure MenuRingItemClickHandler(Sender: TObject);

    procedure MenuAlarmItemClickHandler(Sender: TObject);
    procedure MenuTimerItemClickHandler(Sender: TObject);
    procedure MenuCancelTimerItemClickHandler(Sender: TObject);
    procedure MenuSetCustomColorItemClickHandler(Sender: TObject);
    procedure MenuGetCustomColorItemClickHandler(Sender: TObject);

    procedure MenuHorizontalOrientationItemClickHandler(Sender: TObject);
    procedure MenuVerticalOrientationItemClickHandler(Sender: TObject);
    procedure MountOrientation(const AOrientationKind: TOrientationKind);

    procedure SetAlarmTrigger(
      const ATimeKind: TTimeKind;
      const ATriggerTime: TDateTime);

    procedure SetAlarmTimerFormOkButtonClickHandler(Sender: TObject);
    procedure SetTimerTimerFormOkButtonClickHandler(Sender: TObject);
    procedure SetTimerFormCancelButtonClickHandler(Sender: TObject);

    procedure SetCustomColorOkButtonClickHandler(Sender: TObject);
    procedure SetCustomColorCancelButtonClickHandler(Sender: TObject);

    procedure TimeVoidEditOnChangeHandler(Sender: TObject);

    procedure GestureHandler(const EventInfo: TGestureEventInfo);
    // Создаем и запускаем поток отвечающий за ход часов FTimeThread
    // В соотвествие с TState.TimeKind
    procedure StartTime;
    // Уничтожаем поток отвечающий за ход часов FTimeThread
    procedure StopTime;

    procedure RunTimeCounter(
      const ATriggerTime: TTime);

    procedure RunTicker;

//    procedure OnTimeThreadTerminateHandler(Sender: TObject);
    {$IFDEF ANDROID}
    procedure MenuVibroItemClickHandler(Sender: TObject);
    procedure AlarmJsonParser(const AJson: String = '');

    procedure MenuAutoOrientationOnItemClickHandler(Sender: TObject);
    procedure MenuAutoOrientationOffItemClickHandler(Sender: TObject);
    procedure MenuScreenLockItemClickHandler(Sender: TObject);

    procedure StartMotionSensorDataThread;
    procedure StopMotionSensorDataThread;

    procedure VerticalDetectedProc;
    procedure HorizontalDetectedProc;

    procedure SetIsCheckedVibroMenuItem(const AMenuItem: TItem);
    procedure AndroidDelayedBoardOpen(
      const ABoardKind: TBoardKind;
      const ADoStartTime: Boolean = true);
    {$ENDIF}

    procedure SetIsCheckedForChildrenMenuItems(
      const AParentMenuItem: TItem;
      const AIsChecked: Boolean);

    procedure SetIsCheckedBoardMenuItem(const AMenuItem: TItem);
    procedure SetIsCheckedColorMenuItem(const AMenuItem: TItem);
    procedure SetIsCheckedRingMenuItem(const AMenuItem: TItem);

    procedure RaiseAppException(const AMethod: String; const AE: Exception);

    procedure SetRingFileName(const ARingFileName: String);

    procedure OnSetTriggerTimeHandler(Sender: TObject);
  private
    {$IFDEF ANDROID}
    function HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    {$ENDIF}
    procedure OpenBoard(
      const ABoard: TBoardKind;
      const AImageName: String;
      const AColor: TAlphaColor;
      const AOrientation: TOrientationKind;
      const ADoStartTime: Boolean = true);
    procedure CloseBoard;

    function SetBoardOrientation(const AClass: TFrameClass): Pointer;
    {$IFDEF MSWINDOWS}
    procedure SetBoardSize(
      const AMinWidth: Integer;
      const AMinHeight: Integer;
      const ALastOrientationIsEqual: Boolean);
    {$ENDIF}
    procedure GetElectronicBoard(
      const AImageName: String;
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

//    property TimeThread: TTimeThread read GetTimeThread;
  public
    function DoStartSignal: Boolean;
    procedure StartSignal;
    procedure StopSignal;
//    {$IFDEF MSWINDOWS}
////    property BorderFrame: TBorderFrame read FBorderFrame;
//    {$ENDIF}
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  {$IFDEF MSWINDOWS}
    Winapi.Windows
  , FMX.Platform.Win
  , FMX.MoveByMouse
  ,
  {$ENDIF}
  {$IFDEF ANDROID}
    Androidapi.Helpers
  , Androidapi.JNI.App
  , Androidapi.JNI.JavaTypes
  , FMX.Alarm.Android,
  {$ENDIF}
    ShowTimeUnit
  , ShowTextTimeUnit
  , NumScrollUnit
  , SetTimerFormUnit
  , SetCustomColorFormUnit
  , VerticalElectronicBoardFrameUnit
  , VerticalTextBoardFrameUnit
  , ProportionUnit
  , MotionSensorDataThreadUnit
  , FMX.VibroUnit
  , TimeCalcUnit
  , DateTimeToolsUnit
  , DebugUnit
  ;

{ TMainForm }

procedure TMainForm.SetRingFileName(const ARingFileName: String);
var
  RingName: String;
  RingFileName: String;
begin
  RingName := ARingFileName;

  TState.RingName := RingName;

  if RingName = RING_NAME_OFF then
    Exit;

  RingFileName := GetRingFile(RingName);
  FSingleSound.FileName := RingFileName;
end;

procedure TMainForm.RaiseAppException(const AMethod: String; const AE: Exception);
var
  ExceptionMessage: String;
begin
  ExceptionMessage := AE.Message;

  TThread.ForceQueue(nil,
    procedure
    begin
      ShowMessage(ExceptionMessage);
    end);
end;

procedure TMainForm.ContentLayoutGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  GestureHandler(EventInfo);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  TimeVoidEdit.OnChange := nil;

  FSingleSound.Stop;

  {$IFDEF ANDROID}
  if TState.IsAndroidAlarmEngineStarted then
    TAndroidAlarm.Uninit;
  {$ENDIF}

//  if Assigned(FTimeThread) then
//    FTimeThread.OutputControl := nil;

//  if Assigned(FTimeThread) then
//    ThreadFactory.TerminateThread(FTimeThread);

  // Борды нужно закрывать раньше, чем умрут все потоки
  // Так как при закрытии бордов есть обращение к потоку таймера
  CloseBoard;
end;

procedure TMainForm.BuildPopupMenues;
var
  MenuItem: TItem;
  SetCustomColorsMenuItem: TItem;
  ColorIdent: String;
  i: Integer;
  PCKFileName: String;
  PCKFileNameList: TStringList;
  RingFileNameList: TStringList;
  RingFileName: String;
  ImageName: String;
  RingName: String;
begin
  { SettingsPopupMenu }

  FSettingsPopupMenuExt := TPopupMenuExt.Create(ContentLayout);

  FSettingsPopupMenuExt.Theme.CopyFrom(TState.MenuTheme.PopUpMenuTheme);

  FBoardsMenuItem := TItem.Create;
  FBoardsMenuItem.Text := 'Boards';
  FSettingsPopupMenuExt.Add(FBoardsMenuItem);

  FPatternBoardMenuItem := TItem.Create;
  FPatternBoardMenuItem.Name := ELECTRONIC_BOARD_MENU_ITEM_NAME;
  FPatternBoardMenuItem.Parent := FBoardsMenuItem;
  FPatternBoardMenuItem.Text := 'Electronic';
  FSettingsPopupMenuExt.Add(FPatternBoardMenuItem);

  PCKFileNameList := TStringList.Create;
  try
    GetPatternsPackFileList(PCKFileNameList);
    PCKFileNameList.Sort;
    i := 0;
    for PCKFileName in PCKFileNameList do
    begin
      ImageName := GetNameFromFileName(PCKFileName);

      MenuItem := TItem.Create;
      MenuItem.Name := PATTERN_BOARD_MENU_ITEM_NAME + i.ToString;
      MenuItem.Parent := FPatternBoardMenuItem;
      MenuItem.Text := ImageName;
      MenuItem.Tag := 0;
      MenuItem.OnClick := MenuElectronicBoardItemClickHandler;
      MenuItem.IsChecked :=
        (TState.ImageName = ImageName) and (TState.Board = bkElectronic);
      FSettingsPopupMenuExt.Add(MenuItem);

      Inc(i);
    end;
  finally
    FreeAndNil(PCKFileNameList);
  end;

  FImageBoardMenuItem := TItem.Create;
  FImageBoardMenuItem.Parent := FBoardsMenuItem;
  FImageBoardMenuItem.Text := 'Image';
  FSettingsPopupMenuExt.Add(FImageBoardMenuItem);

  PCKFileNameList := TStringList.Create;
  try
    GetImagesPackFileList(PCKFileNameList);
    PCKFileNameList.Sort;
    i := 0;
    for PCKFileName in PCKFileNameList do
    begin
      ImageName := GetNameFromFileName(PCKFileName);

      MenuItem := TItem.Create;
      MenuItem.Name := IMAGE_BOARD_MENU_ITEM_NAME + i.ToString;
      MenuItem.Parent := FImageBoardMenuItem;
      MenuItem.Text := ImageName;
      MenuItem.Tag := 0;
      MenuItem.OnClick := MenuImageBoardItemClickHandler;
      MenuItem.IsChecked :=
        (TState.ImageName = ImageName) and (TState.Board = bkImage);
      FSettingsPopupMenuExt.Add(MenuItem);

      Inc(i);
    end;
  finally
    FreeAndNil(PCKFileNameList);
  end;

  MenuItem := TItem.Create;
  MenuItem.Name := TEXT_BOARD_MEUN_ITEM_NAME;
  MenuItem.Parent := FBoardsMenuItem;
  MenuItem.Text := 'Text';
  MenuItem.OnClick := MenuTextBoardItemClickHandler;
  MenuItem.IsChecked := TState.Board = bkText;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  FOrientationMenuItem := TItem.Create;
  FOrientationMenuItem.Text := 'Orientation';
  FSettingsPopupMenuExt.Add(FOrientationMenuItem);

  FHorizontalOrientationMenuItem := TItem.Create;
  FHorizontalOrientationMenuItem.Name := HORIZONTAL_ORIENTATION_MENU_ITEM_NAME;
  FHorizontalOrientationMenuItem.Parent := FOrientationMenuItem;
  FHorizontalOrientationMenuItem.Text := 'Horizontal';
  FHorizontalOrientationMenuItem.Tag := 0;
  FHorizontalOrientationMenuItem.OnClick := MenuHorizontalOrientationItemClickHandler;
  FHorizontalOrientationMenuItem.IsChecked := TState.Orientation = okHorizontal;
  FSettingsPopupMenuExt.Add(FHorizontalOrientationMenuItem);

  FVerticalOrientationMenuItem := TItem.Create;
  FVerticalOrientationMenuItem.Name := VERTICAL_ORIENTATION_MENU_ITEM_NAME;
  FVerticalOrientationMenuItem.Parent := FOrientationMenuItem;
  FVerticalOrientationMenuItem.Text := 'Vertical';
  FVerticalOrientationMenuItem.Tag := 1;
  FVerticalOrientationMenuItem.OnClick := MenuVerticalOrientationItemClickHandler;
  FVerticalOrientationMenuItem.IsChecked := TState.Orientation = okVertical;
  FSettingsPopupMenuExt.Add(FVerticalOrientationMenuItem);

  {$IFDEF ANDROID}
  MenuItem := TItem.Create;
  MenuItem.Parent := FOrientationMenuItem;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  FAutoOrientationMenuItem := TItem.Create;
  FAutoOrientationMenuItem.Parent := FOrientationMenuItem;
  FAutoOrientationMenuItem.Text := 'Auto';
  FAutoOrientationMenuItem.Tag := 0;
  FSettingsPopupMenuExt.Add(FAutoOrientationMenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := AUTO_ORIENTATION_ON_MENU_ITEM_NAME;
  MenuItem.Parent := FAutoOrientationMenuItem;
  MenuItem.Text := 'On';
  MenuItem.Tag := 0;
  MenuItem.OnClick := MenuAutoOrientationOnItemClickHandler;
  MenuItem.IsChecked := TState.AutoOrientation;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := AUTO_ORIENTATION_OFF_MENU_ITEM_NAME;
  MenuItem.Parent := FAutoOrientationMenuItem;
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

  for i := 0 to Pred(Length(TColors.ColorArray)) do
  begin
    ColorIdent := TColors.ColorArray[i];
    MenuItem := TItem.Create;
    MenuItem.Name :=
      COLOR_MENU_ITEM_NAME_PREFIX +
      Cardinal(TColors.ColorByIdent(ColorIdent)).ToString;
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
  {$IFDEF MSWINDOWS}
  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  FBorderFrameOff := TItem.Create;
  FBorderFrameOff.Text := 'Border frame off';
  FBorderFrameOff.OnClickProcRef :=
    procedure
    begin
      SetBorderFrameOff(true);
    end;
  FSettingsPopupMenuExt.Add(FBorderFrameOff);

  FBorderFrameOn := TItem.Create;
  FBorderFrameOn.Visible := false;
  FBorderFrameOn.Text := 'Border frame on';
  FBorderFrameOn.OnClickProcRef :=
    procedure
    begin
      SetBorderFrameOn(true);
    end;
  FSettingsPopupMenuExt.Add(FBorderFrameOn);
  {$ENDIF}
  {$IFDEF ANDROID}
  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Screen lock';
  MenuItem.Tag := -1;
  MenuItem.OnClick := MenuScreenLockItemClickHandler;
  FSettingsPopupMenuExt.Add(MenuItem);
  {$ENDIF}

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Close';
  MenuItem.Tag := -1;
  MenuItem.OnClickProcRef :=
    procedure
    begin
      Close;
    end;
  FSettingsPopupMenuExt.Add(MenuItem);

  { ToolsPopupMenu }

  FToolsPopupMenuExt := TPopupMenuExt.Create(ContentLayout);

//  {$IFDEF MSWINDOWS}
//  FToolsPopupMenuExt := TPopupMenuExt.Create(Self, ThreadFactory);
//  {$ELSE IFDEF ANDROID}
//  FToolsPopupMenuExt := TPopupMenuExt.Create(Self);
//  {$ENDIF}
  FToolsPopupMenuExt.Theme.CopyFrom(TState.MenuTheme.PopUpMenuTheme);

  FRingMenuItem := TItem.Create;
  FRingMenuItem.Text := 'Ring';
  FToolsPopupMenuExt.Add(FRingMenuItem);

  FRingsMenuItem := TItem.Create;
  FRingsMenuItem.Parent := FRingMenuItem;
  FRingsMenuItem.Text := 'Rings';
  FToolsPopupMenuExt.Add(FRingsMenuItem);

  MenuItem := TItem.Create;
  MenuItem.Parent := FRingsMenuItem;
  MenuItem.Text := RING_NAME_OFF;
  MenuItem.OnClick := MenuRingItemClickHandler;
  MenuItem.IsChecked := TState.RingName = RING_NAME_OFF;
  FToolsPopupMenuExt.Add(MenuItem);

  RingFileNameList := TStringList.Create;
  try
    GetRingFileList(RingFileNameList);
    RingFileNameList.Sort;
    i := 0;
    for RingFileName in RingFileNameList do
    begin
      RingName := GetNameFromFileName(RingFileName);

      MenuItem := TItem.Create;
//      MenuItem.Name := RING_MENU_ITEM_NAME + i.ToString;
      MenuItem.Parent := FRingsMenuItem;
      MenuItem.Text := RingName;
//      MenuItem.Tag := 0;
      MenuItem.OnClick := MenuRingItemClickHandler;
      MenuItem.IsChecked := TState.RingName = RingName;
      FToolsPopupMenuExt.Add(MenuItem);

      Inc(i);
    end;
  finally
    FreeAndNil(RingFileNameList);
  end;

  {$IFDEF ANDROID}
  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FToolsPopupMenuExt.Add(MenuItem);

  FVibroMenuItem := TItem.Create;
  FVibroMenuItem.Parent := FRingMenuItem;
  FVibroMenuItem.Text := 'Vibration';
  FToolsPopupMenuExt.Add(FVibroMenuItem);

  MenuItem := TItem.Create;
  MenuItem.Parent := FVibroMenuItem;
  MenuItem.Text := VIBRO_NAME_OFF;
  MenuItem.OnClick := MenuVibroItemClickHandler;
  MenuItem.IsChecked := TState.Vibration = false;
  FToolsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Parent := FVibroMenuItem;
  MenuItem.Text := VIBRO_NAME_ON;
  MenuItem.OnClick := MenuVibroItemClickHandler;
  MenuItem.IsChecked := TState.Vibration = true;
  FToolsPopupMenuExt.Add(MenuItem);
  {$ENDIF}

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FToolsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Set alarm';
  MenuItem.OnClick := MenuAlarmItemClickHandler;
  FToolsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Set timer';
  MenuItem.OnClick := MenuTimerItemClickHandler;
  FToolsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  FToolsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Name := CANCEL_MENU_ITEM_NAME;
  MenuItem.Text := 'Cancel';
  MenuItem.OnClick := MenuCancelTimerItemClickHandler;
  MenuItem.Visible := true;
  FToolsPopupMenuExt.Add(MenuItem);

  { Tray menu}

  {$IFDEF MSWINDOWS}
  FTrayPopupMenuExt := TPopupMenuExt.Create(Self);
  FTrayPopupMenuExt.Theme.CopyFrom(TState.MenuTheme.PopUpMenuTheme);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Close';
  MenuItem.OnClick := OnCloseTrayItemHandler;
  FTrayPopupMenuExt.Add(MenuItem);
  {$ENDIF}
end;

procedure TMainForm.FormCreate(Sender: TObject);
const
  METHOD = 'TMainForm.FormCreate';
  SCALE_VALUE = 1;
{$IFDEF ANDROID}
var
  aFMXApplicationEventService: IFMXApplicationEventService;
{$ENDIF}
begin
  ReportMemoryLeaksOnShutdown := true;
  try
    HDelimText.Text := '';
    HHText.Text := '';
    HLText.Text := '';
    MHText.Text := '';
    MLText.Text := '';
    SDelimText.Text := '';
    SHText.Text := '';
    SLText.Text := '';

    FTimeThread := nil;
    FSignalThread := nil;
    FVibroThread := nil;
    // Пусть остается SystemDefault
    // В некоторых эмуляторах при установке в HighQuality
    // зависает на экране заставки
    // На хардовом железе HighQuality отрабатывается
    // Визуально разница не замечена
    Self.Quality := TCanvasQuality.SystemDefault;

    FElectronicBoardFrame := nil;
    FTextBoardFrame := nil;
    FCurrentColorIdent := '';
    //FElectronicBoardColorArray
    FSettingsPopupMenuExt := nil;
    FToolsPopupMenuExt := nil;
    FBoardsMenuItem := nil;
    FImageBoardMenuItem := nil;
    FOrientationMenuItem := nil;
    FColorsMenuItem := nil;
    FCustomColorsMenuItem := nil;
    FHorizontalOrientationMenuItem := nil;
    FVerticalOrientationMenuItem := nil;
//    FIsAppStartedFromAlarmReceiver := false;
    {$IFDEF MSWINDOWS}
    FTrayPopupMenuExt := nil;
    {$ENDIF}
    {$IFDEF ANDROID}
    TState.IsAndroidAlarmEngineStarted :=
      TAndroidAlarm.Init(1001, AlarmJsonParser);

    FAutoOrientationMenuItem := nil;
    if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService,
      IInterface(aFMXApplicationEventService))
    then
      aFMXApplicationEventService.SetApplicationEventHandler(HandleAppEvent)
    else
      ShowMessage('Application Event Service is not supported');

//    FIsAppStartedFromAlarmReceiver :=
//      TAndroidHelper.Activity.getIntent.
//        getBooleanExtra(StringToJString('StartedFromAlarmReceiver'), false);
    {$ENDIF}

    FSingleSound := TSingleSound.Create(ThreadFactory);
    SetRingFileName(TState.RingName);

    SetTimerForm := nil;
    SignalRectangle.Visible := false;
    SignalRectangle.SendToBack;
    AlarmLayout.Visible := TState.IsAlarmCharged;

    { MenuTheme}

    TState.MenuTheme.PopUpMenuTheme.BackgroundColor := $FF2A001A;//TAlphaColorRec.Black;
    TState.MenuTheme.PopUpMenuTheme.NormalBackgroundColor := TAlphaColorRec.Black;//$FFE0E0E0;
    TState.MenuTheme.PopUpMenuTheme.MouseOverColor := TAlphaColorRec.Cornflowerblue;
    TState.MenuTheme.PopUpMenuTheme.CustomTextSettings.FontColor := TAlphaColorRec.White;
    TState.OnSetTriggerTime := OnSetTriggerTimeHandler;
    // Переприсваеваем время триггера, что бы сработал TState.OnSetTriggerTime
    TState.TriggerTime := TState.TriggerTime;

    FCurrentColorIdent := TColors.ColorArray.LastValue;

    BuildPopupMenues;

    {$IFDEF MSWINDOWS}
    BorderFrame.Kind := TBorderFrameKind.bfkNormal;
    BorderFrame.CaptionColor := $FF8D003A;
    BorderFrame.Color := BORDER_FRAME_COLOR;
    BorderFrame.ToolButtonColor := BorderFrame.CaptionColor;
    BorderFrame.ToolButtonMouseOverColor := $FFADADAD;

    TrayIconMouseRightButtonDown := TrayIconMouseRightButtonDownHandler;
    TrayIconMouseLeftButtonDown := TrayIconMouseLeftButtonDownHandler;
    {$ENDIF}

    TimeVoidEdit.OnChange := TimeVoidEditOnChangeHandler;

    FOpeningBoard := TState.Board;

    OpenBoard(
      bkNone,
      TState.ImageName,
      TState.Color,
      TState.Orientation,
      false);

    {$IFDEF MSWINDOWS}

    ShowWindow(ApplicationHWND, SW_HIDE);

    Self.Left := TState.FormLeft;
    Self.Top  := TState.FormTop;
    Self.ClientWidth := TState.FormClientWidth;
    Self.ClientHeight := TState.FormClientHeight;

    Self.OnFormStateLoaded :=
      procedure (AForm: TFormExt)
      begin
        SetBorderFrameOff(false);
      end;

    WindowsDelayedBoardOpen(FOpeningBoard);
    {$ELSE IFDEF ANDROID}
    Self.FullScreen := true;
    {$ENDIF}
  except
    on e: Exception do
      RaiseAppException(METHOD, e);
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSingleSound);
end;

procedure TMainForm.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  if Application.Terminated then
    Exit;

  if TState.Board = bkNone then
    Exit;

  PaintRects(ARect);
  {$IFDEF MSWINDOWS}
  TState.FormLeft     := Self.Left;
  TState.FormTop      := Self.Top;
  TState.FormClientWidth    := Self.ClientWidth;
  TState.FormClientHeight   := Self.ClientHeight;
//  TState.FormWidth    := FBorderFrame.ClientWidth;
//  TState.FormHeight   := FBorderFrame.ClientHeight;
  {$ENDIF}
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if Application.Terminated then
    Exit;

  if TState.Board = bkNone then
    Exit;

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

  if TState.Board = bkText then
    Exit;

  TShowTime.CheckBitmapsResolution(Single(Self.Width), Single(Self.Height));
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

procedure TMainForm.ToolsLayoutMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  {$IFDEF MSWINDOWS}
  if Button = TMouseButton.mbLeft then
    TMoveByMouse.ManualMove(ToolsLayout, Self);
  {$ENDIF}
end;

procedure TMainForm.ToolsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  // Для Андроида специально должно глушиться,
  // иначе не обработает собития жестов OnGesture
  {$IFDEF MSWINDOWS}
  if Button <> TMouseButton.mbRight then
    Exit;

  GetCurPos(X, Y);
  FToolsPopupMenuExt.Open(X, Y);
  {$ENDIF}
end;

procedure TMainForm.ToolsLayoutTap(Sender: TObject; const Point: TPointF);
begin
  FToolsPopupMenuExt.Open(Point.X, Point.Y);
end;

procedure TMainForm.ScreenLockerLayoutGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  case EventInfo.GestureID of
    sgiTriangle:
      begin
        ScreenLockerLayout.HitTest := false;
        ScreenLockerLayout.SendToBack;
      end;
  end;
end;

function TMainForm.SetBoardOrientation(const AClass: TFrameClass): Pointer;
begin
  Result := AClass.Create(nil);
end;

procedure TMainForm.GetElectronicBoard(
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
    GetPatternsPackFile(AImageName),
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
  const AOrientation: TOrientationKind;
  const ADoStartTime: Boolean = true);

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
  FormClientWidth, ClientHeight: Integer;
begin
  TextTimeLayout.Visible := false;

//  SetTimeThreadOutputControl(nil);
//  TimeVoidEdit.OnChange := nil;

  CloseBoard;

  TState.Board := ABoard;
  TState.Color := AColor;
  TState.ImageName := AImageName;

  FormClientWidth := TState.FormClientWidth;
  ClientHeight := TState.FormClientHeight;

  if AOrientation = okNone then
  begin
    LastOrientationIsEqual := false;
    TState.Orientation := okHorizontal;
  end
  else
  begin
    LastOrientationIsEqual := true;
    if TState.Orientation <> AOrientation then
    begin
      LastOrientationIsEqual := false;

      FormClientWidth := TState.FormClientHeight;
      ClientHeight := TState.FormClientWidth;

      TState.FormClientWidth := FormClientWidth;
      TState.FormClientHeight := ClientHeight;
    end;

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
        AImageName,
        TState.Orientation,
        MinWidth,
        MinHeight,
        AColor,
        LastOrientationIsEqual);
    end;
    bkText:
    begin
      TextTimeLayout.Visible := true;

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
    end;
    bkNone:
    begin
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

  if TState.Board = bkNone then
    Exit;

  AlarmLayout.Visible := TState.IsAlarmCharged;

  Self.ClientWidth := FormClientWidth;
  Self.ClientHeight := ClientHeight;

  Self.Resize;

  if ADoStartTime then
    StartTime;
end;

procedure TMainForm.CloseBoard;
begin
  StopTime;

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

  SetIsCheckedColorMenuItem(MenuItem);

  TState.ColorIdent := TColors.ColorArray[MenuItem.Tag];
  OpenBoard(
    TState.Board,
    TState.ImageName,
    TColors.ColorByIdent(TState.ColorIdent),
    TState.Orientation);
end;

procedure TMainForm.MenuTextBoardItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedBoardMenuItem(MenuItem);

  OpenBoard(bkText, TState.ImageName, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuElectronicBoardItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  Log.d('TMainForm.MenuElectronicBoardItemClickHandler.Enter');
  SetIsCheckedBoardMenuItem(MenuItem);

  OpenBoard(bkElectronic, MenuItem.Text, TState.Color, TState.Orientation);
  Log.d('TMainForm.MenuElectronicBoardItemClickHandler.Leave');
end;

procedure TMainForm.MenuImageBoardItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedBoardMenuItem(MenuItem);

  OpenBoard(bkImage, MenuItem.Text, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuRingItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedRingMenuItem(MenuItem);

  SetRingFileName(MenuItem.Text);
end;

procedure TMainForm.MenuAlarmItemClickHandler(Sender: TObject);
begin
  StopSignal;

  SetTimerForm := TSetTimerForm.Create(Self);
  SetTimerForm.Time := Now;
  SetTimerForm.OkButtonRectangle.OnClick := SetAlarmTimerFormOkButtonClickHandler;
  SetTimerForm.CancelButtonRectangle.OnClick := SetTimerFormCancelButtonClickHandler;
  {$IFDEF MSWINDOWS}
  SetTimerForm.ShowModal;
  {$ELSE IFDEF ANDROID}
  SetTimerForm.Show;
  {$ENDIF}
end;

procedure TMainForm.MenuTimerItemClickHandler(Sender: TObject);
var
  Time: TTIme;
begin
  StopSignal;

  Time := EncodeTime(0, 0, 0, 0);
  SetTimerForm := TSetTimerForm.Create(Self);
  SetTimerForm.Time := Time;
  SetTimerForm.OkButtonRectangle.OnClick := SetTimerTimerFormOkButtonClickHandler;
  SetTimerForm.CancelButtonRectangle.OnClick := SetTimerFormCancelButtonClickHandler;
  {$IFDEF MSWINDOWS}
  SetTimerForm.ShowModal;
  {$ELSE IFDEF ANDROID}
  SetTimerForm.Show;
  {$ENDIF}
end;

procedure TMainForm.MenuCancelTimerItemClickHandler(Sender: TObject);
begin
  TState.TimeKind := tkTime;
  TState.TriggerTime := NULL_TIME;

  AlarmLayout.Visible := TState.IsAlarmCharged;

  StopSignal;

  StopTime;
  RunTicker;
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

  SetIsCheckedColorMenuItem(MenuItem);

  CloseBoard;

  OpenBoard(TState.Board, TState.ImageName, Color, TState.Orientation);
end;

procedure TMainForm.MenuVerticalOrientationItemClickHandler(Sender: TObject);
begin
  MountOrientation(okVertical);

//  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);
//  // Выставляем значение не через Sender,
//  // так как при авто повороте, Sender = nil
//  FVerticalOrientationMenuItem.IsChecked := true;
//
//  OpenBoard(TState.Board, TState.ImageName, TState.Color, okVertical);
//
//  TimeVoidEditOnChangeHandler(TimeVoidEdit);
end;

procedure TMainForm.MenuHorizontalOrientationItemClickHandler(Sender: TObject);
begin
  MountOrientation(okHorizontal);

//  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);
//  // Выставляем значение не через Sender,
//  // так как при авто повороте, Sender = nil
//  FHorizontalOrientationMenuItem.IsChecked := true;
//
//  OpenBoard(TState.Board, TState.ImageName, TState.Color, okHorizontal);
//
//  TimeVoidEditOnChangeHandler(TimeVoidEdit);
end;

procedure TMainForm.MountOrientation(const AOrientationKind: TOrientationKind);
begin
  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);
  // Выставляем значение не через Sender,
  // так как при авто повороте, Sender = nil
  if AOrientationKind = okVertical then
    FVerticalOrientationMenuItem.IsChecked := true
  else
  if AOrientationKind = okHorizontal then
    FHorizontalOrientationMenuItem.IsChecked := true;

  OpenBoard(TState.Board, TState.ImageName, TState.Color, AOrientationKind);

  // Запускаем OnChange вручную, иначе цифры не отобразятся на табло,
  // Так как поток тикера не запущен и изменений в TimeVoidEdit не происходит
  // И не вызывается TimeVoidEdit.OnChange
  TimeVoidEditOnChangeHandler(TimeVoidEdit);
end;

procedure TMainForm.StartTime;
begin
  RunTicker;
end;

procedure TMainForm.StopTime;
begin
  if Assigned(FTimeThread) then
    ThreadFactory.TerminateThread(FTimeThread);

  AlarmLayout.Visible := TState.IsAlarmCharged;
end;

procedure TMainForm.RunTimeCounter(
  const ATriggerTime: TTime);
var
  TimeKind: TTimeKind;
  OutputControl: TControl;
begin
  TimeKind := TState.TimeKind;

  if TimeKind = tkTime then
    TState.TriggerTime := NULL_TIME
  else
    TState.TriggerTime := ATriggerTime;

  OutputControl := TimeVoidEdit;

  FTimeThread := TTimeThread.Create(
    ThreadFactory,
    TState.TriggerTime,
    TimeKind,
    Self,
    OutputControl);
end;

procedure TMainForm.RunTicker;
begin
  RunTimeCounter(TState.TriggerTime);
end;

//procedure TMainForm.OnTimeThreadTerminateHandler(Sender: TObject);
//begin
////  FTimeThread := nil;
//end;

function TMainForm.DoStartSignal: Boolean;
begin
  TDebug.ODS('TMainForm.DoStartSignal.Enter');

  Result := false;

  if TState.IsJsonReceived or
     ((TState.IsAlarmCharged) and (TState.TriggerTime <= Now))
  then
  begin
    StartSignal;

    Result := true;
  end;
end;

procedure TMainForm.StartSignal;
const
  VOLUME_VALUE = 1.0;
var
  TimeString: String;
begin
  StopTime;

  TimeString := FormatDateTime('hh:nn:ss', TState.TriggerTime);
  if TState.TimeKind = tkTimer then
    TimeString := ZERO_TIME_STRING;
  CommonUnit.DisplayTime(TimeVoidEdit, TimeString);

  if TState.RingName <> RING_NAME_OFF then
  begin
    FSingleSound.OnFinishedProcRef :=
      procedure
      begin
        FSingleSound.Play(0);
        FSingleSound.Volume := VOLUME_VALUE;
      end;

    TThread.ForceQueue(nil,
      procedure
      begin
        FSingleSound.Play(0);
        FSingleSound.Volume := VOLUME_VALUE;
      end);
  end;

  ThreadFactory.TerminateThread(FVibroThread);
  if TState.Vibration then
  begin
    FVibroThread := ThreadFactory.CreateInlineThread(
      procedure (const AThread: TThreadExt)
      begin
        while not AThread.Terminated do
        begin
          TVibro.Vibrate(200);
          Sleep(600);
        end;
      end);
  end;

  ThreadFactory.TerminateThread(FSignalThread);
  FSignalThread := ThreadFactory.CreateInlineThread(
    procedure (const AThread: TThreadExt)
    begin
      TThread.ForceQueue(nil,
        procedure
        begin
          Self.Show;
        end);

      while not AThread.Terminated do
      begin
        //TThread.ForceQueue(nil,
        AThread.Synchronize(nil,
          procedure
          begin
            SignalRectangle.Visible := true;
            SignalRectangle.BringToFront;
          end);

        Sleep(600);

        //TThread.ForceQueue(nil,
        AThread.Synchronize(nil,
          procedure
          begin
            SignalRectangle.Visible := false;
            SignalRectangle.SendToBack;
          end);

        Sleep(600);
      end;
    end);
end;

procedure TMainForm.StopSignal;
begin
  TState.TriggerTime := NULL_TIME;

  {$IFDEF ANDROID}
  if TState.IsAndroidAlarmEngineStarted then
    TAndroidAlarm.CancelAlarm;
  {$ENDIF}

  FSingleSound.Pause;

  ThreadFactory.TerminateThread(FSignalThread);
  ThreadFactory.TerminateThread(FVibroThread);

  if Assigned(FTimeThread) then
    if not ThreadFactory.ThreadExists(FTimeThread) then
      RunTicker;
end;

procedure TMainForm.SetAlarmTrigger(
  const ATimeKind: TTimeKind;
  const ATriggerTime: TDateTime);
var
//  CurrentTime: TDateTime;
  TriggerTime: TDateTime;
begin
//  CurrentTime := Now;
//  TriggerTime := CurrentTime;
//  TDateTimeTools.ChangeTime(TriggerTime, ATriggerTime);
  TriggerTime := ATriggerTime;

  StopSignal;

  StopTime;

  TState.TimeKind := ATimeKind;
  TState.TriggerTime := TriggerTime;
  AlarmLayout.Visible := TState.IsAlarmCharged;

  if DoStartSignal then
    Exit;

  StartTime;

  {$IFDEF ANDROID}
  if TState.IsAndroidAlarmEngineStarted then
    TAndroidAlarm.RechargeAlarm(TriggerTime);
//    TAndroidAlarm.RechargeAlarm(TimeToDateTime(TriggerTime));
  {$ENDIF}
end;

procedure TMainForm.SetAlarmTimerFormOkButtonClickHandler(Sender: TObject);
var
  TriggerTime: TDateTime;
begin
  TriggerTime := Now;
  TDateTimeTools.ChangeTime(TriggerTime, SetTimerForm.Time);
  SetAlarmTrigger(tkAlarm, TriggerTime);

  TThread.Queue(nil,
    procedure
    begin
      SetTimerForm.Close;
    end);
end;

procedure TMainForm.SetTimerTimerFormOkButtonClickHandler(Sender: TObject);
var
  TriggerTime: TDateTime;
  TimerTime: TTime;
begin
  TimerTime := SetTimerForm.Time;
  TriggerTime := TTimeCalc.CalcDateTime(Now, TimerTime, true);
  SetAlarmTrigger(tkTimer, TriggerTime);

  TThread.Queue(nil,
    procedure
    begin
      SetTimerForm.Close;
    end);
end;

procedure TMainForm.SetTimerFormCancelButtonClickHandler(Sender: TObject);
begin
  TThread.Queue(nil,
    procedure
    begin
      SetTimerForm.Close;
    end
  );
end;

procedure TMainForm.SettingsLayoutMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  {$IFDEF MSWINDOWS}
  if Button = TMouseButton.mbLeft then
    TMoveByMouse.ManualMove(SettingsLayout, Self);
  {$ENDIF}
end;

procedure TMainForm.SettingsLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  // Для Андроида специально должно глушиться,
  // иначе не обработает события жестов OnGesture
  {$IFDEF MSWINDOWS}
  if Button <> TMouseButton.mbRight then
    Exit;

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

  SetIsCheckedColorMenuItem(MenuItem);

  CloseBoard;

  OpenBoard(TState.Board, TState.ImageName, TState.Color, TState.Orientation);
end;

procedure TMainForm.SetCustomColorCancelButtonClickHandler(Sender: TObject);
begin
  SetCustomColorForm.Close;
end;

procedure TMainForm.SetIsCheckedForChildrenMenuItems(
  const AParentMenuItem: TItem;
  const AIsChecked: Boolean);
var
  MenuItem: TItem;
begin
  for MenuItem in AParentMenuItem.Children do
    MenuItem.IsChecked := AIsChecked;
end;

procedure TMainForm.SetIsCheckedBoardMenuItem(const AMenuItem: TItem);
begin
  SetIsCheckedForChildrenMenuItems(FBoardsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FPatternBoardMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);

  AMenuItem.IsChecked := true;
end;

procedure TMainForm.SetIsCheckedColorMenuItem(const AMenuItem: TItem);
begin
  SetIsCheckedForChildrenMenuItems(FColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FCustomColorsMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FImageBoardMenuItem, false);

  AMenuItem.IsChecked := true;
end;

procedure TMainForm.SetIsCheckedRingMenuItem(const AMenuItem: TItem);
begin
  SetIsCheckedForChildrenMenuItems(FRingsMenuItem, false);

  AMenuItem.IsChecked := true;
end;

procedure TMainForm.OnSetTriggerTimeHandler(Sender: TObject);
begin
  AlarmLayout.Visible := TState.IsAlarmCharged;
  AlarmTimeText.Text := TimeToStr(TState.TriggerTime);
end;

{$IFDEF MSWINDOWS}
procedure TMainForm.OnCloseTrayItemHandler(Sender: TObject);
begin
  Close;
//  MainForm.BorderFrame.CloseButtonRectangle.
//    OnClick(MainForm.BorderFrame.CloseButtonRectangle);
end;

procedure TMainForm.TrayIconMouseRightButtonDownHandler(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  GetCurPos(X, Y);

  FTrayPopupMenuExt.Open(X, Y);
end;

procedure TMainForm.TrayIconMouseLeftButtonDownHandler(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ShowWindow(ApplicationHWND, SW_HIDE);
end;

// Приводим размеры к дефолтным только когда меняем ориентацию экрана
procedure TMainForm.SetBoardSize(
  const AMinWidth: Integer;
  const AMinHeight: Integer;
  const ALastOrientationIsEqual: Boolean);
begin
  MinClientWidth := AMinWidth;
  MinClientHeight := AMinHeight;

  if not ALastOrientationIsEqual then
  begin
    ClientWidth := MinClientWidth;
    ClientHeight := MinClientHeight;
  end
  else
  begin
    ClientWidth  := TState.FormClientWidth;
    ClientHeight := TState.FormClientHeight;
  end;
end;

procedure TMainForm.WindowsDelayedBoardOpen(
  const ABoardKind: TBoardKind);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(100);

      TThread.Queue(nil,
        procedure
        begin
          OpenBoard(
            ABoardKind,
            TState.ImageName,
            TState.Color,
            TState.Orientation,
            true);
          ScreenLockerLayout.BringToFront;
        end);
    end
    ).Start;
end;

procedure TMainForm.SetBorderFrameOff(const AForceSet: Boolean);
begin
  if not AForceSet then
    if Self.BorderFrame.Kind <> TBorderFrameKind.bfkNoCaption then
      Exit;

  BorderFrame.Kind := TBorderFrameKind.bfkNoCaption;
  BorderFrame.Color := Fill.Color;

  if Assigned(FBorderFrameOff) then
    FBorderFrameOff.Visible := false;

  if Assigned(FBorderFrameOn) then
    FBorderFrameOn.Visible := true;
end;

procedure TMainForm.SetBorderFrameOn(const AForceSet: Boolean);
begin
  if not AForceSet then
    if Self.BorderFrame.Kind <> TBorderFrameKind.bfkNormal then
      Exit;

  BorderFrame.Kind := TBorderFrameKind.bfkNormal;
  Self.BorderFrame.Color := BORDER_FRAME_COLOR;

  if Assigned(FBorderFrameOff) then
    FBorderFrameOff.Visible := true;

  if Assigned(FBorderFrameOn) then
    FBorderFrameOn.Visible := false;
end;
{$ENDIF}

{$IFDEF ANDROID}
procedure TMainForm.MenuAutoOrientationOnItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FAutoOrientationMenuItem, false);

  MenuItem.IsChecked := true;

  TState.AutoOrientation := true;
  StartMotionSensorDataThread;
end;

procedure TMainForm.MenuAutoOrientationOffItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedForChildrenMenuItems(FOrientationMenuItem, false);
  SetIsCheckedForChildrenMenuItems(FAutoOrientationMenuItem, false);

  MenuItem.IsChecked := true;

  TState.AutoOrientation := false;
  StopMotionSensorDataThread;
end;

procedure TMainForm.MenuVibroItemClickHandler(Sender: TObject);
var
  MenuItem: TItem absolute Sender;
begin
  SetIsCheckedVibroMenuItem(MenuItem);

  TState.Vibration := false;
  if MenuItem.Text = VIBRO_NAME_ON then
    TState.Vibration := true;
end;

procedure TMainForm.AlarmJsonParser(const AJson: String = '');
begin
  TState.IsJsonReceived := AJson.Length > 0;
end;

procedure TMainForm.SetIsCheckedVibroMenuItem(const AMenuItem: TItem);
begin
  SetIsCheckedForChildrenMenuItems(FVibroMenuItem, false);

  AMenuItem.IsChecked := true;
end;

procedure TMainForm.MenuScreenLockItemClickHandler(Sender: TObject);
begin
  ScreenLockerLayout.HitTest := true;
  ScreenLockerLayout.BringToFront;
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

procedure TMainForm.StartMotionSensorDataThread;
begin
  TMotionSensorDataThread.Init(Self, VerticalDetectedProc, HorizontalDetectedProc);
end;

procedure TMainForm.StopMotionSensorDataThread;
begin
  TMotionSensorDataThread.UnInit;
end;

procedure TMainForm.AndroidDelayedBoardOpen(
  const ABoardKind: TBoardKind;
  const ADoStartTime: Boolean = true);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(100);

      TThread.Queue(nil,
        procedure
        begin
          OpenBoard(
            ABoardKind,
            TState.ImageName,
            TState.Color,
            TState.Orientation,
            ADoStartTime);

          ScreenLockerLayout.BringToFront;

          if TState.AutoOrientation then
            StartMotionSensorDataThread;

          DoStartSignal;
        end);
    end
    ).Start;
end;

function TMainForm.HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  Result := True;

  case AAppEvent of
    TApplicationEvent.FinishedLaunching:
    begin
      if TState.IsAndroidAlarmEngineStarted then
        TAndroidAlarm.HandleIntent;

      AndroidDelayedBoardOpen(FOpeningBoard, not TState.IsJsonReceived);
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

end.
