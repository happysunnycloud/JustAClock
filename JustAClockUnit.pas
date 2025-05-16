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
    ContentLayout: TLayout;
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
    FTrayPopupMenuExt: TPopupMenuExt;
    FBorderFrame: TBorderFrame;

    procedure TrayIconMouseRightButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TrayIconMouseLeftButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnCloseTrayItemHandler(Sender: TObject);
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
    procedure SetTimerFormCancelButtonClickHandler(Sender: TObject);

    procedure SetCustomColorOkButtonClickHandler(Sender: TObject);

    procedure TimeVoidEditOnChangeHandler(Sender: TObject);

    procedure RunTime;
    procedure RunTimer(const ATimerTime: TTime);

    procedure VerticalDetectedProc;
    procedure HorizontalDetectedProc;
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

  { MenuTheme}

  TState.MenuTheme.BackgroundColor := $FF2A001A;//TAlphaColorRec.Black;
  TState.MenuTheme.LightBackgroundColor := TAlphaColorRec.Black;//$FFE0E0E0;
  TState.MenuTheme.DarkBackgroundColor := TAlphaColorRec.Cornflowerblue;

  TState.MenuTheme.TextControlSettings.Align := TAlignLayout.Client;
  TState.MenuTheme.TextControlSettings.HitTest := false;
  TState.MenuTheme.TextControlSettings.TextSettings.FontColor :=
    TAlphaColorRec.White;
  TState.MenuTheme.TextControlSettings.TextSettings.HorzAlign :=
    TTextAlign.Leading;
  TState.MenuTheme.TextControlSettings.TextSettings.VertAlign :=
    TTextAlign.Center;
  TState.MenuTheme.TextControlSettings.Margins.Left := 5;
  TState.MenuTheme.TextControlSettings.WordWrap := false;

  { SettingsPopupMenu }

  FSettingsPopupMenuExt := TPopupMenuExt.Create(Self);
  TState.MenuTheme.CopyTo(FSettingsPopupMenuExt.Theme);

  Boards := TItem.Create;
  Boards.Text := 'Boards';
  FSettingsPopupMenuExt.Add(Boards);

  MenuItem := TItem.Create;
  MenuItem.Parent := Boards;
  MenuItem.Text := 'Electronic';
  MenuItem.OnClick := MenuElectronicBoardItemClickHandler;
  FSettingsPopupMenuExt.Add(MenuItem);

  MenuItem := TItem.Create;
  MenuItem.Parent := Boards;
  MenuItem.Text := 'Text';
  MenuItem.OnClick := MenuTextBoardItemClickHandler;
  FSettingsPopupMenuExt.Add(MenuItem);

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

  FCurrentElectronicBoardColor := FElectronicBoardColorArray.LastValue;

  {$IFDEF MSWINDOWS}
  FTrayPopupMenuExt := TPopupMenuExt.Create(Self);
  TState.MenuTheme.CopyTo(FTrayPopupMenuExt.Theme);

  MenuItem := TItem.Create;
  MenuItem.Text := 'Close';
  MenuItem.OnClick := OnCloseTrayItemHandler;
  FTrayPopupMenuExt.Add(MenuItem);

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

  {$ELSE IFDEF ANDROID}
  Self.FullScreen := true;
  {$ENDIF}
  FElectronicBoardFrame := nil;

  RunTime;

  TState.LastOrientation := TState.Orientation;
  OpenBoard(TState.Board, TState.Color, TState.Orientation);

  TMotionSensorDataThread.Init(Self, VerticalDetectedProc, HorizontalDetectedProc);
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
end;

procedure TMainForm.FormResize(Sender: TObject);

  function _GetCurrentOrientation: TOrientationKind;
  begin
    Result := okHorizontal;
    if Width <= Height then
      Result := okVertical;
  end;

var
  CurrentOrientation: TOrientationKind;
begin
  CurrentOrientation := _GetCurrentOrientation;
  if CurrentOrientation <> TState.LastOrientation then
  begin
    TThread.ForceQueue(nil,
      procedure
      begin
        CloseBoard;
      end);

    TThread.ForceQueue(nil,
      procedure
      begin
        TState.LastOrientation := TState.Orientation;
        OpenBoard(TState.Board, TState.Color, CurrentOrientation);
      end);

    Exit;
  end;

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

