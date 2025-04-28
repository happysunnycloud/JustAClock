unit CommonUnit;

interface

uses
  System.UITypes;

const
  VERTICAL_ORIENTATION_IDENT = 'Vertical';
  HORIZONTAL_ORIENTATION_IDENT = 'Horizontal';

  VERTICAL_MIN_WIDTH = 120;
  VERTICAL_MIN_HEIGHT = 320;

  HORIZONTAL_MIN_WIDTH = 300;
  HORIZONTAL_MIN_HEIGHT = 120;

  CHROMAKEY_COLOR_IDENT = 'Green';

type
  TOrientationKind = (okHorizontal = 0, okVertical = 1);
  TBoardKind = (bkText = 0, bkElectronic = 1);

  TState = class
  strict private
    class var
      FColorIdent: String;
      FColor: TAlphaColor;
      FOrientation: TOrientationKind;
      FBoard: TBoardKind;
    class procedure SetBoard(const ABoard: TBoardKind); static;
  public
    class property ColorIdent: String read FColorIdent write FColorIdent;
    class property Color: TAlphaColor read FColor write FColor;
    class property Orientation: TOrientationKind read FOrientation write FOrientation;
    class property Board: TBoardKind read FBoard write SetBoard;
  end;

function ColorByIdent(const AColorIdent: String): TAlphaColor;

implementation

function ColorByIdent(const AColorIdent: String): TAlphaColor;
var
  Color: TAlphaColor;
begin
  Color := $FB00FF1C;
  if AColorIdent = 'Green' then
    Color := $FB00FF1C
  else
  if AColorIdent = 'Red' then
    Color := $FFCE0000
  else
  if AColorIdent = 'Orange' then
    Color := $FBFF8C00
  else
  if AColorIdent = 'White' then
    Color := $FFFFFFFF
  else
  if AColorIdent = 'Blue' then
    Color := $FF00A7FF
  else
  if AColorIdent = 'Violet' then
    Color := $FF8600FF;

  Result := Color;
end;

class procedure TState.SetBoard(const ABoard: TBoardKind);
begin
  FBoard := ABoard;
end;

initialization
  TState.ColorIdent := 'Red';

finalization
  TState.ColorIdent := 'Blue';

end.
