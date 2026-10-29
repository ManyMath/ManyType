@echo off
setlocal
cd /d "%~dp0..\tool\protocol_codegen" || exit /b 1
call dart run protoc_plugin:protoc_plugin %*
exit /b %ERRORLEVEL%
