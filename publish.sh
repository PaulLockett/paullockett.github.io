#!/usr/bin/env bash
# publish.sh — one-shot publisher for paullockett.github.io
#
# What this does:
#   1. Copies the ADEM construction-decade report + companion CSVs + PDF
#      from the source project into adem-construction-decade/ as index.html
#      (so the URL becomes https://paullockett.github.io/adem-construction-decade/).
#   2. Initializes the git repo if not already.
#   3. Stages, commits, and pushes to github.com/PaulLockett/paullockett.github.io.
#   4. Creates the GitHub repo via `gh` if it doesn't exist yet (uses your
#      already-authenticated gh CLI; falls back with a clear message if not).
#
# Run from anywhere:
#     bash /Users/paullockett/Documents/Code/Browserstuff/paullockett.github.io/publish.sh
#
# Re-runs are safe — it's idempotent. To add the next report, drop a new
# subfolder into the repo, update index.html, and re-run this script.

set -euo pipefail

# ─── paths ───────────────────────────────────────────────────────────────────
REPO_DIR="/Users/paullockett/Documents/Code/Browserstuff/paullockett.github.io"
SRC_DIR="/Users/paullockett/Documents/Code/Browserstuff/adem-construction-decade/output"
REPORT_SLUG="adem-construction-decade"
DST_DIR="$REPO_DIR/$REPORT_SLUG"
GH_USER="PaulLockett"
GH_REPO="paullockett.github.io"

say() { printf "\n\033[1;34m▸\033[0m %s\n" "$*"; }
ok()  { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
warn(){ printf "  \033[1;33m!\033[0m %s\n" "$*"; }
die() { printf "\n\033[1;31m✗\033[0m %s\n" "$*"; exit 1; }

# ─── preflight ───────────────────────────────────────────────────────────────
say "Preflight"
[[ -d "$REPO_DIR" ]] || die "Repo folder not found: $REPO_DIR"
[[ -d "$SRC_DIR"  ]] || die "Source folder not found: $SRC_DIR"
[[ -f "$SRC_DIR/Mobile_Baykeeper_Report.html" ]] || die "Report HTML missing: $SRC_DIR/Mobile_Baykeeper_Report.html"
ok "Repo folder:   $REPO_DIR"
ok "Source folder: $SRC_DIR"

# ─── copy report + assets ────────────────────────────────────────────────────
say "Copying report + companion data into $REPORT_SLUG/"
mkdir -p "$DST_DIR"

cp -f "$SRC_DIR/Mobile_Baykeeper_Report.html" "$DST_DIR/index.html"
ok "Report HTML → $REPORT_SLUG/index.html"

if [[ -f "$SRC_DIR/Mobile_Baykeeper_Report.pdf" ]]; then
  cp -f "$SRC_DIR/Mobile_Baykeeper_Report.pdf" "$DST_DIR/"
  ok "PDF copied"
fi

csv_count=0
for csv in "$SRC_DIR"/*.csv; do
  [[ -e "$csv" ]] || continue
  cp -f "$csv" "$DST_DIR/"
  csv_count=$((csv_count + 1))
done
ok "CSVs copied: $csv_count file(s)"

# Remove the placeholder if it survived
[[ -f "$DST_DIR/.gitkeep" ]] && rm "$DST_DIR/.gitkeep" && ok "Removed .gitkeep"

# ─── git init / commit ───────────────────────────────────────────────────────
say "Git: init / add / commit"
cd "$REPO_DIR"

if [[ ! -d .git ]]; then
  git init -b main >/dev/null
  ok "git init (branch: main)"
else
  ok "git already initialized"
fi

git add -A

if git diff --cached --quiet; then
  warn "Nothing new to commit"
else
  git -c user.name="Paul Lockett" -c user.email="paul@pimandco.ai" \
      commit -m "Publish: $REPORT_SLUG report + hub site" >/dev/null
  ok "Commit created"
fi

# ─── remote + push ───────────────────────────────────────────────────────────
say "Pushing to github.com/$GH_USER/$GH_REPO"

if git remote get-url origin >/dev/null 2>&1; then
  ok "Remote 'origin' already set: $(git remote get-url origin)"
else
  if command -v gh >/dev/null 2>&1; then
    # Try to create the repo via gh; if it already exists, just add the remote.
    if gh repo view "$GH_USER/$GH_REPO" >/dev/null 2>&1; then
      git remote add origin "git@github.com:$GH_USER/$GH_REPO.git"
      ok "Repo exists on GitHub — remote added (SSH)"
    else
      gh repo create "$GH_USER/$GH_REPO" --public --source=. --remote=origin --description="Paul Lockett — Research & Reports" >/dev/null
      ok "Repo created on GitHub via gh CLI"
    fi
  else
    die "gh CLI not found and no 'origin' remote set. Either:
      • install gh   (brew install gh && gh auth login), then re-run, or
      • create https://github.com/$GH_USER/$GH_REPO manually (public), then:
          git remote add origin git@github.com:$GH_USER/$GH_REPO.git
          git push -u origin main"
  fi
fi

if git push -u origin main; then
  ok "Pushed to main"
else
  die "Push failed. Check 'gh auth status' or your SSH key for github.com."
fi

# ─── done ────────────────────────────────────────────────────────────────────
say "Done"
cat <<EOF
  Site:   https://paullockett.github.io/
  Report: https://paullockett.github.io/$REPORT_SLUG/

  Pages enables itself automatically on a username.github.io repo.
  Allow 30–90 seconds after first push before the URL resolves.

  To add the next report:
    1) Drop its HTML into a new folder, e.g. $REPO_DIR/next-report/index.html
    2) Add a card to $REPO_DIR/index.html
    3) bash $REPO_DIR/publish.sh
EOF
