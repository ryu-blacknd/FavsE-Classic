@echo off

rem -----------------------------------------------------------------------
rem 初期設定
rem -----------------------------------------------------------------------
set program_dir=C:\DTV\Encode\
set output_dir=F:\

rem -----------------------------------------------------------------------
rem プログラムファイル名
rem -----------------------------------------------------------------------
set x264_path="%program_dir%x264_64.exe"
set wavi_path="%program_dir%wavi_x64.exe"
set qaac_path="%program_dir%qaac64.exe"
set muxer_path="%program_dir%muxer.exe"
set remuxer_path="%program_dir%remuxer.exe"

rem -----------------------------------------------------------------------
rem x264パラメータ
rem -----------------------------------------------------------------------
REM set quality=20
set quality=23
set aspect=1:1
REM set aspect=32:27
REM set aspect=8:9
rem -----------------------------------------------------------------------
set x264=--crf %quality% --sar %aspect% --level 4.1 --bframes 4 --b-adapt 2 --b-pyramid normal --ref 4 --rc-lookahead 50 --qpstep 4 --aq-mode 2 --aq-strength 0.80 --me umh --subme 9 --psy-rd 0.6:0 --trellis 1 --no-fast-pskip --no-dct-decimate --threads 0 --thread-input

rem -----------------------------------------------------------------------
rem ループ処理の開始
rem -----------------------------------------------------------------------
:loop
if "%~1" == "" goto end

set input_avs="%~1"
set filename=%~n1

rem -----------------------------------------------------------------------
rem 出力ファイル名
rem -----------------------------------------------------------------------
set output_enc="%output_dir%%filename%.enc.mp4"
set output_wav="%output_dir%%filename%.wav"
set output_aac="%output_dir%%filename%.aac"
set output_m4a="%output_dir%%filename%.m4a"
set output_mp4="%output_dir%%filename%.mp4"

echo ======================================================================
echo 処理開始
echo ======================================================================
echo %input_avs%
echo.

echo ======================================================================
echo x264で映像エンコード
echo ======================================================================
%x264_path% %x264% -o %output_enc% %input_avs%
REM %
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
REM del /f /q %output_mp4%
REM del /f /q %output_wav%
REM del /f /q %output_aac%
REM del /f /q %output_m4a%
if not exist %output_mp4% echo %output_mp4%
if not exist %output_wav% echo %output_wav%
if not exist %output_aac% echo %output_aac%
if not exist %output_m4a% echo %output_m4a%
echo.
echo.

shift
goto loop
:end

pause
exit
