@echo off
rem Windows companion to tool/melos (POSIX sh). Melos script `exec` launches a
rem bare `melos` child through cmd.exe, where the extensionless sh script is not
rem executable. Keep that child on the workspace-pinned dependency too, without
rem requiring a global installation.
setlocal
set "MANYTYPE_TOOL_DIR=%~dp0"
set "PATH=%MANYTYPE_TOOL_DIR%;%PATH%"
call dart run melos %*
exit /b %ERRORLEVEL%
