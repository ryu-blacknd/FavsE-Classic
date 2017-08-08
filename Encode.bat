@echo off

REM -----------------------------------------------------------------------
REM x264パラメータ (クォリティ = アニメ19～21, 実写21～23 程度)
REM -----------------------------------------------------------------------
set quality=19
REM set quality=23
REM -----------------------------------------------------------------------
REM x264パラメータ (アスペクト比 = 1:1 or リサイズ済み, 16:9, 4:3)
REM -----------------------------------------------------------------------
REM set aspect=1:1
REM set aspect=32:27
REM set aspect=8:9
REM -----------------------------------------------------------------------
REM x264パラメータ (ソースタイプ = アニメ, 実写)
REM -----------------------------------------------------------------------
REM set source_type=--psy-rd 0.2:0 --trellis 2
set source_type=--psy-rd 0.6:0 --trellis 1
REM -----------------------------------------------------------------------
REM x264パラメータ (詳細)
REM -----------------------------------------------------------------------
set x264=--crf %quality% --sar %aspect% --qpmin 10 --qcomp 0.8 --scenecut 50 --min-keyint 1 --direct auto --weightp 1 --bframes 4 --b-adapt 2 --b-pyramid normal --ref 4 --rc-lookahead 50 --qpstep 4 --aq-mode 2 --aq-strength 0.80 --me umh --subme 9 %source_type% --no-fast-pskip --no-dct-decimate --thread-input

REM -----------------------------------------------------------------------
REM プログラムフォルダと出力先フォルダ
REM -----------------------------------------------------------------------
set program_dir=C:\DTV\Encode\
set output_dir=F:\Encode\

REM -----------------------------------------------------------------------
REM プログラムファイル名
REM -----------------------------------------------------------------------
set x264_path="%program_dir%x264_x64.exe"
set wavi_path="%program_dir%wavi_x64.exe"
set qaac_path="%program_dir%qaac64.exe"
set muxer_path="%program_dir%muxer.exe"
set remuxer_path="%program_dir%remuxer.exe"

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
echo %input_avs%
echo.

echo ======================================================================
echo x264で映像エンコード
echo ======================================================================
%x264_path% %x264% -o %output_enc% %input_avs%
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