type
  TFrameClass = class of TFrame;

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
  function _SetOrientation(const AClass: TFrameClass): Pointer;
  begin
    Result := AClass.Create(nil);
  end;
var
  MinClientWidth: Integer;
  MinClientHeight: Integer;
  BoardFrameClass: TFrameClass;
begin
  TimeVoidEdit.OnChange := nil;
  if Assigned(FTimeThread) then
    FTimeThread.OutputControl := nil;

  CloseBoard;

  TState.Board := ABoard;
  TState.Orientation := AOrientation;
  TState.Color := AColor;

  if TState.Orientation = okHorizontal then
  begin
    MinClientWidth := HORIZONTAL_MIN_WIDTH;
    MinClientHeight := HORIZONTAL_MIN_HEIGHT;
    {$IFDEF ANDROID}
    _SetAndroidScreenOrientation(TScreenOrientation.Landscape);
    {$ENDIF}
  end
  else
  if TState.Orientation = okVertical then
  begin
    MinClientWidth := VERTICAL_MIN_WIDTH;
    MinClientHeight := VERTICAL_MIN_HEIGHT;
    {$IFDEF ANDROID}
    _SetAndroidScreenOrientation(TScreenOrientation.Portrait);
    {$ENDIF}
  end
  else
    raise Exception.Create('TMainForm.OpenBoard: Unknown orientation kind');

  if TState.Board = bkElectronic then
  begin
    if TState.Orientation = okHorizontal then
      BoardFrameClass := TElectronicBoardFrame
    else
    if TState.Orientation = okVertical then
      BoardFrameClass := TVerticalElectronicBoardFrame
    else
      raise Exception.Create('TMainForm.OpenBoard: Unknown orientation kind');

    FElectronicBoardFrame := _SetOrientation(BoardFrameClass);

    TProportion.Init(
      TState.Orientation,
      ContentLayout,
      MinClientWidth,
      MinClientHeight,
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

    // Выставлять размеры нужно в конце,
    // иначе уйдет на Resize формы до инициализации табло
    {$IFDEF MSWINDOWS}
    FBorderFrame.MinClientWidth := MinClientWidth;
    FBorderFrame.MinClientHeight := MinClientHeight;
    {$ENDIF}
  end
  else
  if TState.Board = bkText then
  begin
    if TState.Orientation = okHorizontal then
      BoardFrameClass := TTextBoardFrame
    else
    if TState.Orientation = okVertical then
      BoardFrameClass := TVerticalTextBoardFrame
    else
      raise Exception.Create('TMainForm.OpenBoard: Unknown orientation kind');

    FTextBoardFrame := _SetOrientation(BoardFrameClass);

    TProportion.Init(
      TState.Orientation,
      ContentLayout,
      MinClientWidth,
      MinClientHeight,
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

    // Выставлять размеры нужно в конце,
    // иначе уйдет на Resize формы до инициализации табло
    {$IFDEF MSWINDOWS}
    FBorderFrame.MinClientWidth := MinClientWidth;
    FBorderFrame.MinClientHeight := MinClientHeight;
    {$ENDIF}
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
//  TState.LastOrientation := TState.Orientation;
  OpenBoard(bkText, TState.Color, TState.Orientation);
end;

procedure TMainForm.MenuElectronicBoardItemClickHandler(Sender: TObject);
begin
//  TState.LastOrientation := TState.Orientation;
  OpenBoard(bkElectronic, TState.Color, TState.Orientation);
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
  TState.Orientation := okVertical;
  OpenBoard(TState.Board, TState.Color, okVertical);
end;

procedure TMainForm.MenuHorizontalOrientationItemClickHandler(Sender: TObject);
begin
  TState.Orientation := okHorizontal;
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

procedure TMainForm.SetTimerFormCancelButtonClickHandler(Sender: TObject);
begin
  SetTimerForm.Close;
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

end.
