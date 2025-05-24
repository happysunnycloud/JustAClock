unit NumScrollUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Gestures;

type
  TNumScrollFrame = class(TFrame)
    NumsLayout: TLayout;
    TopNumText: TText;
    BottomNumText: TText;
    CurrentNumText: TText;
    BackgroundRectangle: TRectangle;
    Line1: TLine;
    Line2: TLine;
    GestureManager: TGestureManager;
  private
    FMinVal: Integer;
    FMaxVal: Integer;
    FStepVal: Integer;
    FCurrentVal: Integer;
    FDimention: Integer;

    function AlignNum(const AVal: Integer): String;
    procedure SetCurrentVal(const ACurrentVal: Integer);
    function GetCurrentValStr: String;
    procedure SetCurrentValStr(const ACurrentValStr: String);

    function ShiftVal(const AStepVal: Integer; const ADirection: Boolean): Integer;

    procedure OnMouseWheelHandler(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure OnTopNumClickHandler(Sender: TObject);
    procedure OnButtonNumClickHandler(Sender: TObject);
    procedure OnGestureHandler(
      Sender: TObject;
      const EventInfo: TGestureEventInfo;
      var Handled: Boolean);

//    property MinVal: Integer read FMinVal write FMinVal;
//    property MaxVal: Integer read FMaxVal write SetMaxVal;
  public
    procedure AfterConstruction; override;

    property CurrentVal: Integer read FCurrentVal write SetCurrentVal;
    property CurrentValStr: String read GetCurrentValStr write SetCurrentValStr;

    procedure Init(
      const AMinVal: Integer;
      const AMaxVal: Integer;
      const AStepVal: Integer);

    function IncVal: Integer;
    function DecVal: Integer;
  end;

implementation

{$R *.fmx}

procedure TNumScrollFrame.AfterConstruction;
begin
  TopNumText.OnMouseWheel := OnMouseWheelHandler;
  BottomNumText.OnMouseWheel := OnMouseWheelHandler;
  CurrentNumText.OnMouseWheel := OnMouseWheelHandler;

  TopNumText.OnClick := OnTopNumClickHandler;
  BottomNumText.OnClick := OnButtonNumClickHandler;

  NumsLayout.OnGesture := OnGestureHandler;
//  CurrentNumText.OnGesture := OnGestureHandler;
end;

function TNumScrollFrame.AlignNum(const AVal: Integer): String;
var
  i: Byte;
  ValLength: Word;
begin
  Result := '';

  ValLength := AVal.ToString.Length;
  if ValLength < FDimention then
  begin
    for i := 0 to Pred(FDimention - ValLength) do
      Result := '0' + Result;
  end;

  Result := Result + AVal.ToString;
end;

procedure TNumScrollFrame.SetCurrentVal(const ACurrentVal: Integer);
begin
  if (ACurrentVal > FMaxVal) or (ACurrentVal < FMinVal) then
    raise Exception.Create('Out of range');

  FCurrentVal := ACurrentVal;

  TopNumText.Text := AlignNum(ShiftVal(FStepVal, false));
  BottomNumText.Text := AlignNum(ShiftVal(FStepVal, true));
  CurrentNumText.Text := AlignNum(FCurrentVal);
end;

function TNumScrollFrame.GetCurrentValStr: String;
begin
  Result := AlignNum(CurrentVal);
end;

procedure TNumScrollFrame.SetCurrentValStr(const ACurrentValStr: String);
begin
  try
    CurrentVal := ACurrentValStr.ToInteger;
  except
    raise;
  end;
end;

procedure TNumScrollFrame.Init(
  const AMinVal: Integer;
  const AMaxVal: Integer;
  const AStepVal: Integer);
begin
  FMinVal := AMinVal;
  FMaxVal := AMaxVal;
  FStepVal := AStepVal;

  FDimention := FMaxVal.ToString.Length;
end;

function TNumScrollFrame.ShiftVal(
  const AStepVal: Integer;
  const ADirection: Boolean): Integer;
var
  NumVal: Integer;
begin
  if ADirection then
  begin
    NumVal := FCurrentVal + AStepVal;
    if NumVal > FMaxVal then
      NumVal := FMinVal + (NumVal - FMaxVal) - 1;
  end
  else
  begin
    NumVal := FCurrentVal - AStepVal;
    if NumVal < FMinVal then
      NumVal := (FMaxVal + 1) - (NumVal * -1);
  end;

  Result := NumVal;
end;

function TNumScrollFrame.IncVal: Integer;
begin
  Result := ShiftVal(FStepVal, true);
  SetCurrentVal(Result);
end;

function TNumScrollFrame.DecVal: Integer;
begin
  Result := ShiftVal(FStepVal, false);
  SetCurrentVal(Result);
end;

procedure TNumScrollFrame.OnMouseWheelHandler(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
  if WheelDelta < 0 then
    IncVal
  else
  if WheelDelta > 0 then
    DecVal;
end;

procedure TNumScrollFrame.OnTopNumClickHandler(Sender: TObject);
begin
  DecVal;
end;

procedure TNumScrollFrame.OnButtonNumClickHandler(Sender: TObject);
begin
  IncVal;
end;

procedure TNumScrollFrame.OnGestureHandler(
  Sender: TObject;
  const EventInfo: TGestureEventInfo;
  var Handled: Boolean);
var
  Ident: String;
begin
  GestureToIdent(EventInfo.GestureID, Ident);

  if Ident = 'sgiUp' then
    IncVal
  else
  if Ident = 'sgiDown' then
    DecVal;
end;

end.

