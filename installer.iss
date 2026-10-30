; Installateur de Transcry (Inno Setup 6.1+)
; Le modèle (1,6 Go) est téléchargé pendant l'installation depuis la release GitHub "modele-v2".

#define AppName "Transcry"
#define AppVersion "3.1.0"
#define AppExe "Transcry.exe"
#define ModeleBase "https://github.com/Akinalf/transcry/releases/download/modele-v2/"

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

[InstallDelete]
; Mise à jour depuis la 3.0 : l'ancien modèle "medium" n'est plus utilisé.
Type: filesandordirs; Name: "{app}\_internal\modele\medium"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\_internal\modele"

[Code]
const
  DossierModele = '\_internal\modele\large-v3-turbo';
  NbFichiers = 5;

var
  PageTelechargement: TDownloadWizardPage;

function NomFichier(i: Integer): String;
begin
  case i of
    0: Result := 'config.json';
    1: Result := 'preprocessor_config.json';
    2: Result := 'tokenizer.json';
    3: Result := 'vocabulary.json';
  else
    Result := 'model.bin';
  end;
end;

function EmpreinteFichier(i: Integer): String;
begin
  case i of
    0: Result := 'b0253ea6c0d3bea6b1e19e91a02acfd3b53f4467362efcb5a3e6b16c9b3a9b7e';
    1: Result := '7ccc62c6f2765af1f3b46c00c9b5894426835a05021c8b9c01eecb6dfb542711';
    2: Result := '297b13372ac43916285644fb9687add3cc62ee2a1adb60da3dc25cc94c1871fd';
    3: Result := 'c69260f2ab26d659b7c398f9a2b2b48ed0df16c3b47d7326782fd9cba71690c1';
  else
    Result := 'e76620f83d5f5b69efd3d87e3dc180c1bd21df9fbebacfd4335e5e1efcc018da';
  end;
end;

procedure InitializeWizard;
begin
  PageTelechargement := CreateDownloadPage('Téléchargement du modèle',
    'Le modèle de reconnaissance vocale (environ 1,6 Go) est téléchargé une seule fois.', nil);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Dossier: String;
  i: Integer;
begin
  Result := True;
  if CurPageID = wpReady then begin
    Dossier := ExpandConstant('{app}') + DossierModele;
    // Déjà présent (réinstallation) : rien à télécharger.
    if FileExists(Dossier + '\model.bin') then Exit;

    PageTelechargement.Clear;
    for i := 0 to NbFichiers - 1 do
      PageTelechargement.Add('{#ModeleBase}' + NomFichier(i), NomFichier(i), EmpreinteFichier(i));
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
  i: Integer;
begin
  // Les fichiers téléchargés sont dans le dossier temporaire d'Inno : on les place dans l'appli.
  if CurStep = ssPostInstall then begin
    Dossier := ExpandConstant('{app}') + DossierModele;
    if FileExists(Dossier + '\model.bin') then Exit;
    ForceDirectories(Dossier);
    for i := 0 to NbFichiers - 1 do begin
      Fichier := ExpandConstant('{tmp}\') + NomFichier(i);
      if not RenameFile(Fichier, Dossier + '\' + NomFichier(i)) then
        CopyFile(Fichier, Dossier + '\' + NomFichier(i), False);
    end;
  end;
end;
