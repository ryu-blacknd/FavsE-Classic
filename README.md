## FavsE (FullAuto AVS Encode)

読み方は「フェイブス」ですが、別に通称ふぁぶせでも良いと思います。

制作に関すること、質問などはブログへどうぞ。

[BLACKND – Web系エンジニアのチラシ裏](https://blacknd.com/)

### 特徴

- 1つのバッチファイルですべて完結
- 複数のファイルをドラッグすれば連続処理が可能
- PT3等の録画ファイル（TSファイル）が対象
- エンコーダを選択可能（x264, QSVEncC, NVEncC）
- H.264/AVCが基本だが、NVEncのみH.265/HEVCを選択可能）
- どのエンコーダを選択しても大体同じビットレートになる（SSIMで0.98以上が目標）
- 音声処理はFAWとqaacを選択可能
- 自動CMカット（しない設定も可能）
  - 自動CMカットを行う場合はTsSplitterで自動分離
- 自動ロゴ除去
- 1080pになる場合、720pにリサイズするか選択可能
- AviSynthスクリプトをよしなに自動生成
- AviSynthスクリプト作成時にポーズする機能あり（手動編集して作業続行）
- インターレース解除/24fps化/BOB化の自動/手動選択
- DVDソースからゴニョってTS化したファイルにも対応
- DVDソースの場合はいくつかの動作が異なる
- 処理終了後に、作業ファイルをすべて削除するか選択可能

要するに面倒な判定や設定作業を行い、お好きなエンコーダを選んでエンコード完了するまでを完全自動化するバッチファイルです。
毎回使う設定にしておけば、あとはドラッグするだけでガンガン自動処理してくれます。
同様のGUIツールはありますが、毎日繰り返し行う作業でボタンクリックしまくりのGUIは好きになれません。AviUtlよりAviSynth派の作者です。

手動ドラッグではなくフォルダを監視して自動実行したい場合は、そういう監視ツールと併用してください。

面倒な処理を全部自動でやってくれるエンコーダー（のフロントエンド）だと考えてください。
PT3録画ファイルなどのMPEG2-TS（音声はAACのみ対応）なファイルをバッチファイルにドラッグすると、即座に自動処理を開始します。
複数ファイルをドラッグしての連続処理にも対応しています。

### 実行に必要なツール

まずは中核となるAviSynthをインストールしてください。

※以後すべて32bit（x86版）で揃えてください。AviSynth+や64bit（x64版)で揃えていた時は色々面倒でした。

