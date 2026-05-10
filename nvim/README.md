# 最強のNeovim設定

lazy.nvimベースのモダンなNeovim設定です。

## 特徴

- **プラグインマネージャー**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **カラースキーム**: Gruvbox
- **快適な開発環境**: LSP、ファイル検索、ターミナル統合など

## インストール済みプラグイン

- **gruvbox.nvim** - 美しいカラースキーム
- **alpha-nvim** - カスタマイズ可能なスタート画面
- **oil.nvim** - バッファライクなファイラー
- **telescope.nvim** - ファジーファインダー（ファイル・テキスト検索）
- **toggleterm.nvim** - 統合ターミナル
- **lualine.nvim** - モダンなステータスライン
- **noice.nvim** - コマンドライン・通知のUI強化
- **copilot.vim** - GitHub Copilot（AI補完）

## セットアップ方法

### 前提条件

- Neovim 0.9.0以上
- Git
- （オプション）ripgrep（Telescope検索用）
- （オプション）fd（Telescopeファイル検索用）

### 新しい端末でのインストール

```bash
# 既存の設定をバックアップ（ある場合）
mv ~/.config/nvim ~/.config/nvim.bak

# このリポジトリをクローン
git clone <YOUR_GITHUB_REPO_URL> ~/.config/nvim

# Neovimを起動（初回起動時にプラグインが自動インストールされます）
nvim
```

### プラグインの管理

lazy.nvimが自動的にプラグインを管理します。

- `:Lazy` - lazy.nvimのUIを開く
- `:Lazy sync` - プラグインの同期（更新・インストール・削除）
- `:Lazy update` - プラグインの更新
- `:Lazy clean` - 未使用プラグインの削除

## ディレクトリ構造

```
~/.config/nvim/
├── init.lua                   # メインエントリーポイント
├── lua/
│   ├── config/
│   │   ├── options.lua        # Neovimの基本設定
│   │   ├── keymaps.lua        # キーマッピング
│   │   └── autocmds.lua       # 自動コマンド
│   └── plugins/
│       ├── init.lua           # プラグイン定義
│       ├── alpha.lua          # Alphaの設定
│       ├── oil.lua            # Oilの設定
│       ├── telescope.lua      # Telescopeの設定
│       └── toggleterm.lua     # Toggletermの設定
└── .gitignore
```

## カスタマイズ

- **基本設定**: `lua/config/options.lua` を編集
- **キーマッピング**: `lua/config/keymaps.lua` を編集
- **プラグイン追加**: `lua/plugins/init.lua` にプラグインを追加
- **プラグイン設定**: `lua/plugins/` ディレクトリ内に新しいファイルを作成

## トラブルシューティング

### プラグインがインストールされない場合

```bash
# Neovimを開いて以下を実行
:Lazy sync
```

### 設定をリセットしたい場合

```bash
# プラグインデータを削除
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim

# Neovimを再起動してプラグインを再インストール
nvim
```

## ライセンス

MIT License

## 参考リンク

- [Neovim](https://neovim.io/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [LazyVim](https://www.lazyvim.org/) - さらに高機能な設定例
