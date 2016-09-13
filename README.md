# 汎用AviSynth+スクリプトと自動エンコードバッチファイル

avs作成用バッチファイルと、自動エンコード用バッチファイルです。

AviSynthの拡張版であるAviSynth+ 64bit版を前提としています。

汎用性を重視し、DVD / BDソース、PT3等の録画ソース、その他あらゆる動画ファイルからmp4ファイルにエンコードすることができます。

仕組みや手法等、詳しくは[ブログ](https://blacknd.com)を参照してください。

## 実行に必要なもの

### AviSynsh+ 本体

- [AviSynth+ Installer](http://avs-plus.net/)
- [AviSynth+ 開発版](http://avisynth.nl/index.php/AviSynth%2B#Development_branch)

まずは安定版のインストーラーでインストールしてください。

開発版は、以下を上書きコピーしてください。

- `i386`内の`AviSynth.dll`と`system`内の`DevIL.dll`を`C:\Windows\SysWOW64`へ。

- `x64`内の`AviSynth.dll`と`system`内の`DevIL.dll`を`C:\Windows\System32`へ。

> フォルダ名がややこしいですが、逆ではないので注意してください。

- `i386`の`plugins`内ファイルをAviSynth+インストール先の`Plugins+`へ。

- `x64`の`plugins`内ファイルをAviSynth+インストール先の`Plugins64+`へ。

また`vc_regist.x64.exe`と`vc_regist.exe`はインストールされていない場合にインストールします。

> インストール後は、レジストリ書き換えを反映させるために再起動しましょう。

### AvsPmod

AviSynth+の64bit版を使用するとなると、AvsPmodも64bit版でなければなりません。

> 呼び出し元が32bitだと、AviSynth+も32bit版で動作するためです。

開発版の方に付属していますので、好きなところに解凍して使うか、現在のインストール先に上書きしてください。

### AviSynth+ プラグイン

32bit / 64bitの両方がある場合は、両方インストールするとAviSynth+がどちらでも動作するようになります。

このスクリプトを使用する際には64bit版のみでOKです。

- [AviSynth+ x64 plugins - Avisynth wiki](http://avisynth.nl/index.php/AviSynth%2B#AviSynth.2B_x64_plugins)

  -	Delogo
  - FFT3DFilter
  - hqdn3d
  - MaskTools2
  - nnedi3
  - RgTools
  - TDeint
  - TIVTC
  - VSFilterMod
  - WarpSharp

- [POP@4bit](http://pop.4-bit.jp/)

  - L-SMASH Works

- [Releases - chikuzen/TMM2](https://github.com/chikuzen/TMM2/releases)

  - TMM2

- [LSFmod - Doom9's Forum](http://forum.doom9.org/showthread.php?t=142706)

  -LSFmod (avisファイル)

- [FFTW Installation on Windows](http://www.fftw.org/install/windows.html)

  - FFTW Windows DLL : 64-bit version

FFT3DFilterの動作に必要なDLLファイルが入っています。

64bit版の場合、`libfftw3f-3.dll`を`C:\Windows\System32`にコピーします。

### エンコード用コマンド

- [...::: Komisar x264 builds :::...](http://komisar.gin.by/)

  - x264

右上にあるkModのx86_64をダウンロードします。

- [Fix crash of wavi - Doom9's Forum](http://forum.doom9.org/showthread.php?t=161639)

  - WAVI

真ん中辺りにx64版があります。

- [cabinet - qaac](https://sites.google.com/site/qaacpage/cabinet)

  - qaac

64bit版が同梱されています。

- [POP@4bit](http://pop.4-bit.jp/)

  - L-SMASH

必要なファイルは64bit版の`muxer.exe`と`remuxer.exe`です。


## 初期設定

環境によって以下の点を変更してください。

以下、フォルダ名は`\`で終わります。

### MakeAVS.bat

- `files_dir`：エンコード用コマンドのあるフォルダ
- `logos_dir`：透過ロゴファイルのあるフォルダ
- `plugins_dir`：AviSynth+インストールフォルダ内の`Plugins64+`フォルダ

### Encode.bat

- `program_dir`：エンコード用コマンドのあるフォルダ
- `output_dir`：出力先のフォルダ

- `x264_path`：x264コマンドのファイル名
- `wavi_path`：WAVIコマンドのファイル名
- `qaac_path`：qaacコマンドのファイル名
- `muxer_path`：muxerコマンドのファイル名
- `remuxer_path`：remuxerコマンドのファイル名

以下、`output_mp4`以外は一時ファイル名です。基本的に変更しなくてOKです。

```
set output_enc="%output_dir%%filename%.enc.mp4"
set output_wav="%output_dir%%filename%.wav"
set output_aac="%output_dir%%filename%.aac"
set output_m4a="%output_dir%%filename%.m4a"
set output_mp4="%output_dir%%filename%.mp4"
```

### x264のパラメータ設定

`Encode.bat`内のx264パラメータ設定を、ソースに合わせて変更します。

- `Quority`：アニメは19～21、実写は21～23
- `aspect`：必要ない or リサイズ後なら1:1、16:9なら32:27、4:3なら8:9
- `source_type`：アニメなら前者、実写なら後者

## 使い方

### MakeAVS.bat

ソースとなる動画ファイルを`MakeAVS.bat`にドラッグしてください。復数同時にドラッグすることができます。

すると同じファイル名のavsファイルが生成されます。初期状態では以下の動作になります。

- L-SMASH Worksで映像と音声を読み込み
- ロゴ除去をスキップ
- トップファーストに指定
- 逆テレシネ + インターレース解除
- 1280x720にリサイズ

これは私が主に録画したソースのエンコードを行っているためです。

実際には放送局に合致したロゴファイルを準備して、そのファイル名を代入している行をアンコメントして使います。

これで自動検知してロゴ除去が行われるようになります。

それ以外のソースの場合、適宜アンコメントとコメントアウトで機能の取捨選択を行ってください。

例えば逆テレシネ（24fps化）が不要な場合、ここをコメントアウトして、インターレース解除の行をアンコメントするといった具合です。

DVDソース（720x480）でリサイズしたくない場合、リサイズ部分をコメントアウトして、前述したx264のパラメータでアスペクト比を指定します。

この辺り、詳細はブログを御覧ください。

### Encode.bat

上記で用意したavsファイルを`Encode.bat`にドラッグしてください。こちらも複数同時にドラッグすると順番に処理します。

すると以下の手順でエンコードを自動化します（すべて64bit対応）。

1. x264で映像エンコード
1. WAVIでwavファイル作成
1. qaacでaacファイル作成
1. muxerでm4aファイル作成
1. remuxerで映像と音声をmp4に格納

> 巷ではDGIndexやBonTsDemuxで映像と音声を分離したり、擬似WAVを用いる説明が多いと思いますが、このやり方で音ズレも経験していませんし、音質劣化も気になったことがありません。
