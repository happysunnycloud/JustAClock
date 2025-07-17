unit TimeThreadUnit;

interface

uses
    System.Classes
  , System.SysUtils
  , System.SyncObjs

  , FMX.Controls
  , FMX.FormExtUnit
  , ThreadFactoryUnit
  ;

type
  TTimeKind = (tkTime = 0, tkTimer = 1, tkAlarm = 2);

  TTimeThread = class(TThreadExt)
  strict private
    FCriticalSection: TCriticalSection;
    FForm: TFormExt;
    FOutputControl: TControl;
    FExecProc: TProc;
    FTriggerTime: TTime;

    procedure OnTerminateHandler(Sender: TObject);

    procedure SetOutputControl(const AOutputControl: TControl);
    function GetOutputControl: TControl;

    procedure ExecTime;
    procedure ExecTimer;
    procedure ExecAlarm;

    procedure DisplayTime(const ATimeString: String);
  protected
    // Специально не перегружаем Execute,
    // чтобы выполнился на стороне родительского класса
    // В родителе ловятся исключения
    procedure Execute(const AThread: TThreadExt); reintroduce; // override;
  public
    constructor Create(
      const AThreadFactory: TThreadFactory;
      const ATriggerTime: TTime;
      const ATimeKind: TTimeKind;
      const AForm: TFormExt;
      const AOutputControl: TControl);
    destructor Destroy; override;

    property OutputControl: TControl read GetOutputControl write SetOutputControl;
  end;

implementation

uses
    System.DateUtils
  , FMX.ControlToolsUnit
  , TimeCalcUnit
  , JustAClockUnit
  ;

{ TTimeThread }

procedure TTimeThread.OnTerminateHandler(Sender: TObject);
begin
  OutputControl := nil;
//  FForm.Close;
end;

procedure TTimeThread.SetOutputControl(const AOutputControl: TControl);
begin
  FCriticalSection.Enter;
  try
    FOutputControl := AOutputControl;
  finally
    FCriticalSection.Leave;
  end;
end;

function TTimeThread.GetOutputControl: TControl;
begin
  FCriticalSection.Enter;
  try
    Result := FOutputControl;
  finally
    FCriticalSection.Leave;
  end;
end;

constructor TTimeThread.Create(
  const AThreadFactory: TThreadFactory;
  const ATriggerTime: TTime;
  const ATimeKind: TTimeKind;
  const AForm: TFormExt;
  const AOutputControl: TControl);
begin
  if not TControlTools.HasProperty(AOutputControl, 'Text') then
    raise Exception.Create('Output control does not have a "text" property');

  FCriticalSection := TCriticalSection.Create;

  FForm := AForm;
  FOutputControl := AOutputControl;

  FTriggerTime := ATriggerTime;

  FExecProc := ExecTime;
  case ATimeKind of
    tkTimer:
    begin
      FExecProc := ExecTimer;
    end;
    tkAlarm:
    begin
      FExecProc := ExecAlarm;
    end;
  end;

  OnTerminate := OnTerminateHandler;

  FreeOnTerminate := true;

  inherited Create(
    AThreadFactory,
    'TTimeThread',
    Self.Execute);
end;

destructor TTimeThread.Destroy;
begin
  if Assigned(FCriticalSection) then
    FreeAndNil(FCriticalSection);

  inherited;
end;

procedure TTimeThread.Execute(const AThread: TThreadExt);
begin
  FExecProc;
end;

procedure TTimeThread.DisplayTime(const ATimeString: String);
var
  TimeString: String absolute ATimeString;
begin
  if Assigned(OutputControl) then
    Synchronize(
      procedure
      begin
        TControlTools.SetTextProperty(OutputControl, TimeString);
      end);
end;

procedure TTimeThread.ExecTime;
var
  TimeString: String;
begin
  while not Terminated do
  begin
    TimeString := FormatDateTime('hh:nn:ss', Now);

    DisplayTime(TimeString);

    Sleep(100);
  end;
end;

procedure TTimeThread.ExecTimer;
var
  TimeString: String;
  CountdownTimeString: String;
  CountdownTime: TTime;
  FinishTimeString: String;
  FinishTime: TTime;
begin
  CountdownTimeString := TimeToStr(FTriggerTime);
  CountdownTime := StrToTime(CountdownTimeString);
  FinishTime := TTimeCalc.CalcTime(Now, CountdownTime, true);
  FinishTimeString := TimeToStr(FinishTime);

  while not Terminated do
  begin
    TimeString := FormatDateTime('hh:nn:ss', TTimeCalc.CalcTime(FinishTime, Now, false));

    DisplayTime(TimeString);

    if TimeString = '00:00:00' then
    begin
      TMainForm(FForm).StartSignal;

      Break;
    end;

    Sleep(100);
  end;

  while not Terminated do
  begin
    Sleep(1000);
  end;
end;

procedure TTimeThread.ExecAlarm;
var
  TimeString: String;
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
  FullTriggerTime: TDateTime;
begin
  DecodeDate(Now, Year, Month, Day);
  DecodeTime(FTriggerTime, Hour, Min, Sec, MSec);
  FullTriggerTime := EncodeDateTime(Year, Month, Day, Hour, Min, Sec, MSec);

  while not Terminated do
  begin
    TimeString := FormatDateTime('hh:nn:ss', Now);
    DisplayTime(TimeString);

    if Now >= FullTriggerTime then
    begin
      TMainForm(FForm).StartSignal;

      Break;
    end;

    Sleep(100);
  end;
end;

end.
