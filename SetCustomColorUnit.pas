unit SetCustomColorUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Colors,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.FormExtUnit
//  {$IFDEF MSWINDOWS}
//  , BorderFrameUnit
//  {$ENDIF}
  ;

type
  TSetCustomColorForm = class(TFormExt)
    SampleImage: TImage;
    loContent: TLayout;
    OkButtonRectangle: TRectangle;
    OkButtonText: TText;
    ColorQuad: TColorQuad;
    ColorPicker: TColorPicker;
    ColorBox: TColorBox;
    ColorsLayout: TLayout;
    ButtonsLayout: TLayout;
    CancelButtonRectangle: TRectangle;
    CancelButtonText: TText;
    procedure OkButtonRectangleMouseEnter(Sender: TObject);
    procedure OkButtonRectangleMouseLeave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ColorQuadChange(Sender: TObject);
  private
    procedure OnRectangleMouseEnterHandler(Sender: TObject);
    procedure OnRectangleMouseLeaveHandler(Sender: TObject);

    procedure SetColor(const AColor: TAlphaColor);
    function GetColor: TAlphaColor;
  public
//    {$IFDEF MSWINDOWS}
//    FBorderFrame: TBorderFrame;
//    {$ENDIF}
    property Color: TAlphaColor read GetColor write SetColor;
  end;

var
  SetCustomColorForm: TSetCustomColorForm;

implementation

{$R *.fmx}

uses
    System.UIConsts
  , FMX.ImageToolsUnit
  ;

procedure TSetCustomColorForm.OnRectangleMouseEnterHandler(Sender: TObject);
begin
  TRectangle(Sender).Fill.Color := $FF4F4F4F;
end;

procedure TSetCustomColorForm.OnRectangleMouseLeaveHandler(Sender: TObject);
begin
  TRectangle(Sender).Fill.Color := $00000000;
end;

procedure TSetCustomColorForm.ColorQuadChange(Sender: TObject);
begin
  TImageTools.ReplaceNotNullColor(
    SampleImage.Bitmap,
    ColorBox.Color);
end;

procedure TSetCustomColorForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TSetCustomColorForm.FormCreate(Sender: TObject);
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
  {$ENDIF}


  OkButtonRectangle.OnMouseEnter := OnRectangleMouseEnterHandler;
  OkButtonRectangle.OnMouseLeave := OnRectangleMouseLeaveHandler;

  CancelButtonRectangle.OnMouseEnter := OnRectangleMouseEnterHandler;
  CancelButtonRectangle.OnMouseLeave := OnRectangleMouseLeaveHandler;
end;

procedure TSetCustomColorForm.FormDestroy(Sender: TObject);
begin
  SetCustomColorForm := nil;
end;

procedure TSetCustomColorForm.OkButtonRectangleMouseEnter(Sender: TObject);
begin
  OkButtonRectangle.Fill.Color := $FF4F4F4F;
end;

procedure TSetCustomColorForm.OkButtonRectangleMouseLeave(Sender: TObject);
begin
  OkButtonRectangle.Fill.Color := $00000000;
end;

procedure TSetCustomColorForm.SetColor(const AColor: TAlphaColor);
var
  Lum, Sat, Hue: Single;
begin
  RGBtoHSL(AColor, Hue, Sat, Lum);

  ColorPicker.Hue := Hue;

  ColorQuad.Lum := Lum;
  ColorQuad.Sat := Sat;
  ColorQuad.Hue := Hue;

  Self.ColorQuadChange(nil);
end;

function TSetCustomColorForm.GetColor: TAlphaColor;
begin
  Result := ColorBox.Color;
end;

end.
