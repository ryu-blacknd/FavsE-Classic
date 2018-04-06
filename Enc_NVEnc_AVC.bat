@echo off

REM -----------------------------------------------------------------------
REM NVEncC オプション
REM -----------------------------------------------------------------------
set NVCENC_OPTION=--avs --cqp 19:21:23 --lookahead 32 --aq --aq-temporal --aq-strength 0

REM -----------------------------------------------------------------------
REM プログラムフォルダと出力先フォルダ
REM -----------------------------------------------------------------------
set BIN_DIR=C:\DTV\bin\
set OUTPUT_DIR=F:\Encode\

REM -----------------------------------------------------------------------
REM プログラムファイル名
REM -----------------------------------------------------------------------
set NVCENC="%BIN_DIR%NVEncC.exe"
set QAAC="%BIN_DIR%qaac.exe"
set MUXER="%BIN_DIR%muxer.exe"
set REMUXER="%BIN_DIR%REMUXER.exe"
set TSSPRITTER="%BIN_DIR%TsSplitter\TsSplitter.exe"
set TS_PARSER="%BIN_DIR%ts_parser\ts_parser.exe"
set TS2AAC="%BIN_DIR%ts2aac\ts2aac.exe"

REM -----------------------------------------------------------------------
REM ループ処理の開始
REM -----------------------------------------------------------------------
:loop
if "%~n1" == "" goto end

if %~x1 == .avs (
  echo [エラー] avsファイルではなく動画ファイルをドロップしてください。
  echo.
  goto :end
)

set FULLNAME=%1
set PATHNAME=%~dp1
set FILENAME=%~n1
set AVS="%~dpn1.avs"

REM -----------------------------------------------------------------------
REM 出力ファイル名
REM -----------------------------------------------------------------------
set output_enc="%OUTPUT_DIR%%FILENAME%.enc.mp4"
set output_aac="%OUTPUT_DIR%%FILENAME%.aac"
set output_m4a="%OUTPUT_DIR%%FILENAME%.m4a"
set output_mp4="%OUTPUT_DIR%%FILENAME%.mp4"

echo ======================================================================
echo 処理開始: %date% %time%
echo ======================================================================
echo %FULLNAME%
echo.

REM -----------------------------------------------------------------------
REM DVDソースのみアスペクト比を設定
REM -----------------------------------------------------------------------
for /f "delims=" %%A in ('%BIN_DIR%MediaInfo\MediaInfo.exe %FULLNAME% ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set WIDTH=%%A
for /f "delims=" %%A in ('%BIN_DIR%MediaInfo\MediaInfo.exe %FULLNAME% ^| grep "Display aspect ratio" ^| sed -r "s/Display aspect ratio *: (.*)/\1/"') do set ASPECT=%%A
if %WIDTH% == 720 (
  if %ASPECT% == 16:9 (
    set SAR=--sar 32:27
  ) else (
    set SAR=--sar 8:9
  )
) else (
  set SAR=--sar 1:1
)

REM -----------------------------------------------------------------------
REM TSファイル分離
REM -----------------------------------------------------------------------
echo dir /b "%PATHNAME%%FILENAME% *DELAY*.aac"
for /f "usebackq tokens=*" %%A in (`dir /b "%PATHNAME%%FILENAME% *DELAY*.aac"`) do set AAC_FILE=%%A
echo %AAC_FILE%
pause
if not exist %AAC_FILE% (
  call %TS_PARSER% --mode da --delay-type 3 --rb-size 4096 --wb-size 8192 --debug 1 %FULLNAME%
)
call %TSSPRITTER% -EIT -ECM -EMM -SD -1SEG -SEP %FULLNAME%
pause

echo ======================================================================
echo NVEncCで映像エンコード
echo ======================================================================
REM %NVCENC% %NVCENC_OPTION% %SAR% -i %AVS% -o %output_enc%
echo.

echo ======================================================================
echo qaacで音声エンコード(aac)
echo ======================================================================
%QAAC% -q 2 --abr 192 --ignorelength %FULLNAME% -o %output_aac%
echo.

echo ======================================================================
echo L-SMASHで音声mux
echo ======================================================================
%MUXER% -i %output_aac% -o %output_m4a%
echo.

echo ======================================================================
echo L-SMASHで映像・音声remux
echo ======================================================================
%REMUXER% -i %output_enc% -i %output_m4a% -o %output_mp4%
echo.

echo ======================================================================
echo 一時ファイル削除
echo ======================================================================
echo 不要になった一時ファイルを削除します。
echo.
REM pause

if exist %output_mp4% del /f /q %output_enc%
if exist %output_mp4% del /f /q %output_aac%
if exist %output_mp4% del /f /q %output_m4a%

if not exist %output_enc% echo %output_enc%
if not exist %output_aac% echo %output_aac%
if not exist %output_m4a% echo %output_m4a%
echo.

echo ======================================================================
echo 処理終了: %date% %time%
echo ======================================================================

shift
goto loop
:end

pause
exit
