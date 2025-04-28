unit SetTimerFormUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, NumScrollUnit,
  BorderFrameUnit, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects, FMX.Effects, FMX.FormExtUnit;

type
  TSetTimerForm = class(TFormExt)
    HoursNumScrollFrame: TNumScrollFrame;
    loContent: TLayout;
    MinutesNumScrollFrame: TNumScrollFrame;
    OkButtonRectangle: TRectangle;
    Text1: TText;
    TopLayout: TLayout;
    Text2: TText;
    Text3: TText;
    procedure FormCreate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OkButtonRectangleMouseEnter(Sender: TObject);
    procedure OkButtonRectangleMouseLeave(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FBorderFrame: TBorderFrame;
  public
    function GetTime: TTime;
  end;

var
  SetTimerForm: TSetTimerForm;

implementation

{$R *.fmx}

procedure TSetTimerForm.OkButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSetTimerForm.OkButtonRectangleMouseEnter(Sender: TObject);
begin
  OkButtonRectangle.Fill.Color := $FF4F4F4F;
end;

procedure TSetTimerForm.OkButtonRectangleMouseLeave(Sender: TObject);
begin
  OkButtonRectangle.Fill.Color := $00000000;
end;

procedure TSetTimerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TSetTimerForm.FormCreate(Sender: TObject);
begin
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

  HoursNumScrollFrame.Init(0, 23, 1);
  HoursNumScrollFrame.CurrentVal := 0;
  MinutesNumScrollFrame.Init(0, 59, 1);
  MinutesNumScrollFrame.CurrentVal := 0;
end;

procedure TSetTimerForm.FormDestroy(Sender: TObject);
begin
  SetTimerForm := nil;
end;

function TSetTimerForm.GetTime: TTime;
begin
  Result :=
    EncodeTime(
      HoursNumScrollFrame.CurrentVal,
      MinutesNumScrollFrame.CurrentVal,
      0,
      0);
end;

end.
