@echo off

set BIN_DIR=C:\DTV\bin\
set LOGO_DIR=C:\DTV\AutoConvert\logo\
set TS_PARSER="%BIN_DIR%ts_parser\ts_parser.exe"
set TS_SPRITTER="%BIN_DIR%TsSplitter\TsSplitter.exe"

:loop
if "%~1" == "" goto end

set PATH_NAME=%~dp1
set TS_FILENAME=%~n1
set TS_PATH_NAME=%PATH_NAME%%TS_FILENAME%
set TS_FULL_NAME=%TS_PATH_NAME%.ts

REM #TS分離
if not exist "%TS_PATH_NAME%*DELAY*.aac" (
  call %TS_PARSER% --mode da --delay-type 3 --rb-size 4096 --wb-size 8192 --debug 1 "%TS_FULL_NAME%"
)
for /f "usebackq tokens=*" %%A in (`dir /b "%TS_PATH_NAME%*DELAY*.aac"`) do set AAC_FILE=%%A
echo %AAC_FILE%
pause
call %TS_SPRITTER% -EIT -ECM -EMM -SD -1SEG -SEP "%TS_FULL_NAME%"
pause

REM #DVDソースか判定
set ISDVD=0
for /f "delims=" %%A in ('%BIN_DIR%MediaInfo\MediaInfo.exe %1 ^| grep "Width" ^| sed -r "s/Width *: (.*) pixels/\1/" ^| sed -r "s/ //"') do set WIDTH=%%A
if %WIDTH% == 720 set ISDVD=1

REM #avsファイル作成開始
echo 処理中：%~dpn1
set AVS="%~dpn1.avs"
if exist %AVS% del %AVS%

echo avsource = %1>>%AVS%
echo.>>%AVS%

echo SetMemoryMax(2048)>>%AVS%
echo.>>%AVS%

echo SetMTMode(3, 0)>>%AVS%
echo.>>%AVS%

echo ### ファイル読み込み ###>>%AVS%
echo LWLibavVideoSource(avsource, fpsnum=30000, fpsden=1001)>>%AVS%
echo AudioDub(last, LWLibavAudioSource(avsource, av_sync=true))>>%AVS%
echo.>>%AVS%

echo SetMTMode(2, 0)>>%AVS%
echo.>>%AVS%

echo ### フィールドオーダー ###>>%AVS%
for /f "delims=" %%A in ('%BIN_DIR%MediaInfo\MediaInfo.exe %1 ^| grep "Scan type" ^| sed -r "s/Scan type *: (.*)/\1/"') do set SCAN_TYPE=%%A
for /f "delims=" %%A in ('%BIN_DIR%MediaInfo\MediaInfo.exe %1 ^| grep "Scan order" ^| sed -r "s/Scan order *: (.*)/\1/"') do set SCAN_ORDER=%%A

if "%SCAN_TYPE%" == "Progressive" (
  echo # %SCAN_TYPE%>>%AVS%
  goto :END_SCAN
)
if "%SCAN_ORDER%" == "Top Field First" echo AssumeTFF()>>%AVS%
if "%SCAN_ORDER%" == "Bottom Field First" echo AssumeBFF()>>%AVS%
:END_SCAN
echo.>>%AVS%

if %ISDVD% == 1 goto :END_CMLOGOCUT
echo ### CMカット ###>>%AVS%
if exist "%BIN_DIR%join_logo_scp\result\%~n1\obs_cut.avs" goto :END_CMCUT
call %BIN_DIR%join_logo_scp\jlse_bat.bat %1
:END_CMCUT
for /f "usebackq tokens=*" %%A in ("%BIN_DIR%join_logo_scp\result\%~n1\obs_cut.avs") do set TRIMLINE=%%A
echo SetMTMode(1, 0)>>%AVS%
echo %TRIMLINE%>>%AVS%
echo.>>%AVS%

echo ### ロゴ除去 ###>>%AVS%
for /f "delims=" %%A in ('%BIN_DIR%rplsinfo.exe %1 -c') do set SERVICE=%%A
echo #サービス名：%SERVICE%>>%AVS%
echo EraseLOGO("%LOGO_DIR%%SERVICE%.lgd", pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true)>>%AVS%
echo SetMTMode(2, 0)>>%AVS%
echo.>>%AVS%

:END_CMLOGOCUT

if "%SCAN_TYPE%" == "Progressive" goto :END_DEINT
echo ### 逆テレシネ / インターレース処理 ###>>%AVS%
set ISIVTC=0

if %ISDVD% == 0 goto :NOTDVD
echo #TIVTC24P2()>>%AVS%
echo #TDeint(edeint=nnedi3)>>%AVS%
echo TDeint(mode=1, edeint=nnedi3(field=-2))>>%AVS%
echo.>>%AVS%
goto :ENDNOTDVD

:NOTDVD
echo #ジャンル：%GENRE%>>%AVS%
for /f "delims=" %%A in ('%BIN_DIR%rplsinfo.exe %1 -g') do set GENRE=%%A
if "%SCAN_TYPE%" == "Progressive" goto :END_DEINT
echo %GENRE% | find "映画" > NUL
if not ERRORLEVEL 1 goto :SET_TIVTC24P2
echo %GENRE% | find "アニメ" > NUL
if not ERRORLEVEL 1 goto :SET_TIVTC24P2
goto :SET_TDeint
goto :END_DEINT

:SET_TIVTC24P2
set ISIVTC=1
echo TIVTC24P2()>>%AVS%
echo #TDeint(edeint=nnedi3)>>%AVS%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%AVS%
echo.>>%AVS%
goto :END_DEINT
:SET_TDeint
echo #TIVTC24P2()>>%AVS%
echo TDeint(edeint=nnedi3)>>%AVS%
echo #TDeint(mode=1, edeint=nnedi3(field=-2))>>%AVS%
echo.>>%AVS%
:END_DEINT

:ENDNOTDVD

if %ISDVD% == 1 goto :ENDRESIZE
echo ### リサイズ ###>>%AVS%
echo (Width() >= 1440) ? Spline36Resize(1280, 720, 0, 0.6) : last>>%AVS%
echo.>>%AVS%

:ENDRESIZE

echo return last>>%AVS%

if "%SCAN_TYPE%" == "Progressive" goto :ENDTIVTC24P2
echo.>>%AVS%
echo function TIVTC24P2(clip clip){>>%AVS%
echo Deinted=clip.TDeint(order=-1,field=-1,edeint=clip.nnedi3(field=-1))>>%AVS%
echo clip = clip.TFM(mode=6,order=-1,PP=7,slow=2,mChroma=true,clip2=Deinted)>>%AVS%
echo clip = clip.TDecimate(mode=1)>>%AVS%
echo return clip>>%AVS%
echo }>>%AVS%
:ENDTIVTC24P2

shift
goto loop
:end

exit
