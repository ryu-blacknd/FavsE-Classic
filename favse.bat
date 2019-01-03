@echo off

echo FavsE (FullAuto AVS Encode) 5.06
echo.
REM ===========================================================================
REM CPUのコア数（数値）
REM スレッド数ではなく、スレッド数の半分程度（≒コア数）が良いとされています。
REM ---------------------------------------------------------------------------
set cpu_cores=6
REM ---------------------------------------------------------------------------
REM 映像エンコーダ（0:x264, 1:QSVEnc, 2:NVEnc_AVC, 3:NVEnc_HEVC）※推奨：0
REM 画質の差に見合うほど速度差が大きくないため、最も高画質なx264推奨です。
REM ---------------------------------------------------------------------------
set video_encoder=0
REM ---------------------------------------------------------------------------
REM 音声エンコーダ（0:FAW, 1:qaac）※推奨：0
REM 通常はFAWでOKです。FAWが使用できない場合は自動的にqaacで処理します。
REM ---------------------------------------------------------------------------
set audio_encoder=0

REM ===========================================================================
REM LSMASHSource強制使用（0:DGIndex優先, 1:LSMASH強制）※強制的にqaacを使用
REM TSSplitterやDGIndexの処理を行わずLSMASHSourceで読み込む場合に1にします。
REM ---------------------------------------------------------------------------
set use_lsmash=0
REM ---------------------------------------------------------------------------
REM 音ズレ対策（0:行わない, 1:行う）※音ズレが発生する場合のみ推奨：1
REM どうしても音ズレが発生する場合に、fps固定による音ズレ対策を行います。
REM ---------------------------------------------------------------------------
set assumefps=0
REM ---------------------------------------------------------------------------
REM 自動CMカット処理（0:行わない, 1:行う）※推奨：1
REM 録画tsファイルのみ有効です。完璧ではないため手動カットとの併用推奨です。
REM ---------------------------------------------------------------------------
set cut_cm=1
REM ---------------------------------------------------------------------------
REM ロゴ除去処理（0:行わない, 1:行う）※推奨：1
REM 録画tsファイルのみ有効です。AviUtlでlgdファイルを作成しておく必要があります。
REM ---------------------------------------------------------------------------
set cut_logo=1
REM ---------------------------------------------------------------------------
REM avs生成後に処理を一時停止（0:しない, 1:する）※推奨：1
REM 生成されたスクリプトを確認してから進められます。120秒経つと処理を続行します。
REM ---------------------------------------------------------------------------
set check_avs=1

REM ===========================================================================
REM インターレース解除モード（0:保持, 1:通常解除, 2:24fps化, 3:BOB化）※推奨：1
REM 録画tsファイルの場合は自動判別しますので、この設定は無効となります。
REM ---------------------------------------------------------------------------
set deint_mode=1
REM ---------------------------------------------------------------------------
REM ノイズ除去（0:行わない, 1:行う）
REM 高周波ノイズ除去です。弱め設定です。強めにするには設定値を変更してください。
REM ---------------------------------------------------------------------------
set denoize=0
REM ---------------------------------------------------------------------------
REM リサイズ（0:しない, 1:する）
REM 4Kや1080p等、Widthが1,280pxを超える場合に1,280x720pxにリサイズするか。
REM ---------------------------------------------------------------------------
set resize=1
REM ---------------------------------------------------------------------------
REM シャープ化（0:行わない, 1:行う）
REM 弱めのシャープ化です。例えばノイズ除去後や拡大処理後にはそれなりに有効です。
REM ---------------------------------------------------------------------------
set sharpen=0

REM ===========================================================================
REM 終了後に一時ファイルを削除（0:しない, 1:する）
REM 一時ファイル群を削除できます。0だと放置され、やり直し時に再利用できます。
REM ---------------------------------------------------------------------------
set del_temp=0

