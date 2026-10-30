; Installateur de Transcry (Inno Setup 6.1+)
; Le modèle (1,5 Go) est téléchargé pendant l'installation depuis la release GitHub "modele-v1".

#define AppName "Transcry"
#define AppVersion "3.0.0"
#define AppExe "Transcry.exe"
#define ModeleBase "https://github.com/Akinalf/transcry/releases/download/modele-v1/"

[Setup]
AppId={{B7A1D3E2-5C4F-4E6B-9A10-7F3C2D8E1A55}
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=Transcry-Setup
SetupIconFile=ui\icon.ico
UninstallDisplayIcon={app}\{#AppExe}
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
WizardStyle=modern

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "Créer un raccourci sur le Bureau"; GroupDescription: "Raccourcis :"

[Files]
Source: "dist\Transcry\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "Lancer {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\_internal\modele"

[Code]
const
  DossierModele = '\_internal\modele\medium';

var
  PageTelechargement: TDownloadWizardPage;

procedure InitializeWizard;
begin
  PageTelechargement := CreateDownloadPage('Téléchargement du modèle',
    'Le modèle de reconnaissance vocale (environ 1,5 Go) est téléchargé une seule fois.', nil);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Dossier: String;
begin
  Result := True;
  if CurPageID = wpReady then begin
    Dossier := ExpandConstant('{app}') + DossierModele;
    // Déjà présent (réinstallation) : rien à télécharger.
    if FileExists(Dossier + '\model.bin') then Exit;

    PageTelechargement.Clear;
    PageTelechargement.Add('{#ModeleBase}config.json', 'config.json', '3622a2ddc41ec0e0fd4e68c13c6830f03b90c38d89aaad184de02c8c642cf807');
    PageTelechargement.Add('{#ModeleBase}tokenizer.json', 'tokenizer.json', 'fb7b63191e9bb045082c79fd742a3106a12c99513ab30df4a0d47fa6cb6fd0ab');
    PageTelechargement.Add('{#ModeleBase}vocabulary.txt', 'vocabulary.txt', '34ce3fe1c5041027b3f8d42912270993f986dbc4bb34cf27f951e34a1e453913');
    PageTelechargement.Add('{#ModeleBase}model.bin', 'model.bin', '9b45e1009dcc4ab601eff815b61d80e60ce3fd8c74c1a14f4a282258286b51ae');
    PageTelechargement.Show;
    try
      try
        PageTelechargement.Download;
      except
        if PageTelechargement.AbortedByUser then
          Log('Téléchargement annulé')
        else
          SuppressibleMsgBox('Le téléchargement du modèle a échoué :' + #13#10 + GetExceptionMessage + #13#10 + #13#10 + 'Vérifiez votre connexion internet puis relancez l''installation.', mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      PageTelechargement.Hide;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Dossier, Fichier: String;
  Fichiers: TArrayOfString;
  i: Integer;
begin
  // Les fichiers téléchargés sont dans le dossier temporaire d'Inno : on les place dans l'appli.
  if CurStep = ssPostInstall then begin
    Dossier := ExpandConstant('{app}') + DossierModele;
    if FileExists(Dossier + '\model.bin') then Exit;
    ForceDirectories(Dossier);
    SetArrayLength(Fichiers, 4);
    Fichiers[0] := 'config.json';
    Fichiers[1] := 'tokenizer.json';
    Fichiers[2] := 'vocabulary.txt';
    Fichiers[3] := 'model.bin';
    for i := 0 to 3 do begin
      Fichier := ExpandConstant('{tmp}\') + Fichiers[i];
      if not RenameFile(Fichier, Dossier + '\' + Fichiers[i]) then
        FileCopy(Fichier, Dossier + '\' + Fichiers[i], False);
    end;
  end;
end;
