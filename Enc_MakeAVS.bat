@echo off

REM -----------------------------------------------------------------------
REM NVEncCまたはx264のオプション(コメントインされている方がエンコードに使用されます)
REM -----------------------------------------------------------------------
set nvencc_opt=--avs --cqp 21:23:23
REM set x264_opt=--crf 21 --qpmin 10 --qcomp 0.8 --scenecut 50 --min-keyint 1 --direct auto --weightp 1 --bframes 4 --b-adapt 2 --b-pyramid normal --ref 4 --rc-lookahead 50 --qpstep 4 --aq-mode 2 --aq-strength 0.80 --me umh --subme 9 --psy-rd 0.6:0 --trellis 1 --no-fast-pskip --no-dct-decimate --thread-input

REM -----------------------------------------------------------------------
REM フォルダ名(必要に応じて書き換えてください)
REM -----------------------------------------------------------------------
set output_path=F:\Encode\
set bin_path=C:\DTV\bin\
set logo_path=%bin_path%join_logo_scp\logo\
set cut_result_path=%bin_path%join_logo_scp\result\

REM -----------------------------------------------------------------------
REM 実行ファイルダ名(必要に応じて書き換えてください)
REM -----------------------------------------------------------------------
set nvencc=%bin_path%NVEncC.exe
set avs2pipemod=%bin_path%avs2pipemod.exe
set fawcl=%bin_path%fawcl.exe
set muxer=%bin_path%muxer.exe
set remuxer=%bin_path%remuxer.exe

set mediainfo=%bin_path%MediaInfo\MediaInfo.exe
set rplsinfo=%bin_path%rplsinfo.exe
set ts_spritter=%bin_path%TsSplitter\TsSplitter.exe
set ts_parser=%bin_path%ts_parser\ts_parser.exe
set join_logo_scp=%bin_path%join_logo_scp\jlse_bat.bat

