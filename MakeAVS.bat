REM 2016.09.12 AviSynth+ 64bit版用に書き直し

@echo off

set files_dir=C:\DTV\Encode\
set logos_dir=C:\DTV\Encode\logos\
set plugins_dir=C:\Program Files (x86)\AviSynth+\plugins64+\

:loop
if "%~1" == "" goto end

set avs_file="%~dpn1.avs"
echo %avs_file%

echo avsource = %1>> %avs_file%
echo.>> %avs_file%

echo SetMemoryMax(2048)>> %avs_file%
echo Import("%files_dir%MT.avsi")>> %avs_file%
echo.>> %avs_file%

echo ### LSMASHSourceでの読み込み ###>> %avs_file%
echo #LWLibavVideoSource(avsource, dr=true, repeat=true, dominance=1, fpsnum=30000, fpsden=1001)>> %avs_file%
echo LWLibavVideoSource(avsource, dr=true, repeat=true, dominance=1).AssumeFPS(30000, 1001)>> %avs_file%
echo AudioDub(last, LWLibavAudioSource(avsource, av_sync=true, layout="stereo"))>> %avs_file%
echo if (height() == 1088) { Crop(0, 0, 0, -8) }>> %avs_file%
echo.>> %avs_file%

echo ### DirectShowSourceでの読み込み ###>> %avs_file%
echo #DirectShowSource(avsource, fps=30000.0 / 1001.0, convertfps=true)>> %avs_file%
echo.>> %avs_file%

echo ### AviSourceでの読み込み ###>> %avs_file%
echo #AviSource(avsource)>> %avs_file%
echo.>> %avs_file%

echo ### 字幕処理(idx+sub形式の字幕ファイルを拡張子なしで指定) ###>> %avs_file%
echo #VobSub("")>> %avs_file%
echo.>> %avs_file%

echo ### カット編集 ###>> %avs_file%
echo #Trim(0, 0)>> %avs_file%
echo.>> %avs_file%

echo ### 放送局ロゴファイル指定(ロゴ除去を行う場合のみコメントアウト) ###>> %avs_file%
echo logoname = "">> %avs_file%
echo #logoname = "NHK BS1.lgd">> %avs_file%
echo #logoname = "NHK BSプレミアム.lgd">> %avs_file%
echo #logoname = "BS日テレ.lgd">> %avs_file%
echo #logoname = "BS朝日.lgd">> %avs_file%
echo #logoname = "ＢＳ朝日１.lgd">> %avs_file%
echo #logoname = "BS-TBS.lgd">> %avs_file%
echo #logoname = "BSジャパン.lgd">> %avs_file%
echo #logoname = "BSフジ.lgd">> %avs_file%
echo #logoname = "WOWOWプライム.lgd">> %avs_file%
echo #logoname = "ＷＯＷＯＷライブ.lgd">> %avs_file%
echo #logoname = "ＷＯＷＯＷシネマ.lgd">> %avs_file%
echo #logoname = "スターチャンネル STAR1.lgd">> %avs_file%
echo #logoname = "スターチャンネル２.lgd">> %avs_file%
echo #logoname = "スターチャンネル３.lgd">> %avs_file%
echo #logoname = "イマジカＢＳ・映画.lgd">> %avs_file%
echo #logoname = "BS11.lgd">> %avs_file%
echo #logoname = "TwellV.lgd">> %avs_file%
echo #logoname = "ＢＳアニマックス.lgd">> %avs_file%
echo #logoname = "ＢＳ日本映画専門ｃｈ.lgd">> %avs_file%
echo #logoname = "東海テレビ.lgd">> %avs_file%
echo #logoname = "中京テレビ.lgd">> %avs_file%
echo #logoname = "中京テレビ１.lgd">> %avs_file%
echo #logoname = "ＣＢＣテレビ.lgd">> %avs_file%
echo #logoname = "メ～テレ.lgd">> %avs_file%
echo.>> %avs_file%

echo ### ロゴ除去(logonameが指定されている場合のみ実行される) ###>> %avs_file%
echo logofile = (logoname != "") ? "%logos_dir%" + logoname : "">> %avs_file%
echo if (logofile != "") { EraseLOGO(logofile=logofile, pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true) }>> %avs_file%
echo.>> %avs_file%

echo ### クロップ ###>> %avs_file%
echo #Crop(8, 0, -8, 0)>> %avs_file%
echo.>> %avs_file%

echo ### 塗りつぶし(ロゴファイルが無い場合) ###>> %avs_file%
echo #Letterbox(116, 0)>> %avs_file%
echo.>> %avs_file%

echo AssumeTFF()>> %avs_file%
echo.>> %avs_file%

echo ### 逆テレシネ + インターレース解除 ###>> %avs_file%
echo TIVTC24P2()>> %avs_file%
echo.>> %avs_file%

echo ### 逆テレシネのみ ###>> %avs_file%
echo #TDecimate(mode=1, hybrid=0)>> %avs_file%
echo.>> %avs_file%

echo ### インターレース解除のみ(後者は軽い) ###>> %avs_file%
echo #TDeint(order=1, edeint=nnedi3, emask=TMM2())>> %avs_file%
echo #TDeint(order=1, edeint=nnedi3)>> %avs_file%
echo.>> %avs_file%

echo ### リサイズ(x264側でアスペクト比を指定してもよい) ###>> %avs_file%
echo Spline36Resize(1280, 720)>> %avs_file%
echo #Spline36Resize(854, 480)>> %avs_file%
echo #Spline36Resize(640, 480)>> %avs_file%
echo.>> %avs_file%

echo ### アップコンバート(SD->HD拡大時、別に上記リサイズでも良い) ###>> %avs_file%
echo #nnedi3_rpow2(rfactor=2, nsize=4, nns=0, qual=1, cshift="spline36resize", fwidth=1280, fheight=720, ep0=4)>> %avs_file%
echo.>> %avs_file%

echo ### ノイズ除去(後者は軽く実写向け) ###>> %avs_file%
echo #FFT3DFilter(sigma=1.5, beta=1, plane=4, bw=32, bh=32, ow=16, oh=16, bt=3, sharpen=0, interlaced=false, wintype=0)>> %avs_file%
echo #hqdn3d(2)>> %avs_file%
echo.>> %avs_file%

echo ### シャープ化 ###>> %avs_file%
echo #Import("%plugins_dir%LSFmod.v1.9.avsi")>> %avs_file%
echo #LSFmod(defaults="slow", strength=40, dest_x=1280, dest_y=720)>> %avs_file%
echo.>> %avs_file%

echo return last>> %avs_file%
echo.>> %avs_file%

echo function TIVTC24P2(clip clip){>> %avs_file%
echo Deinted=clip.TDeint(order=-1,field=-1,edeint=clip.nnedi3(field=-1))>> %avs_file%
echo clip = clip.TFM(mode=6,order=-1,PP=7,slow=2,mChroma=true,clip2=Deinted)>> %avs_file%
echo clip = clip.TDecimate(mode=1)>> %avs_file%
echo return clip>> %avs_file%
echo }>> %avs_file%
echo.>> %avs_file%

shift
goto loop
:end

exit
