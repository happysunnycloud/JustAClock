unit CommonUnit;

interface

uses
    System.UITypes
  , System.Classes
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

  RING_NAME_OFF = 'Off';

  {$IFDEF ANDROID}
  PATH_DELIMITER = '/';
  {$ELSE IF MSWINDOWS}
  PATH_DELIMITER = '\';
  {$ENDIF}

type
  TBoardKind = (bkText = 0, bkElectronic = 1, bkImage = 2);
  TOrientationKind = (okNone = -1, okHorizontal = 0, okVertical = 1);
  TPCKFileKind = (pkNone = -1, pkPattern = 0, pkImage = 1);

  TPCKFileKindHelper = record helper for TPCKFileKind
  public
    function ToString: String;
    function ToPath: String;
  end;

  TState = class
  strict private
    class var
      FColorIdent: String;
      FColor: TAlphaColor;
      FImageName: String;
      FCustomColor0: TAlphaColor;
      FCustomColor1: TAlphaColor;
      FCustomColor2: TAlphaColor;
      FCustomColor3: TAlphaColor;
      FCustomColorNumber: Integer;
      FOrientation: TOrientationKind;
      FBoard: TBoardKind;
      FAutoOrientation: Boolean;
      FRingName: String;
      FVibration: Boolean;
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
    class property ImageName: String read FImageName write FImageName;
    class property CustomColor0: TAlphaColor read FCustomColor0 write SetCustomColor0;
    class property CustomColor1: TAlphaColor read FCustomColor1 write SetCustomColor1;
    class property CustomColor2: TAlphaColor read FCustomColor2 write SetCustomColor2;
    class property CustomColor3: TAlphaColor read FCustomColor3 write SetCustomColor3;
    class property CustomColorNumber: Integer read FCustomColorNumber write SetCustomColorNumber;
    class property Orientation: TOrientationKind read FOrientation write FOrientation;
    class property RingName: String read FRingName write FRingName;
    class property Vibration: Boolean read FVibration write FVibration;
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

  TColorArray = TArray<String>;
  TColorArrayHelper = record helper for TColorArray
  public
    function FirstValue: String;
    function LastValue: String;
    function NextValue(const ACurrentValue: String): String;
  end;

  TColorRec = record
    Ident: String;
    Value: TAlphaColor;
  end;

  TColors = class
  strict private
    class var FGreen: TColorRec;
    class var FYellow: TColorRec;
    class var FRed: TColorRec;
    class var FOrange: TColorRec;
    class var FWhite: TColorRec;
    class var FPink: TColorRec;
    class var FBlue: TColorRec;
    class var FViolet: TColorRec;

    class var FColorArray: TColorArray;
  public
    class property Green: TColorRec read FGreen write FGreen;
    class property Yellow: TColorRec read FYellow write FYellow;
    class property Red: TColorRec read FRed write FRed;
    class property Orange: TColorRec read FOrange write FOrange;
    class property White: TColorRec read FWhite write FWhite;
    class property Pink: TColorRec read FPink write FPink;
    class property Blue: TColorRec read FBlue write FBlue;
    class property Violet: TColorRec read FViolet write FViolet;

    class property ColorArray: TColorArray
      read FColorArray;

    class function ColorByIdent(const AColorIdent: String): TAlphaColor;

    class procedure Init;
  end;

function CustomColorByNumber(const AColorNumber: Byte): TAlphaColor;
function GetPackFile(
  const AFileKind: TPCKFileKind;
  const AImagePackName: String): String;
function GetDigitsPackFile: String; deprecated;
function GetPatternsPackFile(const AImagePackName: String): String;
function GetImagesPackFile(const AImagePackName: String): String;
function GetNameFromFileName(const AImageFileName: String): String;
procedure GetPackFileList(
  const AFileKind: TPCKFileKind;
  const AImagesPackFileList: TStringList);
procedure GetPatternsPackFileList(const AImagesPackFileList: TStringList);
procedure GetImagesPackFileList(const AImagesPackFileList: TStringList);
function GetRingFile(const ARingName: String): String;
function GetRingsFilesPath: String;
procedure GetRingFileList(const ARingFileList: TStringList);
procedure GetCurPos(var X, Y: Single);

implementation

uses
    System.SysUtils
  , FileStreamToolsUnit
  {$IFDEF ANDROID}
  , System.IOUtils
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  , Winapi.Windows
  {$ENDIF}
  , FileToolsUnit
  ;

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

