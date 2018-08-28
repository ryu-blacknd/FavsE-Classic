@echo off

echo FavsE (FullAuto AVS Encode) 3.22
echo.

REM ----------------------------------------------------------------------
REM 映像エンコーダの指定（0:x264, 1:QSVEnc, 2:NVEnc_AVC, 3:NVEnc_HEVC）
REM 正直それほど強烈な速度差はありません。画質の差はありますのでx264推奨です。
REM ----------------------------------------------------------------------
set video_encoder=0
REM ----------------------------------------------------------------------
REM 音声エンコーダの指定（0:FAW, 1:qaac）
REM 通常はFAWでOKです。FAWが使用できない場合は自動的にqaacで処理します。
REM ----------------------------------------------------------------------
set audio_encoder=0

REM ----------------------------------------------------------------------
REM 自動CMカットの処理を行うか（0:行わない, 1:行う）
REM CMは高精度でカットしますが、完璧ではありません。手動カットとの組み合わせ推奨です。
REM ----------------------------------------------------------------------
set cut_cm=0
REM ----------------------------------------------------------------------
REM ロゴ除去の処理を行うか（0:行わない, 1:行う）
REM 事前にAviUtl + ロゴ解析プラグインで.lgdファイルを作成しておく必要があります。
REM ----------------------------------------------------------------------
set cut_logo=0
REM ----------------------------------------------------------------------
REM avs生成後に処理を一時停止するか（0:しない, 1:する）
REM 生成されたスクリプトを確認してから進められます。ほぼ手動CMカット用です。
REM ----------------------------------------------------------------------
set check_avs=0

REM ----------------------------------------------------------------------
REM インターレース解除を行うか（0:インターレース保持, 1:インターレース解除）
REM 通常は解除推奨です。リサイズ処理を行うのであればインターレース保持の意味は薄れます。
REM ----------------------------------------------------------------------
set deint=1
REM ----------------------------------------------------------------------
REM 30fpsのインターレース解除時にBOB化を行うか（0:行わない, 1:行う）
REM 24fps化（逆テレシネ）ではないケースで、動きヌルヌルの60fps動画にできます。
REM ----------------------------------------------------------------------
set deint_bob=1
REM ----------------------------------------------------------------------
REM インターレース解除 / 逆テレシネをGPUで行うか（0:行わない, 1:行う）
REM 使用するデバイスが複数ある場合は Intel, NVIDIA, Radeonから指定してください。
REM ----------------------------------------------------------------------
set gpu_deint=0
set d3dvp_device=Intel

REM ----------------------------------------------------------------------
REM GPUによるノイズ除去を行うか（0:行わない, 1:行う）
REM _GPU25プラグインを使用します。対応GPUを持っていなければエラーになります。
REM ----------------------------------------------------------------------
set denoize=0
REM ----------------------------------------------------------------------
REM Widthが1280pxを超える場合に1280x720pxにリサイズするか（0:しない, 1:する）
REM 4K / 2K / Full HD等の場合にHDサイズに揃え、ファイルサイズを縮める意味があります。
REM ----------------------------------------------------------------------
set resize=1
REM ----------------------------------------------------------------------
REM 若干のシャープ化を行うか（0:行わない, 1:行う）
REM 気持ち程度のシャープ化ですが、例えばノイズ除去後や拡大処理後にはそれなりに有効です。
REM ----------------------------------------------------------------------
set sharpen=0

REM ----------------------------------------------------------------------
REM 終了後に一時ファイルを削除するか（0:しない, 1:する）
REM 一時ファイル群を一括削除できます。0だと放置されますが、やり直し時に再利用できます。
REM ----------------------------------------------------------------------
set del_temp=0

REM ----------------------------------------------------------------------
REM ■確認必須：フォルダ名
REM 環境に応じて【必ず】書き換えてください。
REM ----------------------------------------------------------------------
set output_path=F:\Encode\
set bin_path=C:\DTV\bin\
set logo_path=%bin_path%join_logo_scp\logo\
set cut_result_path=%bin_path%join_logo_scp\result\

REM ----------------------------------------------------------------------
REM ■確認必須：実行ファイル名
REM 環境に応じて【必ず】書き換えてください。わかる方は必要なものだけで結構です。
REM ----------------------------------------------------------------------
set x264=%bin_path%x264.exe
set qsvencc=%bin_path%QSVEncC.exe
set nvencc=%bin_path%NVEncC.exe

