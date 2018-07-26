@echo off

echo FullAuto AVS Encode 1.26

REM ----------------------------------------------------------------------
REM エンコーダの指定（0:x264, 1:NVEncC）
REM ----------------------------------------------------------------------
set use_nvenvc=0

REM ----------------------------------------------------------------------
REM Width:1280pxを超える場合に1280x720pxに縮小するか（0:しない, 1:する）
REM ----------------------------------------------------------------------
set resize=1

REM ----------------------------------------------------------------------
REM DVDソースのインターレース解除モード（0:通常, 1:BOB化, 2:24fps化）
REM ----------------------------------------------------------------------
set deint_mode=2

REM ----------------------------------------------------------------------
REM TSSplitterでの分離処理を行うか（0:行わない, 1:行う）
REM ----------------------------------------------------------------------
set do_ts_spritter=1

REM ----------------------------------------------------------------------
REM 自動CMカット処理を行うか（0:行わない, 1:行う）
REM ----------------------------------------------------------------------
set cm_cut=1

REM ----------------------------------------------------------------------
REM avs生成後に処理を一時停止するか（0:しない, 1:する）
REM ----------------------------------------------------------------------
set check_avs=0

REM ----------------------------------------------------------------------
REM 終了後に一時ファイルを削除するか（0:しない, 1:する）
REM ----------------------------------------------------------------------
set del_temp=1

REM ----------------------------------------------------------------------
REM ビットレートの指定（NVEncCのみ）
REM ----------------------------------------------------------------------
REM アニメ用
set bitrate_anime=2765
REM 実写映画用
set bitrate_movie=3456
REM その他（TV番組等）
set bitrate_default=4147
REM SD素材（DVD等）
set bitrate_dvd=2592

REM ----------------------------------------------------------------------
REM エンコーダのオプション（ビットレート、アスペクト比は自動設定）
REM ----------------------------------------------------------------------
if %use_nvenvc% == 1 (
  set nvencc_opt=--avs --qp-init 19:22:24 --qp-min 18:21:23 --lookahead 20 --aq
) else (
  set x264_opt=--preset slower --crf 19 --partitions p8x8,b8x8,i8x8,i4x4 --ref 4 --no-fast-pskip --no-dct-decimate
)

REM ----------------------------------------------------------------------
REM フォルダ名(必要に応じて書き換えてください)
REM ----------------------------------------------------------------------
set output_path=F:\Encode\
set bin_path=C:\DTV\bin\
set logo_path=%bin_path%join_logo_scp\logo\
set cut_result_path=%bin_path%join_logo_scp\result\

REM ----------------------------------------------------------------------
REM 実行ファイルダ名(必要に応じて書き換えてください)
REM ----------------------------------------------------------------------
set nvencc=%bin_path%NVEncC.exe
set x264=%bin_path%x264.exe
set avs2pipemod=%bin_path%avs2pipemod.exe
set fawcl=%bin_path%fawcl.exe
REM set qaac=%bin_path%qaac.exe
set muxer=%bin_path%muxer.exe
set remuxer=%bin_path%remuxer.exe

set mediainfo=%bin_path%MediaInfo\MediaInfo.exe
set rplsinfo=%bin_path%rplsinfo.exe
set ts_spritter=%bin_path%TsSplitter\TsSplitter.exe
set ts_parser=%bin_path%ts_parser\ts_parser.exe
set join_logo_scp=%bin_path%join_logo_scp\jlse_bat.bat

:loop
if "%~1" == "" goto end

if %~x1 == .ts (
  echo.
) else (
  echo [エラー] 変換元のTSファイルをドロップしてください。
  echo.
  goto end
)

echo ======================================================================
echo %~1
echo ----------------------------------------------------------------------
echo 処理開始: %date% %time%
echo ======================================================================
echo.

