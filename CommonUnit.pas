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

  {$IFDEF ANDROID}
  PATH_DELIMITER = '/';
  {$ELSE IF MSWINDOWS}
  PATH_DELIMITER = '\';
  {$ENDIF}

type
  TBoardKind = (bkText = 0, bkElectronic = 1);
  TOrientationKind = (okHorizontal = 0, okVertical = 1);

  TState = class
  strict private
    class var
      FColorIdent: String;
      FColor: TAlphaColor;
      FCustomColor0: TAlphaColor;
      FCustomColor1: TAlphaColor;
      FCustomColor2: TAlphaColor;
      FCustomColor3: TAlphaColor;
      FOrientation: TOrientationKind;
      FBoard: TBoardKind;
    class procedure SetBoard(const ABoard: TBoardKind); static;
    class function GetConfigFileName: String; static;

    class property ConfigFileName: String read GetConfigFileName;
  public
    class property ColorIdent: String read FColorIdent write FColorIdent;
    class property Color: TAlphaColor read FColor write FColor;
    class property CustomColor0: TAlphaColor read FCustomColor0 write FCustomColor0;
    class property CustomColor1: TAlphaColor read FCustomColor1 write FCustomColor1;
    class property CustomColor2: TAlphaColor read FCustomColor2 write FCustomColor2;
    class property CustomColor3: TAlphaColor read FCustomColor3 write FCustomColor3;
    class property Orientation: TOrientationKind read FOrientation write FOrientation;
    class property Board: TBoardKind read FBoard write SetBoard;

    class procedure Init;
    class procedure Save;
    class procedure Load;
  end;

function ColorByIdent(const AColorIdent: String): TAlphaColor;
function GetDigitsPackFile: String;
procedure GetCurPos(var X, Y: Single);

implementation

uses
    System.SysUtils
  , System.Classes
  , FileStreamToolsUnit
  {$IFDEF ANDROID}
  , System.IOUtils
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  , Winapi.Windows
  {$ENDIF}
  ;

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

function GetDigitsPackFile: String;
begin
  {$IFDEF ANDROID}
  Result := System.IOUtils.TPath.GetDocumentsPath + PATH_DELIMITER + 'Digits.pck';
  {$ELSE IF MSWINDOWS}
    {$IFDEF DEBUG}
    Result := '..\..\Arts\Digits.pck';
    {$ELSE}
    Result := 'Digits.pck';
    {$ENDIF}
  {$ENDIF}
end;

procedure GetCurPos(var X, Y: Single);
{$IFDEF MSWINDOWS}
var
  MousePoint: TPoint;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  GetCursorPos(MousePoint);
  X := MousePoint.X;
  Y := MousePoint.Y;
  {$ELSE IF ANDROID}
  X := X;
  Y := Y;
  {$ENDIF}
end;

{ TState }

class procedure TState.SetBoard(const ABoard: TBoardKind);
begin
  FBoard := ABoard;
end;

class function TState.GetConfigFileName: String;
begin
  {$IFDEF ANDROID}
  Result := System.IOUtils.TPath.GetDocumentsPath + PATH_DELIMITER + 'Config.jcc';
  {$ELSE IF MSWINDOWS}
  Result := ExtractFilePath(ParamStr(0)) + 'Config.jcc';
  {$ENDIF}
end;

class procedure TState.Save;
var
  FileStreamTools: TFileStreamTools;
  FileName: String;
begin
  FileName := ConfigFileName;

  FileStreamTools := TFileStreamTools.Create(FileName, fmCreate);
  try
    FileStreamTools.Write(FBoard);
    FileStreamTools.Write(FOrientation);
    FileStreamTools.Write(FColor);
    FileStreamTools.Write(FCustomColor0);
    FileStreamTools.Write(FCustomColor1);
    FileStreamTools.Write(FCustomColor2);
    FileStreamTools.Write(FCustomColor3);
  finally
    FreeAndNil(FileStreamTools);
  end;
end;

class procedure TState.Load;
var
  FileStreamTools: TFileStreamTools;
  FileName: String;
begin
  FileName := ConfigFileName;
  if not FileExists(FileName) then
    Exit;

  FileStreamTools := TFileStreamTools.Create(FileName, fmOpenRead);
  try
    FBoard        := TBoardKind(FileStreamTools.ReadAsByte);
    FOrientation  := TOrientationKind(FileStreamTools.ReadAsByte);
    FColor        := FileStreamTools.ReadAsUInt32;
    FCustomColor0 := FileStreamTools.ReadAsUInt32;
    FCustomColor1 := FileStreamTools.ReadAsUInt32;
    FCustomColor2 := FileStreamTools.ReadAsUInt32;
    FCustomColor3 := FileStreamTools.ReadAsUInt32;
  finally
    FreeAndNil(FileStreamTools);
  end;
end;

class procedure TState.Init;
begin
  FColorIdent := CHROMAKEY_COLOR_IDENT;
  FColor := ColorByIdent(FColorIdent);
  FCustomColor0 := FColor;
  FCustomColor1 := FColor;
  FCustomColor2 := FColor;
  FCustomColor3 := FColor;
  FOrientation := TOrientationKind.okHorizontal;
  FBoard := TBoardKind.bkText;
end;

initialization
  TState.Init;
  TState.Load;

finalization
  TState.Save;

end.
