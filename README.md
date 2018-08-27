# FavsE (FullAuto AVS Encode)

読み方は「フェイブス」ですが、別に「ふぁぶせ」でもいいです。

制作に関すること、質問などはブログへどうぞ。

[BLACKND – Web系エンジニアのチラシ裏](https://blacknd.com/)

## 特徴

- 1つのバッチファイルへのドラッグでエンコードまでの処理がすべて完結
- 複数のファイルをドラッグすれば一括処理が可能
- ほぼすべての動画ファイル形式に対応
- DVDソースのtsファイルにも対応（アスペクト比セット等、いくつかの挙動が異なる）
- エンコーダを選択可能（x264, QSVEncC, NVEncC, NVEncC HEVC）
- どのエンコーダを選択しても大体同じビットレートに（SSIMで0.98以上目標）
- 音声処理はFAWとqaacを選択可能
- AviSynthスクリプトを自動生成
- AviSynthスクリプト作成後に一時停止する機能あり（編集して作業続行可能）
- 自動CMカット（しない設定も可能）
- 自動ロゴ除去（しない設定も可能）
- インターレース保持/解除/BOB化/24fps化の自動/手動選択
- 上記をGPU処理に置き換えることが可能（高速だが若干低品質）
- 実写とアニメを自動判別して3Dノイズ除去（しない設定も可能）
- 720p超になる場合、720pにリサイズ（しない設定も可能）
- 若干のシャープネス化（しない設定も可能）
- 処理終了後に、作業ファイルをすべて削除するか選択可能

要するに「面倒な知識・判断・作業を排除し、お好きなエンコーダでのエンコード完了までをほぼ全自動化する1本のバッチファイル」です。

「設定はファイル冒頭のフラグだけ」「ファイルは1つだけ」に拘りました。

## 使用方法

このバッチファイル、もしくはバッチファイルへのショートカットに、動画ファイル（avsファイルではありません）をドラッグしてください。複数ファイルの同時ドラッグにも対応します。

すると設定に応じた動作を自動で行います。AvsPmodやAviUtl + カット編集プラグイン等で手動カット編集を行いたい場合もあるかと思いますが、その際はavsファイル書き出し後に一時停止する設定にしてください。

設定項目については、バッチファイルの冒頭部分を参照してください。

## 実行に必要なツール

FavsEの動作に必要なツールは以下の通りで、結構あります。

設定内容によっては無くても構わないものがありますが、今後の更新でどうなるかわかりませんので、一応すべて入れておくのが無難です。

以後すべて **32bit（x86版）** で揃えてください。Windowsが64bitでも、ツール類は32bitです。

> 動作しない場合は、.NET FrameworkやMicrosoft Visual C++ 再頒布可能パッケージ等がインストールされていないケースが多いかと思います。この辺りは環境によりますのでググってみてください。

### AviSynth

まずは中核となるAviSynthをインストール、そしてMT対応化dllの上書きコピーを行ってください。

- [AviSynth 2.60](https://sourceforge.net/projects/avisynth2/files/AviSynth%202.6/AviSynth%202.6.0/)
- [AviSynth MT対応dll](https://forum.doom9.org/showthread.php?t=148782)（64bit Windowsでは`C:\Windows\SysWOW64`にdllファイルを上書きしてください）

以下のAviSynth用プラグインはdllファイルを`C:\Program Files(x86)\AviSynth\plugins`に置いてください。

- [L-SMASH Works](https://www.dropbox.com/sh/3i81ttxf028m1eh/AAABkQn4Y5w1k-toVhYLasmwa?dl=0)（LSMASHSourceの方がファイル1つなので管理が楽です）
- [delogo](https://github.com/makiuchi-d/delogo-avisynth/releases)
- [nnedi3](https://forum.doom9.org/showthread.php?t=170083)
- [TDeint](http://avisynth.nl/index.php/TDeint)
- [TIVTC](http://avisynth.nl/index.php/TIVTC)
- [D3DVP](https://github.com/nekopanda/D3DVP/releases)
- [_GPU25](http://www.avisynth.info/?GPU%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3)（拡張子`.hlsl`のファイルも必要です）

### 各種ツール

以下は、フォルダを決めてまとめておいてください（例：`C:\bin`）。PATHを通しておくと便利です。

基本的にexeファイルだけで良いのですが例外もありますので、注意書きに目を通してください。

- [x264 kMod](http://komisar.gin.by/)（AviSynthスクリプトの入力に対応しているバイナリです）
- [QSVEncC](https://onedrive.live.com/?cid=6bdd4375ac8933c6&id=6BDD4375AC8933C6%21482&lor=shortUrl)（`QSVEncC\x86`の中身です）
- [NVEncC](https://onedrive.live.com/?id=6BDD4375AC8933C6%212293&cid=6BDD4375AC8933C6)（`NVEncC\x86`の中身です）

- [fawcl](http://www2.wazoku.net/2sen/friioup/)（基本的に最新のものです。ページ内検索してください）
- [qaac](https://sites.google.com/site/qaacpage/cabinet)
- [L-SMASH](http://pop.4-bit.jp/?page_id=7920)（`muxer.exe`と`remuxer.exe`のみ必要です）

- [TSSplitter](https://www.videohelp.com/software/TSSplitter)
- [DGIndex](http://rationalqm.us/dgmpgdec/)（`dgmpgdec158.zip`が最新ですが、入手困難な改良版もあります。`DGIndex.exe`のみ必要です）
- [avs2pipemod](https://github.com/chikuzen/avs2pipemod/releases)

- [MediaInfo CLI](https://mediaarea.net/en/MediaInfo/Download/Windows)
- [rplsinfo](https://web.archive.org/web/20180309090449/http://saysaysay.net/rplstool)
- [join_logo_scp](http://www1.axfc.net/u/3506121.zip)（必要なのは`join_logo_scp試行環境_2.zip`という圧縮ファイルの中身のみです）

※join_logo_scpは、[CMカットスレ](https://mevius.5ch.net/test/read.cgi/avi/1531949212/)で最新版が公開されています。精度が上がっているようです。

### UNIX系コマンド

UNIX系コマンドである`grep`と`sed`が必要です。Cygwin等よりも以下をインストールするのが簡単です。

- [Git for Windows](https://gitforwindows.org/)（Gitと共にLinuxライクなコマンド群もインストールされます）

インストールしたくない場合、Windows版の`grep.exe`と`sed.exe`がPATHの通った場所にあれば構いません。

コマンドが無い or よくわからないのであればGIt for Windowsをインストールし、64bit Windowsの場合`C:\Program Files\Git\usr\bin`にPATHを通してください。

> Git for Windowsは64bit版でも構いません。

## 入力ファイルの仕様

L-SMASH Worksで読めるすべての動画ファイルが対象です（ver.2.00より）。

つまり日常的に扱う動画ファイルはほぼすべてが対象となります。

音声処理にFAWを使う場合、**元の音声がAAC**である必要があります。

> FAW（FakeAacWav）とは、DGIndexやBonTsDemux等で分離したaacファイルを疑似wavファイルに変換（偽装）して使用するソフトウェアです。後にaacファイルに戻すことができ、エンコードを介することによる音質の劣化を回避することができます。また、音ズレを防止する役目も果たします。

PT3等のTVチューナーで録画したtsファイルはFAWの条件をクリアしますので、そのままドラッグすればOKです。

気をつけるのは、同じtsファイルでもDVDソースからゴニョったり、自力で作成した場合です。

例えば当サイト管理人オススメの[TMPGEnc MPEG Smart Renderer](http://tmpgenc.pegasys-inc.com/ja/product/tmsr5.html)は映像無劣化でtsファイルにできますが、デフォルトのままだと音声は**LPCM**や**AC-3**になると思います。

この場合、出力直前の画面で音声を明示的にAAC（**MPEG2 AAC(LC)**）に指定する必要があります。

> せっかくFAWを使うのに非可逆圧縮が入るのも気分的にアレですが、ビットレートを256kbpsとか384kbpsにすれば、元との違いを聞き分けられるような人はそうそういないと思います。

条件に合わない場合、合わせたくない場合、よくわからない場合はFAWではなくqaacを使用してください。

なおFAWを使用する設定でも、使用できない場合は自動判別によりqaacを使用します。