REM ===========================================================================
REM ■確認必須：フォルダ名
REM 環境に応じて【必ず】書き換えてください。
REM ---------------------------------------------------------------------------
set output_path=F:\Encode\
set bin_path=C:\DTV\bin\
set logo_path=%bin_path%join_logo_scp\logo\
set cut_result_path=%bin_path%join_logo_scp\result\

REM ---------------------------------------------------------------------------
REM ■確認必須：実行ファイル名
REM 環境に応じて【必ず】書き換えてください。わかる方は必要なものだけで結構です。
REM ---------------------------------------------------------------------------
set x264=%bin_path%x264_x64.exe
set qsvencc=%bin_path%QSVEncC64.exe
set nvencc=%bin_path%NVEncC64.exe

set avs2pipemod=%bin_path%avs2pipemod64.exe
set fawcl=%bin_path%fawcl.exe
set qaac=%bin_path%qaac64.exe
set muxer=%bin_path%muxer.exe
set remuxer=%bin_path%remuxer.exe

set mediainfo=%bin_path%MediaInfo.exe
set rplsinfo=%bin_path%rplsinfo.exe
set tssplitter=%bin_path%TsSplitter.exe
set dgindex=%bin_path%DGIndex.exe
set join_logo_scp=%bin_path%join_logo_scp\jlse_bat.bat

REM ---------------------------------------------------------------------------
REM 映像エンコーダのオプション
REM 設定値の意味がわかる方は自由に改変してください。
REM ---------------------------------------------------------------------------
if %video_encoder% == 0 (
  set x264_opt=--crf 20 --qcomp 0.7 --me umh --subme 9 --direct auto --ref 5 --trellis 2
) else if %video_encoder% == 1 (
  set qsvencc_opt=-c h264 -u 2 --la-icq 24 --la-quality slow --bframes 3 --weightb --weightp
) else if %video_encoder% == 2 (
  set nvencc_opt=--avs -c h264 --cqp 20:22:24 --qp-init 20:22:24 --weightp --aq --aq-temporal
) else if %video_encoder% == 3 (
  set nvencc_opt=--avs -c hevc --cqp 21:22:24 --qp-init 21:22:24 --weightp --aq --aq-temporal
) else (
  echo [エラー] エンコーダを正しく指定してください。
  goto end
)

REM ---------------------------------------------------------------------------
REM 設定ここまで
REM ===========================================================================

:loop
if "%~1" == "" goto end
set file_ext=%~x1

if %file_ext% == .avs echo avsファイルではなく動画ファイルをドラッグしてください。 & goto end

echo ===========================================================================
echo %~1
echo ---------------------------------------------------------------------------
echo 処理開始: %date% %time%
echo ===========================================================================
echo.

REM ---------------------------------------------------------------------------
REM SD（主にDVDソース）かをサイズ取得で判定
REM ---------------------------------------------------------------------------
set is_sd=0
for /f "delims=" %%A in ('%mediainfo% -f %1 ^| grep "Width" ^| head -n 1 ^| sed -r "s/Width *: (.*)/\1/"') do set info_width=%%A
for /f "delims=" %%A in ('%mediainfo% -f %1 ^| grep "Height" ^| head -n 1 ^| sed -r "s/Height *: (.*)/\1/"') do set info_height=%%A

if %info_width% == 720 set is_sd=1

REM ---------------------------------------------------------------------------
REM 変数セット1
REM ---------------------------------------------------------------------------
set file_path=%~dp1
set file_name=%~n1
set file_fullname=%~dpn1
set file_fullpath=%~1

REM ---------------------------------------------------------------------------
REM 動画情報取得
REM ---------------------------------------------------------------------------
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Commercial name" ^| head -n 1 ^| sed -r "s/Commercial name *: (.*)/\1/"') do set info_container=%%A

for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Codecs Video" ^| sed -r "s/Codecs Video *: (.*)/\1/"') do set info_vcodec=%%A
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Audio codecs" ^| sed -r "s/Audio codecs *: (.*)/\1/"') do set info_acodec=%%A

