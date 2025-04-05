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
  TTimeKind = (tkTime = 0 , tkTimer = 1);

  TTimeThread = class(TThreadExt)
  strict private
    FCriticalSection: TCriticalSection;
    FForm: TFormExt;
    FOutputControl: TControl;
    FExecProc: TProc;
    FTimerTime: TTime;

    procedure OnTerminateHandler(Sender: TObject);

    procedure SetOutputControl(const AOutputControl: TControl);
    function GetOutputControl: TControl;

    procedure ExecTime;
    procedure ExecTimer;
  protected
    // Специально не перегружаем Execute,
    // чтобы выполнился на стороне родительского класса
    // В родителе лювятся исключения
    procedure Execute(const AThread: TThreadExt); reintroduce; // override;
  public
    constructor Create(
      const ARegProc: TRegProc;
      const AUnRegProc: TUnRegProc;
      const ATimerTime: TTime;
      const ATimeKind: TTimeKind;
      const AForm: TFormExt;
      const AOutputControl: TControl);
    destructor Destroy; override;

    property OutputControl: TControl read GetOutputControl write SetOutputControl;
  end;

implementation

uses
    FMX.ControlToolsUnit
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
  const ARegProc: TRegProc;
  const AUnRegProc: TUnRegProc;
  const ATimerTime: TTime;
  const ATimeKind: TTimeKind;
  const AForm: TFormExt;
  const AOutputControl: TControl);
begin
  if not TControlTools.HasProperty(AOutputControl, 'Text') then
    raise Exception.Create('Output control does not have a "text" property');

  FCriticalSection := TCriticalSection.Create;

  FForm := AForm;
  FOutputControl := AOutputControl;

  FExecProc := ExecTime;
  if ATimeKind = tkTimer then
    FExecProc := ExecTimer;

  FTimerTime := ATimerTime;

  OnTerminate := OnTerminateHandler;

  FreeOnTerminate := true;

  inherited Create(
    'TTimeThread',
    ARegProc,
    AUnRegProc,
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

procedure TTimeThread.ExecTime;
var
  TimeString: String;
begin
  while not Terminated do
  begin
    TimeString := TimeToStr(TTime(Now));
    if Assigned(OutputControl) then
      Synchronize(
        procedure
        begin
          TControlTools.SetTextProperty(OutputControl, TimeString);
        end);

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
  CountdownTimeString := TimeToStr(FTimerTime);
  CountdownTime := StrToTime(CountdownTimeString);
  FinishTime := TTimeCalc.CalcTime(Now, CountdownTime, true);
  FinishTimeString := TimeToStr(FinishTime);

  while not Terminated do
  begin
    TimeString := FormatDateTime('hh:nn:ss', TTimeCalc.CalcTime(FinishTime, Now, false));
    if Assigned(OutputControl) then
      Synchronize(
        procedure
        begin
          TControlTools.SetTextProperty(OutputControl, TimeString);
        end);

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

end.