- [AviSynth 2.60](https://sourceforge.net/projects/avisynth2/files/AviSynth%202.6/AviSynth%202.6.0/)
- [AviSynth MT対応dll](https://forum.doom9.org/showthread.php?t=148782)（64bit Windowsでは`C:\Windows\SysWOW64`にDLLを上書きコピーしてくだい）

以下のAviSynth用フィルタとプラグインは`C:\Program Files(x86)\AviSynth\plugins`に置いてください。

- [L-SMASH Works](http://pop.4-bit.jp/?page_id=7929)
- [aacfaw](http://www.rutice.net/)（aacfaw.auiの拡張子を.dllに変更）
- [delogo](https://github.com/makiuchi-d/delogo-avisynth/releases)
- [nnedi3](https://forum.doom9.org/showthread.php?t=170083)
- [TDeint](http://avisynth.nl/index.php/TDeint)
- [TIVTC](http://avisynth.nl/index.php/TIVTC)
- [D3DVP](https://github.com/nekopanda/D3DVP/releases)
- [Hqdn3d](http://avisynth.nl/index.php/Hqdn3d)

使用コマンドのため、以下をインストールしてください。

- [Git for Windows](https://gitforwindows.org/)
インストールしたくない場合、Windows版の`grep.exe`と`sed.exe`がPATHの通った場所にあれば構いません。
無いのであれば、GIt for Windowsに含まれるgrepやsedコマンドが必要なのでインストールし、64bit Windowsの場合`C:\Program Files\Git\usr\bin`にPATHを通してください（詳細はブログ参照）。

以下は、どこかフォルダを決めてまとめておいてください（例：`C:\bin`）。こちらもPATHを通すと便利です。

- [x264 kMod](http://komisar.gin.by/)（AviSynthスクリプトの入力に対応）
- [QSVEncC](https://onedrive.live.com/?cid=6bdd4375ac8933c6&id=6BDD4375AC8933C6%21482&lor=shortUrl)（`QSVEncC\x86`の中身）
- [NVEncC](https://onedrive.live.com/?id=6BDD4375AC8933C6%212293&cid=6BDD4375AC8933C6)（`NVEncC\x86`の中身）

　
- [avs2pipemod](https://github.com/chikuzen/avs2pipemod/releases)
- [fawcl](http://www2.wazoku.net/2sen/friioup/)（アップローダにある`up1009.zip`というファイル）
- [WAVI](https://forum.doom9.org/showthread.php?t=161639)
- [qaac](https://sites.google.com/site/qaacpage/cabinet)
- [L-Smash](http://pop.4-bit.jp/?page_id=7920)（`muxer.exe`と`remuxer.exe`のみ必要）

　
- [MediaInfo CLI](https://mediaarea.net/en/MediaInfo/Download/Windows)
- [rplsinfo](https://web.archive.org/web/20180309090449/http://saysaysay.net/rplstool)
- [TSSplitter](https://www.videohelp.com/software/TSSplitter)
- [ts_parser](https://onedrive.live.com/?cid=8658EC275D9699D5&id=8658EC275D9699D5!1696)
- [join_logo_scp](http://www1.axfc.net/u/3506121.zip)
必要なのは`join_logo_scp試行環境_2.zip`という圧縮ファイルの中身です。さらに[CMカットスレ](https://mevius.5ch.net/test/read.cgi/avi/1531949212/)を参考に、最新版を上書きコピーすることをお勧めします。

### 入力ファイルの仕様

MPEG2-TS（拡張子.ts）で、**音声はAAC**である必要があります。

まず考えられるのは、PT3等の録画ファイルです。これはそのままドラッグすればOKです。

DVDソースからゴニョった場合、例えばオススメの[TMPGEnc MPEG Smart Renderer](http://tmpgenc.pegasys-inc.com/ja/product/tmsr5.html)だと、映像無劣化かつ音声をLPCM、AC-3で出力することが多いと思います。
映像は問題ありませんが、音声はAC-3ではなく**MPEG2 AAC(LC)に変更**する必要があります。

> せっかくFAWを使うのに非可逆圧縮が入るのも気分的にアレですが、ビットレートを256kbpsとか384kbpsにすれば、元との違いを聞き分けられる人はそうそういないと思います。ともかくこれはDVDソースに限った話です。

### 処理内容

おおまかに言うと、以下のような処理を行っています。

1. ソースとなるTSファイルをドラッグで受け取る（複数可）
1. 最初にフラグで初期設定を行う（エンコーダ選択、自動CMカット、インターレース解除の種類、その他動作に関すること等）
1. rplsinfoやMediaInfoで様々な情報を判別、セット
1. DVDソースかその他かを判定（以後この情報により処理や設定を細かく分けている）
1. DVDソースであった場合、適切なアスペクト比を設定（それ以外は720pになるようリサイズ）
1. TSSplitterでエンコード処理部分を抽出
1. ts_parserで音声ファイルを分離（L-Smashと連携するDELAY付き / qaac選択の場合は行わない）
1. join_logo_scpで自動CMカット（DVDソースの場合はスキップ）
1. ここまでに得られた設定を用いてAviSynthスクリプトを生成
1. 作成されたAviSynthスクリプトを確認・編集するため一時停止（デフォルト：停止しない）
1. 指定されたエンコーダで、AviSynthスクリプトから映像をエンコード
1. avs2pipemodで音声をavsからwavに無劣化出力
1. fawclでwavからaacに無劣化変換（qaac選択の場合は行わない）
1. waviでAviSynthスクリプトからwavファイルを作成（FAW選択の場合は行わない）
1. qaacでwavからaacに変換（FAW選択の場合は行わない）
1. L-smash muxerでaacをm4aに変換
1. L-smash remuxerで映像と音声を結合してmp4出力
1. 一時ファイル削除（削除しない設定も可能）
1. 複数ドロップされていたら2に戻って処理を繰り返す
1. すべての処理が完了したら一時停止

### おわりに

結構頻繁に更新していますので、たまに最新版がないかチェックしてください。
大きな変化があればブログに書く予定です。
