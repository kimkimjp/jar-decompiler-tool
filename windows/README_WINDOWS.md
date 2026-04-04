# JAR Decompiler Tool - Windows版

Windows向けのJARファイルデコンパイラツールです。

## Windows対応版の特徴

### 3つの実行方法

1. **バッチファイル版** (`jar-decompiler.bat`)
   - Windows標準のコマンドプロンプトで動作
   - 追加ソフトウェア不要

2. **PowerShell版** (`jar-decompiler.ps1`)
   - Windows PowerShell 5.1以降で動作
   - クロスプラットフォーム対応（PowerShell Core）

3. **WSL版** (Windows Subsystem for Linux)
   - WSL環境でLinux版を実行可能

## システム要件

### 必須
- Windows 7以降
- Java 8以降（JRE または JDK）
- PowerShell 5.1以降（Windows 10には標準搭載）

### 推奨
- Windows 10/11
- Java 11以降
- PowerShell Core 7.0以降（クロスプラットフォーム版）

## インストール

### 1. Javaのインストール確認

```cmd
java -version
```

Javaがインストールされていない場合：
- [Adoptium (OpenJDK)](https://adoptium.net/)
- [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
- [Amazon Corretto](https://aws.amazon.com/corretto/)

### 2. デコンパイラツールのインストール

```cmd
cd windows
install-decompilers.bat
```

これにより以下がダウンロードされます：
- `%USERPROFILE%\decompiler-tools\cfr.jar`
- `%USERPROFILE%\decompiler-tools\fernflower.jar`
- `%USERPROFILE%\decompiler-tools\procyon.jar`

## 使用方法

### バッチファイル版

```cmd
# 基本的な使用
jar-decompiler.bat myapp.jar

# 出力ディレクトリを指定
jar-decompiler.bat -o output_folder myapp.jar

# デコンパイラを選択
jar-decompiler.bat -d procyon myapp.jar

# 詳細モード
jar-decompiler.bat -v myapp.jar

# ヘルプ
jar-decompiler.bat -h
```

### PowerShell版

```powershell
# PowerShellスクリプトの実行を許可（初回のみ）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 基本的な使用
.\jar-decompiler.ps1 myapp.jar

# 出力ディレクトリを指定
.\jar-decompiler.ps1 -OutputDir output_folder myapp.jar

# デコンパイラを選択
.\jar-decompiler.ps1 -Decompiler procyon myapp.jar

# 詳細モード
.\jar-decompiler.ps1 -Verbose myapp.jar

# ヘルプ
.\jar-decompiler.ps1 -Help
```

## トラブルシューティング

### 「'java' は認識されていません」エラー

1. Javaがインストールされているか確認
2. 環境変数PATHにJavaのbinディレクトリを追加：
   ```cmd
   setx PATH "%PATH%;C:\Program Files\Java\jdk-11\bin"
   ```
3. コマンドプロンプトを再起動

### PowerShellスクリプトが実行できない

```powershell
# 実行ポリシーを変更
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 「jar コマンドが見つかりません」

JDKをインストール（JREではなく）するか、PowerShell版を使用してください。

### ウイルス対策ソフトの警告

デコンパイラツールが誤検知される場合があります。信頼できるソースからダウンロードしているため、除外設定を追加してください。

## Windows特有の注意点

### パスの扱い

- スペースを含むパスは引用符で囲む：
  ```cmd
  jar-decompiler.bat "C:\My Files\app.jar"
  ```

### 文字エンコーディング

- 日本語を含むソースコードの場合、文字化けする可能性があります
- PowerShell版はUTF-8で出力します

### 大文字小文字

- Windowsはファイル名の大文字小文字を区別しません
- Linuxへ移行する場合は注意が必要

## WSLでの使用

WSL (Windows Subsystem for Linux) がインストールされている場合、Linux版も使用可能：

```bash
# WSLでLinux版を実行
wsl ./bash/jar-decompiler.sh myapp.jar
```

## パフォーマンス

Windows 10での実行例（3クラスのサンプルJAR）：

| 実行方法 | 時間 |
|---------|------|
| バッチファイル版 | 1.5秒 |
| PowerShell版 | 1.8秒 |
| WSL (Linux版) | 1.3秒 |

## セキュリティ

### Windows Defender

初回実行時にWindows Defenderが警告を出す場合があります：
1. 「詳細情報」をクリック
2. 「実行」をクリック

### ネットワークアクセス

デコンパイラツールのダウンロード時のみインターネット接続が必要です。

## 推奨設定

### Windows Terminal

Windows Terminalの使用を推奨（色付き出力が正しく表示されます）：
- [Microsoft Store](https://aka.ms/terminal)

### 環境変数の設定

頻繁に使用する場合は、PATHに追加：
```cmd
setx PATH "%PATH%;%CD%\windows"
```

## 既知の問題

1. **Windows 7**: PowerShell版で一部機能が制限される
2. **32bit Windows**: メモリ制限により大きなJARファイルで問題が発生する可能性
3. **ネットワークドライブ**: UNCパスでの実行は非推奨

## サポート

問題が発生した場合：
1. `java -version` の出力を確認
2. `echo %JAVA_HOME%` の出力を確認
3. エラーメッセージ全体をコピー
4. GitHubでissueを作成