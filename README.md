# FavsE (FullAuto AVS Encode)

読み方は「フェイブス」です（本人は「ふぁぶせ」と呼んでいます）。

動画ファイル（複数可）をドラッグすると、AVC + AACなMP4動画へのエンコード完了までの様々な工程を全自動で高速処理するバッチファイルです。

## 主な特徴

- 1つのバッチファイルへのドラッグでエンコードまでの処理がすべて完結
- 複数のファイルをドラッグすれば一括処理が可能
- ほぼすべての動画ファイル形式に対応（AVC / HEVC + aacなmp4への変換としても機能する）
- TV録画番組、DVDソースのTSファイルなどを自動判別（アスペクト比自動セット等、いくつかの挙動が変化）
- エンコードが高速（DGDecodeに代わりMPEG2DecPlusを採用。LSMASHSourceはそもそも爆速）
- ビット深度10bitの動画に自動対応（8bitで処理）
- エンコーダを選択可能（x264, QSVEncC, NVEncC, NVEncC HEVC）
- どのエンコーダを選択しても大体同じビットレートに（SSIMで0.98以上目標）
- 音声処理はFAWとqaacを選択可能（FAWを選択しても利用できない場合は自動でqaacを使用）
- 設定や動画の情報からAviSynth+スクリプトを自動生成
- AviSynth+スクリプト作成後に一時停止する機能あり（停止中にスクリプトファイルを編集可能）
- 自動CMカット（しない設定も可能、tsファイル以外では無効）
- 自動ロゴ除去（しない設定も可能、tsファイル以外では無効）
- TMPGEnc MPEG Smart Rendererで番組情報が破壊されてもOK（ファイル名に` [放送局名]`があればそれを使用）
- インターレース保持/解除/24fps化/BOB化の自動/手動選択（プログレッシブなソースでは無効）
- 実写とアニメを自動判別して3Dノイズ除去（しない設定も可能）
- widthが1280px超になる場合、720pにリサイズ（しない設定も可能）
- 映像のシャープ化（しない設定も可能）
- 処理終了後に、作業ファイル群をすべて削除（しない設定も可能。その場合は再利用可能）

## 使用方法

バッチファイル（もしくはバッチファイルへのショートカット）に、動画ファイル（avsファイルではありません）をドラッグしてください。複数ファイルのドラッグにも対応します。

ドラッグされたファイル群を解析し、設定や動画情報に応じた処理を全自動で行います。

設定項目については、バッチファイルの冒頭部分を参照してください。簡単な説明があります。

## 入力ファイルの仕様

LSMASHSourceで読めるすべての動画ファイルが対象です（ver.2.00より）。

つまり、よほど特殊なものを除きほぼすべての動画ファイルが対象となります。

音声処理にFAWを使う場合、**元の音声がAAC**である必要があります。

> FAW（FakeAacWav）とは、DGIndexやBonTsDemux等で分離したaacファイルを疑似wavファイルに変換（偽装）して使用するソフトウェアです。無劣化のままで編集 → aacファイルに戻すことができます。また、音ズレを防止する役目も果たします。

PT3等のTVチューナーで録画したtsファイルはFAWの条件を満たします。

気をつけるのは、同じtsファイルでもDVDソースからリッピングした場合などです。

