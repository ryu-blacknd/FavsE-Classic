# FavsE Classic

読み方は「フェイブス」ですが、読みやすければ「ふぁぶせ」でも良いかと思います。
FavsEは開発当初の名称で、FullAuto AVS Encodeの略です。

## 2020年01月：このプロジェクトはGUI版に移行しました

GUI版の名称をFavsEとし、このバッチファイル版はFavsE Classicと名称を変更しました。
GUI化だけでなく様々な見直しを行っています。また現在入手不可となったツールを含んでいます。
旧版となるこちらのバッチファイル版は開発を停止する予定です。

## これは何？

動画ファイル（複数可）をドラッグすると、AVC + AACなMP4動画にエンコードするバッチファイルです。

手動では面倒なロゴ除去、CMカット、インターレース解除、アスペクト比設定やリサイズ等、様々な工程を全自動で判断して高速に処理します。

AVC / HEVC + aacなmp4ファイルへの変換ツールとしても機能します。

## 主な特徴

- ほぼすべての動画ファイル形式に対応（LSMASHSourceで読めるすべての動画ファイルが対象）
- TV番組録画ファイル、DVDソースのTSファイルなどを自動判別（アスペクト比自動セット等、いくつかの挙動が自動変化）
- 映像エンコーダを選択可能（x264, QSVEncC, NVEncC, NVEncC HEVC）
- ビット深度10bitの動画読み込みに対応（8bitで処理）
- 音声処理はFAWとqaacを選択可能（FAWを選択しても利用できない場合は自動でqaacを使用）
- 設定や動画の情報からAviSynth+スクリプトを自動生成
- AviSynth+スクリプト作成後に一時停止する機能あり（停止中にスクリプトファイルを編集可能）
- 自動ロゴ除去（しない設定も可能、tsファイル以外では無効）
- 自動CMカット（しない設定も可能、tsファイル以外では無効）
- TMPGEnc MPEG Smart Renderer等で番組情報が破壊されても、ファイル名に` [放送局名]`があればそれを使用
- 実写とアニメを自動判別してインターレース解除 / 逆テレシネ処理（インターレース保持、BOB化も可能）
- 実写とアニメを自動判別して3Dノイズ除去（しない設定も可能）
- `width`が1280px超になる場合、720pにリサイズ（しない設定も可能）
- 映像のシャープ化（しない設定も可能）
- 処理終了後に、作業ファイル群をすべて自動削除（しない設定も可能。その場合は作業ファイルを再利用可能）

## インストールと初期設定

フォルダ（例：`C:\DTV\bin`）を作成し、ダウンロードしたファイルを置いてください。

設定項目については、`favse.bat`の冒頭部分を参照してください。簡単な説明があります。  
設定変更による効果がわからない場合はそのままで良いです。

最低限必要な項目は、「**■確認必須：フォルダ名**」と「**■確認必須：実行ファイル名**」です。

実際のフォルダ名や実行ファイル名と合致していないと、エラーで実行できません。

## 使用方法

`favse.bat`（もしくは本ファイルのショートカット）に、動画ファイルをドラッグしてください（avsファイルではありません）。複数ファイルのドラッグにも対応します。

基本的な使用方法はこれだけです。

あとはドラッグされたファイル群を解析し、設定や動画情報に応じた処理を全自動で行います。

## 入力ファイルの仕様

LSMASHSourceで読めるすべての動画ファイルが対象です（ver.2.00より）。

つまり、よほど特殊なものを除きほぼすべての動画ファイルが対象となります。

音声処理にFAWを使う場合、**元の音声がAAC**である必要があります。

> FAW（FakeAacWav）とは、DGIndexやBonTsDemux等で分離したaacファイルを疑似wavファイルに変換（偽装）して使用するソフトウェアです。無劣化のままで編集 → aacファイルに戻すことができます。また、音ズレを防止する役目も果たします。

PT3等のTVチューナーで録画したtsファイルはFAWの条件を満たします。

気をつけるのは、同じtsファイルでもDVDソースからリッピングした場合などです。

