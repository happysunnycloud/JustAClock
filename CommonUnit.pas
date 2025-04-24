unit CommonUnit;

interface

const
  VERTICAL_ORIENTATION_IDENT = 'Vertical';
  HORIZONTAL_ORIENTATION_IDENT = 'Horizontal';

type
  TOrientationKind = (okHorizontal = 0, okVertical = 1);
  TBoardKind = (bkText = 0, bkElectronic = 1);

  TState = class
  strict private
    class var
      FColorIdent: String;
      FOrientation: TOrientationKind;
      FBoard: TBoardKind;
  public
    class property ColorIdent: String read FColorIdent write FColorIdent;
    class property Orientation: TOrientationKind read FOrientation write FOrientation;
    class property Board: TBoardKind read FBoard write FBoard;
  end;

implementation

end.
