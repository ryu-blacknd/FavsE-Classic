@echo off

echo FavsE (FullAuto AVS Encode) 5.50
echo.
REM ===========================================================================
REM CPU�̃R�A���i���l�j
REM �X���b�h���ł͂Ȃ��A�X���b�h���̔������x�i���R�A���j���ǂ��Ƃ���Ă��܂��B
REM ---------------------------------------------------------------------------
set cpu_cores=6
REM ---------------------------------------------------------------------------
REM �f���G���R�[�_�i0:x264, 1:QSVEnc, 2:NVEnc_AVC, 3:NVEnc_HEVC�j�������F0
REM �掿�̍��Ɍ������قǑ��x�����傫���Ȃ����߁A�ł����掿��x264�����ł��B
REM ---------------------------------------------------------------------------
set video_encoder=0
REM ---------------------------------------------------------------------------
REM �����G���R�[�_�i0:FAW, 1:qaac�j�������F0
REM �ʏ��FAW��OK�ł��BFAW���g�p�ł��Ȃ��ꍇ�͎����I��qaac�ŏ������܂��B
REM ---------------------------------------------------------------------------
set audio_encoder=0

REM ===========================================================================
REM LSMASHSource�����g�p�i0:DGIndex�D��, 1:LSMASH�����j�������I��qaac���g�p
REM TSSplitter��DGIndex�̏������s�킸LSMASHSource�œǂݍ��ޏꍇ��1�ɂ��܂��B
REM ---------------------------------------------------------------------------
set use_lsmash=0
REM ---------------------------------------------------------------------------
REM ���Y���΍�i0:�s��Ȃ�, 1:�s���j�����Y������������ꍇ�̂ݐ����F1
REM �ǂ����Ă����Y������������ꍇ�ɁAfps�Œ�ɂ�鉹�Y���΍���s���܂��B
REM ---------------------------------------------------------------------------
set assumefps=0
REM ---------------------------------------------------------------------------
REM ����CM�J�b�g�����i0:�s��Ȃ�, 1:�s���j�������F1
REM �^��ts�t�@�C���̂ݗL���ł��B�����ł͂Ȃ����ߎ蓮�J�b�g�Ƃ̕��p�����ł��B
REM ---------------------------------------------------------------------------
set cut_cm=1
REM ---------------------------------------------------------------------------
REM ���S���������i0:�s��Ȃ�, 1:�s���j�������F1
REM �^��ts�t�@�C���̂ݗL���ł��BAviUtl��lgd�t�@�C�����쐬���Ă����K�v������܂��B
REM ---------------------------------------------------------------------------
set cut_logo=1
REM ---------------------------------------------------------------------------
REM avs������ɏ������ꎞ��~�i0:���Ȃ�, 1:����j�������F1
REM �������ꂽ�X�N���v�g���m�F���Ă���i�߂��܂��B120�b�o�Ə����𑱍s���܂��B
REM ---------------------------------------------------------------------------
set check_avs=1

REM ===========================================================================
REM �C���^�[���[�X�������[�h�i0:�ێ�, 1:�ʏ����, 2:24fps��, 3:BOB���j�������F1
REM �^��ts�t�@�C���̏ꍇ�͎������ʂ��܂��̂ŁA1��2�̐ݒ�͖����ƂȂ�܂��B
REM ---------------------------------------------------------------------------
set deint_mode=1
REM ---------------------------------------------------------------------------
REM �m�C�Y�����i0:�s��Ȃ�, 1:�s���j
REM �����g�m�C�Y�����ł��B��ߐݒ�ł��B���߂ɂ���ɂ͐ݒ�l��ύX���Ă��������B
REM ---------------------------------------------------------------------------
set denoize=0
REM ---------------------------------------------------------------------------
REM ���T�C�Y�i0:���Ȃ�, 1:����j
REM 4K��1080p���AWidth��1,280px�𒴂���ꍇ��1,280x720px�Ƀ��T�C�Y���邩�B
REM ---------------------------------------------------------------------------
set resize=1
REM ---------------------------------------------------------------------------
REM �V���[�v���i0:�s��Ȃ�, 1:�s���j
REM ��߂̃V���[�v���ł��B�Ⴆ�΃m�C�Y�������g�又����ɂ͂���Ȃ�ɗL���ł��B
REM ---------------------------------------------------------------------------
set sharpen=0

REM ===========================================================================
REM �I����Ɉꎞ�t�@�C�����폜�i0:���Ȃ�, 1:����j
REM �ꎞ�t�@�C���Q���폜�ł��܂��B0���ƕ��u����A��蒼�����ɍė��p�ł��܂��B
REM ---------------------------------------------------------------------------
set del_temp=1

REM ===========================================================================
REM ���m�F�K�{�F�t�H���_��
REM ���ɉ����āy�K���z���������Ă��������B
REM ---------------------------------------------------------------------------
set output_path=F:\Encode\
set bin_path=C:\DTV\bin\
set logo_path=%bin_path%join_logo_scp\logo\
set cut_result_path=%bin_path%join_logo_scp\result\

REM ---------------------------------------------------------------------------
REM ���m�F�K�{�F���s�t�@�C����
REM ���ɉ����āy�K���z���������Ă��������B�킩����͕K�v�Ȃ��̂����Ō��\�ł��B
REM ---------------------------------------------------------------------------
set x264=%bin_path%x264_x64.exe
set qsvencc=%bin_path%QSVEncC64.exe
set nvencc=%bin_path%NVEncC64.exe

set wavi=%bin_path%wavi.exe
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
REM �f���G���R�[�_�̃I�v�V����
REM �ݒ�l�̈Ӗ����킩����͎��R�ɉ��ς��Ă��������B
REM ---------------------------------------------------------------------------
if %video_encoder% == 0 (
  REM set x264_opt=--crf 20 --qcomp 0.7 --me umh --subme 10 --direct auto --ref 5 --trellis 2
  set x264_opt=--preset slower --crf 20 --qcomp 0.7 --keyint -1 --min-keyint 4 --partitions p8x8,b8x8,i8x8,i4x4 --subme 10 --ref 5 --no-fast-pskip --no-dct-decimate
) else if %video_encoder% == 1 (
  set qsvencc_opt=-c h264 -u 2 --la-icq 23 --la-quality slow --bframes 3 --weightb --weightp
) else if %video_encoder% == 2 (
  set nvencc_opt=--avs -c h264 --cqp 20:22:24 --qp-init 20:22:24 --weightp --aq --aq-temporal
) else if %video_encoder% == 3 (
  set nvencc_opt=--avs -c hevc --cqp 21:22:24 --qp-init 21:22:24 --weightp --aq --aq-temporal
) else (
  echo [�G���[] �G���R�[�_�𐳂����w�肵�Ă��������B
  goto end
)

REM ---------------------------------------------------------------------------
REM �ݒ肱���܂�
REM ===========================================================================

:loop
if "%~1" == "" goto end
set file_ext=%~x1

if %file_ext% == .avs echo avs�t�@�C���ł͂Ȃ�����t�@�C�����h���b�O���Ă��������B & goto end

echo ===========================================================================
echo %~1
echo ---------------------------------------------------------------------------
echo �����J�n: %date% %time%
echo ===========================================================================
echo.

REM ---------------------------------------------------------------------------
REM SD�i���DVD�\�[�X�j�����T�C�Y�擾�Ŕ���
REM ---------------------------------------------------------------------------
set is_sd=0
for /f "delims=" %%A in ('%mediainfo% -f %1 ^| grep "Width" ^| head -n 1 ^| sed -r "s/Width *: (.*)/\1/"') do set info_width=%%A
for /f "delims=" %%A in ('%mediainfo% -f %1 ^| grep "Height" ^| head -n 1 ^| sed -r "s/Height *: (.*)/\1/"') do set info_height=%%A

if %info_width% == 720 set is_sd=1

REM ---------------------------------------------------------------------------
REM �ϐ��Z�b�g1
REM ---------------------------------------------------------------------------
set file_path=%~dp1
set file_name=%~n1
set file_fullname=%~dpn1
set file_fullpath=%~1

REM ---------------------------------------------------------------------------
REM ������擾
REM ---------------------------------------------------------------------------
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Commercial name" ^| head -n 1 ^| sed -r "s/Commercial name *: (.*)/\1/"') do set info_container=%%A

for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Codecs Video" ^| sed -r "s/Codecs Video *: (.*)/\1/"') do set info_vcodec=%%A
for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Audio codecs" ^| sed -r "s/Audio codecs *: (.*)/\1/"') do set info_acodec=%%A

for /f "delims=" %%A in ('%mediainfo% -f "%file_fullpath%" ^| grep "Bit depth" ^| head -n 1 ^| sed -r "s/Bit depth *: (.*)/\1/"') do set info_bitdepth=%%A
for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Display aspect ratio" ^| sed -r "s/Display aspect ratio *: (.*)/\1/"') do set info_aspect=%%A

for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Scan type" ^| sed -r "s/Scan type *: (.*)/\1/"') do set info_scan_type=%%A
for /f "delims=" %%A in ('%mediainfo% "%file_fullpath%" ^| grep "Scan order" ^| sed -r "s/Scan order *: (.*)/\1/"') do set info_scan_order=%%A

echo ����R���e�i�@�@�F%info_container%
echo �f���R�[�f�b�N�@�F%info_vcodec%
echo �����R�[�f�b�N�@�F%info_acodec%
echo �r�b�g�[�x�@�@�@�F%info_bitdepth%�r�b�g
echo �f���T�C�Y�@�@�@�F%info_width%x%info_height%px
echo �o�̓A�X�y�N�g��F%info_aspect%
echo �X�L�����^�C�v�@�F%info_scan_type%
if not "%info_scan_type%" == "Progressive" echo �X�L�����I�[�_�[�F%info_scan_order%
echo.

REM ---------------------------------------------------------------------------
REM �ϐ��Z�b�g2
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
set output_enc="%output_path%%file_name%.tmp.mp4"
set output_wav="%output_path%%file_name%.wav"
set output_aac="%output_path%%file_name%.aac"
set output_m4a="%output_path%%file_name%.m4a"
set output_mp4="%output_path%%file_name%.mp4"

REM ---------------------------------------------------------------------------
REM �A�X�y�N�g���ݒ�
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
  if %resize% == 0 if %info_width% == 1440 set sar=--sar 4:3
)

REM ---------------------------------------------------------------------------
REM �t�B�[���h�I�[�_�[����
REM ---------------------------------------------------------------------------
if "%info_scan_type%" == "Progressive" (
  set order_ref=PROGRESSIVE
  goto end_info_scan_order
)
if "%info_scan_order%" == "Bottom Field First" (
  set order_ref=BOTTOM
  if %deint_mode% == 0 set order_field=bff
) else (
  set order_ref=TOP
  if %deint_mode% == 0 set order_field=tff
)
if not %deint_mode% == 0 goto end_info_scan_order
if %video_encoder% == 0 (
  set int_opt=--%order_field%
) else if %video_encoder% == 1 (
  set int_opt=--%order_field%
) else if %video_encoder% == 2 (
  set int_opt=--interlace %order_field%
) else if %video_encoder% == 3 (
  set int_opt=--interlace %order_field%
)

:end_info_scan_order

if %use_lsmash% == 1 goto end_dgindex
if not "%info_container%" == "MPEG-TS" goto end_tssplitter
if not "%info_vcodec%" == "MPEG-2 Video" goto end_tssplitter
if not "%info_acodec%" == "AAC LC" if not "%info_acodec%" == "AAC LC / AAC LC" goto end_tssplitter
if %is_sd% == 1 goto end_tssplitter
echo ---------------------------------------------------------------------------
echo TSSplitter����
echo ---------------------------------------------------------------------------
if not exist "%source_fullpath%" (
  call %tssplitter% -EIT -ECM -EMM -SD -1SEG "%file_fullpath%"
) else (
  echo �����ς݂�TS�t�@�C�������݂��Ă��܂��B
)
echo.

:end_tssplitter

if not %audio_encoder% == 0 goto end_dgindex
if not "%info_container%" == "MPEG-TS" goto end_dgindex
if not "%info_vcodec%" == "MPEG-2 Video" goto end_dgindex
if not "%info_acodec%" == "AAC LC" if not "%info_acodec%" == "AAC LC / AAC LC" goto end_dgindex
echo ---------------------------------------------------------------------------
echo DGIndex����
echo ---------------------------------------------------------------------------
REM if not exist "%source_fullname%.d2v" if not exist "%source_fullname% PID *.aac" (
if not exist "%source_fullname%.d2v" (
  call %dgindex% -i "%source_fullpath%" -o "%source_fullname%" -ia 5 -fo 0 -yr 2 -om 2 -hide -exit
) else (
  echo �����ς݂�d2v�t�@�C�������݂��Ă��܂��B
)
echo.

for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *.aac"`) do set aac_fullpath=%file_path%%%A

REM if not %audio_encoder% == 0 goto end_faw
REM if not exist "%aac_fullpath%" goto end_faw
REM echo ---------------------------------------------------------------------------
REM echo  FAW�O����
REM echo ---------------------------------------------------------------------------
REM if not exist "%source_fullname% PID *_aac.wav" (
REM   call %fawcl% "%aac_fullpath%"
REM ) else (
REM   echo �^��wav�t�@�C�������݂��Ă��܂��B
REM )

REM :end_audio_split
REM for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *_aac.wav"`) do set wav_fullpath=%file_path%%%A
REM echo.
REM :end_faw

:end_dgindex

echo ---------------------------------------------------------------------------
echo avs�t�@�C����������
echo ---------------------------------------------------------------------------
if exist %avs% (
  echo avs�t�@�C�������݂��Ă��܂��B
  goto end_avs
)

echo SetFilterMTMode("DEFAULT_MT_MODE", MT_SERIALIZED)>>%avs%
echo SetFilterMTMode("TDeint",          MT_MULTI_INSTANCE)>>%avs%
echo SetFilterMTMode("TFM",             MT_MULTI_INSTANCE)>>%avs%
echo SetFilterMTMode("NNEDI3",          MT_MULTI_INSTANCE)>>%avs%
echo.>>%avs%

echo ### �t�@�C���ǂݍ��� ###>>%avs%
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
echo AudioDub(last, LSMASHAudioSource("%source_fullpath%", layout="stereo"))>>%avs%
goto end_lsmash

:lwlibav
echo LWLibavVideoSource("%source_fullpath%"%lsmash_format%)>>%avs%
echo AudioDub(last, LWLibavAudioSource("%source_fullpath%", av_sync=true, layout="stereo"))>>%avs%

:end_lsmash

:end_readfile
echo.>>%avs%

if %assumefps% == 1 echo AssumeFPS(30000, 1001, true)>>%avs% & echo.>>%avs%

echo ### �t�B�[���h�I�[�_�[ ###>>%avs%
if %order_ref% == TOP echo AssumeTFF()>>%avs%
if %order_ref% == BOTTOM echo AssumeBFF()>>%avs%
if %order_ref% == PROGRESSIVE echo #Progressive>>%avs%
echo.>>%avs%

echo ### �N���b�v ###>>%avs%
echo #Crop(8, 0, -8, 0)>>%avs%
echo.>>%avs%

if %is_sd% == 1 goto end_cm_cut_logo
if not "%info_container%" == "MPEG-TS" goto end_cm_cut_logo
if not "%info_vcodec%" == "MPEG-2 Video" goto end_cm_cut_logo

echo ### �T�[�r�X���擾 ###>>%avs%
echo ���擾��...
echo.

for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -c') do set service=%%A

echo %service% | find "�L���Ȕԑg�������o�ł��܂���ł���" >NUL
if not ERRORLEVEL 0 goto end_service

for /f "delims=" %%A in ('echo "%file_name%" ^| sed -r "s/^.* \[(.*)\].*/\1/"') do set service=%%A
for /f "delims=" %%A in ('echo %service%^| nkf32 -Z') do set service=%%A

:end_service

echo �T�[�r�X���F%service%
echo.
echo #�T�[�r�X���F%service%>>%avs%
echo.>>%avs%

if %cut_cm% == 0 goto end_auto_trim
echo ### ����CM�J�b�g ###>>%avs%
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
echo ### �蓮Trim ###>>%avs%
echo #Trim()>>%avs%
echo.>>%avs%

:end_trim

if %cut_logo% == 0 goto end_cm_cut_logo
echo ### ���S���� ###>>%avs%
echo EraseLOGO("%logo_path%%service%.lgd", pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true)>>%avs%
echo.>>%avs%
:end_cm_cut_logo

if "%info_scan_type%" == "Progressive" goto end_deint
echo ### �C���^�[���[�X���� / �t�e���V�l ###>>%avs%

if %deint_mode% == 3 goto set_deint_bob

if %is_sd% == 0 if "%info_vcodec%" == "MPEG-2 Video" goto is_tv_ts

REM DVD�\�[�X�̏ꍇ�A�܂���MPEG2�łȂ��ꍇ
if %deint_mode% == 1 goto set_deint
if %deint_mode% == 2 goto set_deint_it
goto end_deint

:is_tv_ts
if not "%info_container%" == "MPEG-TS" goto end_get_genre

echo ���擾��...
echo.

for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -g') do set genre=%%A
echo %genre% | find " ���J���̂Ɏ��s���܂���." >NUL
if not ERRORLEVEL 1 set genre=Unknown
echo %genre% | find "�L���Ȕԑg�������o�ł��܂���ł���" >NUL
if not ERRORLEVEL 1 set genre=Unknown

echo �W���������F%genre%
echo.
echo #�W���������F%genre%>>%avs%
echo.>>%avs%

if "%info_scan_type%" == "Progressive" goto end_deint

:end_get_genre

if "%genre%" == "Unknown" (
  if %deint_mode% == 1 goto set_deint
  if %deint_mode% == 2 goto set_deint_it
  goto end_deint
)

echo %genre% | find "�A�j��" > NUL
if not ERRORLEVEL 1 goto set_deint_it
echo %genre% | find "�f��" > NUL
if not ERRORLEVEL 1 goto set_deint_it

if %deint_mode% == 0 goto end_deint

:set_deint
echo #TIVTC24P2()>>%avs%
echo #TFM(order=-1, mode=6, PP=7)>>%avs%
echo #TDecimate(mode=1)>>%avs%
echo #QTGMC(Preset="Slower")>>%avs%
echo TDeint(edeint=nnedi3, emask=TMM2())>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2), emask=TMM2(mode=1))>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint

:set_deint_it
if %deint_mode% == 0 goto not_deint_it
echo TIVTC24P2()>>%avs%
echo #TFM(order=-1, mode=6, PP=7)>>%avs%
echo #TDecimate(mode=1)>>%avs%
echo #QTGMC(Preset="Slower")>>%avs%
echo #TDeint(edeint=nnedi3, emask=TMM2())>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2), emask=TMM2(mode=1))>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint
:not_deint_it
echo #TIVTC24P2()>>%avs%
echo TFM(order=-1, mode=6, PP=7)>>%avs%
echo TDecimate(mode=1)>>%avs%
echo #QTGMC(Preset="Slower")>>%avs%
echo #TDeint(edeint=nnedi3, emask=TMM2())>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2), emask=TMM2(mode=1))>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint

:set_deint_bob
echo #TIVTC24P2()>>%avs%
echo #TFM(order=-1, mode=6, PP=7)>>%avs%
echo #TDecimate(mode=1)>>%avs%
echo #QTGMC(Preset="Slower")>>%avs%
echo #TDeint(edeint=nnedi3, emask=TMM2())>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo TDeint(mode=1, edeint=nnedi3(field=-2), emask=TMM2(mode=1))>>%avs%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%

:end_deint

if %denoize% == 0 goto end_denoize

echo ### �m�C�Y���� ###>>%avs%
echo hqdn3d(2)>>%avs%
echo.>>%avs%

:end_denoize

if %resize% == 0 goto end_resize
if %is_sd% == 1 goto end_resize
if %info_width% leq 1280 goto end_resize

echo ### ���T�C�Y ###>>%avs%
echo Spline36Resize(1280, 720)>>%avs%
echo.>>%avs%
:end_resize

echo ### �V���[�v�� ###>>%avs%
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

echo avs�t�@�C���𐶐����܂����B
echo %avs%

:end_avs
echo.

if %check_avs% == 1 (
  echo ��avs�t�@�C���m�F�I�v�V�������ݒ肳��Ă��܂��B120�b�ԑҋ@���܂��B
  echo.
  echo ���m�F�E�ҏW���s���ꍇ�A[Ctrl] + [C]�ŃJ�E���g�_�E���𒆎~�ł��܂��B
  echo �����~�����ꍇ�A[Y]�ŏI�����邩�A[N]�ŏ����𑱍s���Ă��������B
  echo ���I����ɍēx���s����ƁA���ɍs���������̓X�L�b�v�i�ė��p�j����܂��B
  echo.
  timeout /T 120
)
echo.

echo ---------------------------------------------------------------------------
echo �f������
echo ���C���f�b�N�X�t�@�C�������쐬�̏ꍇ�́A�����J�n�܂łɎ��Ԃ�������܂��B
echo ---------------------------------------------------------------------------
if not exist %output_enc% (
  if %video_encoder% == 0 (
    call %x264% %x264_opt% %sar% %int_opt% -o %output_enc% %avs%
  ) else if %video_encoder% == 1 (
    call %qsvencc% %qsvencc_opt% %sar% %int_opt% -i %avs% -o %output_enc%
  ) else if %video_encoder% == 2 (
    call %nvencc% %nvencc_opt% %sar% %int_opt% -i %avs% -o %output_enc%
  ) else if %video_encoder% == 3 (
    call %nvencc% %nvencc_opt% %sar% %int_opt% -i %avs% -o %output_enc%
  )
) else (
  echo �G���R�[�h�ς݉f���t�@�C�������݂��Ă��܂��B
)
echo.

echo ---------------------------------------------------------------------------
echo ��������
echo ---------------------------------------------------------------------------
if not exist %output_wav% (
  call %wavi% %avs% %output_wav%
) else (
  echo ����wav�t�@�C�������݂��Ă��܂��B
)

if not %audio_encoder% == 0 goto qaac_encode
if %use_lsmash% == 1 goto qaac_encode
if not exist "%source_fullname%.d2v" goto qaac_encode

if not exist %output_aac% (
  call %fawcl% %output_wav% %output_aac%
) else (
  echo �G���R�[�h�ς�aac�t�@�C�������݂��Ă��܂��B
)
goto end_audio_encode

:qaac_encode
if not exist %output_aac% (
  call %qaac% %output_wav% -o %output_aac%
) else (
  echo �G���R�[�h�ς�aac�t�@�C�������݂��Ă��܂��B
)

:end_audio_encode
echo.

echo ---------------------------------------------------------------------------
echo muxer����
echo ---------------------------------------------------------------------------
if not exist %output_m4a% (
  call %muxer% -i %output_aac% -o %output_m4a%
) else (
  echo muxer�ς݂�m4a�t�@�C�������݂��Ă��܂��B
)
echo.

echo ---------------------------------------------------------------------------
echo remuxer����
echo ---------------------------------------------------------------------------
if not exist %output_mp4% (
  call %remuxer% -i %output_enc% -i %output_m4a% -o %output_mp4%
) else (
  echo remuxer�ς݂�mp4�t�@�C�������݂��Ă��܂��B
)
echo.

echo ---------------------------------------------------------------------------
echo �ꎞ�t�@�C������
echo ---------------------------------------------------------------------------
if %del_temp% == 0 goto no_del_temp

echo �ꎞ�t�@�C�����폜���܂��B
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
echo �ꎞ�t�@�C���Q�͎c���Ă���A������s���ɍė��p�i�������X�L�b�v�j�ł��܂��B
echo ����̏�������蒼�������ꍇ�́A�Y���t�@�C�����폜���čĎ��s���Ă��������B
echo �s�v�ɂȂ�����A���ׂĂ̈ꎞ�t�@�C�����폜���č\���܂���B
echo.
:end_del_temp

echo ===========================================================================
echo %output_mp4%
echo ---------------------------------------------------------------------------
echo �����I��: %date% %time%
echo ===========================================================================
echo.

shift
goto loop
:end

pause
