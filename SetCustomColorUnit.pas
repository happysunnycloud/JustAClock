unit SetCustomColorUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Colors,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  BorderFrameUnit;

type
  TSetCustomColorForm = class(TForm)
    ColorPanel: TColorPanel;
    SampleImage: TImage;
    loContent: TLayout;
    OkButtonRectangle: TRectangle;
    Text1: TText;
    procedure OkButtonRectangleMouseEnter(Sender: TObject);
    procedure OkButtonRectangleMouseLeave(Sender: TObject);
    procedure ColorPanelChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure SetColor(const AColor: TAlphaColor);
    function GetColor: TAlphaColor;
  public
    FBorderFrame: TBorderFrame;

    property Color: TAlphaColor read GetColor write SetColor;
  end;

var
  SetCustomColorForm: TSetCustomColorForm;

implementation

{$R *.fmx}

uses
    FMX.ImageToolsUnit
  ;

procedure TSetCustomColorForm.ColorPanelChange(Sender: TObject);
begin
  TImageTools.ReplaceNotNullColor(
    SampleImage.Bitmap,
    ColorPanel.Color);
end;

procedure TSetCustomColorForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TSetCustomColorForm.FormCreate(Sender: TObject);
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
begin
  ColorPanel.Color := AColor;

  Self.ColorPanelChange(nil);
end;

function TSetCustomColorForm.GetColor: TAlphaColor;
begin
  Result := ColorPanel.Color;
end;

end.