例えば管理人オススメの[TMPGEnc MPEG Smart Renderer](https://www.amazon.co.jp/TMPGEnc-MPEG-Smart-Renderer-%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89/dp/B01CZSBBCA/ref=as_li_ss_tl?ie=UTF8&linkCode=ll1&tag=blacknd-22&linkId=018f85d3da64f66563638612dcd1ac37&language=ja_JP)は映像無劣化でtsファイルにできますが、デフォルトのままだと音声は**LPCM**や**AC-3**になるはずですので、出力直前の画面で音声を「**MPEG2 AAC(LC)**」に指定する必要があります。

> せっかくFAWを使うのに非可逆圧縮が入るのも気分的にアレですが、ビットレートを256kbpsとか384kbpsにすれば、元との違いを聞き分けられるような人はそうそういないと思います。

なおFAWを使用する設定でも、使用できない場合は自動判別によりqaacを使用します。

## 実行に必要なツール

FavsEの動作に必要なツールは以下の通りで、結構あります。それだけ多くのことを面倒みてくれると思ってください。

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

インストーラが付属するものを除き、フォルダを決めてまとめて置いてください。`favse.bat`と同一フォルダを推奨します。  
別のフォルダに置いた場合、正しく動作しない可能性があります。その際はWindowsのシステム環境変数`PATH`にフォルダを追加してください。

基本的にexeファイルだけで良いのですが例外もありますので、注意書きに目を通してください。x64などのフォルダ内に64bit版バイナリが格納されている場合が多いので注意してください。

#### エンコード関連

- [x264](https://onedrive.live.com/?authkey=%21ABzai4Ddn6_Xxd0&id=6BDD4375AC8933C6%214477&cid=6BDD4375AC8933C6)（exeファイルのみ必要です。バージョンアップのたびに設定変更するのも面倒なので`x264_x64.exe`にリネーム推奨です）
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

- [WAVI](https://forum.doom9.org/showthread.php?t=161639)（`wavi.exe`のみ必要です）
- [MediaInfo](https://mediaarea.net/en/MediaInfo/Download/Windows)（CLI版の`MediaInfo.exe`のみ必要です）
- [rplsinfo](https://www.axfc.net/u/3933238.zip)（`rplsinfo.exe`のみ必要です）
- [Git for Windows](https://gitforwindows.org/)（一部のLinuxコマンドを使用します。基本デフォルトでインストールします）
- [nkf](https://www.vector.co.jp/soft/win95/util/se295331.html)（`nkf32.exe`のみ必要です。文字列の全角半角変換を行います。）

**重要**： Git for Windowsに含まれるLinuxコマンドをコマンドプロンプトから使用するために、Windowsのシステム環境変数`PATH`に`C:\Program Files\Git\usr\bin\`を追加して再起動してください。

> Git for Windowsをアップデート後にFavsEが起動しなくなった場合、おそらく上記で指定したPATHが削除されてgrepコマンドが使用できなくなっています。この場合、再度PATHを追加すれば起動可能になります。PATH追加後の再起動は不要です。

※他にWSL（Windows Subsystem for Linux）等を使用する方法もありますが、Git for Windowsの方が簡単です。

#### 特殊ツール
- [join_logo_scp](http://www1.axfc.net/u/3458102.zip)（`join_logo_scp試行環境_2.zip`という圧縮ファイルの中身のみ必要です）
- [ver.3.05差分](https://www.axfc.net/u/3907064.zip)（上記フォルダ内に上書きします）

解凍した`join_logo_scp試行環境`フォルダは、`join_logo_scp`にリネームしておきます。

**重要**：join_logo_scpの動作には放送局ロゴの解析結果ファイルが必要です。これはAviUtlの[ロゴ解析](https://onedrive.live.com/?authkey=%21ABosHPfgyg0x7r0&id=6BDD4375AC8933C6%212698&cid=6BDD4375AC8933C6)プラグインで作成できます。  
作成したロゴファイルは、`join_logo_scp`フォルダ以下の`logo`フォルダ内に配置します。

> ロゴファイルを保存する際の拡張子は`.lgd`とします。`.lgd2`で保存するとjoin_logo_scpではエラーとなるようです。
