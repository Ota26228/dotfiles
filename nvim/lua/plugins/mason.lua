-- NixOS では mason によるバイナリ自動インストールが動作しない（非FHS環境）。
-- LSP サーバーは home.nix の home.packages でインストールする。
-- このファイルは mason を読み込まず、lspconfig のみに依存する設定。
return {}