for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Bit depth" ^| head -n 1 ^| sed -r "s/Bit depth *: (.*)/\1/"') do set info_bitdepth=%%A
for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Display aspect ratio" ^| sed -r "s/Display aspect ratio *: (.*)/\1/"') do set info_aspect=%%A

for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Scan type" ^| sed -r "s/Scan type *: (.*)/\1/"') do set info_scan_type=%%A
for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Scan order" ^| sed -r "s/Scan order *: (.*)/\1/"') do set info_scan_order=%%A

echo 動画コンテナ　　：%info_container%
echo 映像コーデック　：%info_vcodec%
echo 音声コーデック　：%info_acodec%
echo ビット深度　　　：%info_bitdepth%ビット
echo 映像サイズ　　　：%info_width%x%info_height%px
echo 出力アスペクト比：%info_aspect%
echo スキャンタイプ　：%info_scan_type%
if not "%info_scan_type%" == "Progressive" echo スキャンオーダー：%info_scan_order%
echo.

REM ---------------------------------------------------------------------------
REM 変数セット2
REM ---------------------------------------------------------------------------
if %use_lsmash% == 1 goto not_tssplitter_source
if not "%info_container%" == "MPEG-TS" goto not_tssplitter_source
if not "%info_vcodec%" == "MPEG-2 Video" goto not_tssplitter_source
if %is_sd% == 1 goto not_tssplitter_source

set source_fullname=%file_fullname%_HD
set cut_dir_name=%file_name%_HD
goto end_source
:not_tssplitter_source

set source_fullname=%file_fullname%
set cut_dir_name=%file_name%
:end_source

set source_fullpath=%source_fullname%%file_ext%

set avs="%source_fullname%.avs"
set output_enc="%output_path%%file_name%.enc.mp4"
set output_wav="%output_path%%file_name%.wav"
set output_aac="%output_path%%file_name%.aac"
set output_m4a="%output_path%%file_name%.m4a"
set output_mp4="%output_path%%file_name%.mp4"

REM ---------------------------------------------------------------------------
REM SD（主にDVDソース）のアスペクト比を設定
REM ---------------------------------------------------------------------------
if %is_sd% == 1 (
  if %info_aspect% == 16:9 (
    set sar=--sar 32:27
    REM set sar=--sar 40:33
  ) else (
    set sar=--sar 8:9
    REM set sar=--sar 10:11
  )
) else (
  set sar=--sar 1:1
)

REM ---------------------------------------------------------------------------
REM フィールドオーダー判定
REM ---------------------------------------------------------------------------
if "%info_scan_type%" == "Progressive" (
  set order_ref=PROGRESSIVE
  goto end_info_scan_order
)
if "%info_scan_order%" == "Bottom Field First" (
  set order_ref=BOTTOM
  if %deint_mode% == 0 set order_tb=bff
) else (
  set order_ref=TOP
  if %deint_mode% == 0 set order_tb=tff
)
if not %deint_mode% == 0 goto end_info_scan_order
if %video_encoder% == 0 (
  set intopt=--%order_tb%
) else if %video_encoder% == 1 (
  set intopt=--%order_tb%
) else if %video_encoder% == 2 (
  set intopt=--interlace %order_tb%
) else if %video_encoder% == 3 (
  set intopt=--interlace %order_tb%
)

:end_info_scan_order

if %use_lsmash% == 1 goto end_dgindex
if not "%info_container%" == "MPEG-TS" goto end_tssplitter
if not "%info_vcodec%" == "MPEG-2 Video" goto end_tssplitter
if not "%info_acodec%" == "AAC LC" if not "%info_acodec%" == "AAC LC / AAC LC" goto end_tssplitter
if %is_sd% == 1 goto end_tssplitter
echo ---------------------------------------------------------------------------
echo TSSplitter処理
echo ---------------------------------------------------------------------------
if not exist "%source_fullpath%" (
  call %tssplitter% -EIT -ECM -EMM -SD -1SEG "%file_fullpath%"
) else (
  echo 分割済みのファイルが存在しています。
)
echo.