function GetPackFile(
  const AFileKind: TPCKFileKind;
  const AImagePackName: String): String;
begin
  Result := Format('%s%s.pck', [AFileKind.ToPath, AImagePackName]);
end;

function GetDigitsPackFile: String;
begin
  Result := GetPackFile(pkPattern, 'Digits');
end;

function GetPatternsPackFile(const AImagePackName: String): String;
begin
  Result := GetPackFile(pkPattern, AImagePackName);
end;

function GetImagesPackFile(const AImagePackName: String): String;
begin
  Result := GetPackFile(pkImage, AImagePackName);
end;

procedure GetPackFileList(
  const AFileKind: TPCKFileKind;
  const AImagesPackFileList: TStringList);
var
  Path: String;
begin
  if not Assigned(AImagesPackFileList) then
    raise Exception.Create('AImagesPackFileList is nil');

  Path := AFileKind.ToPath;

  if not DirectoryExists(Path) then
    raise Exception.CreateFmt('Directory "%s" not exists', [Path]);

  TFileTools.GetFileNameListByDirAndExt(Path, 'pck', AImagesPackFileList);
end;

procedure GetPatternsPackFileList(const AImagesPackFileList: TStringList);
begin
  GetPackFileList(pkPattern, AImagesPackFileList);
end;

procedure GetImagesPackFileList(const AImagesPackFileList: TStringList);
begin
  GetPackFileList(pkImage, AImagesPackFileList);
end;

function GetRingFile(const ARingName: String): String;
begin
  Result := Format('%s%s%s.%s', [GetRingsFilesPath, PATH_DELIMITER, ARingName, 'mp3']);
end;

function GetRingsFilesPath: String;
var
  RootName: String;
begin
  RootName := 'Rings';
  //Format('%s%s', ['Rings', '']);//, PATH_SPLITTER]);
  {$IFDEF ANDROID}
  Result :=
    Format('%s/%s', [System.IOUtils.TPath.GetDocumentsPath, RootName]);
  {$ELSE IF MSWINDOWS}
    {$IFDEF DEBUG}
    Result := Format('..\..\Arts\%s', [RootName]);
    {$ELSE}
    Result := Format('%s', [RootName]);
    {$ENDIF}
  {$ENDIF}
end;

procedure GetRingFileList(const ARingFileList: TStringList);
var
  Path: String;
begin
  if not Assigned(ARingFileList) then
    raise Exception.Create('ARingFileList is nil');

  Path := GetRingsFilesPath;

  if not DirectoryExists(Path) then
    raise Exception.CreateFmt('Directory "%s" not exists', [Path]);

  TFileTools.GetFileNameListByDirAndExt(Path, 'mp3', ARingFileList);
end;

function GetNameFromFileName(const AImageFileName: String): String;
var
  FileName: String;
  FileExtention: String;
begin
  FileExtention := ExtractFileExt(AImageFileName);
  FileName :=
    StringReplace(
      ExtractFileName(AImageFileName),
      FileExtention,
      '',
      [rfReplaceAll, rfIgnoreCase]);

  Result := FileName;
end;

//function GetRingFromFileName(const ARingFileName: String): String;
//var
//  FileName: String;
//  FileExtention: String;
//begin
//  FileExtention := ExtractFileExt(ARingFileName);
//  FileName :=
//    StringReplace(
//      ExtractFileName(ARingFileName),
//      FileExtention,
//      '',
//      [rfReplaceAll, rfIgnoreCase]);
//
//  Result := FileName;
//end;

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

{ TPCKFileKindHelper }

function TPCKFileKindHelper.ToString: String;
begin
  Result := '';

  case Self of
    pkPattern: Result := 'Pattern';
    pkImage: Result := 'Image';
  end;
end;

function TPCKFileKindHelper.ToPath: String;
var
  RootName: String;
