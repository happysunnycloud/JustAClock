program JustAClock;

uses
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
  FMX.PopupMenuExtThreadUnit in '..\DevelopmentsCollection\FMX.PopupMenuExt\FMX.PopupMenuExtThreadUnit.pas',
  FMX.PopupMenuExtUnit in '..\DevelopmentsCollection\FMX.PopupMenuExt\FMX.PopupMenuExtUnit.pas',
  {$IFDEF MSWINDOWS}
  FMX.TrayIcon.Win in '..\DevelopmentsCollection\FMX.TrayIcon.Win.pas',
  BorderFrameUnit in '..\DevelopmentsCollection\BorderFrame\BorderFrameUnit.pas' {BorderFrame: TFrame},
  FMX.Craft.PopupMenu.Win in '..\DevelopmentsCollection\FMX.Craft.PopupMenu\FMX.Craft.PopupMenu.Win.pas',
  FMX.Craft.PopupMenu.Structures in '..\DevelopmentsCollection\FMX.Craft.PopupMenu\FMX.Craft.PopupMenu.Structures.pas',
  FMX.Craft.PopupMenu.Thread.Win in '..\DevelopmentsCollection\FMX.Craft.PopupMenu\FMX.Craft.PopupMenu.Thread.Win.pas',
  {$ENDIF}
  FMX.PopupMenuExtFormUnit in '..\DevelopmentsCollection\FMX.PopupMenuExt\FMX.PopupMenuExtFormUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
