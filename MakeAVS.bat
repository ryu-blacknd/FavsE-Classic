@echo off

set logos_path=C:\DTV\Encode\logos\

:loop
if "%~1" == "" goto end

set avs_file="%~dpn1.avs"
echo %avs_file%

echo avsource = %1>> %avs_file%
echo.>> %avs_file%

echo ### LSMASHSourceでの読み込み ###>> %avs_file%
echo #LWLibavVideoSource(avsource, dr=true, repeat=true, dominance=1, fpsnum=30000, fpsden=1001)>> %avs_file%
echo LWLibavVideoSource(avsource, dr=true, repeat=true, dominance=1).AssumeFPS(30000, 1001)>> %avs_file%
echo AudioDub(last, LWLibavAudioSource(avsource, av_sync=true, layout="stereo"))>> %avs_file%
echo.>> %avs_file%

echo SetMTMode(2, 0)>> %avs_file%
echo.>> %avs_file%

echo ### DirectShowSourceでの読み込み ###>> %avs_file%
echo #DirectShowSource(avsource, fps=30000.0 / 1001.0, convertfps=true)>> %avs_file%
echo.>> %avs_file%

echo ### AviSourceでの読み込み ###>> %avs_file%
echo #AviSource(avsource)>> %avs_file%
echo.>> %avs_file%

echo ### LWLibavVideoSourceでdr=trueを指定した場合の高さ調整 ###>> %avs_file%
echo (height() == 1088) ? Crop(0, 0, 0, -8) : SetMTMode(2)>> %avs_file%
echo.>> %avs_file%

echo ### 字幕処理(idx+sub) ###>> %avs_file%
echo #VobSub("")>> %avs_file%
echo.>> %avs_file%

echo ### カット編集 ###>> %avs_file%
echo.>> %avs_file%

echo ### 放送局ロゴファイル指定（ロゴ除去を行う場合のみ） ###>> %avs_file%
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

echo ### ロゴ除去（logonameが指定されている場合のみ） ###>> %avs_file%
echo logofile = (logoname != "") ? "C:\DTV\Encode\logos\" + logoname : "">> %avs_file%
echo (logofile != "") ? EraseLOGO(logofile=logofile, pos_x=0, pos_y=0, depth=128, yc_y=0, yc_u=0, yc_v=0, start=0, fadein=0, fadeout=0, end=-1, interlaced=true) : SetMTMode(2)>> %avs_file%
echo.>> %avs_file%

echo ### クロップ ###>> %avs_file%
echo #Crop(8, 0, -8, 0)>> %avs_file%
echo.>> %avs_file%

echo ### 塗りつぶし(ロゴファイルが無い場合) ###>> %avs_file%
echo #Letterbox(116, 0)>> %avs_file%
echo.>> %avs_file%

echo #AssumeTFF()>> %avs_file%
echo.>> %avs_file%

echo ### 逆テレシネ + インターレース解除(後者は軽い) ###>> %avs_file%
echo TIVTC24P2()>> %avs_file%
echo #TDeint(mode=0, order=1, type=3, tryweave=true).TDecimate(mode=1, hybrid=0)>> %avs_file%
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

echo ### アップコンバート(SD->HD拡大) ###>> %avs_file%
echo #nnedi3_rpow2(rfactor=2, nsize=4, nns=0, qual=1, cshift="spline36resize", fwidth=1280, fheight=720, ep0=4)>> %avs_file%
echo.>> %avs_file%

echo ### ノイズ除去 ###>> %avs_file%
echo #FFT3DFilter(sigma=1.5, beta=1, plane=4, bw=32, bh=32, ow=16, oh=16, bt=3, sharpen=0, interlaced=false, wintype=0)>> %avs_file%
echo #hqdn3d(2)>> %avs_file%
echo.>> %avs_file%

echo ### シャープ化 ###>> %avs_file%
echo #Import("C:\Program Files (x86)\AviSynth\plugins\LSFmod.v1.9.avsi");>> %avs_file%
echo #SetMTMode(6)>> %avs_file%
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
