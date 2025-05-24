unit CommonUnit;

interface

uses
    System.UITypes
  , FMX.ThemeUnit
  ;

const
  VERTICAL_ORIENTATION_IDENT = 'Vertical';
  HORIZONTAL_ORIENTATION_IDENT = 'Horizontal';

  VERTICAL_MIN_WIDTH = 80;
  VERTICAL_MIN_HEIGHT = 260;

  HORIZONTAL_MIN_WIDTH = 260;
  HORIZONTAL_MIN_HEIGHT = 80;

  CHROMAKEY_COLOR_IDENT = 'Green';
  NO_REPCALE_COLOR = TAlphaColorRec.Null;

  CUSTOM_COLOR_COUNT = 4;

  {$IFDEF ANDROID}
  PATH_DELIMITER = '/';
  {$ELSE IF MSWINDOWS}
  PATH_DELIMITER = '\';
  {$ENDIF}

type
  TBoardKind = (bkText = 0, bkElectronic = 1, bkImage = 2);
  TOrientationKind = (okNone = -1, okHorizontal = 0, okVertical = 1);

  TState = class
  strict private
    class var
      FColorIdent: String;
      FColor: TAlphaColor;
      FCustomColor0: TAlphaColor;
      FCustomColor1: TAlphaColor;
      FCustomColor2: TAlphaColor;
      FCustomColor3: TAlphaColor;
      FCustomColorNumber: Integer;
      FOrientation: TOrientationKind;
      FBoard: TBoardKind;
      FAutoOrientation: Boolean;
      FFormLeft: Integer;
      FFormTop: Integer;
      FFormWidth: Integer;
      FFormHeight: Integer;

      FMenuTheme: TTheme;

    class procedure SetBoard(const ABoard: TBoardKind); static;
    class function GetConfigFileName: String; static;

    class property ConfigFileName: String read GetConfigFileName;
    class procedure SetColor(const AAlphaColor: TAlphaColor); static;
    class procedure SetCustomColorNumber(const ANumber: Integer); static;

    class procedure SetCustomColor0(const AAlphaColor: TAlphaColor); static;
    class procedure SetCustomColor1(const AAlphaColor: TAlphaColor); static;
    class procedure SetCustomColor2(const AAlphaColor: TAlphaColor); static;
    class procedure SetCustomColor3(const AAlphaColor: TAlphaColor); static;
  public
    class constructor Initialize;
    class destructor Finalize;

    class property ColorIdent: String read FColorIdent write FColorIdent;
    class property Color: TAlphaColor read FColor write SetColor;
    class property CustomColor0: TAlphaColor read FCustomColor0 write SetCustomColor0;
    class property CustomColor1: TAlphaColor read FCustomColor1 write SetCustomColor1;
    class property CustomColor2: TAlphaColor read FCustomColor2 write SetCustomColor2;
    class property CustomColor3: TAlphaColor read FCustomColor3 write SetCustomColor3;
    class property CustomColorNumber: Integer read FCustomColorNumber write SetCustomColorNumber;
    class property Orientation: TOrientationKind read FOrientation write FOrientation;
    class property Board: TBoardKind read FBoard write SetBoard;
    class property AutoOrientation: Boolean read FAutoOrientation write FAutoOrientation;
    class property FormLeft: Integer read FFormLeft write FFormLeft;
    class property FormTop: Integer read FFormTop write FFormTop;
    class property FormWidth: Integer read FFormWidth write FFormWidth;
    class property FormHeight: Integer read FFormHeight write FFormHeight;

    class property MenuTheme: TTheme read FMenuTheme write FMenuTheme;

    class procedure Init;
    class procedure Save;
    class procedure Load;
  end;

function ColorByIdent(const AColorIdent: String): TAlphaColor;
function CustomColorByNumber(const AColorNumber: Byte): TAlphaColor;
function GetDigitsPackFile: String;
function GetImagesPackFile(const AImagePackName: String): String;
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

function CustomColorByNumber(const AColorNumber: Byte): TAlphaColor;
var
  CustomColorNumber: Byte;
  Color: TAlphaColor;
begin
  CustomColorNumber := AColorNumber;
  case CustomColorNumber of
    0: Color := TState.CustomColor0;
    1: Color := TState.CustomColor1;
    2: Color := TState.CustomColor2;
    3: Color := TState.CustomColor3;
    else
      raise Exception.Create('CustomColorByNumber: Out of range');
  end;

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

function GetImagesPackFile(const AImagePackName: String): String;
begin
  {$IFDEF ANDROID}
  Result := System.IOUtils.TPath.GetDocumentsPath + PATH_DELIMITER + AImagePackName + '.pck';
  {$ELSE IF MSWINDOWS}
    {$IFDEF DEBUG}
    Result := '..\..\Arts\' + AImagePackName + '.pck';
    {$ELSE}
    Result := AImagePackName + '.pck';
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