REM ----------------------------------------------------------------------
REM DVDソースか判定
REM ----------------------------------------------------------------------
set is_dvd=0
for /f "delims=" %%A in ('%mediainfo% %1 ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set width=%%A
if %width% == 720 set is_dvd=1

REM ----------------------------------------------------------------------
REM 変数セット
REM ----------------------------------------------------------------------
set file_path=%~dp1
set file_name=%~n1
set file_fullname=%~dpn1
set file_fullpath=%~1

if %is_dvd% == 1 goto source_dvd
if %do_ts_spritter% == 0 goto source_dvd
set source_fullname=%file_fullname%_HD
set source_fullname=%file_fullname%_HD
set cut_dir_name=%file_name%_HD
goto end_source
:source_dvd
set source_fullname=%file_fullname%
:end_source
set source_fullpath=%source_fullname%.ts

set avs="%source_fullname%.avs"
set output_enc="%output_path%%file_name%.enc.mp4"
set output_wav="%output_path%%file_name%.wav"
set output_aac="%output_path%%file_name%.aac"
set output_m4a="%output_path%%file_name%.m4a"
set output_mp4="%output_path%%file_name%.mp4"

REM ----------------------------------------------------------------------
REM DVDソースのみアスペクト比を変更
REM ----------------------------------------------------------------------
for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set width=%%A
for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Display aspect ratio" ^| sed -r "s/Display aspect ratio *: (.*)/\1/"') do set aspect=%%A

if %width% == 720 (
  if %aspect% == 16:9 (
    set sar=--sar 32:27
  ) else (
    set sar=--sar 8:9
  )
) else (
  set sar=--sar 1:1
)

if %do_ts_spritter% == 0 goto end_ts_spritter
echo ----------------------------------------------------------------------
echo TSSplitter処理
echo ----------------------------------------------------------------------
if %is_dvd% == 0 (
  if not exist "%source_fullpath%" (
    call %ts_spritter% -EIT -ECM -EMM -SD -1SEG "%file_fullpath%"
  ) else (
    echo 既に処理済みのファイルが存在します。
  )
) else (
  echo 処理は必要ありません。
)
echo.
:end_ts_spritter

echo ----------------------------------------------------------------------
echo  音声分離処理
echo ----------------------------------------------------------------------
if not exist "%source_fullname% PID *.aac" (
  call %ts_parser% --mode da --delay-type 3 --rb-size 16384 --wb-size 32768 "%source_fullpath%"
) else (
  echo 既に分離された音声ファイルが存在します。
)
for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *.aac"`) do set aac_fullpath=%file_path%%%A
echo.

echo ----------------------------------------------------------------------
echo avsファイル生成処理
echo ----------------------------------------------------------------------
if exist %avs% (
  echo 既にavsファイルが存在します。
  goto end_avs
)

echo SetMemoryMax(2048)>>%avs%
echo.>>%avs%

echo ### ファイル読み込み ###>>%avs%
echo LWLibavVideoSource("%source_fullpath%", fpsnum=30000, fpsden=1001)>>%avs%
echo AudioDub(last, AACFaw("%aac_fullpath%"))>>%avs%
echo.>>%avs%

echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%

echo ### フィールドオーダー ###>>%avs%
for /f "delims=" %%A in ('%mediainfo% "%source_fullpath%" ^| grep "Scan type" ^| sed -r "s/Scan type *: (.*)/\1/"') do set scan_type=%%A
for /f "delims=" %%A in ('%mediainfo% "%source_fullpath%" ^| grep "Scan order" ^| sed -r "s/Scan order *: (.*)/\1/"') do set scan_order=%%A

if "%scan_type%" == "Progressive" (
  echo # %scan_type%>>%avs%
  goto end_scan
)
if "%scan_order%" == "Top Field First" echo AssumeTFF()>>%avs%
if "%scan_order%" == "Bottom Field First" echo AssumeBFF()>>%avs%
:end_scan
echo.>>%avs%

if %is_dvd% == 1 goto end_cm_logo_cut
echo SetMTMode(1, 0)>>%avs%
echo.>>%avs%

echo ### サービス情報取得 ###>>%avs%
for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -c') do set service=%%A
echo #サービス名：%service%>>%avs%
echo.>>%avs%

if %cm_cut% == 0 goto end_do_cm_cut
echo ### 自動CMカット ###>>%avs%
set cut_fullpath="%cut_result_path%%cut_dir_name%\obs_cut.avs"
if exist %cut_fullpath% goto end_cm_cut
call %join_logo_scp% "%source_fullpath%"
:end_cm_cut

sleep 2
for /f "usebackq tokens=*" %%A in (%cut_fullpath%) do set trim_line=%%A
echo %trim_line%>>%avs%
echo.>>%avs%
:end_do_cm_cut

echo ### ロゴ除去 ###>>%avs%
echo EraseLOGO("%logo_path%%service%.lgd", pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true)>>%avs%
echo.>>%avs%

echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%
:end_cm_logo_cut

if "%scan_type%" == "Progressive" goto end_deint
echo ### 逆テレシネ / インターレース処理 ###>>%avs%
set is_ivtc=0

if %is_dvd% == 0 goto not_dvd
if %deint_mode% == 0 goto dvd_deint_normal
if %deint_mode% == 1 goto dvd_deint_bob
if %deint_mode% == 2 goto dvd_deint_24p
:dvd_deint_normal
echo TDeint(edeint=nnedi3)>>%avs%
goto end_dvd_deint
:dvd_deint_bob
echo TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
goto end_dvd_deint
:dvd_deint_24p
echo TIVTC24P2()>>%avs%
:end_dvd_deint
echo.>>%avs%
goto end_deint

:not_dvd
for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -g') do set genre=%%A
echo #ジャンル名：%genre%>>%avs%
if "%scan_type%" == "Progressive" goto end_deint
echo %genre% | find "アニメ" > NUL
if not ERRORLEVEL 1 goto set_tivtc24p2
echo %genre% | find "映画" > NUL
if not ERRORLEVEL 1 goto set_tivtc24p2
goto set_tdeint

:set_tivtc24p2
set is_ivtc=1
echo TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint
:set_tdeint
echo #TIVTC24P2()>>%avs%
echo TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
:end_deint

if %is_dvd% == 1 goto end_resize
if %resize% == 0 goto end_resize
echo ### リサイズ ###>>%avs%
echo (Width() ^> 1280) ? Spline36Resize(1280, 720) : last>>%avs%
echo.>>%avs%

:end_resize

echo ### シャープ化 ###>>%avs%
echo #Sharpen(0.02)>>%avs%
echo.>>%avs%

echo return last>>%avs%

if "%scan_type%" == "Progressive" goto end_tivtc24p2
echo.>>%avs%
echo function TIVTC24P2(clip clip){>>%avs%
echo Deinted=clip.TDeint(order=-1,field=-1,edeint=clip.nnedi3(field=-1))>>%avs%
echo clip = clip.TFM(mode=6,order=-1,PP=7,slow=2,mChroma=true,clip2=Deinted)>>%avs%
echo clip = clip.TDecimate(mode=1)>>%avs%
echo return clip>>%avs%
echo }>>%avs%
:end_tivtc24p2

echo avsファイルを生成しました。

:end_avs
echo.

if %check_avs% == 1 (
  echo ※avsファイル確認オプションが設定されています。
  echo ※avsファイルを確認し、必要であれば編集してください。
  echo ※確認・編集完了後はこのまま処理を続行できます。
  echo.
  pause
)
echo.

REM ----------------------------------------------------------------------
REM ビットレートを設定（NVEncCのみ）
REM ----------------------------------------------------------------------
if %use_nvenvc% == 0 goto end_bitrate
if %is_dvd% == 0 (
  echo %genre% | find "アニメ" > NUL
  if not ERRORLEVEL 1 (
    set bitrate_val=%bitrate_anime%
    goto set_bitrate
  )
  echo %genre% | find "映画" > NUL
  if not ERRORLEVEL 1 (
    set bitrate_val=%bitrate_movie%
    goto set_bitrate
  )
  set bitrate_val=%bitrate_default%
) else (
  set bitrate_val=%bitrate_dvd%
)
:set_bitrate
set bitrate=--vbrhq %bitrate_val%
:end_bitrate

echo ----------------------------------------------------------------------
echo 映像エンコード
echo ----------------------------------------------------------------------
if not exist %output_enc% (
  if %use_nvenvc% == 1 (
    call %nvencc% %nvencc_opt% %bitrate% %sar% -i %avs% -o %output_enc%
  ) else (
    call %x264% %x264_opt% %sar% -o %output_enc% %avs%
  )
) else (
  echo 既にエンコード済みファイルが存在します。
)
echo.

echo ----------------------------------------------------------------------
echo 音声処理
echo ----------------------------------------------------------------------
if not exist %output_wav% (
  call %avs2pipemod% -wav %avs% > %output_wav%
) else (
  echo 既にwavファイルが存在します。
)
if not exist %output_aac% (
  call %fawcl% %output_wav% %output_aac%
  REM call %qaac% -q 2 --tvbr 91 %output_wav% -o %output_aac%
  REM call %qaac% -q 2 --tvbr 91 "%aac_fullpath%" -o %output_aac%
) else (
  echo 既にaacファイルが存在します。
)
echo.

echo ----------------------------------------------------------------------
echo muxer処理
echo ----------------------------------------------------------------------
if not exist %output_m4a% (
  call %muxer% -i %output_aac% -o %output_m4a%
) else (
  echo 既にm4aファイルが存在します。
)
echo.

echo ----------------------------------------------------------------------
echo remuxer処理
echo ----------------------------------------------------------------------
if not exist %output_mp4% (
  call %remuxer% -i %output_enc% -i %output_m4a% -o %output_mp4%
) else (
  echo 既にmp4ファイルが存在します。
)
echo.

echo ----------------------------------------------------------------------
echo 一時ファイル処理
echo ----------------------------------------------------------------------
if %del_temp% == 0 goto no_del_temp
echo 不要になった一時ファイルを削除します。
echo.
if exist "%file_fullname%.lwi" del /f /q "%file_fullname%.lwi"
if exist "%source_fullpath%.lwi" del /f /q "%source_fullpath%.lwi"
if exist "%aac_fullpath%.lwi" del /f /q "%aac_fullpath%.lwi"
if exist %avs% del /f /q %avs%
if exist "%aac_fullpath%" del /f /q "%aac_fullpath%"
if %is_dvd% == 0 if exist "%source_fullpath%" del /f /q "%source_fullpath%"
if exist %output_enc% del /f /q %output_enc%
if exist %output_wav% del /f /q %output_wav%
if exist %output_aac% del /f /q %output_aac%
if exist %output_m4a% del /f /q %output_m4a%

if not exist "%file_fullname%.lwi" echo "%file_fullname%.lwi"
if not exist "%source_fullpath%.lwi" echo "%source_fullpath%.lwi"
if not exist "%aac_fullpath%.lwi" echo "%aac_fullpath%.lwi"
if not exist %avs% echo %avs%
if not exist "%aac_fullpath%" echo "%aac_fullpath%"
if %is_dvd% == 0 if not exist "%source_fullpath%" echo "%source_fullpath%"
if not exist %output_enc% echo %output_enc%
if not exist %output_wav% echo %output_wav%
if not exist %output_aac% echo %output_aac%
if not exist %output_m4a% echo %output_m4a%
echo.
goto end_del_temp

:no_del_temp
echo 一時ファイル群は残っており、次回エンコードする際には再利用（処理をスキップ）します。
echo 特定の処理をやり直したい場合は、該当部分の一時ファイルを削除して再実行してください。
echo 不要になったら、すべての一時ファイルは削除して構いません。
echo.
:end_del_temp

echo ======================================================================
echo %~1
echo ----------------------------------------------------------------------
echo 処理終了: %date% %time%
echo ======================================================================

shift
goto loop
:end

pause
