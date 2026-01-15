program JustAClock;
//  {$IFDEF ANDROID}
//  Androidapi.Helpers,
//  Androidapi.JNI.GraphicsContentViewText,
//  Androidapi.JNI.App,
//  Android.JNI.PowerManager in '..\DevelopmentsCollection\Android.JNI.PowerManager.pas',
//  {$ENDIF}
//  Application.Initialize;
//  {$IFDEF ANDROID}
//  //отключаем гашение экрана
//  TAndroidHelper.Activity.GetWindow.addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON);
//  {$ENDIF}
//  Application.CreateForm(TMainForm, MainForm);
//  Application.Run;
uses
  {$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.App,
  Android.JNI.PowerManager in '..\DevelopmentsCollection\Android.JNI.PowerManager.pas',
  {$ENDIF}
  System.SysUtils,
  System.StartUpCopy,
  FMX.Forms,
  JustAClockUnit in 'JustAClockUnit.pas' {MainForm},
  TimeThreadUnit in 'TimeThreadUnit.pas',
  CustomThreadUnit in '..\DevelopmentsCollection\CustomThreadUnit.pas',
  ElectronicBoardFrameUnit in 'Frames\ElectronicBoardFrameUnit.pas' {ElectronicBoardFrame: TFrame},
  ShowTimeUnit in 'ShowTimeUnit.pas',
  FileToolsUnit in '..\DevelopmentsCollection\FileToolsUnit.pas',
  FilePackerUnit in '..\DevelopmentsCollection\FilePacker\FilePackerUnit.pas',
  FMX.ImageExtractorUnit in '..\DevelopmentsCollection\FilePacker\FMX.ImageExtractorUnit.pas',
  TimeCalcUnit in '..\DevelopmentsCollection\TimeCalcUnit.pas',
  FMX.FormExtUnit in '..\DevelopmentsCollection\FMX.FormExtUnit.pas',
  ThreadFactoryUnit in '..\DevelopmentsCollection\ThreadFactoryUnit.pas',
  ThreadRegistryUnit in '..\DevelopmentsCollection\ThreadRegistryUnit.pas',
  ParamsExtUnit in '..\DevelopmentsCollection\ParamsExtUnit.pas',
  NumScrollUnit in 'Frames\NumScrollUnit.pas' {NumScrollFrame: TFrame},
  SetTimerFormUnit in 'SetTimerFormUnit.pas' {SetTimerForm},
  ThreadFactoryRegistryUnit in '..\DevelopmentsCollection\ThreadFactoryRegistryUnit.pas',
  ObjectRegistryUnit in '..\DevelopmentsCollection\ObjectRegistryUnit.pas',
  FMX.ImageToolsUnit in '..\DevelopmentsCollection\FMX.ImageToolsUnit.pas',
  VerticalElectronicBoardFrameUnit in 'Frames\VerticalElectronicBoardFrameUnit.pas' {VeticalElectronicBoardFrame: TFrame},
  CommonUnit in 'CommonUnit.pas',
  ShowTextTimeUnit in 'ShowTextTimeUnit.pas',
  TextBoardFrameUnit in 'Frames\TextBoardFrameUnit.pas' {TextBoardFrame: TFrame},
  VerticalTextBoardFrameUnit in 'Frames\VerticalTextBoardFrameUnit.pas' {VerticalTextBoardFrame: TFrame},
  FMX.ControlToolsUnit in '..\DevelopmentsCollection\FMX.ControlToolsUnit.pas',
  SetCustomColorUnit in 'SetCustomColorUnit.pas' {SetCustomColorForm},
  FileStreamToolsUnit in '..\DevelopmentsCollection\FileStreamToolsUnit.pas',
  FMX.PopupMenuExtUnit in '..\DevelopmentsCollection\FMX.PopupMenuExt\FMX.PopupMenuExtUnit.pas',
  FMX.PopupMenuExtFormUnit in '..\DevelopmentsCollection\FMX.PopupMenuExt\FMX.PopupMenuExtFormUnit.pas',
  FMX.ThemeUnit in '..\DevelopmentsCollection\FMX.ThemeUnit.pas',
  ProportionUnit in 'ProportionUnit.pas',
  MotionSensorDataThreadUnit in 'MotionSensorDataThreadUnit.pas',
  FMX.MultiResBitmapsUnit in '..\DevelopmentsCollection\FMX.MultiResBitmapsUnit.pas',
  FMX.MultiResBitmapExtractorUnit in '..\DevelopmentsCollection\FilePacker\FMX.MultiResBitmapExtractorUnit.pas',
  FMX.VibroUnit in '..\DevelopmentsCollection\FMX.VibroUnit.pas',
  FMX.SingleSoundUnit in '..\DevelopmentsCollection\FMX.SingleSoundUnit.pas'
  {$IFDEF MSWINDOWS}
  ,
  BorderFrameTypesUnit in '..\DevelopmentsCollection\BorderFrame\BorderFrameTypesUnit.pas',
  FMX.PopupMenuExtThreadUnit in '..\DevelopmentsCollection\FMX.PopupMenuExt\FMX.PopupMenuExtThreadUnit.pas',
  BorderFrameUnit in '..\DevelopmentsCollection\BorderFrame\BorderFrameUnit.pas' {BorderFrame: TFrame},
  FMX.TrayIcon.Win in '..\DevelopmentsCollection\FMX.TrayIcon.Win.pas'
  {$ENDIF }
  ;

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF ANDROID}
  //отключаем гашение экрана
  TAndroidHelper.Activity.GetWindow.addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON);
  {$ENDIF}
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
