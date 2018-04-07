@echo off

REM -----------------------------------------------------------------------
REM NVEncCのオプション
REM -----------------------------------------------------------------------
set NVCENC_OPTION=--avs --cqp 19:21:23 --lookahead 32 --aq --aq-temporal --aq-strength 0

REM -----------------------------------------------------------------------
REM フォルダ名
REM -----------------------------------------------------------------------
set BIN_DIR=C:\DTV\bin\
set LOGO_DIR=%BIN_DIR%join_logo_scp\logo\
set OUTPUT_DIR=F:\Encode\

REM -----------------------------------------------------------------------
REM 実行ファイル名
REM -----------------------------------------------------------------------
set NVCENC=%BIN_DIR%NVEncC.exe
set MUXER=%BIN_DIR%muxer.exe
set REMUXER=%BIN_DIR%REMUXER.exe
set MEDIAINFO=%BIN_DIR%MediaInfo\MediaInfo.exe
set DGINDEX=%BIN_DIR%DGIndex\DGIndex.exe

REM -----------------------------------------------------------------------
REM ループ処理の開始
REM -----------------------------------------------------------------------
:loop
if "%~n1" == "" goto end

echo ======================================================================
echo 処理開始: %date% %time%
echo ======================================================================
echo %~dpn1
if %~x1 == .ts (
  echo.
) else (
  echo [エラー] 変換元のTSファイルをドロップしてください。
  echo.
  goto :end
)

REM -----------------------------------------------------------------------
REM DVDソースか判定
REM -----------------------------------------------------------------------
set ISDVD=0
for /f "delims=" %%A in ('%MEDIAINFO% %1 ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set WIDTH=%%A
if %WIDTH% == 720 set ISDVD=1

REM -----------------------------------------------------------------------
REM 変数セット
REM -----------------------------------------------------------------------
set FILENAME=%~n1
set PATH_NAME=%~dp1
set FULLNAME=%~dpn1
set AVS="%FULLNAME%.avs"

set OUTPUT_ENC="%OUTPUT_DIR%%FILENAME%.enc.mp4"
set OUTPUT_MP4="%OUTPUT_DIR%%FILENAME%.mp4"
set OUTPUT_AAC="%OUTPUT_DIR%%FILENAME%.aac"

REM -----------------------------------------------------------------------
REM TS 不要データ削除
REM -----------------------------------------------------------------------
if not exist "%SOURCE_FULLNAME%" call %TS_SPRITTER% -EIT -ECM -EMM -SD -1SEG "%PATH_FILENAME%.ts"

REM -----------------------------------------------------------------------
REM TS 映像・音声分離
REM -----------------------------------------------------------------------
if not exist "%SOURCE_FILENAME%*DELAY*.*" (
  call %DGINDEX% -i "%SOURCE_FULLNAME%" -o "%SOURCE_FILENAME%" -ia 5 -fo 0 -yr 2 -om 2 -hide -exit
  if exist "%SOURCE_FILENAME%.log" del /f /q "%SOURCE_FILENAME%.log"
)
for /f "usebackq tokens=*" %%A in (`dir /b "%SOURCE_FILENAME%*DELAY*.*"`) do set AAC_FILE=%PATH_NAME%%%A
set D2V_FILE=%SOURCE_FILENAME%.d2v

for /f "usebackq tokens=*" %%A in (`dir /b "%SOURCE_FILENAME%*DELAY*.aac"`) do set AAC_FILE=%PATH_NAME%%%A

REM -----------------------------------------------------------------------
REM TS 映像・音声分離
REM -----------------------------------------------------------------------
if not exist "%SOURCE_FILENAME%*DELAY*.*" (
  call %DGINDEX% -i "%SOURCE_FULLNAME%" -o "%SOURCE_FILENAME%" -ia 5 -fo 0 -yr 2 -om 2 -hide -exit
  if exist "%SOURCE_FILENAME%.log" del /f /q "%SOURCE_FILENAME%.log"
)
for /f "usebackq tokens=*" %%A in (`dir /b "%SOURCE_FILENAME%*DELAY*.*"`) do set AAC_FILE=%PATH_NAME%%%A
set D2V_FILE=%SOURCE_FILENAME%.d2v

REM -----------------------------------------------------------------------
REM DVDソースのみアスペクト比を設定
REM -----------------------------------------------------------------------
for /f "delims=" %%A in ('%MEDIAINFO% "%SOURCE_FULLNAME%" ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set WIDTH=%%A
for /f "delims=" %%A in ('%MEDIAINFO% "%SOURCE_FULLNAME%" ^| grep "Display aspect ratio" ^| sed -r "s/Display aspect ratio *: (.*)/\1/"') do set ASPECT=%%A
if %WIDTH% == 720 (
  if %ASPECT% == 16:9 (
    set SAR=--sar 32:27
  ) else (
    set SAR=--sar 8:9
  )
) else (
  set SAR=--sar 1:1
)

echo ======================================================================
echo NVEncCで映像エンコード
echo ======================================================================
REM call %NVCENC% %NVCENC_OPTION% %SAR% -i %AVS% -o %OUTPUT_ENC%
echo.

echo ======================================================================
echo L-SMASHで結合
echo ======================================================================
for /f "delims=" %%A in ('dir /b "%AAC_FILE%" ^| sed -r "s/.* DELAY ([^\.]*)ms.aac/\1/"') do set DELAY=%%A
call %MUXER% -i %OUTPUT_ENC% -i "%AAC_FILE%"?encoder-delay=%DELAY% -o %OUTPUT_MP4%
echo.

echo ======================================================================
echo 一時ファイル削除
echo ======================================================================
echo 不要になった一時ファイルを削除します。
echo.

REM if exist %OUTPUT_MP4% del /f /q %OUTPUT_ENC%
if not exist %OUTPUT_ENC% echo %OUTPUT_ENC%
echo.

echo ======================================================================
echo 処理終了: %date% %time%
echo ======================================================================

shift
goto loop
:end

pause
exit
