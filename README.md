## FavsE (FullAuto AVS Encode)

読み方は「フェイブス」ですが、別に「ふぁぶせ」でも良いです。

制作に関すること、質問などはブログへどうぞ。

[BLACKND – Web系エンジニアのチラシ裏](https://blacknd.com/)

### 特徴

- 1つのバッチファイルでエンコード完了までの処理がすべて完結
- 複数のファイルをドラッグすれば連続一括処理が可能
- ほぼすべての動画ファイル形式に対応
- 10bitの動画読み込みに対応（出力: 8bit）
- エンコーダを選択可能（x264, QSVEncC, NVEncC, NVEncC HEVC）
- どのエンコーダを選択しても大体同じビットレートになる（SSIMで0.98以上目標）
- 音声処理はFAWとqaacを選択可能
- AviSynthスクリプトを自動生成
- AviSynthスクリプト作成時にポーズする機能あり（手動編集して作業続行可能）
- 自動CMカット（しない設定も可能）
  - 自動CMカットを行う場合はTsSplitterで自動分離
- 自動ロゴ除去（しない設定も可能）
- 実写とアニメを自動判別して3Dノイズ除去（しない設定も可能）
- 720p超になる場合、720pにリサイズ（しない設定も可能）
- 若干のシャープネス化（しない設定も可能）
- インターレース保持/解除/24fps化/BOB化の自動/手動選択
  - インターレース解除をGPU処理に置き換えることが可能（高速だが若干低品質）
- DVDソースの動画ファイルにも対応（いくつかの挙動が異なる）
- 処理終了後に、作業ファイルをすべて削除するか選択可能

要するに「面倒な知識・判断・作業を排除し、お好きなエンコーダでのエンコードが完了するまでをほぼ全自動化する1本のバッチファイル」です。

「設定はファイル冒頭のフラグだけ」「ファイルは1つだけ」に拘りました。操作はファイル（複数可）のドラッグのみです。

### 実行に必要なツール

FavsEの動作に必要なツールは以下の通りで、結構あります。

設定内容によっては無くても構わないものがありますが、今後の更新でどうなるかわかりませんので、一応すべて入れておくのが無難です。

以後すべて**32bit(x86版)**で揃えてください（Windowsが64bitでも）。

#### AviSynth

まずは中核となるAviSynthをインストールと、MT対応化ファイルの上書きコピーを行ってください。

- [AviSynth 2.60](https://sourceforge.net/projects/avisynth2/files/AviSynth%202.6/AviSynth%202.6.0/)
- [AviSynth MT対応dll](https://forum.doom9.org/showthread.php?t=148782)（64bit Windowsでは`C:\Windows\SysWOW64`にDLLを上書きコピーしてくだい）

以下のAviSynth用プラグインは`C:\Program Files(x86)\AviSynth\plugins`に置いてください。

- [L-SMASH Works](https://www.dropbox.com/sh/3i81ttxf028m1eh/AAABkQn4Y5w1k-toVhYLasmwa?dl=0)（LSMASHSourceの方が管理が楽）
- [aacfaw](http://www.rutice.net/)（aacfaw.auiの拡張子を.dllに変更）
- [delogo](https://github.com/makiuchi-d/delogo-avisynth/releases)
- [nnedi3](https://forum.doom9.org/showthread.php?t=170083)
- [TDeint](http://avisynth.nl/index.php/TDeint)
- [TIVTC](http://avisynth.nl/index.php/TIVTC)
- [D3DVP](https://github.com/nekopanda/D3DVP/releases)
- [_GPU25](http://www.avisynth.info/?GPU%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3)（拡張子`.hlsl`のファイルも必要）

#### 必須コマンドと推奨ソフトウェア

UNIX系コマンドである`grep`と`sed`が必要であるため、以下をインストールしてください。

- [Git for Windows](https://gitforwindows.org/)

インストールしたくない場合、Windows版の`grep.exe`と`sed.exe`がPATHの通った場所にあれば構いません。

コマンドが無い or よくわからないのであればGIt for Windowsをインストールし、64bit Windowsの場合`C:\Program Files\Git\usr\bin`にPATHを通してください。

#### 各種ツール

以下は、フォルダを決めてまとめておいてください（例：`C:\bin`）。こちらもPATHを通しておくと便利です。

基本的に実行ファイルだけで良いのですが例外もありますので、注意書きに目を通してください。

- [x264 kMod](http://komisar.gin.by/)（AviSynthスクリプトの入力対応版）
- [QSVEncC](https://onedrive.live.com/?cid=6bdd4375ac8933c6&id=6BDD4375AC8933C6%21482&lor=shortUrl)（`QSVEncC\x86`の中身）
- [NVEncC](https://onedrive.live.com/?id=6BDD4375AC8933C6%212293&cid=6BDD4375AC8933C6)（`NVEncC\x86`の中身）

- [fawcl](http://www2.wazoku.net/2sen/friioup/)（アップローダにある`up1009.zip`というファイル）
- [WAVI](https://forum.doom9.org/showthread.php?t=161639)
- [qaac](https://sites.google.com/site/qaacpage/cabinet)
- [L-SMASH](http://pop.4-bit.jp/?page_id=7920)（`muxer.exe`と`remuxer.exe`のみ必要）

- [TSSplitter](https://www.videohelp.com/software/TSSplitter)
- [ts_parser](https://onedrive.live.com/?cid=8658EC275D9699D5&id=8658EC275D9699D5!1696)
- [avs2pipemod](https://github.com/chikuzen/avs2pipemod/releases)

- [MediaInfo CLI](https://mediaarea.net/en/MediaInfo/Download/Windows)
- [rplsinfo](https://web.archive.org/web/20180309090449/http://saysaysay.net/rplstool)
- [join_logo_scp](http://www1.axfc.net/u/3506121.zip)

必要なのは`join_logo_scp試行環境_2.zip`という圧縮ファイルの中身です。さらに[CMカットスレ](https://mevius.5ch.net/test/read.cgi/avi/1531949212/)を参考に、最新版を上書きコピーすることをお勧めします。

### 入力ファイルの仕様

L-SMASH Worksで読めるすべての動画ファイルが対象です（ver.2.00より）

FAWを使う場合、**音声がAAC**である必要があります。よくわからなければqaacを使用してください。高音質設定なので、よほど敏感な人でないと音質はそれほど変わりません。

PT3等のTVチューナーで録画したファイルはFAWの条件をクリアしますので、そのままドラッグすればOKです。

気をつけるのはDVDソースからゴニョったファイルの場合です。

例えば当サイト管理人オススメの[TMPGEnc MPEG Smart Renderer](http://tmpgenc.pegasys-inc.com/ja/product/tmsr5.html)だと、映像無劣化かつ音声を**LPCM**や**AC-3**で出力することが多いと思います。

映像は問題ありませんが、音声はAC-3ではなくAAC（**MPEG2 AAC(LC)**）に変更する必要があります。

> せっかくFAWを使うのに非可逆圧縮が入るのも気分的にアレですが、ビットレートを256kbpsとか384kbpsにすれば、元との違いを聞き分けられるような人はそうそういないと思います。

mpeg4な動画ファイルも音声はAACであることが多いと思いますが、たまにFLACとかもありますのでご注意ください。[MediaInfo](https://mediaarea.net/en/MediaInfo)で調査することをオススメします。

繰り返しになりますが、よくわからなければqaacを使用してください。

### 使用方法

このバッチファイル、もしくはバッチファイルへのショートカットに、動画ファイルをドラッグしてください。複数同時ドラッグも可能です。

> 基本的に、元動画の形式に注意しなければならないのは、前述の通り**FAWを使用するときのみ**です。

すると設定に応じた動作を自動で行います。AvsPmodやAviUtl + カット編集プラグイン等で手動カット編集を行いたい場合もあるかと思いますが、その際はavsファイル書き出し後に一時停止する設定にしてくだい。

設定項目については、バッチファイルの冒頭部分を参照してください。

### おわりに

自動CMカット機能がありますが、オススメは手動カットです。もちろん最も正確なカットになります。

avsファイル作成後に一時停止する設定で、AviUtl + チャプター編集プラグインでカット編集 → Trim エクスポートプラグインでTrim情報をavsファイルの指定位置に書き足す方法が楽です。

またインターレース解除についてですが、私はインターレース保持をオススメしています。これは人によって意見が異なりますが、インターレース解除はプレイヤーやレンダラ、DirectShowフィルタによって「再生時に」で行うことができるからです。

GPUに対応したプレイヤーであれば、Intel Quick SyncやNVIDIA CUDA等により、CPUに負荷をかけずにインターレース解除などの再生支援機能を使用できます。

インターレース解除の方法を後から選択できるのも、インターレース保持でエンコードする際の利点です。
