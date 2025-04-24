unit JustAClockUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  BorderFrameUnit, FMX.Layouts,
  FMX.Craft.PopupMenu.Win,
  TimeThreadUnit,
  ElectronicBoardFrameUnit, FMX.Menus,
  FMX.FormExtUnit,
  CommonUnit
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure loContentMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormResize(Sender: TObject);
  strict private
    FBorderFrame: TBorderFrame;
    FTrayPopupMenu: TCraftPopupMenu;
    FTimeThread: TTimeThread;

    FElectronicBoardFrame: TElectronicBoardFrame;
    FCurrentElectronicBoardColor: String;
    FElectronicBoardColorArray: TElectronicBoardColorArray;

    procedure TrayIconMouseRightButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TrayIconMouseLeftButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

    procedure OnCloseTrayItemHandler;

    procedure MenuColorItemClickHandler(Sender: TObject);
    procedure MenuStandardItemClickHandler(Sender: TObject);
    procedure MenuCountDownItemClickHandler(Sender: TObject);
    procedure MenuCancelTimerItemClickHandler(Sender: TObject);

    procedure MenuHorizontalOrientationItemClickHandler(Sender: TObject);
    procedure MenuVerticalOrientationItemClickHandler(Sender: TObject);

    procedure SetTimerFormOkButtonClickHandler(Sender: TObject);

    procedure TimeVoidEditOnChangeHandler(Sender: TObject);

    procedure RunTime;
    procedure RunTimer(const ATimerTime: TTime);
  private
    { Private declarations }
    procedure OpenElectronicBoard(
      const AColorIdent: String;
      const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
    procedure CloseElectronicBoard;
  public
    procedure StartSignal;
    procedure StopSignal;

    property BorderFrame: TBorderFrame read FBorderFrame;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
    Winapi.Windows
  , FMX.Platform.Win
  , FMX.Craft.PopupMenu.Structures
  , FMX.Craft.PopupMenu.Thread.Win
  , ShowTimeUnit
  , FMX.Edit
  , ThreadFactoryUnit
  , NumScrollUnit
  , SetTimerFormUnit
  , VerticalElectronicBoardFrameUnit
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

procedure TMainForm.OnCloseTrayItemHandler;
begin
  if Assigned(MainForm) then
    MainForm.BorderFrame.CloseButtonRectangle.
      OnClick(MainForm.BorderFrame.CloseButtonRectangle);
end;

procedure TMainForm.TrayIconMouseRightButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MousePoint: TPoint;
begin
  GetCursorPos(MousePoint);
  if FTrayPopupMenu <> nil then
    FTrayPopupMenu.Open(MousePoint.X, MousePoint.Y);
end;

procedure TMainForm.TrayIconMouseLeftButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ShowWindow(ApplicationHWND, SW_HIDE);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FTimeThread := nil;
end;

procedure TMainForm.FormCreate(Sender: TObject);
const
  SCALE_VALUE = 1;
var
  MenuItem: TMenuItem;
  Orientation: TMenuItem;
  Colors: TMenuItem;
  ColorIdent: String;
  Boards: TMenuItem;
  i: Integer;
begin
  ReportMemoryLeaksOnShutdown := true;

  TState.Orientation := okHorizontal;
  TState.Board := bkText;

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

  Boards := TMenuItem.Create(SettingsPopupMenu);
  Boards.Text := 'Boards';
  SettingsPopupMenu.AddObject(Boards);

  MenuItem := TMenuItem.Create(Boards);
  MenuItem.Text := 'Text';
  MenuItem.OnClick := MenuStandardItemClickHandler;
  Boards.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(Boards);
  MenuItem.Text := 'Electronic';
  MenuItem.OnClick := MenuColorItemClickHandler;
  Boards.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(SettingsPopupMenu);
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  SettingsPopupMenu.AddObject(MenuItem);

  Colors := TMenuItem.Create(SettingsPopupMenu);
  Colors.Text := 'Colors';
  SettingsPopupMenu.AddObject(Colors);
  for i := 0 to Pred(Length(FElectronicBoardColorArray)) do
  begin
    ColorIdent := FElectronicBoardColorArray[i];
    MenuItem := TMenuItem.Create(Colors);
    MenuItem.Text := ColorIdent;
    MenuItem.Tag := i;
    MenuItem.OnClick := MenuColorItemClickHandler;
    Colors.AddObject(MenuItem);
  end;
  MenuItem := TMenuItem.Create(SettingsPopupMenu);
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  SettingsPopupMenu.AddObject(MenuItem);

  Orientation := TMenuItem.Create(SettingsPopupMenu);
  Orientation.Text := 'Orientation';
  SettingsPopupMenu.AddObject(Orientation);

  MenuItem := TMenuItem.Create(Orientation);
  MenuItem.Text := 'Horizontal';
  MenuItem.Tag := 0;
  MenuItem.OnClick := MenuHorizontalOrientationItemClickHandler;
  Orientation.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(Orientation);
  MenuItem.Text := 'Vertical';
  MenuItem.Tag := 0;
  MenuItem.OnClick := MenuVerticalOrientationItemClickHandler;
  Orientation.AddObject(MenuItem);

  { ToolsPopupMenu }

  MenuItem := TMenuItem.Create(ToolsPopupMenu);
  MenuItem.Text := 'Set timer';
  MenuItem.OnClick := MenuCountDownItemClickHandler;
  ToolsPopupMenu.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(ToolsPopupMenu);
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  ToolsPopupMenu.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(ToolsPopupMenu);
  MenuItem.Text := 'Cancel';
  MenuItem.OnClick := MenuCancelTimerItemClickHandler;
  ToolsPopupMenu.AddObject(MenuItem);

  FCurrentElectronicBoardColor := FElectronicBoardColorArray.LastValue;

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

  FTrayPopupMenu := TCraftPopupMenu.Create('>>', 1000);
  FTrayPopupMenu.MenuItems.AddItem('Close', 'Close', true, OnCloseTrayItemHandler);
  FTrayPopupMenu.BuildMenu;

  FElectronicBoardFrame := nil;

  RunTime;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FTrayPopupMenu) then
    FTrayPopupMenu.Free;

  CloseElectronicBoard;
