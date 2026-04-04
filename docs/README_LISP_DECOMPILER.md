# JAR Decompiler Tool - Lisp Version

Common Lispで実装されたJARファイルデコンパイラツールです。

## 比較結果

### Bashバージョンとの比較

| 項目 | Bashバージョン | Lispバージョン |
|------|---------------|---------------|
| **実行時間** | 1.241秒 | 1.333秒 |
| **出力結果** | ✅ | ✅ 同一 |
| **機能** | CFR, Fernflower, Procyon | CFR, Fernflower, Procyon |
| **依存関係** | Bash, Java | SBCL, Java |
| **コード行数** | 約280行 | 約300行 |

## 必要な環境

- SBCL (Steel Bank Common Lisp)
- Java Runtime Environment (JRE)

## インストール

### 1. SBCLのインストール

```bash
# Ubuntu/Debian
sudo apt-get install sbcl

# macOS (Homebrew)
brew install sbcl

# または公式サイトから
# https://www.sbcl.org/
```

### 2. デコンパイラツールのインストール

```bash
# Bashバージョンのインストーラを使用可能
./install-decompilers.sh

# またはLispツール経由で自動ダウンロード
```

## 使用方法

### 基本的な使用

```bash
./jar-decompiler-lisp myapp.jar
```

### オプション

```bash
# 出力ディレクトリを指定
./jar-decompiler-lisp -o output_dir myapp.jar

# デコンパイラを選択（cfr, fernflower, procyon）
./jar-decompiler-lisp -d procyon myapp.jar

# 詳細モード
./jar-decompiler-lisp -v myapp.jar

# .classファイルを保持
./jar-decompiler-lisp -k myapp.jar

# ヘルプを表示
./jar-decompiler-lisp -h
```

## 実装の特徴

### Lispバージョンの利点

1. **エラー処理の向上**
   - より詳細なエラーメッセージ
   - condition systemによる柔軟なエラーハンドリング

2. **コードの構造化**
   - 関数型プログラミングの利点を活用
   - より明確な関数の分離

3. **拡張性**
   - 新しいデコンパイラの追加が容易
   - マクロによる拡張が可能

### Lispバージョンの制限

1. **起動時間**
   - SBCL処理系の初期化に約0.1秒余分にかかる

2. **依存関係**
   - SBCLのインストールが必要
   - すべてのシステムで利用可能ではない

3. **デバッグ**
   - Lispの知識がないとデバッグが困難

## 内部実装

### 主要な関数

- `decompile-jar` - メインのデコンパイル関数
- `extract-jar` - JARファイルの展開
- `find-class-files` - .classファイルの検索
- `decompile-classes` - クラスファイルのデコンパイル
- `parse-args` - コマンドライン引数の解析

### 使用しているSBCL固有機能

- `sb-ext:run-program` - 外部プロセスの実行
- `sb-ext:process-exit-code` - 終了コードの取得
- `sb-ext:*posix-argv*` - コマンドライン引数
- `sb-ext:exit` - プログラムの終了

## パフォーマンステスト結果

テストJAR: 3つのクラスファイル

```
Bashバージョン:
real    0m1.241s
user    0m2.593s
sys     0m0.420s

Lispバージョン:
real    0m1.333s  (+7.4%)
user    0m2.623s  (+1.2%)
sys     0m0.433s  (+3.1%)
```

## 結論

- **機能的に同等**: 両バージョンは同じ結果を生成
- **パフォーマンス**: わずかにBashバージョンが高速（約7%）
- **保守性**: Bashバージョンの方が一般的で保守しやすい
- **拡張性**: Lispバージョンの方が高度な機能を追加しやすい

## 推奨使用シナリオ

### Bashバージョンを選ぶべき場合
- 一般的な使用
- 複数人でのメンテナンス
- 最小限の依存関係
- 高速な起動時間が必要

### Lispバージョンを選ぶべき場合
- カスタマイズや拡張が必要
- より高度なエラー処理が必要
- Lispの開発環境がある
- REPLでの対話的な操作が必要