begin
  RootName := Format('%s%s%s%s', ['PCKs', PATH_SPLITTER, Self.ToString, 's']);
  {$IFDEF ANDROID}
  Result :=
    Format('%s/%s/', [System.IOUtils.TPath.GetDocumentsPath, RootName]);
  {$ELSE IF MSWINDOWS}
    {$IFDEF DEBUG}
    Result := Format('..\..\Arts\%s\', [RootName]);
    {$ELSE}
    Result := Format('%s\', [RootName]);
    {$ENDIF}
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
    FileStreamTools.Write(FImageName);
    FileStreamTools.Write(FCustomColor0);
    FileStreamTools.Write(FCustomColor1);
    FileStreamTools.Write(FCustomColor2);
    FileStreamTools.Write(FCustomColor3);
    FileStreamTools.Write(FCustomColorNumber);
    FileStreamTools.Write(FAutoOrientation);
    FileStreamTools.Write(FRingName);
    FileStreamTools.Write(FVibration);
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
    FImageName          := FileStreamTools.ReadAsString;
    FCustomColor0       := FileStreamTools.ReadAsUInt32;
    FCustomColor1       := FileStreamTools.ReadAsUInt32;
    FCustomColor2       := FileStreamTools.ReadAsUInt32;
    FCustomColor3       := FileStreamTools.ReadAsUInt32;
    FCustomColorNumber  := FileStreamTools.ReadAsInteger;
    FAutoOrientation    := FileStreamTools.ReadAsBoolean;
    FRingName           := FileStreamTools.ReadAsString;
    FVibration          := FileStreamTools.ReadAsBoolean;
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
  FColor              := TColors.ColorByIdent(FColorIdent);
  FImageName          := 'Electronic';
  FCustomColor0       := FColor;
  FCustomColor1       := FColor;
  FCustomColor2       := FColor;
  FCustomColor3       := FColor;
  FCustomColorNumber  := -1;
  FBoard              := TBoardKind.bkElectronic;
  FRingName           := RING_NAME_OFF;
  FFormLeft           := 100;
  FFormTop            := 100;
  FFormWidth          := HORIZONTAL_MIN_WIDTH;
  FFormHeight         := HORIZONTAL_MIN_HEIGHT;
  {$IFDEF MSWINDOWS}
  FVibration          := false;
  FAutoOrientation    := false;
  FOrientation        := TOrientationKind.okNone;
  {$ELSE IFDEF ANDROID}
  FVibration          := true;
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

{ TColorArrayHelper }

function TColorArrayHelper.FirstValue: String;
begin
  Result := Self[0];
end;

function TColorArrayHelper.LastValue: String;
begin
  Result := Self[High(Self)];
end;

function TColorArrayHelper.NextValue(
  const ACurrentValue: String): String;
var
  Index: Integer;
  HighIndex: Integer;
begin
  HighIndex := High(Self);
  for Index := 0 to HighIndex do
    if Self[Index] = ACurrentValue then
      Break;

  if Index = HighIndex then
    Index := 0
  else
    Inc(Index);

  Result := Self[Index];
end;

{ TColors }

class procedure TColors.Init;
begin
  FGreen.Ident := 'Green';
  FGreen.Value := $FB00FF1C;

  FYellow.Ident := 'Yellow';
  FYellow.Value := $FFFFFF35;

  FRed.Ident := 'Red';
  FRed.Value := $FFCE0000;

  FOrange.Ident := 'Orange';
  FOrange.Value := $FBFF8C00;

  FWhite.Ident := 'White';
  FWhite.Value := $FFFFFFFF;

  FPink.Ident := 'Pink';
  FPink.Value := $FFFF75E2;

  FBlue.Ident := 'Blue';
  FBlue.Value := $FF00A7FF;

  FViolet.Ident := 'Violet';
  FViolet.Value := $FF8600FF;

  FColorArray :=
    TColorArray.Create(
      Green.Ident,
      Yellow.Ident,
      Red.Ident,
      Orange.Ident,
      White.Ident,
      Pink.Ident,
      Blue.Ident,
      Violet.Ident);
end;

class function TColors.ColorByIdent(const AColorIdent: String): TAlphaColor;
var
  Color: TAlphaColor;
begin
  Color := FGreen.Value;

  if AColorIdent = FGreen.Ident then
    Color := FGreen.Value
  else
  if AColorIdent = FYellow.Ident then
    Color := FYellow.Value
  else
  if AColorIdent = FRed.Ident then
    Color := FRed.Value
  else
  if AColorIdent = FOrange.Ident then
    Color := FOrange.Value
  else
  if AColorIdent = FWhite.Ident then
    Color := FWhite.Value
  else
  if AColorIdent = FPink.Ident then
    Color := FPink.Value
  else
  if AColorIdent = FBlue.Ident then
    Color := FBlue.Value
  else
  if AColorIdent = FViolet.Ident then
    Color := FViolet.Value;

  Result := Color;
end;

initialization
  TColors.Init;
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
