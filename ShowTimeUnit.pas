unit ShowTimeUnit;

interface

uses
    System.Generics.Collections
  , FMX.Objects
  , FMX.Graphics
  , CommonUnit
  , System.UITypes
  , FMX.MultiResBitmapsUnit
  ;

type
  TBitMapList = TList<TBitmap>;

  TShowTime = class
  strict private
    class var
      FHH: TImage;
      FHL: TImage;
      FHDelim: TImage;
      FMH: TImage;
      FML: TImage;
      FSDelim: TImage;
      FSH: TImage;
      FSL: TImage;
      FBitmapList: TBitMapList;
      FMultiResBitmaps: TMultiResBitmaps;
      FColor: TAlphaColor;
      FOrientation: TOrientationKind;

      FNearestResBitmapList: TResBitmapList;

    class procedure LoadResBitmapListByIdent(
      const AResBitmapList: TResBitmapList;
      const ABitmapList: TBitmapList;
      const AColor: TAlphaColor;
      const AOrientation: TOrientationKind);
  public
    class procedure Init(
      const AImageFileName: String;
      const AImagesRootPath: String;
      const AColor: TAlphaColor;
      const AHH: TImage;
      const AHL: TImage;
      const AHDelim: TImage;
      const AMH: TImage;
      const AML: TImage;
      const ASDelim: TImage;
      const ASH: TImage;
      const ASL: TImage;
      const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
    class procedure UnInit;

    class procedure ShowTime(const ATime: String);
    class procedure CheckBitmapsResolution(
      const AWidth: Single; const AHeight: Single);
  end;

implementation

uses
    System.SysUtils
  , System.Classes
  , FMX.ImageToolsUnit
  , FMX.MultiResBitmapExtractorUnit
  ;

class procedure TShowTime.LoadResBitmapListByIdent(
  const AResBitmapList: TResBitmapList;
  const ABitmapList: TBitmapList;
  const AColor: TAlphaColor;
  const AOrientation: TOrientationKind);

  function _GetBitmapByIdent(
    const AResBitmapList: TResBitmapList;
    const AIdent: String): TBitmap;
  begin
    Result := AResBitmapList.FindBitmapByIden(AIdent);
    if not Assigned(Result) then
      raise Exception.CreateFmt('BitMap with ident = "%s" not found', [AIdent]);
  end;

var
  BitmapIdent: String;
  BitMap: TBitMap;
  OrientationPrefix: String;
  i: Integer;
begin
  OrientationPrefix := '';
  if AOrientation = okVertical then
    OrientationPrefix := VERTICAL_ORIENTATION_IDENT;

  ABitmapList.Clear;

  for i := 0 to 9 do
  begin
    BitmapIdent := i.ToString;

    BitMap := _GetBitmapByIdent(AResBitmapList, BitmapIdent);

    if AColor <> NO_REPCALE_COLOR then
      TImageTools.ReplaceNotNullColor(BitMap, AColor);

    ABitmapList.Add(BitMap);
  end;

  BitMap := _GetBitmapByIdent(AResBitmapList, OrientationPrefix + 'Delimiter');

  if AColor <> NO_REPCALE_COLOR then
    TImageTools.ReplaceNotNullColor(BitMap, AColor);

  ABitmapList.Add(BitMap);
end;

class procedure TShowTime.Init(
  const AImageFileName: String;
  const AImagesRootPath: String;
  const AColor: TAlphaColor;
  const AHH: TImage;
  const AHL: TImage;
  const AHDelim: TImage;
  const AMH: TImage;
  const AML: TImage;
  const ASDelim: TImage;
  const ASH: TImage;
  const ASL: TImage;
  const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
begin
  if not FileExists(AImageFileName) then
    raise Exception.CreateFmt('File "%s" not exists', [AImageFileName]);

  FColor := AColor;
  FOrientation := AOrientation;

  FHH := AHH;
  FHL := AHL;
  FHDelim := AHDelim;
  FMH := AMH;
  FML := AML;
  FSDelim := ASDelim;
  FSH := ASH;
  FSL := ASL;

  FMultiResBitmaps := TMultiResBitmaps.Create;

  FBitmapList := TBitMapList.Create;

  TMultiResBitmapExtractor.Extract(
    AImageFileName,
    FMultiResBitmaps);

  FNearestResBitmapList := FMultiResBitmaps.FindResBitmapListByIdent('');

  LoadResBitmapListByIdent(
    FNearestResBitmapList,
    FBitmapList,
    FColor,
    FOrientation);
end;

class procedure TShowTime.UnInit;
begin
  if Assigned(FBitmapList) then
    FreeAndNil(FBitmapList);

  FreeAndNil(FMultiResBitmaps);
end;

class procedure TShowTime.ShowTime(const ATime: String);
  function _GetDigit(const _ATime: String; const _AIndex: Integer): Integer;
  var
    _Char: Char;
  begin
    if _AIndex < 1 then
      raise Exception.Create('Index out of range');
    if _AIndex > _ATime.Length then
      raise Exception.Create('Index out of range');

    _Char := Char(_ATime[_AIndex]);

    Result := String(_Char).ToInteger;
  end;
var
  Time: String;
begin
  Time := ATime;
  if Time.Length < 8 then
  begin
    Time := Concat('0', Time);
//    raise Exception.Create('Incorrect time format');
  end;

  FHH.Bitmap.Assign(FBitmapList[_GetDigit(Time, 1)]);
  FHL.Bitmap.Assign(FBitmapList[_GetDigit(Time, 2)]);
  FHDelim.Bitmap.Assign(FBitmapList[10]);
  FMH.Bitmap.Assign(FBitmapList[_GetDigit(Time, 4)]);
  FML.Bitmap.Assign(FBitmapList[_GetDigit(Time, 5)]);
  FSDelim.Bitmap.Assign(FBitmapList[10]);
  FSH.Bitmap.Assign(FBitmapList[_GetDigit(Time, 7)]);
  FSL.Bitmap.Assign(FBitmapList[_GetDigit(Time, 8)]);
end;

class procedure TShowTime.CheckBitmapsResolution(
  const AWidth: Single; const AHeight: Single);
var
  ResBitmapList: TResBitmapList;
begin
  ResBitmapList := FMultiResBitmaps.FindNearestResBitmapList(AWidth, AHeight);
  if FNearestResBitmapList <> ResBitmapList then
  begin
    LoadResBitmapListByIdent(
      ResBitmapList,
      FBitmapList,
      FColor,
      FOrientation);

    FNearestResBitmapList := ResBitmapList; 
  end;
end;

end.