end;

procedure TMainForm.FormResize(Sender: TObject);
  procedure _HorizontalAlign(const AControl: TControl; const AWidth: Single);
  begin
    AControl.Width := AWidth;
    AControl.Align := TAlignLayout.Left;
  end;
var
  W: Single;
  H0: Single;
  H1: Single;
begin
  if not Assigned(FElectronicBoardFrame) then
    Exit;

  if FElectronicBoardFrame is TVerticalElectronicBoardFrame then
  begin
    FElectronicBoardFrame.DigitsLayout.Align  := TAlignLayout.None;
    FElectronicBoardFrame.DigitsLayout.Height := Self.Height * 0.75;
    FElectronicBoardFrame.DigitsLayout.Width  := Self.Width * 0.65;
    FElectronicBoardFrame.DigitsLayout.Align  := TAlignLayout.Center;

    W  := FElectronicBoardFrame.DigitsLayout.Width / 2;
    H0 := FElectronicBoardFrame.DigitsLayout.Height / 4;
    H1 := FElectronicBoardFrame.DigitsLayout.Height / 8;

    FElectronicBoardFrame.HoursLayout.Align         := TAlignLayout.None;
    FElectronicBoardFrame.HoursDelimLayout.Align    := TAlignLayout.None;
    FElectronicBoardFrame.MinutesLayout.Align       := TAlignLayout.None;
    FElectronicBoardFrame.SecondsDelimLayout.Align  := TAlignLayout.None;
    FElectronicBoardFrame.SecondsLayout.Align       := TAlignLayout.None;

    FElectronicBoardFrame.HoursLayout.Height        := H0;
    FElectronicBoardFrame.HoursDelimLayout.Height   := H1;
    FElectronicBoardFrame.MinutesLayout.Height      := H0;
    FElectronicBoardFrame.SecondsDelimLayout.Height := H1;
    FElectronicBoardFrame.SecondsLayout.Height      := H0;

    FElectronicBoardFrame.HHImage.Width     := W;
    FElectronicBoardFrame.HLImage.Width     := W;
    FElectronicBoardFrame.HDelimImage.Width := W;
    FElectronicBoardFrame.MHImage.Width     := W;
    FElectronicBoardFrame.MLImage.Width     := W;
    FElectronicBoardFrame.SDelimImage.Width := W;
    FElectronicBoardFrame.SHImage.Width     := W;
    FElectronicBoardFrame.SLImage.Width     := W;

    FElectronicBoardFrame.SecondsLayout.Align       := TAlignLayout.Bottom;
    FElectronicBoardFrame.SecondsDelimLayout.Align  := TAlignLayout.Bottom;
    FElectronicBoardFrame.MinutesLayout.Align       := TAlignLayout.Bottom;
    FElectronicBoardFrame.HoursDelimLayout.Align    := TAlignLayout.Bottom;
    FElectronicBoardFrame.HoursLayout.Align         := TAlignLayout.Bottom;

    FElectronicBoardFrame.HoursLayout.Align         := TAlignLayout.Top;
    FElectronicBoardFrame.HoursDelimLayout.Align    := TAlignLayout.Top;
    FElectronicBoardFrame.MinutesLayout.Align       := TAlignLayout.Top;
    FElectronicBoardFrame.SecondsDelimLayout.Align  := TAlignLayout.Top;
    FElectronicBoardFrame.SecondsLayout.Align       := TAlignLayout.Bottom;
  end
  else
  if FElectronicBoardFrame is TElectronicBoardFrame then
  begin
    FElectronicBoardFrame.DigitsLayout.Align  := TAlignLayout.None;
    FElectronicBoardFrame.DigitsLayout.Height := Self.Height * 0.45;
    FElectronicBoardFrame.DigitsLayout.Width  := Self.Width * 0.85;
    FElectronicBoardFrame.DigitsLayout.Align  := TAlignLayout.Center;

    W := FElectronicBoardFrame.DigitsLayout.Width / 8;
    _HorizontalAlign(FElectronicBoardFrame.HoursLayout, W * 2);
    _HorizontalAlign(FElectronicBoardFrame.HHImage, W);
    _HorizontalAlign(FElectronicBoardFrame.HLImage, W);
    _HorizontalAlign(FElectronicBoardFrame.HoursDelimLayout , W);
    _HorizontalAlign(FElectronicBoardFrame.HDelimImage, W);
    _HorizontalAlign(FElectronicBoardFrame.MinutesLayout, W * 2);
    _HorizontalAlign(FElectronicBoardFrame.MHImage, W);
    _HorizontalAlign(FElectronicBoardFrame.MLImage, W);
    _HorizontalAlign(FElectronicBoardFrame.SecondsDelimLayout, W);
    _HorizontalAlign(FElectronicBoardFrame.SDelimImage, W);
    _HorizontalAlign(FElectronicBoardFrame.SecondsLayout, W * 2);
    _HorizontalAlign(FElectronicBoardFrame.SHImage, W);
    _HorizontalAlign(FElectronicBoardFrame.SLImage, W);
  end;
