@echo off

REM -----------------------------------------------------------------------
REM NVEncCパラメータ
REM -----------------------------------------------------------------------
set bitrate=2600
set maxbitrate=16000
REM -------------------------------
REM set bitrate=3500
REM set maxbitrate=26000
REM -------------------------------
REM set bitrate=12000
REM set maxbitrate=45000
REM -----------------------------------------------------------------------
REM NVEncCパラメータ (アスペクト比 = 1:1 or リサイズ済み, 16:9, 4:3)
REM -----------------------------------------------------------------------
set aspect=--sar 32:27
REM set aspect=--sar 8:9
REM -----------------------------------------------------------------------
REM NVEncCパラメータ (詳細)
REM -----------------------------------------------------------------------
set nvcencc=--avs -c hevc --vbrhq %bitrate% --maxbitrate %maxbitrate% %aspect% --vbr-quality 0 --aq --aq-strength 0 --lookahead 20

REM -----------------------------------------------------------------------
REM プログラムフォルダと出力先フォルダ
REM -----------------------------------------------------------------------
set program_dir=C:\DTV\Encode\
set output_dir=F:\Encode\

REM -----------------------------------------------------------------------
REM プログラムファイル名
REM -----------------------------------------------------------------------
REM set nvcencc_path="%program_dir%NVEncC64.exe"
set nvcencc_path="%program_dir%NVEncC64.exe"
set wavi_path="%program_dir%wavi_x64.exe"
set qaac_path="%program_dir%qaac64.exe"
set muxer_path="%program_dir%muxer.exe"
set remuxer_path="%program_dir%remuxer.exe"
set ffmpeg_path="%program_dir%ffmpeg.exe"

REM -----------------------------------------------------------------------
REM ループ処理の開始
REM -----------------------------------------------------------------------
:loop
if "%~1" == "" goto end

set input_avs="%~1"
set filename=%~n1

REM -----------------------------------------------------------------------
REM 出力ファイル名
REM -----------------------------------------------------------------------
set output_enc="%output_dir%%filename%.enc.mp4"
set output_wav="%output_dir%%filename%.wav"
set output_aac="%output_dir%%filename%.aac"
set output_m4a="%output_dir%%filename%.m4a"
set output_mp4="%output_dir%%filename%.mp4"

echo ======================================================================
echo 処理開始: %date% %time%
echo ======================================================================
echo %filename%
echo.

echo ======================================================================
echo NVEncCで映像エンコード
echo ======================================================================
%nvcencc_path% %nvcencc% -i %input_avs% -o %output_enc%
REM %ffmpeg_path% -y -i %input_avs% -an -pix_fmt yuv420p -f yuv4mpegpipe - | %nvcencc_path% --y4m %nvcencc% -i - -o %output_enc%
echo.

echo ======================================================================
echo waviで音声出力(wav)
echo ======================================================================
%wavi_path% %input_avs% %output_wav%
echo.

echo ======================================================================
echo qaacで音声エンコード(aac)
echo ======================================================================
%qaac_path% -q 2 --abr 192 --ignorelength %output_wav% -o %output_aac%
echo.

echo ======================================================================
echo L-SMASHで音声mux
echo ======================================================================
%muxer_path% -i %output_aac% -o %output_m4a%
echo.

echo ======================================================================
echo L-SMASHで映像・音声remux
echo ======================================================================
%remuxer_path% -i %output_enc% -i %output_m4a% -o %output_mp4%
echo.

echo ======================================================================
echo 一時ファイル削除
echo ======================================================================
echo 不要になった一時ファイルを削除します。
echo.
REM pause

if exist %output_mp4% del /f /q %output_enc%
if exist %output_mp4% del /f /q %output_wav%
if exist %output_mp4% del /f /q %output_aac%
if exist %output_mp4% del /f /q %output_m4a%

if not exist %output_enc% echo %output_enc%
if not exist %output_wav% echo %output_wav%
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
