unit ShowTextTimeUnit;

interface

uses
    System.Generics.Collections
  , FMX.Objects
  , FMX.Graphics
  , FilePackerUnit
  , CommonUnit
  ;

const
  HORIZONTAL_DELIMITER = ':';
  VERTICAL_DELIMITER = '-';

type
  TShowTextTime = class
  strict private
    class var
      FHH: TText;
      FHL: TText;
      FHDelim: TText;
      FMH: TText;
      FML: TText;
      FSDelim: TText;
      FSH: TText;
      FSL: TText;

      FDelimiter: String;
  public
    class procedure Init(
      const AColorIdent: String;
      const AHH: TText;
      const AHL: TText;
      const AHDelim: TText;
      const AMH: TText;
      const AML: TText;
      const ASDelim: TText;
      const ASH: TText;
      const ASL: TText;
      const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
    class procedure UnInit;

    class procedure ShowTextTime(const ATime: String);
  end;

implementation

uses
    System.SysUtils
  , System.Classes
  , FMX.ImageExtractorUnit
  ;

class procedure TShowTextTime.Init(
  const AColorIdent: String;
  const AHH: TText;
  const AHL: TText;
  const AHDelim: TText;
  const AMH: TText;
  const AML: TText;
  const ASDelim: TText;
  const ASH: TText;
  const ASL: TText;
  const AOrientation: TOrientationKind = TOrientationKind.okHorizontal);
var
  i: Integer;
  BitMap: TBitMap;
  ImageFile: TFilePacker;
  MemoryStream: TMemoryStream;
begin
  FDelimiter := HORIZONTAL_DELIMITER;
  if AOrientation = okVertical then
    FDelimiter := VERTICAL_DELIMITER;

  FHH := AHH;
  FHL := AHL;
  FHDelim := AHDelim;
  FMH := AMH;
  FML := AML;
  FSDelim := ASDelim;
  FSH := ASH;
  FSL := ASL;
end;

class procedure TShowTextTime.UnInit;
begin
end;

class procedure TShowTextTime.ShowTextTime(const ATime: String);
  function _GetDigit(const _ATime: String; const _AIndex: Integer): String;
  var
    _Char: Char;
  begin
    if _AIndex < 1 then
      raise Exception.Create('Index out of range');
    if _AIndex > _ATime.Length then
      raise Exception.Create('Index out of range');

    _Char := Char(_ATime[_AIndex]);

    Result := String(_Char);
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

  FHH.Text := _GetDigit(Time, 1);
  FHL.Text := _GetDigit(Time, 2);
  FHDelim.Text := FDelimiter;
  FMH.Text := _GetDigit(Time, 4);
  FML.Text := _GetDigit(Time, 5);
  FSDelim.Text := FDelimiter;
  FSH.Text := _GetDigit(Time, 7);
  FSL.Text := _GetDigit(Time, 8);
end;

end.
