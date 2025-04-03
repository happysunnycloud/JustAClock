unit JustAClockUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  BorderFrameUnit, FMX.Layouts,
  FMX.Craft.PopupMenu.Win,
  TimeThreadUnit,
  ElectronicBoardFrameUnit, FMX.Menus,
  FMX.FormExtUnit
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
    ColorsPopupMenu: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure loContentClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
    procedure MenuTimeItemClickHandler(Sender: TObject);

    procedure TimeVoidEditOnChangeHandler(Sender: TObject);

    procedure RunTime;
    procedure RunTimer;
  private
    { Private declarations }
    procedure OpenElectronicBoard(const AColorIdent: String);
    procedure CloseElectronicBoard;
  public
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
  SCALE_VALUE =1;
var
  MenuItem: TMenuItem;
  ElectronicBoardColorName: String;
  Electronic: TMenuItem;
  i: Integer;
begin
  ReportMemoryLeaksOnShutdown := true;

  FElectronicBoardColorArray := TElectronicBoardColorArray.Create(
    'Green',
    'Red',
    'Orange',
    'White',
    'Blue',
    'Violet');

  Electronic := TMenuItem.Create(ColorsPopupMenu);
  Electronic.Text := 'Electronic';
  ColorsPopupMenu.AddObject(Electronic);

  for i := 0 to Pred(Length(FElectronicBoardColorArray)) do
  begin
    ElectronicBoardColorName := FElectronicBoardColorArray[i];
    MenuItem := TMenuItem.Create(Electronic);
    MenuItem.Text := ElectronicBoardColorName;
    MenuItem.Tag := i;
    MenuItem.OnClick := MenuColorItemClickHandler;
    Electronic.AddObject(MenuItem);
  end;
  MenuItem := TMenuItem.Create(ColorsPopupMenu);
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  ColorsPopupMenu.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(ColorsPopupMenu);
  MenuItem.Text := 'Text';
  MenuItem.OnClick := MenuStandardItemClickHandler;
  ColorsPopupMenu.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(ColorsPopupMenu);
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  ColorsPopupMenu.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(ColorsPopupMenu);
  MenuItem.Text := 'Countdown 30 minutes';
  MenuItem.OnClick := MenuCountDownItemClickHandler;
  ColorsPopupMenu.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(ColorsPopupMenu);
  MenuItem.Text := '-';
  MenuItem.Tag := -1;
  ColorsPopupMenu.AddObject(MenuItem);

  MenuItem := TMenuItem.Create(ColorsPopupMenu);
  MenuItem.Text := 'Time';
  MenuItem.OnClick := MenuTimeItemClickHandler;
  ColorsPopupMenu.AddObject(MenuItem);

  FCurrentElectronicBoardColor := FElectronicBoardColorArray.LastValue;

  ShowWindow(ApplicationHWND, SW_HIDE);

  FBorderFrame :=
    TBorderFrame.Create(
      Self,
      loContent,
      'Just a clock',
      Trunc(loContent.Width),
      Trunc(loContent.Height),
      $FF2A001A,
      $FF2A001A,
      TAlphaColorRec.Lime,
      TAlphaColorRec.Lime);

  FBorderFrame.TrayIconMouseRightButtonDown := TrayIconMouseRightButtonDown;
  FBorderFrame.TrayIconMouseLeftButtonDown := TrayIconMouseLeftButtonDown;

  FTrayPopupMenu := TCraftPopupMenu.Create('>>', 1000);
  FTrayPopupMenu.MenuItems.AddItem('Close', 'Close', true, OnCloseTrayItemHandler);
  FTrayPopupMenu.BuildMenu;

//  FTimeThread := TTimeThread.Create(TTimeKind.tkTime, Self, TimeText);
//  ThreadFactory.RegisterThread(FTimeThread);

  FElectronicBoardFrame := nil;

  RunTime;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FTrayPopupMenu) then
    FTrayPopupMenu.Free;

  CloseElectronicBoard;
end;

procedure TMainForm.loContentClick(Sender: TObject);
var
  MousePoint: TPoint;
begin
  GetCursorPos(MousePoint);
  ColorsPopupMenu.Popup(MousePoint.X, MousePoint.Y);
end;

procedure TMainForm.TimeVoidEditOnChangeHandler(Sender: TObject);
var
  Time: String;
begin
  Time := Trim(TEdit(Sender).Text);
  TShowTime.ShowTime(Time);
end;

procedure TMainForm.OpenElectronicBoard(const AColorIdent: String);
begin
  if Assigned(FElectronicBoardFrame) then
    CloseElectronicBoard;

  FElectronicBoardFrame := TElectronicBoardFrame.Create(nil);
  TShowTime.Init(
    {$IFDEF DEBUG}
    '..\..\Arts\Digits.pck',
    //'..\..\Arts\' + AColorIdent + '.pck',
    {$ELSE}
    'Digits.pck',
    //AColorIdent + '.pck',
    {$ENDIF}
    AColorIdent,
    FElectronicBoardFrame.HHImage,
    FElectronicBoardFrame.HLImage,
    FElectronicBoardFrame.HDelimImage,
    FElectronicBoardFrame.MHImage,
    FElectronicBoardFrame.MLImage,
    FElectronicBoardFrame.SDelimImage,
    FElectronicBoardFrame.SHImage,
    FElectronicBoardFrame.SLImage);

  FElectronicBoardFrame.Parent := TimeText;
  FElectronicBoardFrame.OnClick := loContent.OnClick;
  FTimeThread.OutputControl := FElectronicBoardFrame.TimeVoidEdit;
  FElectronicBoardFrame.TimeVoidEdit.OnChange := TimeVoidEditOnChangeHandler;
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
  OpenElectronicBoard(FElectronicBoardColorArray[MenuItem.Tag]);
end;

procedure TMainForm.MenuStandardItemClickHandler(Sender: TObject);
begin
  CloseElectronicBoard;
end;

procedure TMainForm.MenuCountDownItemClickHandler(Sender: TObject);
begin
  RunTimer;
end;

procedure TMainForm.MenuTimeItemClickHandler(Sender: TObject);
begin
  RunTime;
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
      const ARegProc: TRegProc;
      const AUnRegProc: TUnRegProc)
    begin
      FTimeThread :=
        TTimeThread.Create(ARegProc, AUnRegProc, TTimeKind.tkTime, Self, OutputControl);
    end);
end;

procedure TMainForm.RunTimer;
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
      const ARegProc: TRegProc;
      const AUnRegProc: TUnRegProc)
    begin
      FTimeThread :=
        TTimeThread.Create(ARegProc, AUnRegProc, TTimeKind.tkTimer, Self, OutputControl);
    end);
end;

end.
