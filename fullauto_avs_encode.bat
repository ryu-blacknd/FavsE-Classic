@echo off

echo FullAuto AVS Encode 1.06

REM ----------------------------------------------------------------------
REM �G���R�[�_�̎w��i1:NVEncC, 0:x264�j
REM ----------------------------------------------------------------------
set use_nvenvc=0

REM ----------------------------------------------------------------------
REM avs������Ɉꎞ��~����CM�J�b�g���ʂ��m�F�E�ҏW���邩�i1:����, 0:���Ȃ��j
REM ----------------------------------------------------------------------
set check_avs=0

REM ----------------------------------------------------------------------
REM �I����Ɉꎞ�t�@�C�����폜���邩�i1:����, 0:���Ȃ��j
REM ----------------------------------------------------------------------
set del_temp=1

REM ----------------------------------------------------------------------
REM �G���R�[�_�̃I�v�V�����i�r�b�g���[�g�A�A�X�y�N�g��͎����ݒ�j
REM ----------------------------------------------------------------------
if %use_nvenvc% == 1 (
  set nvencc_opt=--avs --qp-init 19:22:24 --qp-min 18:21:23 --lookahead 20 --aq
) else (
  set x264_opt=--preset slower --crf 19 --partitions p8x8,b8x8,i8x8,i4x4 --ref 6 --no-fast-pskip --no-dct-decimate
)

REM ----------------------------------------------------------------------
REM �t�H���_��(�K�v�ɉ����ď��������Ă�������)
REM ----------------------------------------------------------------------
set output_path=F:\Encode\
set bin_path=C:\DTV\bin\
set logo_path=%bin_path%join_logo_scp\logo\
set cut_result_path=%bin_path%join_logo_scp\result\

REM ----------------------------------------------------------------------
REM ���s�t�@�C���_��(�K�v�ɉ����ď��������Ă�������)
REM ----------------------------------------------------------------------
set nvencc=%bin_path%NVEncC.exe
set x264=%bin_path%x264.exe
set avs2pipemod=%bin_path%avs2pipemod.exe
set fawcl=%bin_path%fawcl.exe
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
  echo [�G���[] �ϊ�����TS�t�@�C�����h���b�v���Ă��������B
  echo.
  goto end
)

echo ======================================================================
echo %~1
echo ----------------------------------------------------------------------
echo �����J�n: %date% %time%
echo ======================================================================
echo.

REM ----------------------------------------------------------------------
REM DVD�\�[�X������
REM ----------------------------------------------------------------------
set is_dvd=0
for /f "delims=" %%A in ('%mediainfo% %1 ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set width=%%A
if %width% == 720 set is_dvd=1

REM ----------------------------------------------------------------------
REM �ϐ��Z�b�g
REM ----------------------------------------------------------------------
set file_path=%~dp1
set file_name=%~n1
set file_fullname=%~dpn1
set file_fullpath=%~1

if %is_dvd% == 1 goto source_dvd
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
REM DVD�\�[�X�̂݃A�X�y�N�g���ύX
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

echo ----------------------------------------------------------------------
echo TSSplitter����
echo ----------------------------------------------------------------------
if %is_dvd% == 0 (
  if not exist "%source_fullpath%" (
    call %ts_spritter% -EIT -ECM -EMM -SD -1SEG "%file_fullpath%"
  ) else (
    echo ���Ƀt�@�C�������݂��܂��B
  )
) else (
  echo �����͕K�v����܂���B
)
echo.

echo ----------------------------------------------------------------------
echo  ������������
echo ----------------------------------------------------------------------
if not exist "%source_fullname% PID *.aac" (
  call %ts_parser% --mode da --delay-type 3 --rb-size 16384 --wb-size 32768 "%source_fullpath%"
) else (
  echo ���Ƀt�@�C�������݂��܂��B
)
for /f "usebackq tokens=*" %%A in (`dir /b "%source_fullname% PID *.aac"`) do set aac_fullpath=%file_path%%%A
echo.

echo ----------------------------------------------------------------------
echo avs�t�@�C����������
echo ----------------------------------------------------------------------
if exist %avs% (
  echo ���Ƀt�@�C�������݂��܂��B
  goto end_avs
)

echo SetMemoryMax(2048)>>%avs%
echo.>>%avs%

echo ### �t�@�C���ǂݍ��� ###>>%avs%
echo LWLibavVideoSource("%source_fullpath%", fpsnum=30000, fpsden=1001)>>%avs%
echo AudioDub(last, AACFaw("%aac_fullpath%"))>>%avs%
echo.>>%avs%

echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%

echo ### �t�B�[���h�I�[�_�[ ###>>%avs%
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

echo ### CM�J�b�g ###>>%avs%
for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -c') do set service=%%A
echo #�T�[�r�X���F%service%>>%avs%
set cut_fullpath="%cut_result_path%%cut_dir_name%\obs_cut.avs"
if exist %cut_fullpath% goto end_cm_cut
call %join_logo_scp% "%source_fullpath%"
:end_cm_cut

sleep 2
for /f "usebackq tokens=*" %%A in (%cut_fullpath%) do set trim_line=%%A
echo %trim_line%>>%avs%
echo.>>%avs%

echo ### ���S���� ###>>%avs%
echo EraseLOGO("%logo_path%%service%.lgd", pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true)>>%avs%
echo.>>%avs%

echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%
:end_cm_logo_cut

if "%scan_type%" == "Progressive" goto end_deint
echo ### �t�e���V�l / �C���^�[���[�X���� ###>>%avs%
set is_ivtc=0

if %is_dvd% == 0 goto not_dvd
echo #TIVTC24P2()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%
goto end_deint

:not_dvd
for /f "delims=" %%A in ('%rplsinfo% "%source_fullpath%" -g') do set genre=%%A
echo #�W���������F%genre%>>%avs%
if "%scan_type%" == "Progressive" goto end_deint
echo %genre% | find "�A�j��" > NUL
if not ERRORLEVEL 1 goto set_tivtc24p2
echo %genre% | find "�f��" > NUL
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
echo ### ���T�C�Y ###>>%avs%
echo (Width() ^> 1280) ? Spline36Resize(1280, 720) : last>>%avs%
echo.>>%avs%

REM echo ### �V���[�v�� ###>>%avs%
REM echo Sharpen(0.02)>>%avs%
REM echo.>>%avs%

:end_resize

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

echo avs�t�@�C���𐶐����܂����B

:end_avs
echo.

if %check_avs% == 1 (
  echo ��avs�t�@�C���m�F�I�v�V�������ݒ肳��Ă��܂��B
  echo ��avs�t�@�C����AvsPmod��AviUtl�Ŋm�F�E�ҏW���Ă��������B
  echo ���m�F�E�ҏW������͏����𑱍s�ł��܂��B
  echo.
  pause
)

REM ----------------------------------------------------------------------
REM �r�b�g���[�g��ݒ�iNVEncC�̂݁j
REM ----------------------------------------------------------------------
if %use_nvenvc% == 0 goto end_bitrate
if %is_dvd% == 0 (
  echo %genre% | find "�A�j��" > NUL
  if not ERRORLEVEL 1 (
    set bitrate_val=2765
    REM set bitrate_val=3456
    goto set_bitrate
  )
  echo %genre% | find "�f��" > NUL
  if not ERRORLEVEL 1 (
    set bitrate_val=3456
    goto set_bitrate
  )
  set bitrate_val=4147
) else (
  set bitrate_val=2592
)
:set_bitrate
set bitrate=--vbrhq %bitrate_val%
:end_bitrate

echo ----------------------------------------------------------------------
echo �f���G���R�[�h
echo ----------------------------------------------------------------------
if not exist %output_enc% (
  if %use_nvenvc% == 1 (
    call %nvencc% %nvencc_opt% %bitrate% %sar% -i %avs% -o %output_enc%
  ) else (
    call %x264% %x264_opt% %sar% -o %output_enc% %avs%
  )
) else (
  echo ���Ƀt�@�C�������݂��܂��B
)
echo.

echo ----------------------------------------------------------------------
echo ��������
echo ----------------------------------------------------------------------
if not exist %output_wav% (
  call %avs2pipemod% -wav %avs% > %output_wav%
) else (
  echo ���Ƀt�@�C�������݂��܂��B
)
if not exist %output_aac% (
  call %fawcl% %output_wav% %output_aac%
) else (
  echo ���Ƀt�@�C�������݂��܂��B
)
echo.

echo ----------------------------------------------------------------------
echo muxer����
echo ----------------------------------------------------------------------
if not exist %output_m4a% (
  call %muxer% -i %output_aac% -o %output_m4a%
) else (
  echo ���Ƀt�@�C�������݂��܂��B
)
echo.

echo ----------------------------------------------------------------------
echo remuxer����
echo ----------------------------------------------------------------------
if not exist %output_mp4% (
  call %remuxer% -i %output_enc% -i %output_m4a% -o %output_mp4%
) else (
  echo ���Ƀt�@�C�������݂��܂��B
)
echo.

echo ----------------------------------------------------------------------
echo �ꎞ�t�@�C������
echo ----------------------------------------------------------------------
if %del_temp% == 0 goto no_del_temp
echo �s�v�ɂȂ����ꎞ�t�@�C�����폜���܂��B
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
echo �ꎞ�t�@�C���Q�͎c���Ă���A����G���R�[�h����ۂɂ͍ė��p�i�������X�L�b�v�j���܂��B
echo ����̏�������蒼�������ꍇ�́A�Y�������̈ꎞ�t�@�C�����폜���čĎ��s���Ă��������B
echo �s�v�ɂȂ�����A���ׂĂ̈ꎞ�t�@�C���͍폜���č\���܂���B
echo.
:end_del_temp

echo ======================================================================
echo %~1
echo ----------------------------------------------------------------------
echo �����I��: %date% %time%
echo ======================================================================

shift
goto loop
:end

pause