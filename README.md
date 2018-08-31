# FavsE (FullAuto AVS Encode)

読み方は「フェイブス」ですが、別に「ふぁぶせ」でもいいです。

動画ファイル（複数可）をドラッグすると、AVC + AACなMP4動画へのエンコード完了までの様々な工程を全自動で処理するバッチファイルです。

## 主な特徴

- 1つのバッチファイルへのドラッグでエンコードまでの処理がすべて完結
- 複数のファイルをドラッグすれば一括処理が可能
- ほぼすべての動画ファイル形式に対応（AVC / HEVC + aacなmp4への変換としても機能する）
- DVDソースのtsファイルにも対応（アスペクト比セット等、いくつかの挙動が異なる）
- ビット深度10bitの動画に自動対応（8bitで処理）
- エンコーダを選択可能（x264, QSVEncC, NVEncC, NVEncC HEVC）
- どのエンコーダを選択しても大体同じビットレートに（SSIMで0.98以上目標）
- 音声処理はFAWとqaacを選択可能（FAWを選択しても利用できない場合は自動でqaacを使用）
- 設定や動画の情報からAviSynth+スクリプトを自動生成
- AviSynth+スクリプト作成後に一時停止する機能あり（編集して作業続行可能）
- 自動CMカット（しない設定も可能、tsファイル以外では無効）
- 自動ロゴ除去（しない設定も可能、tsファイル以外では無効）
- インターレース保持/解除/BOB化/24fps化の自動/手動選択（プログレッシブな場合は無効）
  - 上記をGPU処理に置き換えることが可能（高速だが若干低品質）
- 実写とアニメを自動判別して3Dノイズ除去（しない設定も可能）
- widthが1280px超になる場合、720pにリサイズ（しない設定も可能）
- 若干のシャープ化（しない設定も可能）
- 処理終了後に、作業ファイル群をすべて削除（しない設定も可能。その場合は再利用可能）

### 要するに

「面倒な知識・判断・作業が不要で、お好きなエンコーダでのエンコード完了までを全自動化する1本のバッチファイル」です。

あの場合はこうして、この場合はこうして、あのソフトで読み込んでポチポチ、このソフトで読み込んでポチポチ…と面倒な作業は必要ありません。動画ファイルをドラッグするだけです。

## 使用方法

このバッチファイル（もしくはバッチファイルへのショートカット）に、動画ファイル（avsファイルではありません）をドラッグしてください。複数ファイルのドラッグにも対応します。

すると設定や動画情報に応じた動作を全自動で行います。AvsPmodやAviUtl + カット編集プラグイン等で手動カット編集を行いたい場合もあるかと思いますが、その際はavsファイル書き出し後に一時停止する設定にしてください。

設定項目については、バッチファイルの冒頭部分を参照してください。簡単な説明があります。

## 実行に必要なツール

FavsEの動作に必要なツールは以下の通りで、結構あります。それだけ多くのことを面倒みてくれると思ってください。

設定内容によっては無くても構わないものがありますが、今後の更新でどうなるかわかりませんので、一応すべて入れておくのが無難です。

以後すべて **64bit（x64版）** で揃えてください。Windowsが32bitの場合、もしくは64bit版が存在しない場合のみ32bitに読み換えてください。

AviSynth+のプラグインは、64bitと32bitの両方が必要であり、配布サイトが異なる場合があります（例：`DGDecode.dll`）。

