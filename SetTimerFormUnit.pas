unit SetTimerFormUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, NumScrollUnit,
//  {$IFDEF MSWINDOWS}
//  BorderFrameUnit,
//  {$ENDIF}
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects, FMX.Effects, FMX.FormExtUnit;

type
  TSetTimerForm = class(TFormExt)
    HoursNumScrollFrame: TNumScrollFrame;
    loContent: TLayout;
    MinutesNumScrollFrame: TNumScrollFrame;
    OkButtonRectangle: TRectangle;
    OkButtonText: TText;
    TopLayout: TLayout;
    HoursText: TText;
    MinutsText: TText;
    CancelButtonRectangle: TRectangle;
    ButtonsLayout: TLayout;
    CancelButtonText: TText;
    ButtonsLine: TLine;
    CenterLayout: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
  private
//    {$IFDEF MSWINDOWS}
//    FBorderFrame: TBorderFrame;
//    {$ENDIF}
    procedure OnRectangleMouseEnterHandler(Sender: TObject);
    procedure OnRectangleMouseLeaveHandler(Sender: TObject);

    function GetTime: TTime;
    procedure SetTime(const ATime: TTime);
  public
    property Time: TTime read GetTime write SetTime;
  end;

var
  SetTimerForm: TSetTimerForm;

implementation

{$R *.fmx}

procedure TSetTimerForm.OnRectangleMouseEnterHandler(Sender: TObject);
begin
  TRectangle(Sender).Fill.Color := $FF4F4F4F;
end;

procedure TSetTimerForm.OnRectangleMouseLeaveHandler(Sender: TObject);
begin
  TRectangle(Sender).Fill.Color := $00000000;
end;

procedure TSetTimerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TSetTimerForm.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
//  FBorderFrame :=
//    TBorderFrame.Create(
//      Self,
//      loContent,
//      'Just a clock',
//      Trunc(loContent.Width),
//      Trunc(loContent.Height),
//      $FF8D003A,
//      $FF2A001A,
//      TAlphaColorRec.Lime,
//      $FFADADAD);

  BorderFrame.BorderFrameKind := TBorderFrameKind.bfkNormal;
  BorderFrame.CaptionColor := $FF8D003A;
  BorderFrame.BorderColor := $FF2A001A;
  BorderFrame.ToolButtonColor := BorderFrame.CaptionColor;
  BorderFrame.ToolButtonMouseOverColor := $FFADADAD;

{
//  ACaptionColor: TAlphaColor = TAlphaColorRec.White;
//  ABorderColor: TAlphaColor = TAlphaColorRec.Cornflowerblue;
//  ACloseButtonColor: TAlphaColor = TAlphaColorRec.White;
//  ACloseButtonMouseOverColor: TAlphaColor = TAlphaColorRec.Lime
}
  {$ENDIF}
  HoursNumScrollFrame.Init(0, 23, 1);
  HoursNumScrollFrame.CurrentVal := 0;
  MinutesNumScrollFrame.Init(0, 59, 1);
  MinutesNumScrollFrame.CurrentVal := 0;

  OkButtonRectangle.OnMouseEnter := OnRectangleMouseEnterHandler;
  OkButtonRectangle.OnMouseLeave := OnRectangleMouseLeaveHandler;

  CancelButtonRectangle.OnMouseEnter := OnRectangleMouseEnterHandler;
  CancelButtonRectangle.OnMouseLeave := OnRectangleMouseLeaveHandler;
end;

procedure TSetTimerForm.FormDestroy(Sender: TObject);
begin
  //asd нужно ли нилить?
//  SetTimerForm := nil;
end;

procedure TSetTimerForm.FormResize(Sender: TObject);
begin
  HoursNumScrollFrame.Width := Self.Width / 2;
  MinutesNumScrollFrame.Width := Self.Width / 2;

  HoursText.Width := Self.Width / 2;
  MinutsText.Width := Self.Width / 2;
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

procedure TSetTimerForm.SetTime(const ATime: TTime);
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(ATime, Hour, Min, Sec, MSec);

  HoursNumScrollFrame.CurrentVal := Hour;
  MinutesNumScrollFrame.CurrentVal := Min;
end;

end.