set avs2pipemod=%bin_path%avs2pipemod.exe
set fawcl=%bin_path%fawcl.exe
set qaac=%bin_path%qaac.exe
set muxer=%bin_path%muxer.exe
set remuxer=%bin_path%remuxer.exe

set mediainfo=%bin_path%MediaInfo\MediaInfo.exe
set rplsinfo=%bin_path%rplsinfo.exe
set tsspritter=%bin_path%TsSplitter\TsSplitter.exe
set dgindex=%bin_path%DGIndex.exe
set join_logo_scp=%bin_path%join_logo_scp\jlse_bat.bat

REM ----------------------------------------------------------------------
REM 映像エンコーダのオプション
REM 設定値の意味がわかる方は自由に改変してください。
REM ----------------------------------------------------------------------
if %video_encoder% == 0 (
  set x264_opt=--crf 21 --qcomp 0.7 --me umh --subme 9 --direct auto --ref 5 --trellis 2
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

REM ----------------------------------------------------------------------
REM 設定ここまで
REM ======================================================================

:loop
if "%~1" == "" goto end
set file_ext=%~x1

echo ======================================================================
echo %~1
echo ----------------------------------------------------------------------
echo 処理開始: %date% %time%
echo ======================================================================
echo.

REM ----------------------------------------------------------------------
REM SD（主にDVDソース）かをサイズ取得で判定
REM ----------------------------------------------------------------------
set is_sd=0
for /f "delims=" %%A in ('%mediainfo% %1 ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set info_width=%%A
if %info_width% == 720 set is_sd=1

REM ----------------------------------------------------------------------
REM 変数セット
REM ----------------------------------------------------------------------
set file_path=%~dp1
set file_name=%~n1
set file_fullname=%~dpn1
set file_fullpath=%~1

if not %file_ext% == .ts goto not_hd_ts_source
if %is_sd% == 1 goto not_hd_ts_source

set source_fullname=%file_fullname%_HD
set cut_dir_name=%file_name%_HD
goto end_source
:not_hd_ts_source

set source_fullname=%file_fullname%
:end_source

set source_fullpath=%source_fullname%%file_ext%

set avs="%source_fullname%.avs"
set avs_template="%bin_path%.template.avs"
set output_enc="%output_path%%file_name%.enc.mp4"
set output_wav="%output_path%%file_name%.wav"
set output_aac="%output_path%%file_name%.aac"
set output_m4a="%output_path%%file_name%.m4a"
set output_mp4="%output_path%%file_name%.mp4"

REM ----------------------------------------------------------------------
REM コーデック取得
REM ----------------------------------------------------------------------
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Commercial name" ^| head -n 1 ^| sed -r "s/Commercial name *: (.*)/\1/"') do set info_container=%%A
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Codecs Video" ^| sed -r "s/Codecs Video *: (.*)/\1/"') do set info_vcodec=%%A
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Audio codecs" ^| sed -r "s/Audio codecs *: (.*)/\1/"') do set info_acodec=%%A
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Bit depth" ^| head -n 1 ^| sed -r "s/Bit depth *: (.*)/\1/"') do set info_bitdepth=%%A
echo コンテナ　　　：%info_container%
echo 映像コーデック：%info_vcodec%
echo 音声コーデック：%info_acodec%
echo ビット深度　　：%info_bitdepth%ビット
echo.

REM ----------------------------------------------------------------------
REM SD（主にDVDソース）のアスペクト比を設定
REM ----------------------------------------------------------------------
for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Display aspect ratio" ^| sed -r "s/Display aspect ratio *: (.*)/\1/"') do set info_aspect=%%A

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

REM ----------------------------------------------------------------------
REM フィールドオーダー判定
REM ----------------------------------------------------------------------
for /f "delims=" %%A in ('%mediainfo% "%source_fullpath%" ^| grep "Scan type" ^| sed -r "s/Scan type *: (.*)/\1/"') do set scan_type=%%A
for /f "delims=" %%A in ('%mediainfo% "%source_fullpath%" ^| grep "Scan order" ^| sed -r "s/Scan order *: (.*)/\1/"') do set scan_order=%%A

if "%scan_type%" == "Progressive" (
  echo ※プログレッシブソースです。
  echo.
  set order_ref=PROGRESSIVE
  goto end_scan_order
)
if "%scan_order%" == "Bottom Field First" (
  set order_ref=BOTTOM
  if %deint% == 0 set order_tb= --bff
) else (
  set order_ref=TOP
  if %deint% == 0 set order_tb= --tff
)
:end_scan_order

if not %file_ext% == .ts goto end_tssplitter
if not "%info_vcodec%" == "MPEG-2 Video" goto end_tssplitter
if not "%info_acodec%" == "AAC LC" goto end_tssplitter
if %is_sd% == 1 goto end_tssplitter
echo ----------------------------------------------------------------------
echo TSSplitter処理
echo ----------------------------------------------------------------------
if %is_sd% == 0 (
  if not exist "%source_fullpath%" (
    call %tsspritter% -EIT -ECM -EMM -SD -1SEG "%file_fullpath%"
  ) else (
    echo 分割済みのファイルが存在しています。
  )
) else (
  echo 処理は必要ありません。
)
echo.
:end_tssplitter

if not %file_ext% == .ts goto end_dgindex
if not "%info_vcodec%" == "MPEG-2 Video" goto end_dgindex
if not "%info_acodec%" == "AAC LC" goto end_dgindex
if %is_sd% == 1 goto end_dgindex
if not %audio_encoder% == 0 goto end_dgindex
echo ----------------------------------------------------------------------
echo DGIndex処理
echo ----------------------------------------------------------------------
if not exist "%source_fullname%.d2v" (
  call %dgindex% -i "%source_fullpath%" -o "%source_fullname%" -ia 5 -fo 0 -yr 2 -om 2 -hide -exit
) else (
  echo 分離済みのファイルが存在しています。
)
echo.
:end_dgindex

if not %audio_encoder% == 0 goto end_faw
if not %file_ext% == .ts goto end_faw
if not "%info_vcodec%" == "MPEG-2 Video" goto end_faw
if not "%info_acodec%" == "AAC LC" goto end_faw
if %is_sd% == 1 goto end_faw
echo ----------------------------------------------------------------------
echo  FAWによるaac → 疑似wav化処理
echo ----------------------------------------------------------------------
for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *.aac"`) do set aac_fullpath=%file_path%%%A
if exist "%source_fullname% PID *_aac.wav" goto exist_wav
call %fawcl% -s2 "%aac_fullpath%"
goto end_audio_split

:exist_wav
echo 疑似wavファイルが存在しています。

:end_audio_split
for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *_aac.wav"`) do set wav_fullpath=%file_path%%%A
echo.
:end_faw

echo ----------------------------------------------------------------------
echo avsファイル生成処理
echo ----------------------------------------------------------------------
if exist %avs% (
  echo avsファイルが存在しています。
  goto end_avs
)

echo SetMemoryMax(1024)>>%avs%
echo.>>%avs%

echo ### ファイル読み込み ###>>%avs%
if not %audio_encoder% == 0 goto not_faw
if not %file_ext% == .ts goto not_faw
if not "%info_vcodec%" == "MPEG-2 Video" goto not_faw
if not "%info_acodec%" == "AAC LC" goto not_faw
if %is_sd% == 1 goto not_faw
echo SetMTMode(1, 0)>>%avs%
echo MPEG2Source("%source_fullname%.d2v")>>%avs%
echo SetMTMode(2)>>%avs%
echo AudioDub(last, WAVSource("%wav_fullpath%"))>>%avs%
goto end_fileread

:not_faw
if %info_bitdepth% == 8 echo LWLibavVideoSource("%source_fullpath%")>>%avs%
if not %info_bitdepth% == 8 echo LWLibavVideoSource("%source_fullpath%", format="YUV420P8")>>%avs%
echo AudioDub(last, LWLibavAudioSource("%source_fullpath%", av_sync=true, layout="stereo"))>>%avs%
echo.>>%avs%
echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%

:end_fileread

echo ### フィールドオーダー ###>>%avs%
if %order_ref% == TOP echo AssumeTFF()>>%avs%
if %order_ref% == BOTTOM echo AssumeBFF()>>%avs%
if %order_ref% == PROGRESSIVE echo #Progressive>>%avs%
echo.>>%avs%

echo ### クロップ ###>>%avs%
echo #Crop(8, 0, -8, 0)>>%avs%
echo.>>%avs%

if %is_sd% == 1 goto end_cm_cut_logo

echo ### サービス情報取得 ###>>%avs%
for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -c') do set service=%%A
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

if %deint% == 0 goto end_deint
if "%scan_type%" == "Progressive" goto end_deint
echo ### インターレース解除 / 逆テレシネ ###>>%avs%
set is_ivtc=0

if %is_sd% == 0 goto not_sd
if %deint_bob% == 0 goto set_deint
if %deint_bob% == 1 goto set_deint_bob

:not_sd
for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -g') do set genre=%%A
echo #ジャンル名：%genre%>>%avs%
if "%scan_type%" == "Progressive" goto end_deint

echo %genre% | find " を開くのに失敗しました." > NUL
if not ERRORLEVEL 1 if %deint_bob% == 0 goto set_deint
if not ERRORLEVEL 1 if %deint_bob% == 1 goto set_deint_bob

echo %genre% | find "アニメ" > NUL
if not ERRORLEVEL 1 goto set_deint_it
echo %genre% | find "映画" > NUL
if not ERRORLEVEL 1 goto set_deint_it

:set_deint
if %gpu_deint% == 1 goto set_deint_gpu
echo #TIVTC24P2()>>%avs%
echo TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
echo #D3DVP(mode=0, device="%d3dvp_device%")>>%avs%
echo #GPU_Begin()>>%avs%
echo #GPU_IT(fps=24, ref="%order_ref%", blend=false)>>%avs%
echo #GPU_End()>>%avs%
goto end_deint
echo.>>%avs%

:set_deint_gpu
echo #TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
echo D3DVP(mode=0, device="%d3dvp_device%")>>%avs%
echo #GPU_Begin()>>%avs%
echo #GPU_IT(fps=24, ref="%order_ref%", blend=false)>>%avs%
echo #GPU_End()>>%avs%
goto end_deint
echo.>>%avs%

:set_deint_bob
if %gpu_deint% == 1 goto set_deint_bob_gpu
echo #TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo #D3DVP(mode=1, device="%d3dvp_device%")>>%avs%
echo.>>%avs%
echo #D3DVP(mode=1, device="%d3dvp_device%")>>%avs%
echo #GPU_Begin()>>%avs%
echo #GPU_IT(fps=24, ref="%order_ref%", blend=false)>>%avs%
echo #GPU_End()>>%avs%
goto end_deint
echo.>>%avs%

:set_deint_bob_gpu
echo #TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
echo D3DVP(mode=1, device="%d3dvp_device%")>>%avs%
echo #GPU_Begin()>>%avs%
echo #GPU_IT(fps=24, ref="%order_ref%", blend=false)>>%avs%
echo #GPU_End()>>%avs%
goto end_deint
echo.>>%avs%

:set_deint_it
set is_ivtc=1
if %gpu_deint% == 1 goto set_deint_it_gpu
echo TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
echo #D3DVP(mode=0, device="%d3dvp_device%")>>%avs%
echo #GPU_Begin()>>%avs%
echo #GPU_IT(fps=24, ref="%order_ref%", blend=false)>>%avs%
echo #GPU_End()>>%avs%
goto end_deint
echo.>>%avs%

:set_deint_it_gpu
echo #TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
echo D3DVP(mode=0, device="%d3dvp_device%")>>%avs%
echo GPU_Begin()>>%avs%
echo GPU_IT(fps=24, ref="%order_ref%", blend=false)>>%avs%
echo GPU_End()>>%avs%
goto end_deint
echo.>>%avs%

:end_deint

echo ### ノイズ除去 ###>>%avs%
if %denoize% == 0 goto not_denoize
set is_anime=0
echo %genre% | find "アニメ" > NUL
if not ERRORLEVEL 1 set is_anime=1

echo GPU_Begin()>>%avs%
if %is_anime% == 1 goto anime_hq
echo GPU_Convolution3d(preset="movieLQ")>>%avs%
echo #GPU_Convolution3d(preset="animeLQ")>>%avs%
goto end_mov_anm

:anime_hq
echo #GPU_Convolution3d(preset="movieLQ")>>%avs%
echo GPU_Convolution3d(preset="animeLQ")>>%avs%

:end_mov_anm
echo GPU_End()>>%avs%
goto end_denoize

:not_denoize
echo #GPU_Begin()>>%avs%
echo #GPU_Convolution3d(preset="movieLQ")>>%avs%
echo #GPU_Convolution3d(preset="animeLQ")>>%avs%
echo #GPU_End()>>%avs%
:end_denoize
echo.>>%avs%

if %is_sd% == 1 goto end_resize
if %resize% == 0 goto end_resize

echo ### リサイズ ###>>%avs%
echo (Width() ^> 1280) ? Spline36Resize(1280, 720) : last>>%avs%
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

echo ### その他の処理 ###>>%avs%
echo.>>%avs%

echo return last>>%avs%

if %deint% == 0 goto end_tivtc24p2
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
echo %avs%

:end_avs
echo.

if %check_avs% == 1 (
  echo ※avsファイル確認オプションが設定されています。
  echo ※確認・編集完了後は何かキーを押せば処理を続行できます。
  echo.
  pause
)
echo.

echo ----------------------------------------------------------------------
echo 映像処理
echo ----------------------------------------------------------------------
if not exist %output_enc% (
  if %video_encoder% == 0 (
    call %x264% %x264_opt% %sar%%order_tb% -o %output_enc% %avs%
  ) else if %video_encoder% == 1 (
    call %qsvencc% %qsvencc_opt% %sar%%order_tb% -i %avs% -o %output_enc%
  ) else if %video_encoder% == 2 (
    call %nvencc% %nvencc_opt% %sar%%order_tb% -i %avs% -o %output_enc%
  ) else if %video_encoder% == 3 (
    call %nvencc% %nvencc_opt% %sar%%order_tb% -i %avs% -o %output_enc%
  )
) else (
  echo エンコード済み映像ファイルが存在しています。
)
echo.

echo ----------------------------------------------------------------------
echo 音声処理
echo ----------------------------------------------------------------------
if not exist %output_wav% (
  call %avs2pipemod% -wav %avs% > %output_wav%
) else (
  echo 中間wavファイルが存在しています。
)
if %audio_encoder% == 1 goto qaac_encode
if not %file_ext% == .ts goto qaac_encode
if %is_sd% == 1 goto qaac_encode

if not exist %output_aac% (
  call %fawcl% %output_wav% %output_aac%
) else (
  echo エンコード済みaacファイルが存在しています。
)
goto end_audio_encode

:qaac_encode
if not exist %output_aac% (
  call %qaac% -q 2 --tvbr 95 %output_wav% -o %output_aac%
) else (
  echo エンコード済みaacファイルが存在しています。
)

:end_audio_encode
echo.

echo ----------------------------------------------------------------------
echo muxer処理
echo ----------------------------------------------------------------------
if not exist %output_m4a% (
  call %muxer% -i %output_aac% -o %output_m4a%
) else (
  echo muxer済みのm4aファイルが存在しています。
)
echo.

echo ----------------------------------------------------------------------
echo remuxer処理
echo ----------------------------------------------------------------------
if not exist %output_mp4% (
  call %remuxer% -i %output_enc% -i %output_m4a% -o %output_mp4%
) else (
  echo remuxer済みのmp4ファイルが存在しています。
)
echo.

echo ----------------------------------------------------------------------
echo 一時ファイル処理
echo ----------------------------------------------------------------------
if %del_temp% == 0 goto no_del_temp

echo 一時ファイルを削除します。
echo.

set del_hd_file=0
if %file_ext% == .ts if %is_sd% == 0 set del_hd_file=1

if exist "%file_fullname%.lwi" del /f /q "%file_fullname%.lwi" & echo "%file_fullname%.lwi"
if exist "%source_fullpath%.lwi" del /f /q "%source_fullpath%.lwi" & echo "%source_fullpath%.lwi"
if exist "%source_fullname%.d2v" del /f /q "%source_fullname%.d2v" & echo "%source_fullname%.d2v"
if exist "%source_fullname%.d2v" del /f /q "%source_fullname%.d2v.lwi" & echo "%source_fullname%.d2v.lwi"
if exist "%source_fullname%.log" del /f /q "%source_fullname%.log" & echo "%source_fullname%.log"
if exist "%aac_fullpath%.lwi" del /f /q "%aac_fullpath%.lwi" & echo "%aac_fullpath%.lwi"
if exist "%wav_fullpath%.lwi" del /f /q "%wav_fullpath%.lwi" & echo "%wav_fullpath%.lwi"
if exist %avs% del /f /q %avs%
if exist "%aac_fullpath%" del /f /q "%aac_fullpath%" & echo "%aac_fullpath%"
if exist "%wav_fullpath%" del /f /q "%wav_fullpath%" & echo "%wav_fullpath%"
if %del_hd_file% == 1 if exist "%source_fullpath%" del /f /q "%source_fullpath%" & echo "%source_fullpath%"
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

echo ======================================================================
echo %output_mp4%
echo ----------------------------------------------------------------------
echo 処理終了: %date% %time%
echo ======================================================================
echo.

shift
goto loop
:end

pause
