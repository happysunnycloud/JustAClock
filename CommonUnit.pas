unit CommonUnit;

interface

const
  VERTICAL_ORIENTATION_IDENT = 'Vertical';
  HORIZONTAL_ORIENTATION_IDENT = 'Horizontal';

  VERTICAL_MIN_WIDTH = 120;
  VERTICAL_MIN_HEIGHT = 320;

  HORIZONTAL_MIN_WIDTH = 300;
  HORIZONTAL_MIN_HEIGHT = 120;
type
  TOrientationKind = (okHorizontal = 0, okVertical = 1);
  TBoardKind = (bkText = 0, bkElectronic = 1);

  TState = class
  strict private
    class var
      FColorIdent: String;
      FOrientation: TOrientationKind;
      FBoard: TBoardKind;
    class procedure SetBoard(const ABoard: TBoardKind); static;
  public
    class property ColorIdent: String read FColorIdent write FColorIdent;
    class property Orientation: TOrientationKind read FOrientation write FOrientation;
    class property Board: TBoardKind read FBoard write SetBoard;
  end;

implementation

class procedure TState.SetBoard(const ABoard: TBoardKind);
begin
  FBoard := ABoard;
end;

end.