例えば管理人オススメの[TMPGEnc MPEG Smart Renderer](https://www.amazon.co.jp/TMPGEnc-MPEG-Smart-Renderer-%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89/dp/B01CZSBBCA/ref=as_li_ss_tl?ie=UTF8&linkCode=ll1&tag=blacknd-22&linkId=018f85d3da64f66563638612dcd1ac37&language=ja_JP)は映像無劣化でtsファイルにできますが、デフォルトのままだと音声は**LPCM**や**AC-3**になると思います。

この場合、出力直前の画面で音声を「**MPEG2 AAC(LC)**」に指定する必要があります。

> せっかくFAWを使うのに非可逆圧縮が入るのも気分的にアレですが、ビットレートを256kbpsとか384kbpsにすれば、元との違いを聞き分けられるような人はそうそういないと思います。

なおFAWを使用する設定でも、使用できない場合は自動判別によりqaacを使用します。

## 実行に必要なツール

FavsEの動作に必要なツールは以下の通りで、結構あります。**それだけ多くのことを面倒みてくれる**と思ってください。

設定内容によっては無くても構わないものがありますが、今後の更新でどうなるかわかりませんので、一応すべて入れておくのが無難です。

以後すべて **64bit（x64版）** で揃えてください。Windowsが32bitの場合、もしくは64bit版が存在しない場合のみ32bitに読み換えてください。

AviSynth+のプラグインは、64bitと32bitの両方が必要であり、配布サイトが異なる場合があります。

> ツール類が動作しない場合は、[.NET Framework](https://www.microsoft.com/ja-jp/download/details.aspx?id=21)や[VC\+\+ Redistributable Packages](https://www.microsoft.com/en-us/download/details.aspx?id=40784)等の対応バージョンがインストールされていないケースが多いかと思います。この辺りは環境によりますのでググってみてください。

### AviSynth+ MT

まずは中核となるAviSynth+ MTをインストールしてください。

> 4.00よりAviSynth MT 32bitからAviSynth+ MT 64bitに変更しました。

- [AviSynth+ MT](https://github.com/pinterf/AviSynthPlus/releases)（よくわからなければwith-vc-redistで）

#### AviSynth+ プラグイン

64bit版を`C:¥Program Files (x86)¥AviSynth+`内の`plugins64+`へ、32bit版を`plugins+`へコピーして使用します。

- [MPEG2DecPlus](https://kuroko.fushizen.eu/bin/)（AviSynth+対応高速化版です。既にDGDecode.dllがある場合は差し替えてください）
- [LSMASHSource](https://www.dropbox.com/sh/3i81ttxf028m1eh/AAABkQn4Y5w1k-toVhYLasmwa?dl=0)（2種ありますがLSMASHSourceの方です。`LSMASHSource.dll`のみ必要です）
- [delogo](https://www.avisynth.info/?%E3%82%A2%E3%83%BC%E3%82%AB%E3%82%A4%E3%83%96#bbcd6a1e)（`delogo.dll`のみ必要です）
- [NNEDI3](https://github.com/jpsdr/NNEDI3/releases)（`nnedi3.dll`のみ必要です。CPUに合ったフォルダを選択してください）
- [TDeinterlace](https://www.mediafire.com/download/kmcztm1xzjm/TDeinterlace_3-14-2010.rar)（`TDeinterlace.dll`のみ必要です。32bitは[TDeint](http://web.archive.org/web/20140420182314/http://bengal.missouri.edu/~kes25c/TDeintv11.zip)で、`TDeint.dll`のみ必要です）
- [TIVTC](https://github.com/pinterf/TIVTC/releases)（`TIVTC.dll`のみ必要です）
- [TMM2](https://github.com/chikuzen/TMM2/releases)（`TMM2.dll`またはCPUがAVX2に対応しているのであれば`TMM2_avx2.dll`が必要です）
- [Hqdn3dY](https://forum.doom9.org/attachment.php?attachmentid=15589&d=1474456943)（`Hqdn3dY-x64.dll`が64bit版です。ハイフンは非推奨と警告が出るので`-x64`を消したほうが良いです）

※「avsファイル作成処理」でエラーが発生する場合、上記プラグインが正しく導入されていない可能性が高いです。

### 各種ツール

以下はフォルダを決めて、まとめて置いてください（例：`C:\bin`）。PATHを通しておくと便利です。

基本的にexeファイルだけで良いのですが例外もありますので、注意書きに目を通してください。x64などのフォルダ内に64bit版バイナリが格納されている場合が多いので注意してください。

#### エンコード関連

- [x264](https://onedrive.live.com/?authkey=%21ABzai4Ddn6_Xxd0&id=6BDD4375AC8933C6%214477&cid=6BDD4375AC8933C6)（exeファイルのみ必要です。毎回設定変更するのも面倒なので`x264_x64.exe`等にリネーム推奨です）
- [QSVEncC](https://onedrive.live.com/?id=6BDD4375AC8933C6%21482&cid=6BDD4375AC8933C6)（AviUtl用プラグインに同梱されています。`QSVEncC\x64`の中身が必要です）
- [NVEncC](https://onedrive.live.com/?id=6BDD4375AC8933C6%212293&cid=6BDD4375AC8933C6)（AviUtl用プラグインに同梱されています。`NVEncC\x64`の中身が必要です）
- [fawcl](http://www2.wazoku.net/2sen/friioup/)（基本的に最新のものです。ページ内検索してください。`fawcl.exe`のみ必要です）
- [aacfaw](http://www.rutice.net/)（`aacfaw.aui`を`aacfaw.dll`に、`aacfaw_x64.aui`を`aacfaw_x64.dll`にリネームして配置してください）
- [qaac](https://sites.google.com/site/qaacpage/cabinet)（`qaac64.exe`のみ必要です）
- [L-SMASH](https://onedrive.live.com/?id=6BDD4375AC8933C6%21404&cid=6BDD4375AC8933C6)（`muxer.exe`と`remuxer.exe`のみ必要です）

rigaya氏ビルドのものは更新多めなので、[同氏のブログ](https://rigaya34589.blog.fc2.com/)でフィードを購読しておくことをおすすめします。

#### 分割ツール

- [TSSplitter](https://www.videohelp.com/software/TSSplitter)（`TsSplitter.exe`のみ必要です）
- [DGIndex](http://rationalqm.us/dgmpgdec/dgmpgdec.html)（`DGDecode.dll`, `DGIndex.exe`, dllをリネームした`DGVfapi.vfp`が必要です）

> DGIndexは、AviSynth+プラグインのMPEG2DecPlusとは別物で、使い道も異なります。

> DGIndex 1.5.8にはバグがあり、修正・改造した[mod版のソース](https://onedrive.live.com/?id=8658EC275D9699D5%211215&cid=8658EC275D9699D5)が公開されています。ソースのみの配布でバイナリが無いため、VisualStudio 2017とNASMを導入して自分でビルドする必要があります。手順とWindows SDKのバージョンだけ気をつければ特に難しくはありません。なおビルドできるのは32bit版のみです。

#### 補助ツール

- [avs2pipemod](https://github.com/chikuzen/avs2pipemod/releases)（`avs2pipemod64.exe`のみ必要です）
- [MediaInfo](https://mediaarea.net/en/MediaInfo/Download/Windows)（CLI版の`MediaInfo.exe`のみ必要です）
- [rplsinfo](https://www.axfc.net/u/3933238.zip)（`rplsinfo.exe`のみ必要です）
- [Git for Windows](https://gitforwindows.org/)（一部のLinuxコマンドを使用します。基本デフォルトでインストールします）
- [nkf](https://www.vector.co.jp/soft/win95/util/se295331.html)（`nkf32.exe`のみ必要です。文字列の全角半角変換を行います。）

Git for Windowsに含まれるLinuxコマンドをコマンドプロンプトから使用するため、Windowsのシステム環境変数`PATH`に`C:\Program Files\Git\usr\bin\`を追加して再起動してください。

※他にWSL（Windows Subsystem for Linux）等を使用する方法もありますが、Git for Windowsの方が簡単です。

#### 特殊ツール
- [join_logo_scp](http://www1.axfc.net/u/3458102.zip)（`join_logo_scp試行環境_2.zip`という圧縮ファイルの中身のみ必要です）

> join_logo_scpは、[CMカットスレ](https://mevius.5ch.net/test/read.cgi/avi/1531949212/)で最新版が公開されています。上書きして使用します。不具合が修正されているようです。

#### その他（任意）

- [AvsPmod](https://forum.doom9.org/showpost.php?p=1801766&postcount=1202)（フィルタ動作の確認やカット編集を行えます）

AvsPmodを導入すると、avsファイルを直接編集しながら結果を確認できます。自分でフィルタ設定やカット編集を行わない場合は不要です。

[AviUtl](http://spring-fragrance.mints.ne.jp/aviutl/) + [AviSynth Script エクスポート](http://www.geocities.jp/aji_0/)のTrim エクスポートプラグインでもカット編集はできます。AviUtl上のカット編集結果からAviSynthのTrim行をエクスポートできますので、これをコピペします。

[TMPGEnc MPEG Smart Renderer](https://www.amazon.co.jp/TMPGEnc-MPEG-Smart-Renderer-%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89/dp/B01CZSBBCA/ref=as_li_ss_tl?ie=UTF8&linkCode=ll1&tag=blacknd-22&linkId=018f85d3da64f66563638612dcd1ac37&language=ja_JP)はカット編集、特に自動CMカットには最適ですが、録画ファイルを編集した場合は番組情報が損なわれ、放送局名とジャンル情報を取得できなくなります（以前から要望が出ていますが改善されていません）。  
ただし先述の通り、ファイル名に` [放送局名]`が含まれる場合はそれを放送局名として使用しますので、CMカットやロゴ除去は問題はありません。

ジャンルについてはどうしようもないため、逆テレシネが必要となるアニメや映画の場合、エンコード前に生成されたavsファイルの編集が必要です。  
具体的にはインターレース解除の部分で、`TIVTC24P2()`（インターレース保持の場合は`TFM`と`TDecimate`の行）のコメントを外し、他をコメントアウトする必要があります。

なおこれらで手動CMカットを行った場合、本スクリプト設定部分の`cut_cm`を`0`にしてください。
