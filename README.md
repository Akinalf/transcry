<div align="center">

<img src="ui/logo.png" alt="Logo Transcry" width="120">

# Transcry

**Parlez, ça s'écrit.**<br>
Transformez n'importe quel enregistrement audio ou vidéo en texte, directement sur votre PC.

[![Télécharger pour Windows](https://img.shields.io/badge/T%C3%A9l%C3%A9charger-Transcry--Setup.exe-6366F1?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/Akinalf/transcry/releases/latest)

![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-8B5CF6?style=flat-square&logo=windows&logoColor=white)
![Hors ligne](https://img.shields.io/badge/100%25-hors%20ligne-34D399?style=flat-square)
![Modèle](https://img.shields.io/badge/Whisper-large--v3--turbo-A5B4FC?style=flat-square&labelColor=1E293B)
![Python](https://img.shields.io/badge/Python-3.12-6366F1?style=flat-square&logo=python&logoColor=white)

<br>

<img src="docs/screenshot.png" alt="Capture d'écran de Transcry" width="420">

</div>

<br>

## Pourquoi Transcry ?

- **Privé** : tout est traité sur votre ordinateur, rien n'est envoyé en ligne.
- **Simple** : un bouton, un fichier, un texte.
- **Précis** : basé sur le modèle Whisper *large-v3-turbo*, très bon en français.
- **Pratique** : l'application reste ouverte pour enchaîner les transcriptions.

Formats pris en charge : mp3, wav, m4a, mp4, mkv, mov, flac, ogg, aac.

## Installer

1. Cliquez sur le bouton **Télécharger** ci-dessus (ou ouvrez les [Releases](https://github.com/Akinalf/transcry/releases/latest)) et récupérez `Transcry-Setup.exe`.
2. Lancez-le. Windows peut afficher « Windows a protégé votre ordinateur », car l'application n'est pas signée : cliquez sur *Informations complémentaires*, puis *Exécuter quand même*.
3. L'installation télécharge le modèle de reconnaissance (environ 1,6 Go), une seule fois. Ensuite, tout fonctionne sans internet.

## Développer

```powershell
py -3.12 -m pip install faster-whisper pywebview
py -3.12 transcry.py
```

Au premier lancement en développement, le modèle est téléchargé automatiquement. Pour le placer à la main, copiez les fichiers du modèle dans `modele/large-v3-turbo/`.

### Construire l'installateur

1. Installez [Inno Setup 6](https://jrsoftware.org/isinfo.php).
2. `build.bat` génère `dist\Transcry`.
3. Compilez `installer.iss` : l'installateur est créé dans `Output\Transcry-Setup.exe`.

Le modèle est hébergé comme fichiers de la release [`modele-v2`](https://github.com/Akinalf/transcry/releases/tag/modele-v2) ; `installer.iss` les télécharge (avec vérification SHA-256) pendant l'installation.

## Crédits

Reconnaissance vocale : [faster-whisper](https://github.com/SYSTRAN/faster-whisper) et le modèle [Whisper](https://github.com/openai/whisper) d'OpenAI. Interface : [pywebview](https://pywebview.flowrl.com/).