:end_tssplitter

if not %audio_encoder% == 0 goto end_dgindex
if not "%info_container%" == "MPEG-TS" goto end_dgindex
if not "%info_vcodec%" == "MPEG-2 Video" goto end_dgindex
if not "%info_acodec%" == "AAC LC" if not "%info_acodec%" == "AAC LC / AAC LC" goto end_dgindex
echo ---------------------------------------------------------------------------
echo DGIndex処理
echo ---------------------------------------------------------------------------
if not exist "%source_fullname%.d2v" if not exist "%source_fullname% PID *.aac" (
  call %dgindex% -i "%source_fullpath%" -o "%source_fullname%" -ia 5 -fo 0 -yr 2 -om 2 -hide -exit
) else (
  echo 分離済みのd2v / aacファイルが存在しています。
)
echo.

for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *.aac"`) do set aac_fullpath=%file_path%%%A

REM if not %audio_encoder% == 0 goto end_faw
REM if not exist "%aac_fullpath%" goto end_faw
REM echo ---------------------------------------------------------------------------
REM echo  FAW前処理
REM echo ---------------------------------------------------------------------------
REM if not exist "%source_fullname% PID *_aac.wav" (
REM   call %fawcl% "%aac_fullpath%"
REM ) else (
REM   echo 疑似wavファイルが存在しています。
REM )

REM :end_audio_split
REM for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *_aac.wav"`) do set wav_fullpath=%file_path%%%A
REM echo.
REM :end_faw

:end_dgindex

echo ---------------------------------------------------------------------------
echo avsファイル生成処理
echo ---------------------------------------------------------------------------
if exist %avs% (
  echo avsファイルが存在しています。
  goto end_avs
)

echo SetFilterMTMode("DEFAULT_MT_MODE", MT_MULTI_INSTANCE)>>%avs%
echo SetFilterMTMode("MPEG2Source",        MT_NICE_FILTER)>>%avs%
echo SetFilterMTMode("LWLibavVideoSource",  MT_SERIALIZED)>>%avs%
echo SetFilterMTMode("LWLibavAudioSource",  MT_SERIALIZED)>>%avs%
echo SetFilterMTMode("LSMASHVideoSource",   MT_SERIALIZED)>>%avs%
echo SetFilterMTMode("LSMASHAudioSource",   MT_SERIALIZED)>>%avs%
echo SetFilterMtMode("AudioDub",            MT_SERIALIZED)>>%avs%
echo SetFilterMTMode("TDecimate",           MT_SERIALIZED)>>%avs%
echo SetFilterMTMode("EraseLOGO",           MT_SERIALIZED)>>%avs%
echo.>>%avs%

echo ### ファイル読み込み ###>>%avs%
if not exist "%source_fullname%.d2v" goto lsmashsource

echo MPEG2Source("%source_fullname%.d2v")>>%avs%
REM echo AudioDub(last, WAVSource("%wav_fullpath%"))>>%avs%
echo AudioDub(last, AACFaw("%aac_fullpath%"))>>%avs%
goto end_readfile

:lsmashsource
set lsmash_format=
if not %info_bitdepth% == 8 set lsmash_format=, format="YUV420P8"
if not "%info_container%" == "MPEG-4" goto lwlibav

echo LSMASHVideoSource("%source_fullpath%"%lsmash_format%)>>%avs%
REM if exist "%wav_fullpath%" echo AudioDub(last, WAVSource("%wav_fullpath%"))>>%avs%
REM if not exist "%wav_fullpath%" echo AudioDub(last, LSMASHAudioSource("%source_fullpath%", layout="stereo"))>>%avs%
echo AudioDub(last, LSMASHAudioSource("%source_fullpath%", layout="stereo"))>>%avs%
goto end_lsmash

