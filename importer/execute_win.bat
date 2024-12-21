@echo off
rem スクリプトのディレクトリに移動
cd /d "%~dp0"

rem Bashスクリプトを実行してインポート
bash app/script.sh
pause