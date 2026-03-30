# astro-xserver

Astro で構築したポートフォリオサイトを、Xserver レンタルサーバー向けに静的出力でホストするリポジトリ。  
rsync over SSH による1コマンドデプロイで運用しています。

> Cloudflare Pages 版: [yktsnet/portfolio-astro](https://github.com/yktsnet/portfolio-astro)

---

## スタック

| レイヤー | 技術 |
|---|---|
| フレームワーク | Astro（静的出力） |
| スタイリング | Tailwind CSS · Fira Code · Poimandres パレット |
| ホスティング | Xserver レンタルサーバー |
| デプロイ | rsync over SSH |

---

## ローカル確認

NixOS 環境では ZSH 関数でサブコマンドを管理しています。  
関数の実装は [`zsh/functions.zsh`](./zsh/functions.zsh) を参照してください。

```zsh
# 開発サーバー起動
astro-xserver dev

# ビルド確認
astro-xserver build
astro-xserver preview

# 依存インストール
astro-xserver install

# キャッシュ・成果物を一括削除
astro-xserver clean
```

他の環境では通常の npm コマンドで動きます。

```bash
npm install
npm run dev
npm run build
npm run preview
```

---

## デプロイ

`deploy-xserver` を実行すると以下を順に処理します。

1. `npm run build` — `dist/` を生成
2. `rsync` — SSH 経由で Xserver の `public_html/` へ転送
3. `git push` — リポジトリを更新

```zsh
deploy-xserver
# コミットメッセージを指定する場合
deploy-xserver "feat: update works section"
```

SSH の事前設定として、Xserver サーバーパネルの SSH 設定画面で公開鍵を登録しておく必要があります。

---

## ライセンス

MIT