:lwlibav
echo LWLibavVideoSource("%source_fullpath%"%lsmash_format%)>>%avs%
REM if exist "%wav_fullpath%" echo AudioDub(last, WAVSource("%wav_fullpath%"))>>%avs%
REM if not exist "%wav_fullpath%" echo AudioDub(last, LWLibavAudioSource("%source_fullpath%", av_sync=true, layout="stereo"))>>%avs%
echo AudioDub(last, LWLibavAudioSource("%source_fullpath%", av_sync=true, layout="stereo"))>>%avs%

:end_lsmash

:end_readfile
echo.>>%avs%

if %assumefps% == 1 echo AssumeFPS(30000, 1001, true)>>%avs% & echo.>>%avs%

echo ### フィールドオーダー ###>>%avs%
if %order_ref% == TOP echo AssumeTFF()>>%avs%
if %order_ref% == BOTTOM echo AssumeBFF()>>%avs%
if %order_ref% == PROGRESSIVE echo #Progressive>>%avs%
echo.>>%avs%

echo ### クロップ ###>>%avs%
echo #Crop(8, 0, -8, 0)>>%avs%
echo.>>%avs%

if %is_sd% == 1 goto end_cm_cut_logo
if not "%info_container%" == "MPEG-TS" goto end_cm_cut_logo
if not "%info_vcodec%" == "MPEG-2 Video" goto end_cm_cut_logo

echo ### サービス情報取得 ###>>%avs%
echo 情報取得中...
echo.

for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -c') do set service=%%A

echo %service% | find "有効な番組情報を検出できませんでした" >NUL
if not ERRORLEVEL 0 goto end_service

for /f "delims=" %%A in ('echo "%file_name%" ^| sed -r "s/^.* \[(.*)\].*/\1/"') do set service=%%A
for /f "delims=" %%A in ('echo %service%^| nkf32 -Z') do set service=%%A

:end_service

echo サービス名：%service%
echo.
echo #サービス名：%service%>>%avs%
echo.>>%avs%

if %cut_cm% == 0 goto end_auto_trim
echo ### 自動CMカット ###>>%avs%
set cut_fullpath="%cut_result_path%%cut_dir_name%\obs_cut.avs"
if exist %cut_fullpath% goto end_cut_cm
call %join_logo_scp% "%source_fullpath%"

:end_cut_cm
sleep 2
for /f "usebackq tokens=*" %%A in (%cut_fullpath%) do set trim_line=%%A
echo %trim_line%>>%avs%
echo.>>%avs%
goto end_trim

:end_auto_trim

if %cut_cm% == 1 goto end_do_manual_cut
echo ### 手動Trim ###>>%avs%
echo #Trim()>>%avs%
echo.>>%avs%

:end_trim

if %cut_logo% == 0 goto end_cm_cut_logo
echo ### ロゴ除去 ###>>%avs%
echo EraseLOGO("%logo_path%%service%.lgd", pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true)>>%avs%
echo.>>%avs%
:end_cm_cut_logo

if "%info_scan_type%" == "Progressive" goto end_deint
echo ### インターレース解除 / 逆テレシネ ###>>%avs%

if %is_sd% == 0 if "%info_vcodec%" == "MPEG-2 Video" goto is_tv_ts
if %deint_mode% == 1 goto set_deint
if %deint_mode% == 2 goto set_deint_it
if %deint_mode% == 3 goto set_deint_bob
goto end_deint

:is_tv_ts
if not "%info_container%" == "MPEG-TS" goto end_get_genre

if %deint_mode% == 3 goto set_deint_bob

echo 情報取得中...
echo.

for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -g') do set genre=%%A
echo %genre% | find "有効な番組情報を検出できませんでした" >NUL
if not ERRORLEVEL 1 set genre=Unknown

