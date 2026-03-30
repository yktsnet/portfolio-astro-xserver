# ── Local dev ────────────────────────────────────────────────────
# Launches Astro dev server from anywhere.
# Usage: astro-xserver [dev|build|preview|install|clean]
#
astro-xserver() {
  emulate -L zsh
  setopt err_return pipe_fail

  local repo="$HOME/github-public/astro-xserver"
  local cmd="${1:-dev}"
  (( $# > 0 )) && shift

  cd "$repo" || return 1

  case "$cmd" in
    dev)     npm run dev -- --host "$@" ;;
    build)   npm run build "$@" ;;
    preview) npm run preview -- --host "$@" ;;
    install) npm install "$@" ;;
    clean)   rm -rf node_modules dist .astro package-lock.json ;;
    *)       npm run "$cmd" -- "$@" ;;
  esac
}

# ── Deploy to Xserver ─────────────────────────────────────────────
# Runs 3 steps in sequence:
#   1. npm run build  → generates dist/
#   2. rsync dist/ → Xserver public_html/ over SSH
#   3. git add -A / commit / push
#
# Usage: deploy-xserver ["optional commit message"]
#
deploy-xserver() {
  emulate -L zsh
  setopt err_return pipe_fail

  local repo="$HOME/github-public/astro-xserver"
  local remote_host="xs402041@xs402041.xsrv.jp"
  local remote_port="10022"
  local remote_path="xs402041.xsrv.jp/public_html/"

  if [[ ! -d "$repo/.git" ]]; then
    print "Error: $repo is not a git repository." >&2
    return 1
  fi

  print "→ build"
  (cd "$repo" && npm run build) || return 1

  print "→ rsync to Xserver"
  rsync -avz --delete \
    -e "ssh -p $remote_port" \
    "$repo/dist/" \
    "$remote_host:~/$remote_path" || return 1

  print "→ git push"
  local git_cmd=(git -C "$repo")
  $git_cmd add -A
  if ! $git_cmd diff --cached --quiet; then
    local msg="${*:-chore: auto-commit $(date -u +'%Y-%m-%d %H:%M:%S UTC')}"
    $git_cmd commit --no-verify -m "$msg"
  fi

  local branch
  branch=$($git_cmd symbolic-ref -q --short HEAD || true)
  if [[ -z "$branch" ]]; then
    print "Error: detached HEAD state." >&2
    return 1
  fi

  if $git_cmd rev-parse --symbolic-full-name @{u} >/dev/null 2>&1; then
    $git_cmd pull --no-rebase || return 1
    $git_cmd push --no-verify || return 1
  else
    local remote_name
    remote_name=$($git_cmd remote | head -n 1 || true)
    if [[ -n "$remote_name" ]]; then
      $git_cmd push --no-verify -u "$remote_name" "$branch" || return 1
    fi
  fi

  print "✓ deploy-xserver done"
}
