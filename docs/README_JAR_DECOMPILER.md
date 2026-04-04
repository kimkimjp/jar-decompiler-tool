# JAR Decompiler Tool

JAR ファイルを Java ソースコードに変換するツールです。

## 機能

- JAR ファイルから .class ファイルを抽出
- .class ファイルを .java ソースファイルにデコンパイル
- 複数のデコンパイラをサポート（CFR、Fernflower、Procyon）
- 元のパッケージ構造を保持
- Lambda 式、内部クラス、ローカルクラスなどの Java 8+ 機能をサポート

## インストール

1. Java がインストールされていることを確認:
```bash
java -version
```

2. デコンパイラツールをインストール:
```bash
./install-decompilers.sh
```

## 使用方法

### 基本的な使用方法
```bash
./jar-decompiler.sh myapp.jar
```

### オプション

- `-o, --output <dir>` : 出力ディレクトリを指定（デフォルト: `<jar_name>_src`）
- `-d, --decompiler <type>` : 使用するデコンパイラを選択（cfr、fernflower、procyon）
- `-k, --keep-class` : デコンパイル後も .class ファイルを保持
- `-v, --verbose` : 詳細出力を有効化
- `-h, --help` : ヘルプメッセージを表示

### 使用例

1. 特定の出力ディレクトリに展開:
```bash
./jar-decompiler.sh -o output_dir myapp.jar
```

2. Fernflower デコンパイラを使用:
```bash
./jar-decompiler.sh -d fernflower myapp.jar
```

3. 詳細モードで実行し、.class ファイルを保持:
```bash
./jar-decompiler.sh -v -k library.jar
```

## サポートされているデコンパイラ

### CFR (Class File Reader)
- **特徴**: 高速で信頼性が高い
- **長所**: 最新の Java 機能を良くサポート、エラー処理が優秀
- **推奨**: デフォルトで使用

### Fernflower
- **特徴**: IntelliJ IDEA の公式デコンパイラ
- **長所**: 読みやすいコードを生成、複雑な構造を良く処理

### Procyon
- **特徴**: 現代的な Java 機能を良く処理
- **長所**: Java 8+ の機能（Lambda、Stream API など）を正確に処理

## ファイル構成

- `jar-decompiler.sh` : メインのデコンパイラスクリプト
- `install-decompilers.sh` : デコンパイラツールのインストールスクリプト
- `decompiler-tools/` : デコンパイラの JAR ファイルが保存されるディレクトリ

## トラブルシューティング

### Java がインストールされていない場合
```bash
# Ubuntu/Debian
sudo apt-get install default-jdk

# RHEL/CentOS
sudo yum install java-11-openjdk

# macOS
brew install openjdk
```

### デコンパイルエラーが発生する場合
異なるデコンパイラを試してみてください:
```bash
./jar-decompiler.sh -d fernflower problematic.jar
./jar-decompiler.sh -d procyon problematic.jar
```

### メモリ不足エラーの場合
大きな JAR ファイルの場合、Java のヒープサイズを増やす必要があるかもしれません。
スクリプト内の java コマンドに `-Xmx2G` などのオプションを追加してください。

## 注意事項

- デコンパイルされたコードは元のソースコードと完全に一致しない場合があります
- コメントや変数名の一部は失われる可能性があります
- ライセンスや著作権に注意して使用してください
- デコンパイルは学習、デバッグ、依存関係の調査などの正当な目的でのみ使用してください