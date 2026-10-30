#! python3.12
import json
import os
import sys
import threading

import webview

# En mode .exe sans console, stdout/stderr valent None : on les redirige pour
# éviter un plantage quand une librairie écrit dedans (barres de progression...).
if sys.stdout is None:
    sys.stdout = open(os.devnull, "w")
if sys.stderr is None:
    sys.stderr = open(os.devnull, "w")
os.environ.setdefault("HF_HUB_DISABLE_PROGRESS_BARS", "1")

TYPES_FICHIERS = (
    "Audio ou vidéo (*.wav;*.mp3;*.m4a;*.mp4;*.mkv;*.mov;*.flac;*.ogg;*.aac)",
    "Tous les fichiers (*.*)",
)

_modele = None  # chargé une seule fois, réutilisé pour les transcriptions suivantes
_verrou = threading.Lock()
_fenetre = None


def chemin_ressource(relatif):
    base = getattr(sys, "_MEIPASS", os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base, relatif)


def charger_modele():
    """Charge le modèle une seule fois ; les appels concurrents attendent le premier."""
    global _modele
    with _verrou:
        if _modele is None:
            from faster_whisper import WhisperModel

            # Modèle embarqué dans l'appli ; à défaut, téléchargement classique.
            local = chemin_ressource(os.path.join("modele", "medium"))
            source = local if os.path.isdir(local) else "medium"
            _modele = WhisperModel(source, device="cpu", compute_type="int8")
    return _modele


def js(appel, *args):
    """Appelle window.app.<appel>(...) dans l'interface."""
    if _fenetre is not None:
        params = ", ".join(json.dumps(a) for a in args)
        _fenetre.evaluate_js(f"window.app.{appel}({params})")


def precharger():
    try:
        charger_modele()
        js("modelePret")
    except Exception:
        pass  # l'erreur sera rapportée au moment de la transcription


def transcrire(source, destination):
    try:
        if _modele is None:
            js("statut", "Chargement du modèle...")
        modele = charger_modele()
        js("modelePret")
        js("statut", "Transcription en cours...")
        segments, info = modele.transcribe(source, language="fr")
        with open(destination, "w", encoding="utf-8") as f:
            for s in segments:
                f.write(s.text.strip() + "\n")
                if info.duration:
                    js("progression", min(100, s.end / info.duration * 100))
        js("progression", 100)
        js("fini", destination)
    except Exception as e:
        js("erreur", str(e))


class Api:
    """Méthodes appelables depuis l'interface (window.pywebview.api.*)."""

    def __init__(self):
        self._destination = None

    def modele_pret(self):
        return _modele is not None

    def choisir(self):
        """Demande le fichier puis la destination ; lance la transcription.
        Retourne le nom du fichier choisi, ou None si l'utilisateur annule."""
        try:
            res = _fenetre.create_file_dialog(
                webview.FileDialog.OPEN, file_types=TYPES_FICHIERS
            )
            if not res:
                return None
            source = res[0]

            dossier, nom = os.path.split(source)
            res = _fenetre.create_file_dialog(
                webview.FileDialog.SAVE,
                directory=dossier,
                save_filename=os.path.splitext(nom)[0] + ".txt",
                file_types=("Texte (*.txt)",),
            )
            if not res:
                return None
            destination = res if isinstance(res, str) else res[0]
            if not destination.lower().endswith(".txt"):
                destination += ".txt"
        except Exception as e:
            js("erreur", str(e))
            return None

        self._destination = destination
        threading.Thread(target=transcrire, args=(source, destination), daemon=True).start()
        return nom

    def ouvrir_texte(self):
        if self._destination and os.path.exists(self._destination):
            os.startfile(self._destination)

    def ouvrir_dossier(self):
        if self._destination:
            os.startfile(os.path.dirname(self._destination))


def main():
    global _fenetre
    _fenetre = webview.create_window(
        "Transcry",
        chemin_ressource(os.path.join("ui", "index.html")),
        js_api=Api(),
        width=640,
        height=720,
        resizable=False,
        background_color="#0F172A",
    )
    # Préchargement du modèle en arrière-plan, une fois l'interface affichée.
    webview.start(
        lambda: threading.Thread(target=precharger, daemon=True).start(),
        icon=chemin_ressource(os.path.join("ui", "icon.ico")),
    )


if __name__ == "__main__":
    main()
