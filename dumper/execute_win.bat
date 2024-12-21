@echo off
rem スクリプトのディレクトリに移動
cd /d "%~dp0\app"
rem メインスクリプトをGit Bashで実行
bash script.sh
pause