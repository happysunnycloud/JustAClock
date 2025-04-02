program JustAClock;

uses
  System.StartUpCopy,
  FMX.Forms,
  JustAClockUnit in 'JustAClockUnit.pas' {MainForm},
  TimeThreadUnit in 'TimeThreadUnit.pas',
  FMX.TrayIcon.Win in '..\DevelopmentsCollection\FMX.TrayIcon.Win.pas',
  BorderFrameUnit in '..\DevelopmentsCollection\BorderFrame\BorderFrameUnit.pas' {BorderFrame: TFrame},
  FMX.Craft.PopupMenu.Win in '..\DevelopmentsCollection\FMX.Craft.PopupMenu\FMX.Craft.PopupMenu.Win.pas',
  FMX.Craft.PopupMenu.Structures in '..\DevelopmentsCollection\FMX.Craft.PopupMenu\FMX.Craft.PopupMenu.Structures.pas',
  FMX.Craft.PopupMenu.Thread.Win in '..\DevelopmentsCollection\FMX.Craft.PopupMenu\FMX.Craft.PopupMenu.Thread.Win.pas',
  CustomThreadUnit in '..\DevelopmentsCollection\CustomThreadUnit.pas',
  FMX.ControlToolsUnit in '..\DevelopmentsCollection\FMX.ControlToolsUnit.pas',
  ElectronicBoardFrameUnit in 'Frames\ElectronicBoardFrameUnit.pas' {ElectronicBoardFrame: TFrame},
  ShowTimeUnit in 'ShowTimeUnit.pas',
  FileToolsUnit in '..\DevelopmentsCollection\FileToolsUnit.pas',
  FilePackerUnit in '..\DevelopmentsCollection\FilePacker\FilePackerUnit.pas',
  FMX.ImageExtractorUnit in '..\DevelopmentsCollection\FilePacker\FMX.ImageExtractorUnit.pas',
  TimeCalcUnit in '..\DevelopmentsCollection\TimeCalcUnit.pas',
  FMX.FormExtUnit in '..\DevelopmentsCollection\FMX.FormExtUnit.pas',
  ThreadFactoryUnit in '..\DevelopmentsCollection\ThreadFactoryUnit.pas',
  ThreadRegistryUnit in '..\DevelopmentsCollection\ThreadRegistryUnit.pas',
  ParamsExtUnit in '..\DevelopmentsCollection\ParamsExtUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
