unit MotionSensorDataThreadUnit;

interface

uses
    System.SyncObjs
  , System.Sensors
  , ThreadFactoryUnit
  , FMX.FormExtUnit
  ;

const
  FACTORY_NAME = 'TMotionSensorDataThread';

type
  TDetectOrientationProc = reference to procedure;

  TMotionSensorDataThread = class(TThreadExt)
  strict private
//    FCriticalSection: TCriticalSection;
    class var
      FForm: TFormExt;

    FVerticalDetectedProc: TDetectOrientationProc;
    FHorizontalDetectedProc: TDetectOrientationProc;
    FSensor: TCustomMotionSensor;

  protected
    // —пециально не перегружаем Execute,
    // чтобы выполнилс€ на стороне родительского класса
    // ¬ родителе лов€тс€ исключени€
    procedure Execute(const AThread: TThreadExt); reintroduce; // override;
  public
    constructor Create(
      const AThreadFactory: TThreadFactory;
      const AThreadName: String;
      const ASensor: TCustomMotionSensor;
      const AVerticalDetectedProc: TDetectOrientationProc;
      const AHorizontalDetectedProc: TDetectOrientationProc);
    destructor Destroy; override;

    class procedure Init(
      const AForm: TFormExt;
      const AVerticalDetectedProc: TDetectOrientationProc;
      const AHorizontalDetectedProc: TDetectOrientationProc);
    class procedure UnInit;
  end;

implementation

uses
    System.SysUtils
  , System.Math
  ;

constructor TMotionSensorDataThread.Create(
  const AThreadFactory: TThreadFactory;
  const AThreadName: String;
  const ASensor: TCustomMotionSensor;
  const AVerticalDetectedProc: TDetectOrientationProc;
  const AHorizontalDetectedProc: TDetectOrientationProc);
begin
//  FCriticalSection := TCriticalSection.Create;

  FSensor := ASensor;

  FVerticalDetectedProc := AVerticalDetectedProc;
  FHorizontalDetectedProc := AHorizontalDetectedProc;

  FreeOnTerminate := true;

  inherited Create(
    AThreadFactory,
    AThreadName,
    Self.Execute);
end;

destructor TMotionSensorDataThread.Destroy;
begin
//  if Assigned(FCriticalSection) then
//    FreeAndNil(FCriticalSection);

  inherited;
end;

class procedure TMotionSensorDataThread.Init(
  const AForm: TFormExt;
  const AVerticalDetectedProc: TDetectOrientationProc;
  const AHorizontalDetectedProc: TDetectOrientationProc);

  function _HasSensorProperty(
    const ASensor: TCustomMotionSensor;
    const AProperty: TCustomMotionSensor.TProperty): Boolean;
  var
    SensorProperty: TCustomMotionSensor.TProperty;
  begin
    Result := false;

    for SensorProperty in ASensor.AvailableProperties do
    begin
      if SensorProperty = AProperty then
        Exit(true);
    end;
  end;

var
  SensorManager: TSensorManager;
  Sensors: TSensorArray;
  Sensor: TCustomMotionSensor;
  HasProperties: Boolean;
begin
  FForm := AForm;

  SensorManager := TSensorManager.Current;
  SensorManager.Activate;

  Sensors := TSensorManager.Current.GetSensorsByCategory(TSensorCategory.Motion);
  if Length(Sensors) = 0 then
    Exit;

  Sensor := TCustomMotionSensor(Sensors[0]);

  HasProperties :=
    _HasSensorProperty(Sensor, TCustomMotionSensor.TProperty.AccelerationX) and
    _HasSensorProperty(Sensor, TCustomMotionSensor.TProperty.AccelerationY) and
    _HasSensorProperty(Sensor, TCustomMotionSensor.TProperty.AccelerationX);

  if not HasProperties then
    Exit;

  FForm.ThreadFactory.CreateRegistredThread(
    procedure (
      const AThreadFactory: TThreadFactory)
    begin
      TMotionSensorDataThread.Create(
        AThreadFactory,
        FACTORY_NAME,
        Sensor,
        AVerticalDetectedProc,
        AHorizontalDetectedProc);
    end);
end;

class procedure TMotionSensorDataThread.UnInit;
var
  ThreadExt: TThreadExt;
begin
  ThreadExt := FForm.ThreadFactory.GetThreadByName(FACTORY_NAME);
  if Assigned(ThreadExt) then
    ThreadExt.Terminate;
end;

procedure TMotionSensorDataThread.Execute(const AThread: TThreadExt);
var
  AccelerationX: Double;
  AccelerationY: Double;
begin
  FSensor.Start;

  while not Terminated do
  begin
    AccelerationX := FSensor.AccelerationX;
    AccelerationY := FSensor.AccelerationY;

    if (Abs(RoundTo(AccelerationX, -2)) > 0.5) and
       (Abs(RoundTo(AccelerationY, -2)) < 0.5)
    then
      TThreadExt.Queue(nil,
        procedure
        begin
          FHorizontalDetectedProc;
        end)
    else
      TThreadExt.Queue(nil,
        procedure
        begin
          FVerticalDetectedProc;
        end);

    Sleep(1000);
  end;

  FSensor.Stop;
end;

end.
