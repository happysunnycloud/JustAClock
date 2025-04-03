unit ShowTimeUnit;

interface

uses
    System.Generics.Collections
  , FMX.Objects
  , FMX.Graphics
  , FilePackerUnit
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
  public
    class procedure Init(
      const AImageFileName: String;
      const AColorIdent: String;
      const AHH: TImage;
      const AHL: TImage;
      const AHDelim: TImage;
      const AMH: TImage;
      const AML: TImage;
      const ASDelim: TImage;
      const ASH: TImage;
      const ASL: TImage);
    class procedure UnInit;

    class procedure ShowTime(const ATime: String);
  end;

implementation

uses
    System.SysUtils
  , System.Classes
  , FMX.ImageExtractorUnit
  ;

class procedure TShowTime.Init(
  const AImageFileName: String;
  const AColorIdent: String;
  const AHH: TImage;
  const AHL: TImage;
  const AHDelim: TImage;
  const AMH: TImage;
  const AML: TImage;
  const ASDelim: TImage;
  const ASH: TImage;
  const ASL: TImage);
var
  i: Integer;
  BitMap: TBitMap;
  ImageFile: TFilePacker;
  MemoryStream: TMemoryStream;
begin
  if not FileExists(AImageFileName) then
    raise Exception.CreateFmt('File "%s" not exists', [AImageFileName]);

  FHH := AHH;
  FHL := AHL;
  FHDelim := AHDelim;
  FMH := AMH;
  FML := AML;
  FSDelim := ASDelim;
  FSH := ASH;
  FSL := ASL;

  FBitmapList := TBitMapList.Create;

  ImageFile := TFilePacker.Create(AImageFileName, fmOpenRead);
  try
    for i := 0 to 9 do
    begin
      BitMap := TBitMap.Create;
      MemoryStream := TMemoryStream.Create;
      try
        TImageExtractor.ExtractToBitmap(
          ImageFile,
          AColorIdent + '\' + i.ToString + '.png',
          BitMap);
        FBitmapList.Add(BitMap);
      finally
        FreeAndNil(MemoryStream);
      end;
    end;

    TImageExtractor.ExtractToBitmap(
      ImageFile,
      AColorIdent + '\' + 'Delimiter.png',
      FHDelim.Bitmap);
    TImageExtractor.ExtractToBitmap(
      ImageFile,
      AColorIdent + '\' + 'Delimiter.png',
      FSDelim.Bitmap);
  finally
    FreeAndNil(ImageFile);
  end;
end;

class procedure TShowTime.UnInit;
var
  i: Integer;
begin
  if Assigned(FBitmapList) then
  begin
    i := FBitmapList.Count;
    while i > 0 do
    begin
      Dec(i);

      FBitmapList[i].Free;
    end;
    FreeAndNil(FBitmapList);
  end;
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
  FMH.Bitmap.Assign(FBitmapList[_GetDigit(Time, 4)]);
  FML.Bitmap.Assign(FBitmapList[_GetDigit(Time, 5)]);
  FSH.Bitmap.Assign(FBitmapList[_GetDigit(Time, 7)]);
  FSL.Bitmap.Assign(FBitmapList[_GetDigit(Time, 8)]);
end;

end.