REM -----------------------------------------------------------------------
REM ループ処理の開始
REM -----------------------------------------------------------------------
:loop
if "%~1" == "" goto end

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
set is_dvd=0
for /f "delims=" %%A in ('%mediainfo% %1 ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set width=%%A
if %width% == 720 set is_dvd=1

REM -----------------------------------------------------------------------
REM 変数セット
REM -----------------------------------------------------------------------
set file_path=%~dp1
set file_name=%~n1
set file_fullpath=%~dpn1

if %is_dvd% == 1 goto :SET_DVD
set source_file_name=%file_fullpath%_HD
set cut_dir_name=%file_name%_HD
goto :END_SET
:SET_DVD
set source_file_name=%file_fullpath%
:END_SET
set source_file_fullpath=%source_file_name%.ts

set avs="%file_fullpath%.avs"
set output_enc="%output_path%%file_name%.enc.mp4"
set output_wav="%output_path%%file_name%.wav"
set output_aac="%output_path%%file_name%.aac"
set output_m4a="%output_path%%file_name%.m4a"
set output_mp4="%output_path%%file_name%.mp4"

echo ======================================================================
echo 処理開始
echo ======================================================================
echo %file_fullpath%
echo.

REM -----------------------------------------------------------------------
REM DVDソースのみアスペクト比を変更
REM -----------------------------------------------------------------------
for /f "delims=" %%A in ('%mediainfo% "%source_file_fullpath%" ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set width=%%A
for /f "delims=" %%A in ('%mediainfo% "%source_file_fullpath%" ^| grep "Display aspect ratio" ^| sed -r "s/Display aspect ratio *: (.*)/\1/"') do set aspect=%%A

if %width% == 720 (
  if %aspect% == 16:9 (
    set sar=--sar 32:27
  ) else (
    set sar=--sar 8:9
  )
) else (
  set sar=--sar 1:1
)

echo ======================================================================
echo TSSplitter処理
echo ======================================================================
if not exist "%source_file_fullpath%" (
  call %ts_spritter% -EIT -ECM -EMM -SD -1SEG "%file_fullpath%.ts"
) else (
   echo 既にファイルが存在します。
)
echo.

echo ======================================================================
echo  音声分離処理
echo ======================================================================
if not exist "%source_file_name% PID *.aac" (
  call %ts_parser% --mode da --delay-type 3 --rb-size 16384 --wb-size 32768 "%source_file_fullpath%"
) else (
  echo 既にファイルが存在します。
)
for /f "usebackq tokens=*" %%A in (`dir /b "%source_file_name% PID *.aac"`) do set aac_fullpath=%file_path%%%A
echo.


echo ======================================================================
echo avsファイル生成処理
echo ======================================================================
if exist %avs% del %avs%

echo SetMemoryMax(2048)>>%avs%
echo.>>%avs%

echo ### ファイル読み込み ###>>%avs%
echo LWLibavVideoSource("%source_file_fullpath%", fpsnum=30000, fpsden=1001)>>%avs%
echo AudioDub(last, AACFaw("%aac_fullpath%"))>>%avs%
echo.>>%avs%

echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%

echo ### フィールドオーダー ###>>%avs%
for /f "delims=" %%A in ('%mediainfo% "%source_file_fullpath%" ^| grep "Scan type" ^| sed -r "s/Scan type *: (.*)/\1/"') do set scan_type=%%A
for /f "delims=" %%A in ('%mediainfo% "%source_file_fullpath%" ^| grep "Scan order" ^| sed -r "s/Scan order *: (.*)/\1/"') do set scan_order=%%A

if "%scan_type%" == "Progressive" (
  echo # %scan_type%>>%avs%
  goto :end_scan
)
if "%scan_order%" == "Top Field First" echo AssumeTFF()>>%avs%
if "%scan_order%" == "Bottom Field First" echo AssumeBFF()>>%avs%
:end_scan
echo.>>%avs%

if %is_dvd% == 1 goto :end_cm_logo_cut
echo SetMTMode(1, 0)>>%avs%
echo.>>%avs%

echo ### CMカット ###>>%avs%
set cut_fullpath="%cut_result_path%%cut_dir_name%\obs_cut.avs"
if exist %cut_fullpath% goto :end_cm_cut
call %join_logo_scp% "%source_file_fullpath%"
:end_cm_cut

sleep 2
for /f "usebackq tokens=*" %%A in (%cut_fullpath%) do set trim_line=%%A
echo %trim_line%>>%avs%
echo.>>%avs%

echo ### ロゴ除去 ###>>%avs%
for /f "delims=" %%A in ('%rplsinfo% "%source_file_fullpath%" -c') do set service=%%A
echo #サービス名：%service%>>%avs%
echo EraseLOGO("%logo_path%%service%.lgd", pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true)>>%avs%
echo.>>%avs%

echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%
:end_cm_logo_cut

if "%scan_type%" == "Progressive" goto :end_deint
echo ### 逆テレシネ / インターレース処理 ###>>%avs%
set is_ivtc=0

if %is_dvd% == 0 goto :not_dvd
echo #TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto :end_not_dvd

:not_dvd
for /f "delims=" %%A in ('%rplsinfo% "%source_file_fullpath%" -g') do set genre=%%A
echo #ジャンル名：%genre%>>%avs%
if "%scan_type%" == "Progressive" goto :end_deint
echo %genre% | find "映画" > NUL
if not ERRORLEVEL 1 goto :set_tivtc24p2
echo %genre% | find "アニメ" > NUL
if not ERRORLEVEL 1 goto :set_tivtc24p2
goto :set_tdeint
goto :end_deint

:set_tivtc24p2
set is_ivtc=1
echo TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto :end_deint
:set_tdeint
echo #TIVTC24P2()>>%avs%
echo TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
:end_deint

:end_not_dvd

if %is_dvd% == 1 goto :end_resize
echo ### リサイズ ###>>%avs%
echo (Width() ^> 1280) ? Spline36Resize(1280, 720, 0, 0.6) : last>>%avs%
echo.>>%avs%

:end_resize

echo return last>>%avs%

if "%scan_type%" == "Progressive" goto :end_tivtc24p2
echo.>>%avs%
echo function TIVTC24P2(clip clip){>>%avs%
echo Deinted=clip.TDeint(order=-1,field=-1,edeint=clip.nnedi3(field=-1))>>%avs%
echo clip = clip.TFM(mode=6,order=-1,PP=7,slow=2,mChroma=true,clip2=Deinted)>>%avs%
echo clip = clip.TDecimate(mode=1)>>%avs%
echo return clip>>%avs%
echo }>>%avs%
:end_tivtc24p2

echo avsファイルを生成しました。
echo.

echo ======================================================================
echo 映像エンコード
echo ======================================================================
if not exist %output_enc% (
  if defined %nvencc_opt% call %nvencc% %nvencc_opt% %sar% -i %avs% -o %output_enc%
  if defined %x264_opt% call %x264% %x264_opt% %sar% -o %output_enc% %avs%
) else (
   echo 既にファイルが存在します。
)
echo.

echo ======================================================================
echo 音声処理
echo ======================================================================
if not exist %output_wav% (
  call %avs2pipemod% -wav %avs% > %output_wav%
) else (
   echo 既にファイルが存在します。
)
if not exist %output_aac% (
  call %fawcl% %output_wav% %output_aac%
) else (
   echo 既にファイルが存在します。
)
echo.

echo ======================================================================
echo muxer
echo ======================================================================
call %muxer% -i %output_aac% -o %output_m4a%
echo.

echo ======================================================================
echo remuxer
echo ======================================================================
call %remuxer% -i %output_enc% -i %output_m4a% -o %output_mp4%
echo.

echo ======================================================================
echo 一時ファイルについて
echo ======================================================================
REM echo 不要になった一時ファイルを削除します。
echo 生成された一時ファイル群は再度エンコードする際に使用できます。
echo 不要であれば削除してください。
echo 処理をやり直したい部分の一時ファイルのみ削除しても問題なく動作します。
echo.

REM if exist %avs% del /f /q %avs%
REM if exist %file_fullpath%.lwi del /f /q %file_fullpath%.lwi
REM if exist %source_file_fullpath% del /f /q %source_file_fullpath%
REM if exist %source_file_fullpath%.lwi del /f /q %source_file_fullpath%.lwi
REM if exist %aac_fullpath% del /f /q %aac_fullpath%
REM if exist %aac_fullpath%.lwi del /f /q %aac_fullpath%.lwi
REM if exist %output_enc% del /f /q %output_enc%
REM if exist %output_wav% del /f /q %output_wav%
REM if exist %output_aac% del /f /q %output_aac%
REM if exist %output_m4a% del /f /q %output_m4a%

REM if not exist %avs% echo %avs%
REM if not exist %file_fullpath%.lwi echo %file_fullpath%.lwi
REM if not exist %source_file_fullpath% echo %source_file_fullpath%
REM if not exist %source_file_fullpath%.lwi echo %source_file_fullpath%.lwi
REM if not exist %aac_fullpath% echo %aac_fullpath%
REM if not exist %aac_fullpath%.lwi echo %aac_fullpath%.lwi
REM if not exist %output_enc% echo %output_enc%
REM if not exist %output_wav% echo %output_wav%
REM if not exist %output_aac% echo %output_aac%
REM if not exist %output_m4a% echo %output_m4a%
echo.

echo ======================================================================
echo 処理終了: %date% %time%
echo ======================================================================

shift
goto loop
:end

pause