echo ジャンル名：%genre%
echo.
echo #ジャンル名：%genre%>>%avs%
echo.>>%avs%

if "%info_scan_type%" == "Progressive" goto end_deint

:end_get_genre
echo %genre% | find " を開くのに失敗しました." > NUL
if not ERRORLEVEL 1 (
  if %deint_mode% == 1 goto set_deint
  if %deint_mode% == 2 goto set_deint_it
  goto end_deint
)
echo %genre% | find "有効な番組情報を検出できませんでした" >NUL
if not ERRORLEVEL 1 (
  if %deint_mode% == 1 goto set_deint
  if %deint_mode% == 2 goto set_deint_it
  goto end_deint
)

echo %genre% | find "アニメ" > NUL
if not ERRORLEVEL 1 goto set_deint_it
echo %genre% | find "映画" > NUL
if not ERRORLEVEL 1 goto set_deint_it

:set_deint
echo #TIVTC24P2()>>%avs%
echo TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint

:set_deint_it
if %deint_mode% == 0 goto not_deint_it
echo TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint
:not_deint_it
echo #TIVTC24P2()>>%avs%
echo TFM(order=-1, mode=6, PP=7)>>%avs%
echo TDecimate(mode=1)>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint


:set_deint_bob
echo #TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%

:end_deint

if %denoize% == 0 goto end_denoize

echo ### ノイズ除去 ###>>%avs%
echo hqdn3d(2)>>%avs%
echo.>>%avs%

:end_denoize

if %resize% == 0 goto end_resize
if %is_sd% == 1 goto end_resize
if %info_width% leq 1280 goto end_resize

echo ### リサイズ ###>>%avs%
echo Spline36Resize(1280, 720)>>%avs%
echo.>>%avs%
:end_resize

echo ### シャープ化 ###>>%avs%
if %sharpen% == 0 goto not_sharpen
echo Sharpen(0.02)>>%avs%
goto end_sharpen

:not_sharpen
echo #Sharpen(0.02)>>%avs%
:end_sharpen
echo.>>%avs%

echo Prefetch(%cpu_cores%)>>%avs%
echo return last>>%avs%

if %deint_mode% == 0 goto end_tivtc24p2
if "%info_scan_type%" == "Progressive" goto end_tivtc24p2
echo.>>%avs%
echo function TIVTC24P2(clip clip){>>%avs%
echo Deinted=clip.TDeint(order=-1,field=-1,edeint=clip.nnedi3(field=-1))>>%avs%
echo clip = clip.TFM(mode=6,order=-1,PP=7,slow=2,mChroma=true,clip2=Deinted)>>%avs%
echo clip = clip.TDecimate(mode=1)>>%avs%
echo return clip>>%avs%
echo }>>%avs%

:end_tivtc24p2

echo avsファイルを生成しました。
echo %avs%

:end_avs
echo.

if %check_avs% == 1 (
  echo ※avsファイル確認オプションが設定されています。120秒間待機します。
  echo.
  echo ※確認・編集を行う場合、[Ctrl] + [C]でカウントダウンを中止できます。
  echo ※中止した場合、[Y]で終了するか、[N]で処理を続行してください。
  echo ※終了後に再度実行すると、既に行った処理はスキップ（再利用）されます。
  echo.
  timeout /T 120
)
echo.

echo ---------------------------------------------------------------------------
echo 映像処理
echo ※インデックスファイルが未作成の場合は、処理開始までに時間がかかります。
echo ---------------------------------------------------------------------------
if not exist %output_enc% (
  if %video_encoder% == 0 (
    call %x264% %x264_opt% %sar% %intopt% -o %output_enc% %avs%
  ) else if %video_encoder% == 1 (
    call %qsvencc% %qsvencc_opt% %sar% %intopt% -i %avs% -o %output_enc%
  ) else if %video_encoder% == 2 (
    call %nvencc% %nvencc_opt% %sar% %intopt% -i %avs% -o %output_enc%
  ) else if %video_encoder% == 3 (
    call %nvencc% %nvencc_opt% %sar% %intopt% -i %avs% -o %output_enc%
  )
) else (
  echo エンコード済み映像ファイルが存在しています。
)
echo.

