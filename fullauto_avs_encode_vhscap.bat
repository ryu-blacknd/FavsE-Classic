@echo off

echo FullAuto AVS Encode VHSCap 1.04

REM ----------------------------------------------------------------------
REM avs生成後に一時停止してCMカット結果を確認・編集するか（1:する, 0:しない）
REM ----------------------------------------------------------------------
set check_avs=1

REM ----------------------------------------------------------------------
REM 終了後に一時ファイルを削除するか（1:する, 0:しない）
REM ----------------------------------------------------------------------
set del_temp=0

REM ----------------------------------------------------------------------
REM エンコーダのオプション（ビットレート、アスペクト比は自動設定）
REM ----------------------------------------------------------------------
set x264_opt=--preset slower --crf 19 --partitions p8x8,b8x8,i8x8,i4x4 --ref 6 --no-fast-pskip --no-dct-decimate

REM ----------------------------------------------------------------------
REM フォルダ名(必要に応じて書き換えてください)
REM ----------------------------------------------------------------------
set output_path=F:\Encode\
set bin_path=C:\DTV\bin\

REM ----------------------------------------------------------------------
REM 実行ファイルダ名(必要に応じて書き換えてください)
REM ----------------------------------------------------------------------
set x264=%bin_path%x264.exe
set avs2pipemod=%bin_path%avs2pipemod.exe
set qaac=%bin_path%qaac.exe
set muxer=%bin_path%muxer.exe
set remuxer=%bin_path%remuxer.exe

:loop
if "%~1" == "" goto end

if %~x1 == .avi (
  echo.
) else (
  echo [エラー] 変換元のAVIファイルをドロップしてください。
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
REM 変数セット
REM ----------------------------------------------------------------------
set file_path=%~dp1
set file_name=%~n1
set file_fullname=%~dpn1
set file_fullpath=%~1

set source_fullpath=%file_fullname%.avi

set avs="%file_fullname%.avs"
set output_enc="%output_path%%file_name%.enc.mp4"
set output_wav="%output_path%%file_name%.wav"
set output_aac="%output_path%%file_name%.aac"
set output_m4a="%output_path%%file_name%.m4a"
set output_mp4="%output_path%%file_name%.mp4"

echo ----------------------------------------------------------------------
echo avsファイル生成処理
echo ----------------------------------------------------------------------
if exist %avs% (
  echo 既にファイルが存在します。
  goto end_avs
)

echo SetMemoryMax(2048)>>%avs%
echo.>>%avs%

echo ### ファイル読み込み ###>>%avs%
echo AVISource("%source_fullpath%")>>%avs%
echo.>>%avs%

echo SetMTMode(2, 0)>>%avs%
echo.>>%avs%

echo ### クロップと塗りつぶし ###>>%avs%
echo Crop(8, 0, -8, -0)>>%avs%
echo Letterbox(0, 8, 0, 0)>>%avs%
echo.>>%avs%

echo ### インターレース解除 ###>>%avs%
echo AssumeTFF()>>%avs%
echo #TDeint(edeint=nnedi3)>>%avs%
echo TDeint(mode=1, edeint=nnedi3(field=-2))>>%avs%
echo.>>%avs%

echo ### リサイズ ###>>%avs%
echo LanczosResize(640, 480)>>%avs%
echo.>>%avs%

echo ### シャープ化 ###>>%avs%
echo #Sharpen(0.02)>>%avs%
echo.>>%avs%

echo ### カット編集 ###>>%avs%
echo #Trim()>>%avs%
echo.>>%avs%

echo return last>>%avs%

echo avsファイルを生成しました。

:end_avs
echo.

if %check_avs% == 1 (
  echo ※avsファイル確認オプションが設定されています。
  echo ※avsファイルをAvsPmodやAviUtlで確認・編集してください。
  echo ※確認・編集完了後は処理を続行できます。
  echo.
  pause
)
echo.

echo ----------------------------------------------------------------------
echo 映像エンコード
echo ----------------------------------------------------------------------
if not exist %output_enc% (
  call %x264% %x264_opt% %sar% -o %output_enc% %avs%
) else (
  echo 既にファイルが存在します。
)
echo.

echo ----------------------------------------------------------------------
echo 音声処理
echo ----------------------------------------------------------------------
if not exist %output_wav% (
  call %avs2pipemod% -wav %avs% > %output_wav%
) else (
  echo 既にファイルが存在します。
)
if not exist %output_aac% (
  call %qaac% -q 2 --tvbr 91 %output_wav% -o %output_aac%
) else (
  echo 既にファイルが存在します。
)
echo.

echo ----------------------------------------------------------------------
echo muxer処理
echo ----------------------------------------------------------------------
if not exist %output_m4a% (
  call %muxer% -i %output_aac% -o %output_m4a%
) else (
  echo 既にファイルが存在します。
)
echo.

echo ----------------------------------------------------------------------
echo remuxer処理
echo ----------------------------------------------------------------------
if not exist %output_mp4% (
  call %remuxer% -i %output_enc% -i %output_m4a% -o %output_mp4%
) else (
  echo 既にファイルが存在します。
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
if exist %avs% del /f /q %avs%
if exist %output_enc% del /f /q %output_enc%
if exist %output_wav% del /f /q %output_wav%
if exist %output_aac% del /f /q %output_aac%
if exist %output_m4a% del /f /q %output_m4a%

if not exist "%file_fullname%.lwi" echo "%file_fullname%.lwi"
if not exist "%source_fullpath%.lwi" echo "%source_fullpath%.lwi"
if not exist %avs% echo %avs%
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