class constructor TState.Initialize;
begin
  FMenuTheme := TTheme.Create;
end;

class destructor TState.Finalize;
begin
  FreeAndNil(FMenuTheme);
end;

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
  Orientation: Integer;
begin
  FileName := ConfigFileName;

  Orientation := Integer(FOrientation);

  FileStreamTools := TFileStreamTools.Create(FileName, fmCreate);
  try
    FileStreamTools.Write(FBoard);
    FileStreamTools.Write(Orientation);
    FileStreamTools.Write(FColor);
    FileStreamTools.Write(FCustomColor0);
    FileStreamTools.Write(FCustomColor1);
    FileStreamTools.Write(FCustomColor2);
    FileStreamTools.Write(FCustomColor3);
    FileStreamTools.Write(FCustomColorNumber);
    FileStreamTools.Write(FAutoOrientation);
    FileStreamTools.Write(FFormLeft);
    FileStreamTools.Write(FFormTop);
    FileStreamTools.Write(FFormWidth);
    FileStreamTools.Write(FFormHeight);
  finally
    FreeAndNil(FileStreamTools);
  end;
end;

class procedure TState.Load;
var
  FileStreamTools: TFileStreamTools;
  FileName: String;
  Orientation: Integer;
begin
  FileName := ConfigFileName;
  if not FileExists(FileName) then
    Exit;

  FileStreamTools := TFileStreamTools.Create(FileName, fmOpenRead);
  try
    FBoard              := TBoardKind(FileStreamTools.ReadAsByte);
    Orientation         := FileStreamTools.ReadAsInteger;
    FColor              := FileStreamTools.ReadAsUInt32;
    FCustomColor0       := FileStreamTools.ReadAsUInt32;
    FCustomColor1       := FileStreamTools.ReadAsUInt32;
    FCustomColor2       := FileStreamTools.ReadAsUInt32;
    FCustomColor3       := FileStreamTools.ReadAsUInt32;
    FCustomColorNumber  := FileStreamTools.ReadAsInteger;
    FAutoOrientation    := FileStreamTools.ReadAsBoolean;
    FFormLeft           := FileStreamTools.ReadAsInteger;
    FFormTop            := FileStreamTools.ReadAsInteger;
    FFormWidth          := FileStreamTools.ReadAsInteger;
    FFormHeight         := FileStreamTools.ReadAsInteger;

    FOrientation := TOrientationKind(Orientation);
  finally
    FreeAndNil(FileStreamTools);
  end;
end;

class procedure TState.Init;
begin
  FColorIdent         := CHROMAKEY_COLOR_IDENT;
  FColor              := ColorByIdent(FColorIdent);
  FCustomColor0       := FColor;
  FCustomColor1       := FColor;
  FCustomColor2       := FColor;
  FCustomColor3       := FColor;
  FCustomColorNumber  := -1;
  FBoard              := TBoardKind.bkElectronic;
  FFormLeft           := 100;
  FFormTop            := 100;
  FFormWidth          := HORIZONTAL_MIN_WIDTH;
  FFormHeight         := HORIZONTAL_MIN_HEIGHT;
  {$IFDEF MSWINDOWS}
  FAutoOrientation    := false;
  FOrientation        := TOrientationKind.okNone;
  {$ELSE IFDEF ANDROID}
  FAutoOrientation    := true;
  FOrientation        := TOrientationKind.okNone;
  {$ENDIF}
end;

class procedure TState.SetColor(const AAlphaColor: TAlphaColor);
begin
  FColor := AAlphaColor;
end;

class procedure TState.SetCustomColorNumber(const ANumber: Integer);
begin
  FCustomColorNumber := ANumber;
end;

class procedure TState.SetCustomColor0(const AAlphaColor: TAlphaColor);
begin
  FCustomColor0 := AAlphaColor;
  CustomColorNumber := 0;
end;

class procedure TState.SetCustomColor1(const AAlphaColor: TAlphaColor);
begin
  FCustomColor1 := AAlphaColor;
  CustomColorNumber := 1;
end;

class procedure TState.SetCustomColor2(const AAlphaColor: TAlphaColor);
begin
  FCustomColor2 := AAlphaColor;
  CustomColorNumber := 2;
end;

class procedure TState.SetCustomColor3(const AAlphaColor: TAlphaColor);
begin
  FCustomColor3 := AAlphaColor;
  CustomColorNumber := 3;
end;

initialization
  try
    TState.Init;
    TState.Load;
  except
    RaiseLastOSError;
  end;

finalization
  try
    TState.Save;
  except
    RaiseLastOSError;
  end;

end.
