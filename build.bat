@echo off
cd /d "%~dp0"
py -3.12 -m pip install --upgrade pyinstaller pywebview
py -3.12 -m PyInstaller --noconfirm --noconsole --onedir --name Transcry ^
    --icon "ui\icon.ico" ^
    --add-data "ui;ui" ^
    --collect-all faster_whisper --collect-all ctranslate2 transcry.py
echo.
echo Executable : %~dp0dist\Transcry\Transcry.exe
pause