end;

procedure TMainForm.loContentMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  MousePoint: TPoint;
begin
  GetCursorPos(MousePoint);
  if Button = TMouseButton.mbLeft then
  begin
    SettingsPopupMenu.Popup(MousePoint.X, MousePoint.Y);
  end
  else
  if Button = TMouseButton.mbRight then
  begin
    ToolsPopupMenu.Popup(MousePoint.X, MousePoint.Y);
  end;
end;

procedure TMainForm.TimeVoidEditOnChangeHandler(Sender: TObject);
var
  Time: String;
begin
  Time := Trim(TEdit(Sender).Text);
  TShowTime.ShowTime(Time);
end;

procedure TMainForm.OpenElectronicBoard(
  const AColorIdent: String;
  const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
begin
  if Assigned(FElectronicBoardFrame) then
    CloseElectronicBoard;

  TState.ColorIdent := AColorIdent;

  TState.Orientation := AOrientation;
  if TState.Orientation = okHorizontal then
  begin
    FBorderFrame.MinWidth := HORIZONTAL_MIN_WIDTH;
    FBorderFrame.MinHeight := HORIZONTAL_MIN_HEIGHT;

    FElectronicBoardFrame := TElectronicBoardFrame.Create(nil);
  end
  else
  if TState.Orientation = okVertical then
  begin
    FBorderFrame.MinWidth := VERTICAL_MIN_WIDTH;
    FBorderFrame.MinHeight := VERTICAL_MIN_HEIGHT;

    FElectronicBoardFrame := TVerticalElectronicBoardFrame.Create(nil);
  end;

  TShowTime.Init(
    {$IFDEF DEBUG}
    '..\..\Arts\Digits.pck',
    {$ELSE}
    'Digits.pck',
    {$ENDIF}
    TState.ColorIdent,
    FElectronicBoardFrame.HHImage,
    FElectronicBoardFrame.HLImage,
    FElectronicBoardFrame.HDelimImage,
    FElectronicBoardFrame.MHImage,
    FElectronicBoardFrame.MLImage,
    FElectronicBoardFrame.SDelimImage,
    FElectronicBoardFrame.SHImage,
    FElectronicBoardFrame.SLImage,
    AOrientation);

  FElectronicBoardFrame.Parent := TimeText;
  FElectronicBoardFrame.HitTest := false;
  FTimeThread.OutputControl := FElectronicBoardFrame.TimeVoidEdit;
  FElectronicBoardFrame.TimeVoidEdit.OnChange := TimeVoidEditOnChangeHandler;

  loContent.BringToFront;
  Self.Resize;
end;

procedure TMainForm.CloseElectronicBoard;
begin
  if Assigned(FTimeThread) then
    FTimeThread.OutputControl := TimeText;
  TShowTime.UnInit;
  if Assigned(FElectronicBoardFrame) then
    FreeAndNil(FElectronicBoardFrame);
end;

procedure TMainForm.MenuColorItemClickHandler(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := TMenuItem(Sender);
  OpenElectronicBoard(FElectronicBoardColorArray[MenuItem.Tag], TState.Orientation);
end;

procedure TMainForm.MenuStandardItemClickHandler(Sender: TObject);
begin
  CloseElectronicBoard;
end;

procedure TMainForm.MenuCountDownItemClickHandler(Sender: TObject);
begin
  StopSignal;

  SetTimerForm := TSetTimerForm.Create(Self);
  SetTimerForm.OkButton.OnClick := SetTimerFormOkButtonClickHandler;
  SetTimerForm.ShowModal;
end;

procedure TMainForm.MenuCancelTimerItemClickHandler(Sender: TObject);
begin
  StopSignal;

  RunTime;
end;

procedure TMainForm.MenuVerticalOrientationItemClickHandler(Sender: TObject);
begin
  OpenElectronicBoard(TState.ColorIdent , okVertical);
end;

procedure TMainForm.MenuHorizontalOrientationItemClickHandler(Sender: TObject);
begin
  OpenElectronicBoard(TState.ColorIdent, okHorizontal);
end;

procedure TMainForm.RunTime;
var
  OutputControl: TControl;
begin
  OutputControl := TimeText;
  if Assigned(FElectronicBoardFrame) then
    OutputControl := FElectronicBoardFrame.TimeVoidEdit;

  if Assigned(FTimeThread) then
    FTimeThread.Terminate;

  ThreadFactory.CreateRegistredThread(
    procedure (
      const AThreadFactory: TThreadFactory)
    begin
      FTimeThread :=
        TTimeThread.Create(
          AThreadFactory,
          StrToTime('00:00'),
          TTimeKind.tkTime,
          Self,
          OutputControl);
    end);
end;

procedure TMainForm.RunTimer(const ATimerTime: TTime);
var
  OutputControl: TControl;
begin
  OutputControl := TimeText;
  if Assigned(FElectronicBoardFrame) then
    OutputControl := FElectronicBoardFrame.TimeVoidEdit;

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
      while not AThread.Terminated do
      begin
        TThread.ForceQueue(nil,
          procedure
          begin
            SignalRectangle.Visible := true;
            //ShowWindow(ApplicationHwnd, SW_SHOW);
            Self.Show;
            //SetForegroundWindow(ApplicationHwnd);
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

end.
