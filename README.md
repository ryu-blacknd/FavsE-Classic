## FullAuto AVS Encode

CMカット付きAviSynthスクリプトを自動生成して、面倒な判定や設定も自動で行い、NVEncまたはx264とFAWでエンコードするまでを完全自動化するバッチファイルです（長い）。

[BLACKND](https://blacknd.com)

面倒な処理を全部自動でやってくれるエンコーダー（のフロントエンド）だと考えてください。
PT3録画ファイルなどのMPEG2-TS（音声はAACのみ対応）なファイルをバッチファイルにドラッグすると、即座に自動処理を開始します。
複数ファイルをドラッグしての連続処理にも対応しています。

### 特徴

ソースとなる動画ファイルの情報を自動取得・判別し、適切な設定や処理内容を自動選択し、一部動作も変化します。
ビットレート、インターレース、逆テレシネ、アスペクト比、リサイズ、音声処理といった初心者の方には敷居が高い処理もすべて自動処理します。

判別の結果、DVDソースでなければCMカットも自動で行います。ただし結果が完全である保証はありません。
そのため、avsファイル生成後に一時停止して、CMカット結果をAvsPmodやAviUtlで確認・編集することができます。
編集した場合も、何かキーを押すことで処理を続行することができます。

映像のエンコーダはNVEncC（AVC）とx264を選択可能です。音声処理にはFAWを使用して無劣化で編集・出力します。
最終的にはH.264/AVC + AAC LCのmp4ファイルを出力します。

前にエンコードした際の一時ファイルが残っている場合はそれを流用するため、一部処理だけ高速にやり直すことが可能です。

処理完了後に一時ファイルは削除するか否かをバッチファイルの先頭で指定可能です。

### 実行に必要なツール

すべて32bit版で揃えてください。AviSynth+や64bit版で揃えていた時は色々面倒でした。

- [AviSynth](https://sourceforge.net/projects/avisynth2/files/AviSynth%202.6/AviSynth%202.6.0/)
2.60（32bit版）をインストール後、[MT対応dll](https://forum.doom9.org/showthread.php?t=148782)を`C:\Windows\SysWOW64`に上書きコピーしてくだい。
以下のフィルタ・プラグインが必要ですので、`C:\Program Files(x86)\AviSynth\plugins`に置いてください。

  - [L-SMASH Works](http://pop.4-bit.jp/?page_id=7929)
  - [aacfaw](http://www.rutice.net/)（aacfaw.auiをリネーム）
  - [delogo](https://github.com/makiuchi-d/delogo-avisynth/releases)
  - [nnedi3](https://forum.doom9.org/showthread.php?t=170083)
  - [TDeint](http://avisynth.nl/index.php/TDeint)
  - [TIVTC](http://avisynth.nl/index.php/TIVTC)

- [Git for Windows](https://gitforwindows.org/)
インストールしたくないなら、`grep.exe`と`sed.exe`がPATHの通った場所にあれば構いません。

- [NVEnvC](https://onedrive.live.com/?id=6BDD4375AC8933C6%212293&cid=6BDD4375AC8933C6)
必要なのは`NVEncC\x86`の中身です。x264しか使わないのであれば不要です。

- [x264 kMod](http://komisar.gin.by/)
avsの入力に対応しているバイナリです。ダウンロード後、ファイル名を`x264.exe`に変更してください。NVEncCしか使わないのであれば不要です。

- [TSSplitter](https://www.videohelp.com/software/TSSplitter)（日本語化：http://donkichirou.web.fc2.com/TSSplitter/TSSplitter_Jp.html）

- [ts_parser](https://onedrive.live.com/?cid=8658EC275D9699D5&id=8658EC275D9699D5!1696)

- [join_logo_scp](http://www1.axfc.net/u/3506121.zip)
必要なのは`join_logo_scp試行環境_2.zip`という圧縮ファイルの中身です。さらに[最新版](http://www1.axfc.net/u/3506121.zip)を上書きコピーしてください。

- [avs2pipemod](https://github.com/chikuzen/avs2pipemod/releases)

- [fawcl](http://www2.wazoku.net/2sen/friioup/)
アップローダにある`up1009.zip`というファイルです。

- [L-Smash](http://pop.4-bit.jp/?page_id=7920)
`muxer.exe`と`remuxer.exe`のみ必要です。

### 入力ファイル

MPEG2-TS（拡張子.ts）で、音声はAACである必要があります。

まず考えられるのは、PT3等の録画ファイルです。これはそのままドラッグすればOKです。
DVDソースからゴニョった場合、例えばTMPGEnc MPEG Smart Rendererだと、映像無劣化かつ音声無変換（LPCM、AC-3）で出力することが多いと思います。
映像は問題ありませんが、音声はAC-3ではなくMPEG2 AAC(LC)に変更する必要があります。私はこれをデフォルト設定として登録しています。

> せっかくFAWを使うのに非可逆圧縮が入るのも気分的にアレですが、ビットレートを256kbpsとか384kbpsにすれば、元との違いを聞き分けられる人はそうそういないかと。ともかくこれはDVDソースに限った話です。

### 処理内容

おおまかに言うと、以下のような処理を行っています。

1. 最初にフラグで初期設定を行う（エンコーダ選択、avsファイル生成後の一時停止、完了後の一時ファイル削除）
1. ソースとなるTSファイルをドラッグで受け取る（複数可）
1. DVDソースかその他かを判定（以後この情報により処理や設定を細かく分けている）
1. DVDソースであった場合、適切なアスペクト比を設定（それ以外は720pにリサイズ）
1. TSSplitterでエンコード処理部分を抽出
1. ts_parserで音声ファイルを分離（L-Smashと連携するDELAY付き）
1. join_logo_scpで自動CMカット（DVDソースの場合はスキップ）
1. ここまでに得られた設定を用いてavsファイルを生成
ロゴ除去、インターレース解除、逆テレシネ、リサイズもここでソースに従い処理します。DVDソースの場合は60fps化を行います。
1. 作成されたavsファイルを確認・編集するため一時停止（一時停止する設定の場合）
1. DVDソース、もしくはアニメや映画であるか等で判断してビットレートを設定
1. NVEncCまたはx264でavsから映像をエンコード（エンコーダは設定で選択）
1. avs2pipemodで音声をavsからwavに無劣化出力
1. fawclでwavからaacに無劣化変換
1. L-smash muxerでaacをm4aに変換
1. L-smash remuxerで映像と音声を結合してmp4出力
1. 一時ファイル削除（削除する設定の場合）
1. 複数ドロップされていたら1に戻って次の処理へ進む
1. すべての処理が完了したら一時停止

### おわりに

このように設定や処理内容をソースによって自動判別しつつ、GUI操作なしで完全自動処理するものが（そして希望通りの動作をするものが）、他に見つかりませんでした。

最後に残った候補がAuto Convertで、非常に良くできていると感じましたが、残念ながら細かな判定と分岐処理が自分の理想と少し違っていたので、結局自作しました。当たり前ですが、自分では便利に使えています。

要望があれば機能の拡張も考えます。例えば現段階だとQSVEncへの対応とかですね。自分の環境でテストできないので実装していません。
H.265/HEVCに対応していないのは、自分の都合によるものです（対応はすぐできるのですが）。この辺はブログに書く予定です。
