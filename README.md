# Transcry

Application Windows qui transforme un enregistrement audio ou vidéo en texte français.
Tout est traité sur votre ordinateur, rien n'est envoyé en ligne.

Basée sur [faster-whisper](https://github.com/SYSTRAN/faster-whisper) (modèle `medium`) et pywebview pour l'interface.

## Installer

1. Rendez-vous dans les [Releases](../../releases) et téléchargez **Transcry-Setup.exe**.
2. Lancez-le. Windows peut afficher « Windows a protégé votre ordinateur » (l'application n'est pas signée) : cliquez sur *Informations complémentaires* puis *Exécuter quand même*.
3. L'installation télécharge le modèle de reconnaissance (environ 1,5 Go), une seule fois. Ensuite l'application fonctionne hors ligne.

Formats pris en charge : mp3, wav, m4a, mp4, mkv, mov, flac, ogg, aac.

## Développer

```powershell
py -3.12 -m pip install faster-whisper pywebview
py -3.12 transcry.py
```

Au premier lancement en développement, le modèle est téléchargé automatiquement. Pour le placer à la main, copiez les fichiers du modèle dans `modele/medium/`.

### Construire l'installateur

1. Installez [Inno Setup 6](https://jrsoftware.org/isinfo.php).
2. `build.bat` génère `dist\Transcry`.
3. Compilez `installer.iss` : l'installateur est créé dans `Output\Transcry-Setup.exe`.

Le modèle est hébergé comme fichiers de la release `modele-v1` ; `installer.iss` les télécharge (avec vérification SHA-256) pendant l'installation.
