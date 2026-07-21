@if "%DEBUG%" == "" @echo off
setlocal

set "APP_HOME=%~dp0"
set "WRAPPER_SCRIPT=%APP_HOME%hvigor\hvigor-wrapper.js"

if not exist "%WRAPPER_SCRIPT%" (
  echo ERROR: Cannot find "%WRAPPER_SCRIPT%" 1>&2
  exit /b 1
)

if defined DEVECO_STUDIO_HOME (
  if exist "%DEVECO_STUDIO_HOME%\tools\node\node.exe" (
    set "NODE_EXE=%DEVECO_STUDIO_HOME%\tools\node\node.exe"
    goto execute
  )
)

if defined DEVECO_HOME (
  if exist "%DEVECO_HOME%\tools\node\node.exe" (
    set "NODE_EXE=%DEVECO_HOME%\tools\node\node.exe"
    goto execute
  )
)

if defined NODE_HOME (
  if exist "%NODE_HOME%\node.exe" (
    set "NODE_EXE=%NODE_HOME%\node.exe"
    goto execute
  )
  if exist "%NODE_HOME%\bin\node.exe" (
    set "NODE_EXE=%NODE_HOME%\bin\node.exe"
    goto execute
  )
)

if defined LOCALAPPDATA (
  if exist "%LOCALAPPDATA%\Huawei\DevEco Studio\tools\node\node.exe" (
    set "NODE_EXE=%LOCALAPPDATA%\Huawei\DevEco Studio\tools\node\node.exe"
    goto execute
  )
)

if exist "%ProgramFiles%\Huawei\DevEco Studio\tools\node\node.exe" (
  set "NODE_EXE=%ProgramFiles%\Huawei\DevEco Studio\tools\node\node.exe"
  goto execute
)

where node.exe >NUL 2>&1
if "%ERRORLEVEL%" == "0" (
  set "NODE_EXE=node.exe"
  goto execute
)

echo ERROR: Node.js was not found. Set DEVECO_STUDIO_HOME or NODE_HOME, or add node to PATH. 1>&2
exit /b 1

:execute
"%NODE_EXE%" "%WRAPPER_SCRIPT%" %*
set "EXIT_CODE=%ERRORLEVEL%"
endlocal & exit /b %EXIT_CODE%
