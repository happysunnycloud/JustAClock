unit JustAClockUnit;
{ 85 * 230 }
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  BorderFrameUnit, FMX.Layouts,
  FMX.Craft.PopupMenu.Win,
  TimeThreadUnit,
  ElectronicBoardFrameUnit, FMX.Menus,
  FMX.FormExtUnit,
  CommonUnit, FMX.Controls.Presentation, FMX.Edit,
  TextBoardFrameUnit
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
    FTextBoardFrame: TTextBoardFrame;
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

    procedure ResizeVerticalBoardFrame(
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
    { Private declarations }
    procedure OpenElectronicBoard(
      const ABoard: TBoardKind;
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
  , ShowTextTimeUnit
  , ThreadFactoryUnit
  , NumScrollUnit
  , SetTimerFormUnit
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

  OpenElectronicBoard(bkText, TState.ColorIdent, TState.Orientation);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TShowTextTime.UnInit;

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
  W0: Single;
  W1: Single;
  H0: Single;
  H1: Single;
begin
  if Assigned(FTextBoardFrame) then
  begin
    if FTextBoardFrame is TVerticalTextBoardFrame then
    begin
      ResizeVerticalBoardFrame(
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

//      FTextBoardFrame.TextTimeLayout.Align  := TAlignLayout.None;
//      FTextBoardFrame.TextTimeLayout.Height := Self.Height * 0.75;
//      FTextBoardFrame.TextTimeLayout.Width  := Self.Width * 0.65;
//      FTextBoardFrame.TextTimeLayout.Align  := TAlignLayout.Center;
//
//      W0 := FTextBoardFrame.TextTimeLayout.Width / 2;
//      H0 := FTextBoardFrame.TextTimeLayout.Height / 4;
//      H1 := FTextBoardFrame.TextTimeLayout.Height / 8;
//
//      FTextBoardFrame.TextHoursLayout.Align         := TAlignLayout.None;
//      FTextBoardFrame.TextHoursDelimLayout.Align    := TAlignLayout.None;
//      FTextBoardFrame.TextMinutesLayout.Align       := TAlignLayout.None;
//      FTextBoardFrame.TextSecondsDelimLayout.Align  := TAlignLayout.None;
//      FTextBoardFrame.TextSecondsLayout.Align       := TAlignLayout.None;
//
//      FTextBoardFrame.TextHoursLayout.Height        := H0;
//      FTextBoardFrame.TextHoursDelimLayout.Height   := H1;
//      FTextBoardFrame.TextMinutesLayout.Height      := H0;
//      FTextBoardFrame.TextSecondsDelimLayout.Height := H1;
//      FTextBoardFrame.TextSecondsLayout.Height      := H0;
//
//      FTextBoardFrame.HHText.Width     := W0;
//      FTextBoardFrame.HLText.Width     := W0;
//      FTextBoardFrame.HDelimText.Width := W0;
//      FTextBoardFrame.MHText.Width     := W0;
//      FTextBoardFrame.MLText.Width     := W0;
//      FTextBoardFrame.SDelimText.Width := W0;
//      FTextBoardFrame.SHText.Width     := W0;
//      FTextBoardFrame.SLText.Width     := W0;
//
//      FTextBoardFrame.TextSecondsLayout.Align       := TAlignLayout.Bottom;
//      FTextBoardFrame.TextSecondsDelimLayout.Align  := TAlignLayout.Bottom;
//      FTextBoardFrame.TextMinutesLayout.Align       := TAlignLayout.Bottom;
//      FTextBoardFrame.TextHoursDelimLayout.Align    := TAlignLayout.Bottom;
//      FTextBoardFrame.TextHoursLayout.Align         := TAlignLayout.Bottom;
//
//      FTextBoardFrame.TextHoursLayout.Align         := TAlignLayout.Top;
//      FTextBoardFrame.TextHoursDelimLayout.Align    := TAlignLayout.Top;
//      FTextBoardFrame.TextMinutesLayout.Align       := TAlignLayout.Top;
//      FTextBoardFrame.TextSecondsDelimLayout.Align  := TAlignLayout.Top;
//      FTextBoardFrame.TextSecondsLayout.Align       := TAlignLayout.Bottom;
    end
    else
    if FTextBoardFrame is TTextBoardFrame then
    begin
      FTextBoardFrame.TextTimeLayout.Align  := TAlignLayout.None;
      FTextBoardFrame.TextTimeLayout.Height := Self.Height * 0.6;
      FTextBoardFrame.TextTimeLayout.Width  := Self.Width * 0.85;
      FTextBoardFrame.TextTimeLayout.Align  := TAlignLayout.Center;

      FTextBoardFrame.TextHoursLayout.Align := TAlignLayout.Right;
      FTextBoardFrame.TextHoursDelimLayout.Align := TAlignLayout.Right;
      FTextBoardFrame.TextMinutesLayout.Align := TAlignLayout.Right;
      FTextBoardFrame.TextSecondsDelimLayout.Align := TAlignLayout.Right;
      FTextBoardFrame.TextSecondsLayout.Align := TAlignLayout.Right;

      W0 := FTextBoardFrame.TextTimeLayout.Width / 3.5;
      W1 := FTextBoardFrame.TextTimeLayout.Width / 14;
      _HorizontalAlign(FTextBoardFrame.TextHoursLayout, W0);
      _HorizontalAlign(FTextBoardFrame.HHText, W0 / 2);
      _HorizontalAlign(FTextBoardFrame.HLText, W0 / 2);
      _HorizontalAlign(FTextBoardFrame.TextHoursDelimLayout , W1);
      _HorizontalAlign(FTextBoardFrame.HDelimText, W1);
      _HorizontalAlign(FTextBoardFrame.TextMinutesLayout, W0);
      _HorizontalAlign(FTextBoardFrame.MHText, W0 / 2);
      _HorizontalAlign(FTextBoardFrame.MLText, W0 / 2);
      _HorizontalAlign(FTextBoardFrame.TextSecondsDelimLayout, W1);
      _HorizontalAlign(FTextBoardFrame.SDelimText, W1);
      _HorizontalAlign(FTextBoardFrame.TextSecondsLayout, W0);
      _HorizontalAlign(FTextBoardFrame.SHText, W0 / 2);
      _HorizontalAlign(FTextBoardFrame.SLText, W0 / 2);

      FTextBoardFrame.TextHoursLayout.Align := TAlignLayout.Left;
      FTextBoardFrame.TextHoursDelimLayout.Align := TAlignLayout.Left;
      FTextBoardFrame.TextMinutesLayout.Align := TAlignLayout.Left;
      FTextBoardFrame.TextSecondsDelimLayout.Align := TAlignLayout.Left;
      FTextBoardFrame.TextSecondsLayout.Align := TAlignLayout.Left;
    end;
  end
  else
  if Assigned(FElectronicBoardFrame) then
  begin
    if FElectronicBoardFrame is TVerticalElectronicBoardFrame then
    begin
      FElectronicBoardFrame.DigitsLayout.Align  := TAlignLayout.None;
      FElectronicBoardFrame.DigitsLayout.Height := Self.Height * 0.75;
      FElectronicBoardFrame.DigitsLayout.Width  := Self.Width * 0.65;
      FElectronicBoardFrame.DigitsLayout.Align  := TAlignLayout.Center;

      W0  := FElectronicBoardFrame.DigitsLayout.Width / 2;
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

      FElectronicBoardFrame.HHImage.Width     := W0;
      FElectronicBoardFrame.HLImage.Width     := W0;
      FElectronicBoardFrame.HDelimImage.Width := W0;
      FElectronicBoardFrame.MHImage.Width     := W0;
      FElectronicBoardFrame.MLImage.Width     := W0;
      FElectronicBoardFrame.SDelimImage.Width := W0;
      FElectronicBoardFrame.SHImage.Width     := W0;
      FElectronicBoardFrame.SLImage.Width     := W0;

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

      W0 := FElectronicBoardFrame.DigitsLayout.Width / 8;
      _HorizontalAlign(FElectronicBoardFrame.HoursLayout, W0 * 2);
      _HorizontalAlign(FElectronicBoardFrame.HHImage, W0);
      _HorizontalAlign(FElectronicBoardFrame.HLImage, W0);
      _HorizontalAlign(FElectronicBoardFrame.HoursDelimLayout , W0);
      _HorizontalAlign(FElectronicBoardFrame.HDelimImage, W0);
      _HorizontalAlign(FElectronicBoardFrame.MinutesLayout, W0 * 2);
      _HorizontalAlign(FElectronicBoardFrame.MHImage, W0);
      _HorizontalAlign(FElectronicBoardFrame.MLImage, W0);
      _HorizontalAlign(FElectronicBoardFrame.SecondsDelimLayout, W0);
      _HorizontalAlign(FElectronicBoardFrame.SDelimImage, W0);
      _HorizontalAlign(FElectronicBoardFrame.SecondsLayout, W0 * 2);
      _HorizontalAlign(FElectronicBoardFrame.SHImage, W0);
      _HorizontalAlign(FElectronicBoardFrame.SLImage, W0);
    end;
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
  if TState.Board = bkText then
    TShowTextTime.ShowTextTime(Time)
  else
    TShowTime.ShowTime(Time);
end;

procedure TMainForm.OpenElectronicBoard(
  const ABoard: TBoardKind;
  const AColorIdent: String;
  const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
begin
  TimeVoidEdit.OnChange := nil;
  if Assigned(FTimeThread) then
    FTimeThread.OutputControl := nil;

  CloseElectronicBoard;

  TState.Board := ABoard;
  TState.ColorIdent := AColorIdent;
  TState.Orientation := AOrientation;

  if TState.Board = bkElectronic then
  begin
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

    FElectronicBoardFrame.Parent := TimeLayout;
    FElectronicBoardFrame.Align := TAlignLayout.Contents;
    FElectronicBoardFrame.HitTest := false;
  end
  else
  if TState.Board = bkText then
  begin
    if TState.Orientation = okHorizontal then
    begin
      FBorderFrame.MinWidth := HORIZONTAL_MIN_WIDTH;
      FBorderFrame.MinHeight := HORIZONTAL_MIN_HEIGHT;

      FTextBoardFrame := TTextBoardFrame.Create(nil);
    end
    else
    if TState.Orientation = okVertical then
    begin
      FBorderFrame.MinWidth := VERTICAL_MIN_WIDTH;
      FBorderFrame.MinHeight := VERTICAL_MIN_HEIGHT;

      FTextBoardFrame := TVerticalTextBoardFrame.Create(nil);
    end;

    TShowTextTime.Init(
      TState.ColorIdent,
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

procedure TMainForm.CloseElectronicBoard;
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
  MenuItem: TMenuItem;
begin
  MenuItem := TMenuItem(Sender);
  OpenElectronicBoard(bkElectronic, FElectronicBoardColorArray[MenuItem.Tag], TState.Orientation);
end;

procedure TMainForm.MenuStandardItemClickHandler(Sender: TObject);
begin
  OpenElectronicBoard(bkText, TState.ColorIdent, TState.Orientation);
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
  OpenElectronicBoard(TState.Board, TState.ColorIdent, okVertical);
end;

procedure TMainForm.MenuHorizontalOrientationItemClickHandler(Sender: TObject);
begin
  OpenElectronicBoard(TState.Board, TState.ColorIdent, okHorizontal);
end;

procedure TMainForm.RunTime;
var
  OutputControl: TControl;
begin
  OutputControl := TimeVoidEdit;
//  if Assigned(FElectronicBoardFrame) then
//    OutputControl := FElectronicBoardFrame.TimeVoidEdit;

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
  OutputControl := TimeVoidEdit; //TimeText;
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

procedure TMainForm.ResizeVerticalBoardFrame(
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
  ADigitsLayout.Height := Self.Height * 0.85;
  ADigitsLayout.Width  := Self.Width * 0.6;
  ADigitsLayout.Align  := TAlignLayout.Center;

  W0 := ADigitsLayout.Width / 2;
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

//  AHHControl.Align         := TAlignLayout.None;
//  AHLControl.Align         := TAlignLayout.None;
//  AHDelimControl.Align     := TAlignLayout.None;
//  AMHControl.Align         := TAlignLayout.None;
//  AMLControl.Align         := TAlignLayout.None;
//  ASDelimControl.Align     := TAlignLayout.None;
//  ASHControl.Align         := TAlignLayout.None;
//  ASLControl.Align         := TAlignLayout.None;

  AHHControl.Width     := W0;
  AHLControl.Width     := W0;
  AHDelimControl.Width := W0;
  AMHControl.Width     := W0;
  AMLControl.Width     := W0;
  ASDelimControl.Width := W0;
  ASHControl.Width     := W0;
  ASLControl.Width     := W0;

//  AHHControl.Align         := TAlignLayout.Right;
//  AHLControl.Align         := TAlignLayout.Right;
//  AHDelimControl.Align     := TAlignLayout.Right;
//  AMHControl.Align         := TAlignLayout.Right;
//  AMLControl.Align         := TAlignLayout.Right;
//  ASDelimControl.Align     := TAlignLayout.Right;
//  ASHControl.Align         := TAlignLayout.Right;
//  ASLControl.Align         := TAlignLayout.Right;
//
//  AHHControl.Align         := TAlignLayout.Left;
//  AHLControl.Align         := TAlignLayout.Left;
//  AHDelimControl.Align     := TAlignLayout.Left;
//  AMHControl.Align         := TAlignLayout.Left;
//  AMLControl.Align         := TAlignLayout.Left;
//  ASDelimControl.Align     := TAlignLayout.Left;
//  ASHControl.Align         := TAlignLayout.Left;
//  ASLControl.Align         := TAlignLayout.Left;
end;

end.
