@echo off
title Maher Quiz App - Share Server
echo ==============================================
echo       Maher Islamic Quiz - Live Sharing
echo ==============================================
echo.
echo 1. Starting Web Server...
start /b python tools\serve_web.py
timeout /t 2 >nul
echo 2. Generating Public Cloudflare Link...
echo.
tools\cloudflared.exe tunnel --url http://localhost:8080
pause