> ツール類が動作しない場合は、[.NET Framework](https://www.microsoft.com/ja-jp/download/details.aspx?id=21)や[VC\+\+ Redistributable Packages](https://www.microsoft.com/en-us/download/details.aspx?id=40784)等の対応バージョンがインストールされていないケースが多いかと思います。この辺りは環境によりますのでググってみてください。

### AviSynth+ MT

まずは中核となるAviSynth+をインストールしてください。

> 4.00よりAviSynth MT 32bitからAviSynth+ MT 64bitに変更しました。

- [AviSynth+ MT](https://github.com/pinterf/AviSynthPlus/releases)（よくわからなければwith-vc-redistで）

#### AviSynth+ プラグイン

64bit版は`C:¥Program Files (x86)¥AviSynth+`内の`plugins64+`へ、32bit版は`plugins+`へコピーして使用します。

- [LSMASHSource](https://www.dropbox.com/sh/3i81ttxf028m1eh/AAABkQn4Y5w1k-toVhYLasmwa?dl=0)（2種ありますがLSMASHSourceの方です。`LSMASHSource.dll`のみ必要です）
- [delogo](https://www.avisynth.info/?%E3%82%A2%E3%83%BC%E3%82%AB%E3%82%A4%E3%83%96#bbcd6a1e)（`delogo.dll`のみ必要です）
- [NNEDI3](https://github.com/jpsdr/NNEDI3/releases)（`nnedi3.dll`のみ必要です。CPUに合ったフォルダを選択してください）
- [TDeinterlace](https://www.mediafire.com/download/kmcztm1xzjm/TDeinterlace_3-14-2010.rar)（`TDeinterlace.dll`のみ必要です。32bitは[TDeint](http://web.archive.org/web/20140420182314/http://bengal.missouri.edu/~kes25c/TDeintv11.zip)で、`TDeint.dll`のみ必要です）
- [TIVTC](https://github.com/pinterf/TIVTC/releases)（`TIVTC.dll`のみ必要です）
- [Hqdn3dY](https://forum.doom9.org/attachment.php?attachmentid=15589&d=1474456943)（`Hqdn3dY-x64.dll`が64bit版です。ハイフンは非推奨と警告が出るので`-x64`を消したほうが良いです）

### 各種ツール

以下はフォルダを決めて、まとめて置いてください（例：`C:\bin`）。PATHを通しておくと便利です。

基本的にexeファイルだけで良いのですが例外もありますので、注意書きに目を通してください。x64などのフォルダ内に64bit版バイナリが格納されている場合が多いので注意してください。

#### エンコード関連

- [x264](https://onedrive.live.com/?authkey=%21ABzai4Ddn6_Xxd0&id=6BDD4375AC8933C6%214477&cid=6BDD4375AC8933C6)（exeファイルのみ必要です。毎回設定変更するのも面倒なので`x264_x64.exe`等にリネーム推奨です）
- [QSVEncC](https://onedrive.live.com/?id=6BDD4375AC8933C6%21482&cid=6BDD4375AC8933C6)（AviUtl
用プラグインに同梱されています。`QSVEncC\x86`の中身が必要です）
- [NVEncC](https://onedrive.live.com/?id=6BDD4375AC8933C6%212293&cid=6BDD4375AC8933C6)（AviUtl
用プラグインに同梱されています。`NVEncC\x86`の中身が必要です）
- [fawcl](http://www2.wazoku.net/2sen/friioup/)（基本的に最新のものです。ページ内検索してください。`fawcl.exe`のみ必要です）
- [qaac](https://sites.google.com/site/qaacpage/cabinet)（`qaac64.exe`のみ必要です）
- [L-SMASH](https://onedrive.live.com/?id=6BDD4375AC8933C6%21404&cid=6BDD4375AC8933C6)（`muxer.exe`と`remuxer.exe`のみ必要です）

rigaya氏ビルドのものは更新多めなので、[同氏のブログ](https://rigaya34589.blog.fc2.com/)でフィードを購読しておくことをおすすめします。

#### 分割ツール

- [TSSplitter](https://www.videohelp.com/software/TSSplitter)（`TsSplitter.exe`のみ必要です）
- [DGIndex](http://rationalqm.us/dgmpgdec/dgmpgdec.html)（`DGDecode.dll`, `DGIndex.exe`, dllをリネームした`DGVfapi.vfp`が必要です）

> DGIndex 1.5.8にはバグがあり、修正・改造した[mod版のソース](https://onedrive.live.com/?id=8658EC275D9699D5%211215&cid=8658EC275D9699D5)が公開されています。ソースのみの配布でバイナリが無いため、VisualStudio 2017とNASMを導入して自分でビルドする必要があります。手順とWindows SDKのバージョンだけ気をつければ特に難しくはありません。なおビルドできるのは32bit版のみです。

#### 補助ツール

- [avs2pipemod](https://github.com/chikuzen/avs2pipemod/releases)（`avs2pipemod64.exe`のみ必要です）
- [MediaInfo](https://mediaarea.net/en/MediaInfo/Download/Windows)（CLI版の`MediaInfo.exe`のみ必要です）
- [rplsinfo](https://www.axfc.net/u/3933238.zip)（`rplsinfo.exe`のみ必要です）
- [sed for Windows](http://gnuwin32.sourceforge.net/packages/sed.htm)（BinariesとDependencies、`bin`の中身が必要です）
- [Grep for Windows](http://gnuwin32.sourceforge.net/packages/grep.htm)（BinariesとDependencies、`bin`の中身が必要です）

#### 特殊ツール
- [join_logo_scp](http://www1.axfc.net/u/3458102.zip)（`join_logo_scp試行環境_2.zip`という圧縮ファイルの中身のみ必要です）

> join_logo_scpは、[CMカットスレ](https://mevius.5ch.net/test/read.cgi/avi/1531949212/)で最新版が公開されています。上書きして使用します。不具合が修正されているようです。

#### その他

- [AvsPmod](https://forum.doom9.org/showpost.php?p=1801766&postcount=1202)（確認やカット編集を行えます。AviUtl + チャプター編集プラグインでも可です）

## 入力ファイルの仕様

LSMASHSourceで読めるすべての動画ファイルが対象です（ver.2.00より）。

つまり日常的に扱う動画ファイルのほぼすべてが対象となります。

音声処理にFAWを使う場合、**元の音声がAAC**である必要があります。

> FAW（FakeAacWav）とは、DGIndexやBonTsDemux等で分離したaacファイルを疑似wavファイルに変換（偽装）して使用するソフトウェアです。無劣化のままで編集 → aacファイルに戻すことができます。また、音ズレを防止する役目も果たします。

PT3等のTVチューナーで録画したtsファイルはFAWの条件を満たします。

気をつけるのは、同じtsファイルでもDVDソースからゴニョった場合など自力で作成した場合です。

例えば当サイト管理人オススメの[TMPGEnc MPEG Smart Renderer](https://www.amazon.co.jp/TMPGEnc-MPEG-Smart-Renderer-%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89/dp/B01CZSBBCA/ref=as_li_ss_tl?ie=UTF8&linkCode=ll1&tag=blacknd-22&linkId=018f85d3da64f66563638612dcd1ac37&language=ja_JP)は映像無劣化でtsファイルにできますが、デフォルトのままだと音声は**LPCM**や**AC-3**になると思います。

この場合、出力直前の画面で音声をAAC（**MPEG2 AAC(LC)**）に指定する必要があります。

> せっかくFAWを使うのに非可逆圧縮が入るのも気分的にアレですが、ビットレートを256kbpsとか384kbpsにすれば、元との違いを聞き分けられるような人はそうそういないと思います。

なおFAWを使用する設定でも、使用できない場合は自動判別によりqaacを使用します。