echo ---------------------------------------------------------------------------
echo 音声処理
echo ---------------------------------------------------------------------------
if not exist %output_wav% (
  call %avs2pipemod% -wav %avs% > %output_wav%
) else (
  echo 中間wavファイルが存在しています。
)

if not %audio_encoder% == 0 goto qaac_encode
if %use_lsmash% == 1 goto qaac_encode
REM if not exist "%wav_fullpath%" goto qaac_encode

if not exist %output_aac% (
  call %fawcl% %output_wav% %output_aac%
) else (
  echo エンコード済みaacファイルが存在しています。
)
goto end_audio_encode

:qaac_encode
if not exist %output_aac% (
  call %qaac% %output_wav% -o %output_aac%
) else (
  echo エンコード済みaacファイルが存在しています。
)

:end_audio_encode
echo.

echo ---------------------------------------------------------------------------
echo muxer処理
echo ---------------------------------------------------------------------------
if not exist %output_m4a% (
  call %muxer% -i %output_aac% -o %output_m4a%
) else (
  echo muxer済みのm4aファイルが存在しています。
)
echo.

echo ---------------------------------------------------------------------------
echo remuxer処理
echo ---------------------------------------------------------------------------
if not exist %output_mp4% (
  call %remuxer% -i %output_enc% -i %output_m4a% -o %output_mp4%
) else (
  echo remuxer済みのmp4ファイルが存在しています。
)
echo.

echo ---------------------------------------------------------------------------
echo 一時ファイル処理
echo ---------------------------------------------------------------------------
if %del_temp% == 0 goto no_del_temp

echo 一時ファイルを削除します。
echo.

set del_hd_file=0
if "%info_container%" == "MPEG-TS" if %is_sd% == 0 set del_hd_file=1

if exist "%file_fullname%.lwi" del /f /q "%file_fullname%.lwi" & echo %file_fullname%.lwi
if %del_hd_file% == 1 if exist "%source_fullpath%" del /f /q "%source_fullpath%" & echo %source_fullpath%
if exist "%source_fullpath%.lwi" del /f /q "%source_fullpath%.lwi" & echo %source_fullpath%.lwi
if exist "%source_fullname%.d2v" del /f /q "%source_fullname%.d2v" & echo %source_fullname%.d2v
if exist "%source_fullname%.d2v" del /f /q "%source_fullname%.d2v.lwi" & echo %source_fullname%.d2v.lwi
if exist "%aac_fullpath%" del /f /q "%aac_fullpath%" & echo %aac_fullpath%
REM if exist "%wav_fullpath%" del /f /q "%wav_fullpath%" & echo %wav_fullpath%
if exist %avs% del /f /q %avs% & echo %avs%
if exist %output_enc% del /f /q %output_enc% & echo %output_enc%
if exist %output_wav% del /f /q %output_wav% & echo %output_wav%
if exist %output_aac% del /f /q %output_aac% & echo %output_aac%
if exist %output_m4a% del /f /q %output_m4a% & echo %output_m4a%
echo.
goto end_del_temp

:no_del_temp
echo 一時ファイル群は残っており、次回実行時に再利用（処理をスキップ）できます。
echo 特定の処理をやり直したい場合は、該当ファイルを削除して再実行してください。
echo 不要になったら、すべての一時ファイルを削除して構いません。
echo.
:end_del_temp

echo ===========================================================================
echo %output_mp4%
echo ---------------------------------------------------------------------------
echo 処理終了: %date% %time%
echo ===========================================================================
echo.

shift
goto loop
:end

pause
