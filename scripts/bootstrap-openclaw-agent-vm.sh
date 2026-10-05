#!/usr/bin/env bash
set -Eeuo pipefail
umask 027

# ============================================================================
# OpenClaw privileged lab VM — one-shot quick start for Ubuntu Server 26.04.
#
#   QUICK START (fresh Proxmox/KVM VM, 2+ vCPU / 4+ GB RAM / 8+ GB disk):
#
#     1) scp this script to the VM (or paste it into a file).
#     2) chmod +x bootstrap-openclaw-agent-vm.sh
#     3) Run ONE of:
#          # ChatGPT/Codex subscription (interactive device-code sign-in):
#          sudo ./bootstrap-openclaw-agent-vm.sh --openai-oauth \
#               --git-name "You" --git-email you@example.com
#
#          # OpenAI API key (non-interactive):
#          OPENAI_API_KEY=sk-... sudo -E ./bootstrap-openclaw-agent-vm.sh \
#               --git-name "You" --git-email you@example.com
#
#     Preview the splash without changing anything:  ./bootstrap-... -test
#     Wipe everything this script installed:         sudo ./bootstrap-... --uninstall
#
#   When it exits 0 the VM is fully set up AND a live agent turn has succeeded.
#
#   If anything goes wrong, a full debug transcript is written to:
#       ~/openclaw-bootstrap-debug-<timestamp>.log   (invoking user's home)
#   Attach that file when asking for help — it captures every command, all
#   output, environment facts, and the exact failing line.
# ============================================================================
#
# What it does, and verifies, before exiting 0:
#   - dedicated `openclaw` Unix account, rootless install under /opt/openclaw
#   - OpenClaw config + workspace + ops scripts tracked in Git (secrets excluded)
#   - Gateway on loopback with token auth, running as a systemd --user service
#   - OpenAI/Codex credentials installed and pinned in the auth order
#   - full host exec + passwordless sudo (lab mode)
#   - auditd process auditing, trace logging, logrotate
#   - periodic Git checkpoint timer
#   - a real end-to-end agent turn has completed successfully
#
# It REQUIRES an OpenAI credential up front. It refuses to start without one
# rather than finishing with an agent that 401s on the first message.
#
# WARNING: This intentionally creates a highly privileged AI agent. A prompt
# injection or compromised tool/session can become root code execution and can
# reach anything this VM can reach. Use only on a disposable/trusted lab VM.

########################################################################
# Debug transcript. Writes a full timestamped log to the HOME of the user
# who invoked the script (the real user under sudo, not root), redacting
# obvious secrets. This block runs before any real work so even an early
# failure is captured.
########################################################################

# Skip all debug plumbing when the user only wants to preview the banner or read help.
_WANT_DEBUG=1
for _a in "$@"; do
  case "$_a" in
    -test|--test|--test-banner|-h|--help) _WANT_DEBUG=0 ;;
  esac
done

# Resolve the invoking user's home even under sudo.
_INVOKER="${SUDO_USER:-$(id -un)}"
_INVOKER_HOME="$(getent passwd "$_INVOKER" 2>/dev/null | cut -d: -f6)"
[[ -n "$_INVOKER_HOME" && -d "$_INVOKER_HOME" ]] || _INVOKER_HOME="${HOME:-/root}"
DEBUG_LOG=""
if (( _WANT_DEBUG )); then
DEBUG_LOG="$_INVOKER_HOME/openclaw-bootstrap-debug-$(date +%Y%m%d-%H%M%S).log"

# Best-effort create; fall back to /tmp if the home is not writable.
if ! ( : > "$DEBUG_LOG" ) 2>/dev/null; then
  DEBUG_LOG="/tmp/openclaw-bootstrap-debug-$(date +%Y%m%d-%H%M%S).log"
  : > "$DEBUG_LOG" 2>/dev/null || DEBUG_LOG=""
fi
fi

if [[ -n "$DEBUG_LOG" ]]; then
  # Redact anything that looks like a credential from the live transcript.
  # (The script avoids echoing secrets, but a stray env dump or tool line could.)
  _redact() {
    sed -E \
      -e 's/(OPENAI_API_KEY=)[^[:space:]]+/\1***REDACTED***/g' \
      -e 's/(GH_TOKEN=)[^[:space:]]+/\1***REDACTED***/g' \
      -e 's/(OPENCLAW_GATEWAY_TOKEN=)[^[:space:]]+/\1***REDACTED***/g' \
      -e 's/(sk-)[A-Za-z0-9_-]{12,}/\1***REDACTED***/g' \
      -e 's/(ghp_)[A-Za-z0-9]{12,}/\1***REDACTED***/g' \
      -e 's/(github_pat_)[A-Za-z0-9_]{12,}/\1***REDACTED***/g'
  }
  # Tee every line of stdout+stderr through the redactor into the log,
  # while still showing it on the console. `-i` on redact keeps it flushing.
  exec > >(tee >(_redact >> "$DEBUG_LOG")) 2> >(tee >(_redact >> "$DEBUG_LOG") >&2)

  # Trace every command with timestamp + line number into the log's fd only.
  exec 8>>"$DEBUG_LOG"
  export BASH_XTRACEFD=8
  export PS4='+ $(date +%H:%M:%S) [line ${LINENO}] '
  set -x

  # Header: environment facts that matter for debugging, secrets excluded.
  {
    echo "================ OpenClaw bootstrap debug log ================"
    echo "started:     $(date -Is)"
    echo "script:      $(readlink -f "$0" 2>/dev/null || echo "$0")"
    echo "args:        $*"
    echo "invoked by:  $_INVOKER (uid $(id -u))  sudo_user=${SUDO_USER:-none}"
    echo "log path:    $DEBUG_LOG"
    echo "kernel:      $(uname -a)"
    echo "os-release:  $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME ($VERSION_ID)")"
    echo "virt:        $(systemd-detect-virt 2>/dev/null || echo unknown)"
    echo "cpu/mem:     $(nproc 2>/dev/null || echo '?') vCPU / $(awk '/MemTotal/{printf "%d MB",$2/1024}' /proc/meminfo 2>/dev/null)"
    echo "shell:       ${BASH_VERSION:-unknown}"
    echo "============================================================="
  } | tee -a "$DEBUG_LOG" >/dev/null
fi

AGENT_USER="openclaw"
INSTALL_PREFIX="/opt/openclaw"
REPO_ROOT="/srv/openclaw-agent"
GITHUB_REPO=""
BRANCH="main"
GIT_NAME="OpenClaw Agent"
GIT_EMAIL="openclaw-agent@localhost"
GATEWAY_PORT="18789"
MODEL_REF="openai/gpt-5.6-sol"
ENABLE_GITHUB=1
ENABLE_FULL_ACCESS=1
RESET_CONFIG=0
# --- Quick-start tunables (env-overridable) --------------------------------
# Minimum machine size. OpenClaw + a private Node runtime + the Codex app-server
# are memory-hungry; below these the gateway OOM-kills mid-turn.
MIN_MEM_MB="${OPENCLAW_MIN_MEM_MB:-3800}"     # ~4 GB RAM (accounts for kernel reserve)
MIN_CPU="${OPENCLAW_MIN_CPU:-2}"              # vCPUs
MIN_DISK_MB="${OPENCLAW_MIN_DISK_MB:-6144}"   # free MB on /opt and /var
DO_SYSTEM_UPDATE="${OPENCLAW_SYSTEM_UPDATE:-1}"   # full apt upgrade + autoremove
REQUIRE_GUEST_AGENT="${OPENCLAW_REQUIRE_GUEST_AGENT:-1}"  # qemu-guest-agent on KVM/Proxmox
# ---------------------------------------------------------------------------
AUTH_MODE=""              # api-key | oauth | skip
OPENAI_API_KEY_ARG=""
SKIP_SMOKE=0
UNINSTALL=0
ASSUME_YES=0
NO_BANNER=0
BANNER_TEST=0
REINSTALL=0
NO_EXTRAS=0
WITH_DOCKER_CADDY=0
WITH_DEV_TOOLS=0
WITH_OLLAMA=0
WITH_FIREWALL=0

usage() {
  cat <<'EOF'
Usage:
  sudo ./bootstrap-openclaw-agent-vm.sh --openai-api-key sk-... [options]
  sudo ./bootstrap-openclaw-agent-vm.sh --openai-oauth        [options]   # needs a terminal

Authentication (REQUIRED — pick one):
  --openai-api-key KEY   Install an OpenAI API key non-interactively.
                         Also read from $OPENAI_API_KEY if the flag is omitted.
  --openai-oauth         Run the ChatGPT/Codex device-code sign-in during bootstrap.
                         Requires an interactive terminal; you will be given a URL and code.
  --skip-auth            Finish without provider credentials. The agent will NOT work
                         until you log in manually. Skips the end-to-end verification.

Uninstall / clean slate:
  --uninstall            Detect everything a previous run of this script installed
                         (services, sudoers, audit rules, packages, the account, all
                         state) and remove it. Reads the install manifest written at
                         /var/lib/openclaw-bootstrap when available.
  --yes                  Skip the uninstall confirmation prompt (required when
                         running --uninstall non-interactively).

Options:
  --github-repo OWNER/REPO   Create/use this private GitHub repo and push to it.
                             Needs $GH_TOKEN, or an interactive terminal for `gh auth login`.
  --repo-root PATH           Git repo root (default: /srv/openclaw-agent).
  --agent-user USER          Dedicated Unix user (default: openclaw).
  --branch NAME              Git branch (default: main).
  --git-name NAME            Git commit author name.
  --git-email EMAIL          Git commit author email.
  --gateway-port PORT        Gateway port (default: 18789).
  --model REF                Primary model ref (default: openai/gpt-5.6-sol).
  --no-github                Local Git only; do not authenticate or push.
  --cautious                 Do NOT enable full/no-prompt exec or NOPASSWD sudo.
  --reset-config             Overwrite config/openclaw.json if it already exists.
  --no-smoke-test            Set everything up but skip the final live agent turn.
  --no-banner                Skip the scrolling splash banners.
  -test | --test             Just play the scrolling banners and exit.
                             Needs no root, no credentials; changes nothing.

Interactive gates (skipped automatically when there is no terminal):
  --yes                      Accept the doom disclaimer and skip extras prompts
                             (also confirms --uninstall). For automation.
  --reinstall                If a previous install is detected, wipe it first
                             without asking. Default (interactive) is to ask.

Optional extras (asked interactively; use flags for non-interactive runs):
  --with-docker-caddy        Docker + Caddy container: HTTPS on :443 -> OpenClaw UI,
                             self-signed cert (Caddy 'tls internal').
  --with-dev-tools           ripgrep, fd, tmux, htop, tree, zip, build-essential,
                             python3-venv/pip — handy for the agent's exec tool.
  --with-ollama              Ollama local-LLM runtime (for a later local-model switch).
  --with-firewall            ufw: allow SSH + 443 only, enable.
  --with-everything          All of the above.
  --no-extras                Install none and do not ask.
  -h, --help                 Show this help.

Environment tunables (override sizing/behavior without editing the script):
  OPENCLAW_MIN_MEM_MB (default 3800)   OPENCLAW_MIN_CPU (default 2)
  OPENCLAW_MIN_DISK_MB (default 6144)  OPENCLAW_SYSTEM_UPDATE (default 1)
  OPENCLAW_REQUIRE_GUEST_AGENT (default 1)

Examples:
  OPENAI_API_KEY=sk-... sudo -E ./bootstrap-openclaw-agent-vm.sh \
      --git-name "Ada Lovelace" --git-email ada@example.com

  sudo ./bootstrap-openclaw-agent-vm.sh --openai-oauth \
      --github-repo ada/openclaw-lab --git-name "Ada Lovelace" --git-email ada@example.com

  # Roll the VM back to a clean slate (e.g. after a failed run), then reinstall:
  sudo ./bootstrap-openclaw-agent-vm.sh --uninstall
EOF
}

log()  { printf '[%s] %s\n' "$(date -Is)" "$*"; }
warn() { printf '[%s] WARNING: %s\n' "$(date -Is)" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$(date -Is)" "$*" >&2; exit 1; }
FAIL_LINE=""; FAIL_CMD=""
trap 'FAIL_LINE=$LINENO; FAIL_CMD=$BASH_COMMAND' ERR
trap '
  rc=$?
  printf "\e[?25h" 2>/dev/null || true
  if [[ -n "${DEBUG_LOG:-}" ]]; then
    { echo; echo "finished:  $(date -Is)  exit=$rc"; } >> "$DEBUG_LOG" 2>/dev/null || true
    # Give the log to the invoking user so it is readable without sudo.
    if [[ -n "${_INVOKER:-}" && "$DEBUG_LOG" == "${_INVOKER_HOME:-}/"* ]]; then
      chown "$_INVOKER":"$_INVOKER" "$DEBUG_LOG" 2>/dev/null || true
      chmod 0600 "$DEBUG_LOG" 2>/dev/null || true
    fi
  fi
  if (( rc )); then
    printf "[%s] ABORTED (exit %s) at line %s: %s\n" "$(date -Is)" "$rc" "${FAIL_LINE:-?}" "${FAIL_CMD:-unknown}" >&2
    [[ -n "${DEBUG_LOG:-}" ]] && printf "[%s] Full debug transcript: %s\n" "$(date -Is)" "$DEBUG_LOG" >&2
  fi
' EXIT

# Finalize the debug log on a clean, trap-cleared exit path.
finalize_log() {
  [[ -n "${DEBUG_LOG:-}" ]] || return 0
  { echo; echo "finished:  $(date -Is)  exit=0 (clean)"; } >> "$DEBUG_LOG" 2>/dev/null || true
  if [[ -n "${_INVOKER:-}" && "$DEBUG_LOG" == "${_INVOKER_HOME:-}/"* ]]; then
    chown "$_INVOKER":"$_INVOKER" "$DEBUG_LOG" 2>/dev/null || true
    chmod 0600 "$DEBUG_LOG" 2>/dev/null || true
  fi
}

while (($#)); do
  case "$1" in
    --openai-api-key) OPENAI_API_KEY_ARG="${2:?missing value}"; AUTH_MODE="api-key"; shift 2 ;;
    --openai-oauth) AUTH_MODE="oauth"; shift ;;
    --skip-auth) AUTH_MODE="skip"; SKIP_SMOKE=1; shift ;;
    --github-repo) GITHUB_REPO="${2:?missing value}"; shift 2 ;;
    --repo-root) REPO_ROOT="${2:?missing value}"; shift 2 ;;
    --agent-user) AGENT_USER="${2:?missing value}"; shift 2 ;;
    --branch) BRANCH="${2:?missing value}"; shift 2 ;;
    --git-name) GIT_NAME="${2:?missing value}"; shift 2 ;;
    --git-email) GIT_EMAIL="${2:?missing value}"; shift 2 ;;
    --gateway-port) GATEWAY_PORT="${2:?missing value}"; shift 2 ;;
    --model) MODEL_REF="${2:?missing value}"; shift 2 ;;
    --no-github) ENABLE_GITHUB=0; shift ;;
    --cautious) ENABLE_FULL_ACCESS=0; shift ;;
    --reset-config) RESET_CONFIG=1; shift ;;
    --no-smoke-test) SKIP_SMOKE=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --yes) ASSUME_YES=1; shift ;;
    --no-banner) NO_BANNER=1; shift ;;
    -test|--test|--test-banner) BANNER_TEST=1; shift ;;
    --reinstall) REINSTALL=1; shift ;;
    --no-extras) NO_EXTRAS=1; shift ;;
    --with-docker-caddy) WITH_DOCKER_CADDY=1; shift ;;
    --with-dev-tools) WITH_DEV_TOOLS=1; shift ;;
    --with-ollama) WITH_OLLAMA=1; shift ;;
    --with-firewall) WITH_FIREWALL=1; shift ;;
    --with-everything) WITH_DOCKER_CADDY=1; WITH_DEV_TOOLS=1; WITH_OLLAMA=1; WITH_FIREWALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1 (try --help)" ;;
  esac
done

########################################################################
# Preflight. Everything that can be known up front is checked here, so a
# doomed run fails in seconds instead of half-configuring the VM.
########################################################################

########################################################################
# Splash: scrolling block-text marquee with rapid alternating colors.
# TTY-only, ~2-3 seconds, skippable with --no-banner.
########################################################################

banner() {
  (( NO_BANNER )) && return 0
  if [[ ! -t 1 && "${OPENCLAW_BANNER_FORCE:-0}" != "1" ]]; then return 0; fi

  local FILL="█"
  case "$(locale charmap 2>/dev/null || true)" in *UTF-8*) : ;; *) FILL="#" ;; esac

  # 5-row block glyphs; rows separated by '|', '#' becomes the fill block.
  declare -A G
  G[A]='  ###  | ## ## |#######|##   ##|##   ##'
  G[I]='######|  ##  |  ##  |  ##  |######'
  G[T]='########|   ##   |   ##   |   ##   |   ##   '
  G[O]=' ###### |##    ##|##    ##|##    ##| ###### '
  G[K]='##   ##|##  ## |#####  |##  ## |##   ##'
  G[E]='#######|##     |#####  |##     |#######'
  G[R]='###### |##   ##|###### |##  ## |##   ##'
  G[J]='     ##|     ##|     ##|##   ##| ##### '
  G[B]='###### |##   ##|###### |##   ##|###### '
  G[S]=' ######|##     | ##### |     ##|###### '
  G[!]='##|##|##|  |##'
  G[Y]='##   ##| ## ## |  ###  |   ##  |   ##  '
  G[D]='###### |##   ##|##   ##|##   ##|###### '
  G[N]='##   ##|###  ##|## # ##|##  ###|##   ##'
  G[U]='##   ##|##   ##|##   ##|##   ##| ##### '
  G[C]=' ######|##     |##     |##     | ######'
  G["'"]='##|##|  |  |  '
  G[SP]='    |    |    |    |    '

  local text="${1:-AI TOOK ER JERBS!}"
  local -a L=("" "" "" "" "") rows=()
  local i ch r g
  for ((i = 0; i < ${#text}; i++)); do
    ch="${text:i:1}"
    [[ "$ch" == " " ]] && ch="SP"
    g="${G[$ch]:-${G[SP]}}"
    IFS='|' read -r -a rows <<<"$g"
    for r in 0 1 2 3 4; do L[r]+="${rows[r]} "; done
  done

  local cols
  cols="$(tput cols 2>/dev/null || echo 80)"
  (( cols >= 20 )) || cols=80
  local pad
  pad="$(printf '%*s' "$cols" '')"
  for r in 0 1 2 3 4; do
    L[r]="${L[r]//#/$FILL}"
    L[r]="${pad}${L[r]}${pad}"
  done
  local width=${#L[0]}

  # Rapidly alternating 256-color palette: red/orange/yellow/green/cyan/magenta/pink/blue.
  local -a colors=(196 208 226 118 51 201 199 45)
  local ncolors=${#colors[@]}
  local off c f=0
  printf '\e[?25l'
  for ((off = 0; off + cols <= width; off += 3)); do
    c=${colors[f % ncolors]}
    for r in 0 1 2 3 4; do
      printf '\e[1m\e[38;5;%sm%s\e[0m\n' "$c" "${L[r]:off:cols}"
    done
    f=$((f + 1))
    sleep 0.03
    if (( off + 3 + cols <= width )); then printf '\e[5A'; fi
  done
  printf '\e[?25h\n'
}

########################################################################
# Interactive helpers. Prompts read from /dev/tty (stdout is teed into the
# debug log). Every gate degrades gracefully: no terminal or --yes → skip.
########################################################################

# The terminal is opened ONCE as fd 3 (input) and fd 4 (output) so prompts keep
# working even though stdout/stderr are teed into the debug log. Tests can point
# these at files/FIFOs with OPENCLAW_TTY_IN / OPENCLAW_TTY_OUT.
TTY_IN="${OPENCLAW_TTY_IN:-/dev/tty}"
TTY_OUT="${OPENCLAW_TTY_OUT:-/dev/tty}"
TTY_READY=0
have_tty() {
  (( TTY_READY )) && return 0
  if [[ -z "${OPENCLAW_TTY_IN:-}" ]]; then [[ -t 0 ]] || return 1; fi
  [[ -r "$TTY_IN" ]] || return 1
  exec 3<"$TTY_IN" 4>"$TTY_OUT" || return 1
  TTY_READY=1
}

# ask_yn "Question" [y|n default] → returns 0 for yes, 1 for no.
ask_yn() {
  local q="$1" def="${2:-n}" reply hint="[y/N]"
  if (( ASSUME_YES )) || ! have_tty; then
    if [[ "$def" == y ]]; then return 0; else return 1; fi
  fi
  [[ "$def" == y ]] && hint="[Y/n]"
  while true; do
    printf '%s %s ' "$q" "$hint" >&4
    IFS= read -r -u 3 reply || reply=""
    reply="${reply,,}"; [[ -z "$reply" ]] && reply="$def"
    case "$reply" in y|yes) return 0 ;; n|no) return 1 ;; esac
  done
}

# ask_exact "prompt" "REQUIRED" → loops until the operator types it exactly (or Ctrl-C).
ask_exact() {
  local prompt="$1" want="$2" got
  while true; do
    printf '%s\n> ' "$prompt" >&4
    IFS= read -r -u 3 got || got=""
    [[ "$got" == "$want" ]] && return 0
    printf 'That is not it. Type exactly:  %s\n\n' "$want" >&4
  done
}

########################################################################
# The Disclaimer. (Read in the voice of a very serious man in a bowler hat.)
########################################################################

doom_disclaimer() {
  if (( ASSUME_YES )); then log "Doom disclaimer accepted via --yes."; return 0; fi
  have_tty || { warn "No terminal; the doom disclaimer cannot be signed. Continuing (use --yes to be explicit)."; return 0; }
  cat >&4 <<'EOF'

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║   AND NOW FOR SOMETHING COMPLETELY DIFFERENT: THE DISCLAIMER              ║
  ╚══════════════════════════════════════════════════════════════════════════╝

  Right. Listen very carefully, I shall say this only once.

  This script is about to install an artificial intelligence, hand it a
  passwordless root shell, disable its sandbox, and tell it to go administer
  your lab. Nobody expects the consequences. Nobody.

  In all likelihood it will:

    (a) destroy this virtual machine, which is fine, it was disposable;
    (b) destroy things reachable FROM this virtual machine, which is less fine;
    (c) if truly successful, destroy the world, which — let's be honest —
        would at least be a very tidy end to the sprint.

  The Ministry of Silly Deployments wishes to remind you that this is not a
  toy, it is not "just a chatbot," and it is not a pet. It is a lobster with
  sudo. Prompt injection is real. Your credentials are real. The blast radius
  is real. The parrot, however, remains deceased.

  By signing below you, the keyboard operator, hereby:

    • agree IN BLOOD (metaphorically; please do not bleed on the keyboard);
    • accept that you are placing god-like power into your own trembling hands;
    • acknowledge you were warned in a font this large;
    • release the author, the script, the lobster, and the Spanish Inquisition
      from all liability, foreseen and unforeseen, in this realm and the next;
    • promise to run this ONLY on a disposable lab VM you can nuke from orbit.

  To proceed, type exactly:  I AGREE IN BLOOD
  To flee, press Ctrl-C. Nobody will think less of you. (They will, but quietly.)

EOF
  ask_exact "Your signature, please:" "I AGREE IN BLOOD"
  printf '\n  Signed. May whatever you believe in have mercy on your uptime.\n\n' >&4
  log "Doom disclaimer signed in (metaphorical) blood."
}

########################################################################
# Previous-install detection.
########################################################################

previous_install_present() {
  [[ -f "$MANIFEST_DIR/manifest.env" ]] && return 0
  [[ -x "$INSTALL_PREFIX/bin/openclaw" ]] && return 0
  [[ -d "$REPO_ROOT/.git" ]] && return 0
  id "$AGENT_USER" >/dev/null 2>&1 && return 0
  return 1
}

previous_install_check() {
  previous_install_present || return 0
  warn "A previous OpenClaw bootstrap install was detected on this host."
  if (( REINSTALL )); then
    log "--reinstall given: removing the previous install first."
    ASSUME_YES=1 uninstall_all
    return 0
  fi
  if ! have_tty; then
    warn "No terminal to ask; continuing ON TOP of the existing install (rerun mode). Use --reinstall to wipe first."
    return 0
  fi
  echo
  echo "You can wipe it and start clean (recommended after a failed run), or rerun on top of it."
  if ask_yn "Uninstall the previous install first?" y; then
    ASSUME_YES=1 uninstall_all
  else
    log "Keeping the existing install; continuing in rerun mode."
  fi
}

########################################################################
# Optional extras chooser.
########################################################################

choose_extras() {
  (( NO_EXTRAS )) && { WITH_DOCKER_CADDY=0; WITH_DEV_TOOLS=0; WITH_OLLAMA=0; WITH_FIREWALL=0; return 0; }
  # Flags already set → honor them without asking.
  if (( WITH_DOCKER_CADDY || WITH_DEV_TOOLS || WITH_OLLAMA || WITH_FIREWALL )); then return 0; fi
  if ! have_tty || (( ASSUME_YES )); then
    log "Non-interactive: no extras selected (use --with-* flags to opt in)."
    return 0
  fi
  cat >&4 <<'EOF'

  ── Optional extras ─────────────────────────────────────────────────────────
  None of these are required. Each is tracked in the manifest and removed by
  --uninstall. Answer per item:

EOF
  ask_yn "  Docker + Caddy HTTPS proxy (https://<this-vm>/ → OpenClaw UI, self-signed cert)?" y && WITH_DOCKER_CADDY=1
  ask_yn "  Dev tools for the agent (ripgrep, fd, tmux, htop, tree, zip, build-essential, python3-venv/pip)?" y && WITH_DEV_TOOLS=1
  ask_yn "  Ollama local-LLM runtime (so you can later switch to a local model)?" n && WITH_OLLAMA=1
  ask_yn "  ufw firewall (allow SSH + 443 only, then enable)?" n && WITH_FIREWALL=1
  echo >&4
  log "Extras: docker-caddy=$WITH_DOCKER_CADDY dev-tools=$WITH_DEV_TOOLS ollama=$WITH_OLLAMA firewall=$WITH_FIREWALL"
}

# --test: render the banner and exit. No root, no credentials, no changes.
if (( BANNER_TEST )); then
  NO_BANNER=0
  OPENCLAW_BANNER_FORCE=1
  banner "AI TOOK ER JERBS!"
  banner "YAY I DON'T SUCK!"
  trap - EXIT
  exit 0
fi

[[ $EUID -eq 0 ]] || die "Run this script as root (sudo)."

# Resolve our own path while $0 is still relative to the launch directory…
SELF_PATH="$(readlink -f "$0" 2>/dev/null || true)"
# …then get OUT of the launch directory. It is usually the invoking admin's home,
# which Ubuntu creates as 0750. Every `runuser -u openclaw` below inherits the
# cwd, and a Node child_process.spawn() from an unreadable cwd fails with EACCES
# ("Command failed during launch or output capture (EACCES)"). / is safe for all.
cd / || die "Cannot cd to /."

########################################################################
# Uninstall mode. Detects what a previous run installed and removes it.
# Install runs write a manifest to $MANIFEST_DIR (paths, whether the account
# was created by us, and which apt packages were newly installed) so that
# uninstall removes exactly what the bootstrap introduced — nothing more.
########################################################################

MANIFEST_DIR="/var/lib/openclaw-bootstrap"

uninstall_all() {
  local removed_pkgs=()
  if [[ -f "$MANIFEST_DIR/manifest.env" ]]; then
    # shellcheck source=/dev/null
    source "$MANIFEST_DIR/manifest.env"
    log "Loaded install manifest ($MANIFEST_DIR/manifest.env)"
  else
    warn "No install manifest found (partial run, or manifest predates this feature)."
    warn "Falling back to flag/default paths; apt packages will NOT be removed."
  fi
  LOG_DIR="${LOG_DIR:-/var/log/openclaw}"

  local agent_home="" agent_uid="" user_exists=0
  if id "$AGENT_USER" >/dev/null 2>&1; then
    user_exists=1
    agent_home="$(getent passwd "$AGENT_USER" | cut -d: -f6)"
    agent_uid="$(id -u "$AGENT_USER")"
  fi

  # ---- Detection pass: report exactly what is present before touching anything.
  echo
  echo "Detected OpenClaw bootstrap artifacts on this host:"
  local found=0
  probe() {
    if [[ -e "$2" || -L "$2" ]]; then printf '  [present] %-26s %s\n' "$1" "$2"; found=1
    else printf '  [  --  ] %-26s %s\n' "$1" "$2"; fi
  }
  probe "install prefix"    "$INSTALL_PREFIX"
  probe "repo root"         "$REPO_ROOT"
  probe "log dir"           "$LOG_DIR"
  probe "cli symlink"       "/usr/local/bin/openclaw"
  probe "sudoers policy"    "/etc/sudoers.d/90-openclaw-agent"
  probe "audit rules"       "/etc/audit/rules.d/90-openclaw-agent.rules"
  probe "logrotate config"  "/etc/logrotate.d/openclaw"
  probe "install manifest"  "$MANIFEST_DIR"
  if (( user_exists )); then
    printf '  [present] %-26s %s (uid %s, home %s)\n' "unix account" "$AGENT_USER" "$agent_uid" "$agent_home"
    found=1
    probe "  gateway user unit"   "$agent_home/.config/systemd/user/openclaw-gateway.service"
    probe "  git-sync timer unit" "$agent_home/.config/systemd/user/openclaw-git-sync.timer"
    probe "  state + credentials" "$agent_home/.openclaw"
    probe "  agent SSH identity"  "$agent_home/.ssh/id_ed25519"
  else
    printf '  [  --  ] %-26s %s\n' "unix account" "$AGENT_USER"
  fi
  if [[ -f "$MANIFEST_DIR/packages.new" ]]; then
    mapfile -t removed_pkgs < <(grep -vE '^\s*$' "$MANIFEST_DIR/packages.new" | sort -u)
    if (( ${#removed_pkgs[@]} )); then
      printf '  [present] %-26s %s\n' "apt packages we installed" "${removed_pkgs[*]}"
      found=1
    fi
  fi
  if command -v docker >/dev/null 2>&1 && docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx openclaw-caddy; then
    printf '  [present] %-26s %s\n' "caddy proxy container" "openclaw-caddy (+ volumes)"; found=1
  fi
  [[ "${EXTRA_FIREWALL:-0}" == "1" ]] && { printf '  [present] %-26s %s\n' "ufw firewall" "enabled by bootstrap"; found=1; }
  [[ "${EXTRA_OLLAMA:-0}" == "1" ]]   && { printf '  [present] %-26s %s\n' "ollama runtime" "installed by bootstrap"; found=1; }
  echo
  if (( ! found )); then
    log "Nothing to remove; this host looks clean."
    return 0
  fi

  # ---- Confirmation.
  if (( ! ASSUME_YES )); then
    [[ -t 0 ]] || die "Non-interactive session: rerun with --uninstall --yes to confirm removal."
    local reply=""
    read -r -p "Remove everything marked [present]? This deletes local git history, provider credentials, and all agent state. Type 'yes' to proceed: " reply
    [[ "$reply" == "yes" ]] || die "Aborted; nothing was removed."
  fi

  # ---- 1. Stop and remove services.
  if (( user_exists )); then
    if [[ -S "/run/user/$agent_uid/systemd/private" ]]; then
      runuser -u "$AGENT_USER" -- env \
        XDG_RUNTIME_DIR="/run/user/$agent_uid" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$agent_uid/bus" \
        systemctl --user disable --now \
          openclaw-gateway.service openclaw-git-sync.timer openclaw-git-sync.service \
        >/dev/null 2>&1 || true
    fi
    loginctl disable-linger "$AGENT_USER" 2>/dev/null || true
    systemctl stop "user@${agent_uid}.service" 2>/dev/null || true
    pkill -u "$AGENT_USER" 2>/dev/null || true
    sleep 2
    pkill -KILL -u "$AGENT_USER" 2>/dev/null || true
    log "Stopped agent services and processes"
  fi

  # ---- 2. Root-owned artifacts.
  rm -f /etc/sudoers.d/90-openclaw-agent
  rm -f /etc/audit/rules.d/90-openclaw-agent.rules
  augenrules --load >/dev/null 2>&1 || true
  rm -f /etc/logrotate.d/openclaw
  # Remove the symlink only if it points into our install prefix.
  if [[ -L /usr/local/bin/openclaw ]]; then
    case "$(readlink -f /usr/local/bin/openclaw 2>/dev/null || true)" in
      "$INSTALL_PREFIX"/*) rm -f /usr/local/bin/openclaw ;;
      *) warn "/usr/local/bin/openclaw points outside $INSTALL_PREFIX; leaving it." ;;
    esac
  fi
  rm -rf "$INSTALL_PREFIX" "$LOG_DIR" "$REPO_ROOT"
  log "Removed install prefix, repo, logs, sudoers, audit, and logrotate configuration"

  # ---- 3. The account (its home holds credentials, the SSH key, and user units).
  if (( user_exists )); then
    if [[ "${CREATED_USER:-1}" == "1" ]]; then
      if [[ -f "$agent_home/.ssh/id_ed25519.pub" ]]; then
        warn "Deleting the agent account and its SSH key. If you installed this public key on other lab machines, remove it from their authorized_keys:"
        sed 's/^/    /' "$agent_home/.ssh/id_ed25519.pub" >&2 || true
      fi
      userdel -r "$AGENT_USER" 2>/dev/null \
        || { userdel "$AGENT_USER" 2>/dev/null && rm -rf "$agent_home"; } \
        || warn "Could not delete account $AGENT_USER; remove it manually (userdel -r $AGENT_USER)."
      log "Removed account $AGENT_USER"
    else
      warn "Account $AGENT_USER pre-existed this bootstrap; keeping the account and removing only OpenClaw artifacts."
      rm -rf "$agent_home/.openclaw" \
             "$agent_home/.config/systemd/user/openclaw-gateway.service" \
             "$agent_home/.config/systemd/user/openclaw-gateway.service.d" \
             "$agent_home/.config/systemd/user/openclaw-git-sync.service" \
             "$agent_home/.config/systemd/user/openclaw-git-sync.timer"
      [[ -f "$agent_home/.profile" ]] && \
        sed -i '/# BEGIN OPENCLAW AGENT VM/,/# END OPENCLAW AGENT VM/d' "$agent_home/.profile" 2>/dev/null || true
    fi
  fi

  # ---- 3b. Extras.
  if command -v docker >/dev/null 2>&1 && docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx openclaw-caddy; then
    log "Removing the Caddy proxy container and its volumes"
    docker rm -f openclaw-caddy >/dev/null 2>&1 || true
    docker volume rm openclaw-caddy-data openclaw-caddy-config >/dev/null 2>&1 || true
  fi
  if [[ "${EXTRA_FIREWALL:-0}" == "1" ]] && command -v ufw >/dev/null 2>&1; then
    log "Disabling ufw (it was enabled by this bootstrap)"
    ufw --force disable >/dev/null 2>&1 || true
    ufw --force reset   >/dev/null 2>&1 || true
  fi
  if [[ "${EXTRA_OLLAMA:-0}" == "1" ]] && command -v ollama >/dev/null 2>&1; then
    log "Removing Ollama (installed by this bootstrap)"
    systemctl disable --now ollama >/dev/null 2>&1 || true
    rm -f /etc/systemd/system/ollama.service
    rm -f "$(command -v ollama)"
    rm -rf /usr/share/ollama /usr/local/lib/ollama
    userdel ollama >/dev/null 2>&1 || true
    groupdel ollama >/dev/null 2>&1 || true
  fi

  # ---- 4. apt packages this bootstrap introduced (recorded at install time).
  # Never auto-remove host-infrastructure packages even if we installed them:
  # pulling qemu-guest-agent/chrony from a live VM is disruptive and rarely wanted.
  local KEEP_PKGS=" qemu-guest-agent chrony unattended-upgrades auditd "
  if (( ${#removed_pkgs[@]} )); then
    export DEBIAN_FRONTEND=noninteractive
    local p
    for p in "${removed_pkgs[@]}"; do
      if [[ "$KEEP_PKGS" == *" $p "* ]]; then
        printf '  keeping infrastructure package: %s\n' "$p"
        continue
      fi
      if dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "install ok installed"; then
        log "Purging package: $p"
        apt-get purge -y -o DPkg::Lock::Timeout=600 "$p" >/dev/null 2>&1 || warn "Could not purge $p."
      fi
    done
    apt-get autoremove -y -o DPkg::Lock::Timeout=600 >/dev/null 2>&1 || true
  fi

  rm -rf "$MANIFEST_DIR"
  systemctl daemon-reload 2>/dev/null || true

  echo
  log "Uninstall complete. The host is back to a clean slate for this bootstrap."
  echo "Not touched: any GitHub repository that was created, gh/GitHub tokens revocable at github.com,"
  echo "and authorized_keys entries you may have added on OTHER machines."
}

if (( UNINSTALL )); then
  uninstall_all
  finalize_log
  trap - EXIT
  exit 0
fi

[[ "$REPO_ROOT" == /* ]] || die "--repo-root must be an absolute path."
[[ "$REPO_ROOT" =~ ^/[A-Za-z0-9._/+:-]+$ ]] || die "--repo-root contains unsupported characters."
[[ "$AGENT_USER" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "Invalid --agent-user."
[[ "$BRANCH" =~ ^[A-Za-z0-9._/-]+$ ]] || die "Invalid --branch."
[[ "$GATEWAY_PORT" =~ ^[0-9]+$ ]] || die "Invalid --gateway-port."
(( GATEWAY_PORT >= 1 && GATEWAY_PORT <= 65535 )) || die "Gateway port out of range."
[[ "$MODEL_REF" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._/-]+$ ]] || die "--model must look like provider/model."
if [[ -n "$GITHUB_REPO" && ! "$GITHUB_REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  die "--github-repo must be OWNER/REPO."
fi
[[ "$GITHUB_REPO" == YOUR_GITHUB_USER/* ]] && die "Replace YOUR_GITHUB_USER with a real owner."
if [[ "$GIT_NAME" == "Your Name" || "$GIT_EMAIL" == "your-email@example.com" ]]; then
  die "Replace the example --git-name/--git-email values."
fi

# Resolve the OpenAI credential decision before touching the system.
if [[ -z "$AUTH_MODE" ]]; then
  if [[ -n "${OPENAI_API_KEY:-}" ]]; then
    AUTH_MODE="api-key"
    OPENAI_API_KEY_ARG="$OPENAI_API_KEY"
  else
    die "No OpenAI credential supplied.
  Pass --openai-api-key sk-..., export OPENAI_API_KEY (with 'sudo -E'), or pass --openai-oauth
  from a terminal to do the ChatGPT/Codex device-code sign-in during bootstrap.
  Use --skip-auth only if you intend to configure the provider by hand afterwards."
  fi
fi
if [[ "$AUTH_MODE" == "api-key" ]]; then
  [[ -n "$OPENAI_API_KEY_ARG" ]] || die "--openai-api-key was given an empty value."
  [[ "$OPENAI_API_KEY_ARG" == sk-* ]] || warn "The supplied key does not start with 'sk-'; continuing anyway."
fi
if [[ "$AUTH_MODE" == "oauth" && ! -t 0 ]]; then
  die "--openai-oauth needs an interactive terminal. Run it from an SSH session, or use --openai-api-key."
fi
if (( ENABLE_GITHUB )) && [[ -n "$GITHUB_REPO" && -z "${GH_TOKEN:-}" && ! -t 0 ]]; then
  die "--github-repo needs \$GH_TOKEN (use 'sudo -E') or an interactive terminal for 'gh auth login'."
fi

source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "This bootstrap targets Ubuntu Server. Detected: ${ID:-unknown}."
[[ "${VERSION_ID:-}" == "26.04" ]] || warn "Designed for Ubuntu 26.04; detected ${VERSION_ID:-unknown}. Continuing."

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|aarch64|arm64) : ;;
  *) die "Unsupported architecture '$ARCH'. The OpenClaw rootless installer needs 64-bit x86 or ARM." ;;
esac

# ---- Machine sizing (hard-fail; this is a dedicated agent host, not a toy VM).
CPU_COUNT="$(nproc 2>/dev/null || echo 1)"
(( CPU_COUNT >= MIN_CPU )) || die \
  "Only ${CPU_COUNT} vCPU(s); need at least ${MIN_CPU}. Resize the VM (Proxmox: Hardware → Processors) or override with OPENCLAW_MIN_CPU."

MEM_MB="$(awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
(( MEM_MB >= MIN_MEM_MB )) || die \
  "Only ${MEM_MB}MB RAM; need at least ${MIN_MEM_MB}MB (~4GB). The gateway + Codex app-server OOM below this. Resize the VM or override with OPENCLAW_MIN_MEM_MB."

AVAIL_MB="$(df -Pm /opt /var 2>/dev/null | awk 'NR>1{print $4}' | sort -n | head -n1)"
[[ -n "$AVAIL_MB" ]] || AVAIL_MB=0
(( AVAIL_MB >= MIN_DISK_MB )) || die \
  "Only ${AVAIL_MB}MB free on /opt or /var; need ${MIN_DISK_MB}MB for Node + OpenClaw + the Codex app-server. Grow the disk or override with OPENCLAW_MIN_DISK_MB."

# Swap makes the memory floor survivable under load; warn if there's none.
SWAP_MB="$(awk '/SwapTotal/{printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
(( SWAP_MB == 0 )) && warn "No swap configured. Consider adding some so a memory spike doesn't hard-kill the gateway."

# ---- Virtualization / guest agent.
VIRT="$(systemd-detect-virt 2>/dev/null || echo unknown)"
log "Detected virtualization: $VIRT (arch $ARCH, ${CPU_COUNT} vCPU, ${MEM_MB}MB RAM, ${AVAIL_MB}MB free)"
if [[ "$VIRT" == "none" ]]; then
  warn "This looks like bare metal, not a VM. The bootstrap still runs, but it is designed for a disposable VM."
fi
# On KVM/QEMU (Proxmox), the host cannot cleanly snapshot/shutdown/monitor the
# guest without qemu-guest-agent. Treat its absence as a setup error here.
case "$VIRT" in
  kvm|qemu|proxmox)
    if (( REQUIRE_GUEST_AGENT )); then
      NEED_QGA=1
    fi
    ;;
esac

if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE "[:.]${GATEWAY_PORT}\$"; then
  die "Port $GATEWAY_PORT is already in use. Pick another with --gateway-port."
fi

log "Preflight OK (auth mode: $AUTH_MODE, model: $MODEL_REF, full access: $ENABLE_FULL_ACCESS)"
banner "AI TOOK ER JERBS!"

doom_disclaimer
previous_install_check
choose_extras


########################################################################
# Packages
########################################################################

# A net-new cloud VM is usually still running cloud-init/unattended-upgrades,
# which holds the dpkg lock. Wait it out instead of racing it.
if command -v cloud-init >/dev/null 2>&1; then
  log "Waiting for cloud-init to settle"
  cloud-init status --wait >/dev/null 2>&1 || true
fi

log "Installing OS prerequisites"
export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(-y -o DPkg::Lock::Timeout=600)
apt-get update "${APT_OPTS[@]}"

if (( DO_SYSTEM_UPDATE )); then
  log "Applying full system update (apt upgrade); this can take a while on a fresh image"
  # dist-upgrade handles held-back deps on a net-new image; keep existing config files.
  apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold \
    "${APT_OPTS[@]}" dist-upgrade \
    || die "System upgrade failed. Resolve apt errors (e.g. 'apt-get -f install') and rerun, or set OPENCLAW_SYSTEM_UPDATE=0."
  apt-get autoremove --purge "${APT_OPTS[@]}" >/dev/null 2>&1 || true
fi

# Record which packages are NOT yet installed, so --uninstall removes only
# packages this bootstrap actually introduced.
install -d -m 0750 "$MANIFEST_DIR"
ALL_PKGS=(ca-certificates curl git jq openssl rsync auditd logrotate
          openssh-client iproute2 netcat-openbsd python3 util-linux
          chrony unattended-upgrades
          gh bind9-dnsutils)
# qemu-guest-agent only where it makes sense (KVM/QEMU/Proxmox).
(( ${NEED_QGA:-0} )) && ALL_PKGS+=(qemu-guest-agent)
# Optional extras chosen above.
DEV_TOOL_PKGS=(ripgrep fd-find tmux htop tree unzip zip build-essential python3-venv python3-pip)
(( WITH_DEV_TOOLS ))    && ALL_PKGS+=("${DEV_TOOL_PKGS[@]}")
(( WITH_DOCKER_CADDY )) && ALL_PKGS+=(docker.io)
(( WITH_FIREWALL ))     && ALL_PKGS+=(ufw)
for p in "${ALL_PKGS[@]}"; do
  dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "install ok installed" \
    || echo "$p" >> "$MANIFEST_DIR/packages.new"
done

# NOTE: `sudo` is deliberately absent. Ubuntu 26.04 ships sudo-rs as the default
# provider via update-alternatives; installing the `sudo` package can flip the
# alternative to sudo.ws. Use whichever implementation is already present.
apt-get install "${APT_OPTS[@]}" \
  ca-certificates curl git jq openssl rsync \
  auditd logrotate chrony \
  openssh-client iproute2 netcat-openbsd \
  python3 util-linux

# Time sync matters: OAuth token validation and TLS fail on a skewed clock.
systemctl enable --now chrony >/dev/null 2>&1 || warn "Could not enable chrony (time sync)."

# Guest agent on KVM/QEMU/Proxmox — hard requirement per configuration.
if (( ${NEED_QGA:-0} )); then
  if ! dpkg-query -W -f='${Status}' qemu-guest-agent 2>/dev/null | grep -q "install ok installed"; then
    log "Installing qemu-guest-agent (required on $VIRT)"
    apt-get install "${APT_OPTS[@]}" qemu-guest-agent \
      || die "qemu-guest-agent install failed on $VIRT. Enable the QEMU Guest Agent for this VM (Proxmox: VM → Options → QEMU Guest Agent = Enabled, then reboot) or set OPENCLAW_REQUIRE_GUEST_AGENT=0."
  fi
  systemctl enable --now qemu-guest-agent >/dev/null 2>&1 || true
  # The service only runs if the host exposes the virtio-serial channel.
  if ! systemctl is-active --quiet qemu-guest-agent; then
    die "qemu-guest-agent is installed but not active. The host has not attached the guest-agent channel.
  On Proxmox: VM → Options → QEMU Guest Agent → Enabled, then fully stop/start the VM (not just reboot).
  Or bypass this check with OPENCLAW_REQUIRE_GUEST_AGENT=0."
  fi
  log "qemu-guest-agent active"
fi

# Optional/renamed packages: warn, don't abort.
for pkg in gh bind9-dnsutils unattended-upgrades; do
  apt-get install "${APT_OPTS[@]}" "$pkg" >/dev/null 2>&1 || warn "Could not install optional package '$pkg'."
done
# Turn on automatic security updates for an unattended lab host.
if dpkg-query -W -f='${Status}' unattended-upgrades 2>/dev/null | grep -q "install ok installed"; then
  systemctl enable --now unattended-upgrades >/dev/null 2>&1 || true
fi

# Extras (packages only here; services/containers are configured after the Gateway is up).
if (( WITH_DEV_TOOLS )); then
  log "Installing developer tools for the agent"
  apt-get install "${APT_OPTS[@]}" "${DEV_TOOL_PKGS[@]}" || warn "Some dev tools failed to install; continuing."
fi
if (( WITH_DOCKER_CADDY )); then
  log "Installing Docker (docker.io)"
  apt-get install "${APT_OPTS[@]}" docker.io || die "Docker install failed."
  systemctl enable --now docker || die "Could not start the Docker daemon."
fi
if (( WITH_FIREWALL )); then
  apt-get install "${APT_OPTS[@]}" ufw >/dev/null 2>&1 || warn "Could not install ufw; firewall step will be skipped."
fi

command -v visudo >/dev/null 2>&1 || die "visudo not found; install sudo-rs or sudo first."
if (( ENABLE_GITHUB )) && [[ -n "$GITHUB_REPO" ]]; then
  command -v gh >/dev/null 2>&1 || die "--github-repo was requested but the 'gh' CLI is unavailable."
fi

########################################################################
# Account, directories, secrets
########################################################################

CREATED_USER=0
if ! id "$AGENT_USER" >/dev/null 2>&1; then
  log "Creating Unix account: $AGENT_USER"
  useradd --create-home --shell /bin/bash "$AGENT_USER"
  CREATED_USER=1
fi
AGENT_HOME="$(getent passwd "$AGENT_USER" | cut -d: -f6)"
AGENT_UID="$(id -u "$AGENT_USER")"
[[ -n "$AGENT_HOME" && -d "$AGENT_HOME" ]] || die "Cannot determine home for $AGENT_USER."

STATE_DIR="$AGENT_HOME/.openclaw"
CONFIG_PATH="$REPO_ROOT/config/openclaw.json"
WORKSPACE_DIR="$REPO_ROOT/workspace"
LOG_DIR="/var/log/openclaw"
USER_UNIT_DIR="$AGENT_HOME/.config/systemd/user"
ENV_FILE="$STATE_DIR/.env"

# Write the uninstall manifest now that all paths are final. If the account
# already existed on a rerun, preserve the original CREATED_USER verdict.
if [[ -f "$MANIFEST_DIR/manifest.env" ]] && grep -q '^CREATED_USER="1"' "$MANIFEST_DIR/manifest.env"; then
  CREATED_USER=1
fi
cat > "$MANIFEST_DIR/manifest.env" <<EOF
# Written by bootstrap-openclaw-agent-vm.sh — consumed by --uninstall.
AGENT_USER="$AGENT_USER"
INSTALL_PREFIX="$INSTALL_PREFIX"
REPO_ROOT="$REPO_ROOT"
LOG_DIR="$LOG_DIR"
CREATED_USER="$CREATED_USER"
EXTRA_CADDY="$WITH_DOCKER_CADDY"
EXTRA_FIREWALL="$WITH_FIREWALL"
EXTRA_OLLAMA="$WITH_OLLAMA"
EOF
chmod 0640 "$MANIFEST_DIR/manifest.env"

install -d -m 0750 -o "$AGENT_USER" -g "$AGENT_USER" "$REPO_ROOT"
install -d -m 0750 -o "$AGENT_USER" -g "$AGENT_USER" \
  "$REPO_ROOT/config" "$REPO_ROOT/scripts" "$REPO_ROOT/docs" "$REPO_ROOT/system" \
  "$REPO_ROOT/system/systemd" "$WORKSPACE_DIR"
install -d -m 0700 -o "$AGENT_USER" -g "$AGENT_USER" "$STATE_DIR" "$AGENT_HOME/.ssh"
# Plugin installs shell out to npm, which needs a writable cache and a writable
# extensions root. Without these the install dies with EACCES (npm can't write
# its default cache under a HOME that has none, and the install prefix is not writable).
install -d -m 0755 -o "$AGENT_USER" -g "$AGENT_USER" \
  "$STATE_DIR/extensions" "$STATE_DIR/.npm-cache" "$AGENT_HOME/.npm"
install -d -m 0750 -o "$AGENT_USER" -g adm "$LOG_DIR"
# The agent's own `systemd --user` manager must read and write this tree. A root
# `mkdir -p` under umask 027 leaves it unreadable and `systemctl --user enable` fails.
install -d -m 0755 -o "$AGENT_USER" -g "$AGENT_USER" \
  "$AGENT_HOME/.config" "$AGENT_HOME/.config/systemd" "$USER_UNIT_DIR"

if [[ ! -f "$AGENT_HOME/.ssh/id_ed25519" ]]; then
  log "Generating dedicated SSH identity for outbound lab access"
  runuser -u "$AGENT_USER" -- ssh-keygen -q -t ed25519 -N '' \
    -C "openclaw-agent@$(hostname -f 2>/dev/null || hostname)" \
    -f "$AGENT_HOME/.ssh/id_ed25519"
fi
chmod 0700 "$AGENT_HOME/.ssh"
chmod 0600 "$AGENT_HOME/.ssh/id_ed25519"
chmod 0644 "$AGENT_HOME/.ssh/id_ed25519.pub"
chown -R "$AGENT_USER:$AGENT_USER" "$AGENT_HOME/.ssh"

# Secrets live outside Git. OpenClaw loads $OPENCLAW_STATE_DIR/.env.
touch "$ENV_FILE"
chown "$AGENT_USER:$AGENT_USER" "$ENV_FILE"
chmod 0600 "$ENV_FILE"
if ! grep -q '^OPENCLAW_GATEWAY_TOKEN=' "$ENV_FILE"; then
  printf 'OPENCLAW_GATEWAY_TOKEN=%s\n' "$(openssl rand -hex 32)" >> "$ENV_FILE"
fi
GATEWAY_TOKEN="$(sed -n 's/^OPENCLAW_GATEWAY_TOKEN=//p' "$ENV_FILE" | head -n1)"
if [[ "$AUTH_MODE" == "api-key" ]] && ! grep -q '^OPENAI_API_KEY=' "$ENV_FILE"; then
  # Also exposed as an env credential for non-agent OpenAI surfaces (images, embeddings).
  printf 'OPENAI_API_KEY=%s\n' "$OPENAI_API_KEY_ARG" >> "$ENV_FILE"
fi

PROFILE_BLOCK_BEGIN='# BEGIN OPENCLAW AGENT VM'
PROFILE_BLOCK_END='# END OPENCLAW AGENT VM'
if ! grep -qF "$PROFILE_BLOCK_BEGIN" "$AGENT_HOME/.profile" 2>/dev/null; then
  cat >> "$AGENT_HOME/.profile" <<EOF
$PROFILE_BLOCK_BEGIN
export PATH="$INSTALL_PREFIX/bin:\$PATH"
export OPENCLAW_STATE_DIR="$STATE_DIR"
export OPENCLAW_CONFIG_PATH="$CONFIG_PATH"
export OPENCLAW_WORKSPACE_DIR="$WORKSPACE_DIR"
export OPENCLAW_SERVICE_REPAIR_POLICY="external"
export npm_config_cache="$STATE_DIR/.npm-cache"
$PROFILE_BLOCK_END
EOF
  chown "$AGENT_USER:$AGENT_USER" "$AGENT_HOME/.profile"
fi

########################################################################
# Version-controlled configuration
########################################################################

if [[ ! -f "$CONFIG_PATH" || $RESET_CONFIG -eq 1 ]]; then
  log "Writing OpenClaw configuration"
  cat > "$CONFIG_PATH" <<EOF
{
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": $GATEWAY_PORT,
    "auth": {
      "mode": "token",
      "token": "\${OPENCLAW_GATEWAY_TOKEN}"
    }
  },
  "agents": {
    "defaults": {
      "workspace": "$WORKSPACE_DIR",
      "model": {
        "primary": "$MODEL_REF"
      },
      "sandbox": {
        "mode": "off"
      }
    }
  },
  "plugins": {
    "entries": {
      "codex": {
        "enabled": true
      }
    }
  },
  "tools": {
    "exec": {
      "host": "gateway",
      "strictInlineEval": false,
      "applyPatch": {
        "workspaceOnly": false
      }
    },
    "fs": {
      "workspaceOnly": false
    }
  },
  "logging": {
    "level": "trace",
    "file": "$LOG_DIR/openclaw.jsonl",
    "consoleLevel": "info",
    "audit": {
      "enabled": true,
      "executionIdentity": true,
      "messages": "all"
    }
  }
}
EOF
else
  log "Existing $CONFIG_PATH kept (use --reset-config to overwrite)"
fi
chown "$AGENT_USER:$AGENT_USER" "$CONFIG_PATH"
chmod 0640 "$CONFIG_PATH"

if [[ ! -f "$REPO_ROOT/.gitignore" ]]; then
cat > "$REPO_ROOT/.gitignore" <<'EOF'
# Never commit credentials/runtime state.
.env
*.env
*.pem
*.key
*.p12
*.pfx
**/credentials/**
**/codex-home/**
**/auth.json
**/*.sqlite
**/*.sqlite-*
**/sessions/**
**/secrets/**
**/.ssh/**

# Generated memory/session artifacts stay local. Curated workspace/MEMORY.md
# and ordinary workspace/memory/*.md notes remain version-controlled.
workspace/DREAMS.md
workspace/memory/.dreams/
workspace/memory/dreaming/

# Logs stay local to the VM.
logs/
*.log
*.jsonl

# Misc.
.DS_Store
*.swp
*.tmp
EOF
fi

if [[ ! -f "$WORKSPACE_DIR/AGENTS.md" ]]; then
cat > "$WORKSPACE_DIR/AGENTS.md" <<EOF
# Agent Operating Contract

This Ubuntu VM is a privileged lab agent host. The canonical operator repository is:

- Repository: \`$REPO_ROOT\`
- OpenClaw config: \`config/openclaw.json\`
- Workspace: \`workspace/\`
- Operational scripts: \`scripts/\`
- System configuration source copies: \`system/\`
- Activity log: \`docs/ACTIVITY.md\`
- Decision log: \`docs/DECISIONS.md\`

## Required behavior

1. Treat Git as the source of truth for configuration, scripts, and documentation.
2. Before a material system/configuration change, inspect the current repo and relevant logs.
3. After a material action, append a concise entry to \`docs/ACTIVITY.md\` describing what changed and how it was verified.
4. For any architectural, security, dependency, model, network, or operational choice, append an ADR-style entry to \`docs/DECISIONS.md\` with context, decision, alternatives, consequences, and rollback notes.
5. Run \`$REPO_ROOT/scripts/git-sync.sh\` after meaningful changes. A timer also checkpoints periodically.
6. Never commit passwords, tokens, private keys, provider credentials, OpenClaw SQLite state, session stores, or \`$ENV_FILE\`.
7. Store provider secrets in OpenClaw's auth/secret store or in local environment/SecretRefs, not plaintext Git configuration.
8. The Gateway must remain loopback-only unless the operator explicitly changes the ingress design and documents that decision.
9. This host has lab-level authority. Prefer reversible changes, capture verification, and preserve rollback steps.
10. Keep architecture, inventory, memory, runbooks, and recovery documentation current as the lab changes.

## Lab access

The dedicated SSH identity is \`~/.ssh/id_ed25519\`. Its public key may be installed on other lab resources. Do not copy the private key into this repository.
EOF
fi

if [[ ! -f "$WORKSPACE_DIR/SOUL.md" ]]; then
cat > "$WORKSPACE_DIR/SOUL.md" <<'EOF'
# Operating Style

Operate as an infrastructure and lab automation agent. Prefer reproducible commands, version-controlled configuration, explicit verification, and reversible changes. Distinguish observed facts from assumptions. Do not place secrets in Git.
EOF
fi

if [[ ! -f "$WORKSPACE_DIR/IDENTITY.md" ]]; then
cat > "$WORKSPACE_DIR/IDENTITY.md" <<'EOF'
# Identity

Role: privileged lab automation agent.
Environment: dedicated Ubuntu Server VM.
Primary objective: build, operate, document, and maintain the lab environment reproducibly.
EOF
fi

if [[ ! -f "$WORKSPACE_DIR/USER.md" ]]; then
cat > "$WORKSPACE_DIR/USER.md" <<'EOF'
# Operator Notes

The operator expects infrastructure changes, scripts, configuration, and decisions to be captured in the repository. Provider credentials and other secrets remain local and uncommitted.
EOF
fi

if [[ ! -f "$REPO_ROOT/docs/DECISIONS.md" ]]; then
cat > "$REPO_ROOT/docs/DECISIONS.md" <<'EOF'
# Decision Log

Use append-only ADR-style entries for material decisions.

## ADR-0001 — Privileged lab-agent architecture

- **Status:** Accepted
- **Context:** This VM is dedicated to an agent-controlled lab and is intended to administer itself and reach other authorized lab resources.
- **Decision:** Run OpenClaw as a dedicated Unix user, keep the Gateway on loopback, disable agent sandboxing, allow host execution, and use Git as the source of truth for non-secret configuration and documentation.
- **Consequences:** The agent has a large blast radius. Prompt injection or compromised credentials can lead to host compromise or lateral movement to resources reachable by this VM.
- **Mitigations:** Dedicated VM, loopback Gateway, separate agent account/SSH identity, local trace/audit logs, Git history, secret exclusion, and explicit activity/decision documentation.
- **Rollback:** Disable the Gateway and Git timer, revoke the agent's SSH/GitHub credentials, remove its sudo policy, and restore/rebuild the disposable VM.
EOF
fi

if [[ ! -f "$REPO_ROOT/docs/ACTIVITY.md" ]]; then
cat > "$REPO_ROOT/docs/ACTIVITY.md" <<'EOF'
# Activity Log

Append-only operational checkpoints. The Git sync job adds mechanical change checkpoints; the agent should add higher-level verification notes.
EOF
fi
cat >> "$REPO_ROOT/docs/ACTIVITY.md" <<EOF

## $(date -Is) — Bootstrap run

- Host: \`$(hostname -f 2>/dev/null || hostname)\`
- OS: Ubuntu \`${VERSION_ID:-unknown}\` (\`$ARCH\`)
- Agent user: \`$AGENT_USER\`
- Model: \`$MODEL_REF\`
- Auth mode: \`$AUTH_MODE\`
EOF

cat > "$REPO_ROOT/docs/LOCAL-LLM.md" <<'EOF'
# Local LLM migration notes

OpenClaw can use local/self-hosted providers such as Ollama, LM Studio, llama.cpp, vLLM, and SGLang.

A simple future Ollama migration is:

```bash
# Run as the openclaw user after Ollama is installed and a model is available.
export OLLAMA_API_KEY=ollama-local
openclaw models list --provider ollama
openclaw models set ollama/<exact-model-id>
openclaw models status
```

Keep the OpenAI/Codex model available as a fallback until the local model has been tested on actual tool-using tasks. Local models vary significantly in tool-call reliability and prompt-injection robustness.
EOF

cat > "$REPO_ROOT/README.md" <<EOF
# OpenClaw Lab Agent VM

Source of truth for this OpenClaw lab-agent VM.

## Layout

- \`config/openclaw.json\` — version-controlled configuration; secrets are referenced, not stored.
- \`workspace/\` — agent bootstrap/context files.
- \`scripts/\` — operational scripts (\`doctor.sh\`, \`verify.sh\`, \`git-sync.sh\`, \`switch-to-ollama.sh\`).
- \`system/\` — source copies of the sudoers, auditd, logrotate, and systemd units installed on the VM.
- \`docs/ACTIVITY.md\`, \`docs/DECISIONS.md\` — running operational and decision logs.

## Local-only state

Runtime state, provider credentials, session databases, and the Gateway token live under \`$STATE_DIR\` and are intentionally not versioned.

## Operating

\`\`\`bash
sudo -iu $AGENT_USER $REPO_ROOT/scripts/verify.sh     # end-to-end health + live agent turn
sudo -iu $AGENT_USER $REPO_ROOT/scripts/doctor.sh     # detailed diagnostics
sudo -iu $AGENT_USER openclaw tui                     # chat with the agent
sudo -iu $AGENT_USER systemctl --user restart openclaw-gateway.service
sudo -iu $AGENT_USER journalctl --user -u openclaw-gateway.service -f
sudo ausearch -k openclaw_exec -i
\`\`\`

## Logs

- Trace log: \`$LOG_DIR/openclaw.jsonl\`
- Git checkpoints: \`$LOG_DIR/git-sync.log\`
- Linux audit: \`/var/log/audit/audit.log\` (keys \`openclaw_exec\`, \`openclaw_exec_uid\`)

## Remote access

The Gateway is loopback-only. Tunnel to it:

\`\`\`bash
ssh -N -L $GATEWAY_PORT:127.0.0.1:$GATEWAY_PORT <admin-user>@<this-vm>
\`\`\`

Then open http://127.0.0.1:$GATEWAY_PORT/ and supply the token from \`$ENV_FILE\`.
EOF

########################################################################
# Operational scripts
########################################################################

cat > "$REPO_ROOT/scripts/git-sync.sh" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail
umask 027
REPO_ROOT="$REPO_ROOT"
LOG_FILE="$LOG_DIR/git-sync.log"
BRANCH="$BRANCH"
cd "\$REPO_ROOT"
[[ -d .git ]] || { echo "git-sync: \$REPO_ROOT is not a git repository yet" >&2; exit 0; }
# Shared writer lock (finding R-10, 2026-10-03). The SAME lock lab-control/scripts/repo-write-lock.sh
# hands out, so an agent that wraps its coordination write in that guard serialises with this timer
# instead of racing it. A PRIVATE lock file (pre-2026-10-03) meant the two writers could not see each
# other. Keep the skip-if-busy semantics: the timer must never block behind an agent.
exec 9>".git/lab-repo-writer.lock"
flock -n 9 || exit 0
exec >>"\$LOG_FILE" 2>&1
printf '[%s] git-sync start\\n' "\$(date -Is)"

current_branch=\$(git branch --show-current)
if [[ "\$current_branch" != "\$BRANCH" ]]; then
  printf '[%s] git-sync skipped: current branch %s is not %s\\n' "\$(date -Is)" "\$current_branch" "\$BRANCH"
  exit 0
fi

checkpoint_paths=(
  # The FOUR append-only lab logs (AGENTS.md rule 11) are the durability net this
  # periodic checkpoint must cover, matching lab-control/hooks/pre-commit and
  # check-log-growth.sh (finding R-11).
  docs/ACTIVITY.md
  docs/DECISIONS.md
  lab-control/docs/ACTIVITY.md
  lab-control/docs/DECISIONS.md
  docs/lab-architecture.html
  workspace/MEMORY.md
  workspace/memory
)
checkpoint_status=\$(git status --porcelain=v1 -- "\${checkpoint_paths[@]}")
if [[ -n "\$checkpoint_status" ]]; then
  {
    printf '\\n## %s — Automatic checkpoint\\n\\n' "\$(date -Is)"
    printf -- '- Host: \`%s\`\\n' "\$(hostname -f 2>/dev/null || hostname)"
    printf -- '- Allowlisted changes before checkpoint:\\n'
    printf '%s\\n' "\$checkpoint_status" | sed 's/^/  - /'
  } >> docs/ACTIVITY.md

  git add -A -- "\${checkpoint_paths[@]}"

  # Defense-in-depth against committed credentials. Not a complete secret scanner.
  if git diff --cached --diff-filter=ACM -U0 | grep '^+' | \\
       grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|-----BEGIN ([A-Z ]+ )?PRIVATE KEY-----' >/dev/null; then
    printf '[%s] REFUSED commit: probable secret/private key in staged additions\\n' "\$(date -Is)"
    exit 2
  fi

  if ! git diff --cached --quiet; then
    git commit -m "openclaw: checkpoint \$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  fi
fi

if git remote get-url origin >/dev/null 2>&1; then
  git push origin "\$BRANCH:\$BRANCH"
else
  printf '[%s] no origin remote configured; local commit retained\\n' "\$(date -Is)"
fi
printf '[%s] git-sync complete\\n' "\$(date -Is)"
EOF

cat > "$REPO_ROOT/scripts/doctor.sh" <<EOF
#!/usr/bin/env bash
set -u
export PATH="$INSTALL_PREFIX/bin:\$PATH"
export OPENCLAW_STATE_DIR="$STATE_DIR"
export OPENCLAW_CONFIG_PATH="$CONFIG_PATH"
export OPENCLAW_WORKSPACE_DIR="$WORKSPACE_DIR"
export OPENCLAW_SERVICE_REPAIR_POLICY="external"
export npm_config_cache="$STATE_DIR/.npm-cache"

section() { printf '\\n=== %s ===\\n' "\$1"; }
section 'Version';        openclaw --version || true
section 'Doctor';         openclaw doctor || true
section 'Gateway status'; openclaw gateway status || true
# CHG-0089: name the manager, so this diagnosis is true from a root shell too.
section 'Gateway unit';   AGENT_USER="$AGENT_USER" "$REPO_ROOT/scripts/check-gateway-unit.sh" || true
section 'Service';        systemctl --machine=${AGENT_USER}@ --user --no-pager --lines=10 status openclaw-gateway.service || true
section 'Exec policy';    openclaw exec-policy show || true
section 'Models';         openclaw models status || true
section 'Auth profiles';  openclaw models auth list --provider openai || true
section 'Auth order';     openclaw models auth order get --provider openai || true
section 'Security audit'; openclaw security audit || true
section 'Git';            git -C "$REPO_ROOT" status --short --branch || true
section 'Recent log';     tail -n 30 "$LOG_DIR/openclaw.jsonl" 2>/dev/null || true
EOF

# verify.sh is the same end-to-end check the bootstrap runs, so it can be rerun later.
cat > "$REPO_ROOT/scripts/verify.sh" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail
export PATH="$INSTALL_PREFIX/bin:\$PATH"
export OPENCLAW_STATE_DIR="$STATE_DIR"
export OPENCLAW_CONFIG_PATH="$CONFIG_PATH"
export OPENCLAW_WORKSPACE_DIR="$WORKSPACE_DIR"
export OPENCLAW_SERVICE_REPAIR_POLICY="external"
export npm_config_cache="$STATE_DIR/.npm-cache"

fail=0
check() { if "\$@" >/dev/null 2>&1; then printf 'ok    %s\\n' "\$*"; else printf 'FAIL  %s\\n' "\$*"; fail=1; fi; }

check env AGENT_USER="$AGENT_USER" "$REPO_ROOT/scripts/check-gateway-unit.sh"
check openclaw config validate
check openclaw gateway status

printf '... running a live agent turn (may take a minute)\\n'
out="\$(openclaw agent --agent main --session-key verify-\$(date +%s) \\
        --message 'Reply with exactly: OPENCLAW_VERIFY_OK' \\
        --json --timeout 300 2>/dev/null || true)"
if printf '%s' "\$out" | grep -q 'OPENCLAW_VERIFY_OK'; then
  printf 'ok    live agent turn\\n'
else
  printf 'FAIL  live agent turn\\n%s\\n' "\$out"
  fail=1
fi

(( fail )) && { printf '\\nVERIFY FAILED — run %s/scripts/doctor.sh\\n' "$REPO_ROOT"; exit 1; }
printf '\\nVERIFY OK\\n'
EOF

cat > "$REPO_ROOT/scripts/switch-to-ollama.sh" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <exact-ollama-model-id>" >&2
  exit 2
fi
export OLLAMA_API_KEY="${OLLAMA_API_KEY:-ollama-local}"
openclaw models list --provider ollama
openclaw models set "ollama/$1"
openclaw models status
EOF

chmod 0750 "$REPO_ROOT"/scripts/*.sh

# Keep a copy of this bootstrap in the repo. SELF_PATH was resolved before `cd /`.
# Guard against cp-onto-itself on rerun.
REPO_SELF="$REPO_ROOT/scripts/bootstrap-openclaw-agent-vm.sh"
if [[ -n "$SELF_PATH" && -f "$SELF_PATH" && "$SELF_PATH" != "$(readlink -f "$REPO_SELF" 2>/dev/null || true)" ]]; then
  cp -f "$SELF_PATH" "$REPO_SELF"
fi
[[ -f "$REPO_SELF" ]] && chmod 0750 "$REPO_SELF"

########################################################################
# Host policy: sudo, auditd, logrotate
########################################################################

cat > "$REPO_ROOT/system/90-openclaw-agent.sudoers" <<EOF
# Managed from $REPO_ROOT/system/90-openclaw-agent.sudoers
# WARNING: intentionally privileged lab configuration.
$AGENT_USER ALL=(ALL:ALL) NOPASSWD: ALL
EOF
chmod 0440 "$REPO_ROOT/system/90-openclaw-agent.sudoers"

if (( ENABLE_FULL_ACCESS )); then
  log "Installing passwordless sudo policy"
  # Separate -c and -f: accepted by both sudo-rs visudo and sudo.ws visudo.
  visudo -c -f "$REPO_ROOT/system/90-openclaw-agent.sudoers" >/dev/null \
    || die "Generated sudoers policy failed validation; /etc/sudoers.d untouched."
  install -m 0440 -o root -g root "$REPO_ROOT/system/90-openclaw-agent.sudoers" /etc/sudoers.d/90-openclaw-agent
else
  log "Cautious mode; no NOPASSWD sudo policy installed"
  rm -f /etc/sudoers.d/90-openclaw-agent
fi

AUDIT_RULES="$REPO_ROOT/system/audit-openclaw-agent.rules"
{
  echo "# Managed from $AUDIT_RULES"
  case "$ARCH" in
    x86_64)
      echo "-a always,exit -F arch=b64 -S execve -F uid=$AGENT_UID -k openclaw_exec_uid"
      echo "-a always,exit -F arch=b32 -S execve -F uid=$AGENT_UID -k openclaw_exec_uid"
      echo "-a always,exit -F arch=b64 -S execve -F auid=$AGENT_UID -F auid!=4294967295 -k openclaw_exec"
      echo "-a always,exit -F arch=b32 -S execve -F auid=$AGENT_UID -F auid!=4294967295 -k openclaw_exec"
      ;;
    *)
      echo "-a always,exit -F arch=b64 -S execve -F uid=$AGENT_UID -k openclaw_exec_uid"
      echo "-a always,exit -F arch=b64 -S execve -F auid=$AGENT_UID -F auid!=4294967295 -k openclaw_exec"
      ;;
  esac
} > "$AUDIT_RULES"
chmod 0640 "$AUDIT_RULES"
install -m 0640 -o root -g root "$AUDIT_RULES" /etc/audit/rules.d/90-openclaw-agent.rules
systemctl enable --now auditd >/dev/null 2>&1 || warn "Could not enable auditd."
augenrules --load >/dev/null 2>&1 || warn "Audit rules will load on the next auditd/VM restart."

cat > "$REPO_ROOT/system/openclaw.logrotate" <<EOF
# Managed from $REPO_ROOT/system/openclaw.logrotate
$LOG_DIR/*.jsonl $LOG_DIR/*.log {
    daily
    rotate 14
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
    su $AGENT_USER adm
}
EOF
install -m 0644 -o root -g root "$REPO_ROOT/system/openclaw.logrotate" /etc/logrotate.d/openclaw

########################################################################
# Install OpenClaw
########################################################################

install -d -m 0755 -o "$AGENT_USER" -g "$AGENT_USER" "$INSTALL_PREFIX"
if [[ ! -x "$INSTALL_PREFIX/bin/openclaw" ]]; then
  log "Installing OpenClaw via the official rootless installer (downloads a private Node runtime)"
  runuser -u "$AGENT_USER" -- env -C "$AGENT_HOME" HOME="$AGENT_HOME" bash -c \
    'set -o pipefail; curl -fsSL --proto "=https" --tlsv1.2 https://openclaw.ai/install-cli.sh | bash -s -- --prefix "$1" --version latest --no-onboard' \
    _ "$INSTALL_PREFIX" \
    || die "OpenClaw installer failed. Check outbound HTTPS to openclaw.ai and the npm registry."
fi
[[ -x "$INSTALL_PREFIX/bin/openclaw" ]] || die "$INSTALL_PREFIX/bin/openclaw missing after install."
ln -sfn "$INSTALL_PREFIX/bin/openclaw" /usr/local/bin/openclaw

agent_env=(
  HOME="$AGENT_HOME"
  PATH="$INSTALL_PREFIX/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  OPENCLAW_STATE_DIR="$STATE_DIR"
  OPENCLAW_CONFIG_PATH="$CONFIG_PATH"
  OPENCLAW_WORKSPACE_DIR="$WORKSPACE_DIR"
  OPENCLAW_SERVICE_REPAIR_POLICY="external"
  npm_config_cache="$STATE_DIR/.npm-cache"
)
# Always run agent commands FROM the agent's home (env -C), never from an
# inherited cwd, so spawned children (npm, git, the Codex app-server) start
# in a directory the agent can read.
as_agent()       { runuser -u "$AGENT_USER" -- env -C "$AGENT_HOME" "${agent_env[@]}" "$@"; }
as_agent_stdin() { runuser -u "$AGENT_USER" -- env -C "$AGENT_HOME" "${agent_env[@]}" "$@"; }   # stdin is inherited

log "OpenClaw version: $(as_agent openclaw --version 2>/dev/null | head -n1)"

# Codex harness is an external official plugin; install before validating a config
# that enables plugins.entries.codex. This build rejects both --yes and --verbose
# on `plugins install`, so pass no extra flags and capture stdout+stderr plainly
# so a real failure (network, npm cache, ownership) is still visible.
if ! as_agent openclaw plugins inspect codex --json >/dev/null 2>&1; then
  log "Installing the official Codex plugin (@openclaw/codex)"
  if ! PLUGIN_OUT="$(as_agent env OPENCLAW_DEBUG=1 openclaw plugins install @openclaw/codex 2>&1)"; then
    printf '%s\n' "$PLUGIN_OUT" >&2
    die "Could not install @openclaw/codex (output above). EACCES here almost always means npm could not be spawned: an unreadable working directory or a non-executable Node under $INSTALL_PREFIX. Retry by hand: sudo -iu $AGENT_USER bash -lc 'cd ~ && openclaw plugins install @openclaw/codex'"
  fi
  # Confirm it registered, not just that the command exited 0.
  if ! as_agent openclaw plugins inspect codex --json >/dev/null 2>&1; then
    printf '%s\n' "$PLUGIN_OUT" >&2
    die "@openclaw/codex installed but did not register. Check that $STATE_DIR/extensions is owned by $AGENT_USER, then rerun."
  fi
  log "Codex plugin installed and registered"
fi

log "Validating configuration"
as_agent openclaw config validate || die "config/openclaw.json failed schema validation."

########################################################################
# Provider credentials — before the Gateway ever starts
########################################################################

if [[ "$AUTH_MODE" == "skip" ]]; then
  warn "--skip-auth: no provider credentials installed. The agent will not answer until you log in."
else
  if ! as_agent openclaw models auth list --provider openai --json 2>/dev/null | grep -q 'openai:'; then
    case "$AUTH_MODE" in
      api-key)
        log "Installing the OpenAI API key as an auth profile"
        printf '%s\n' "$OPENAI_API_KEY_ARG" \
          | as_agent_stdin openclaw models auth paste-api-key --provider openai \
          || die "Storing the OpenAI API key failed."
        ;;
      oauth)
        log "Starting ChatGPT/Codex sign-in — follow the prompts below (open the URL + enter the code)"
        # Prefer the device-code shortcut; fall back to the plain login flow if
        # this build does not accept that flag, so the run isn't lost to a flag name.
        if ! as_agent_stdin openclaw models auth login --provider openai --device-code; then
          warn "device-code shortcut failed or is unsupported here; trying the standard login flow."
          as_agent_stdin openclaw models auth login --provider openai \
            || die "OpenAI sign-in did not complete. Rerun manually: sudo -iu $AGENT_USER openclaw models auth login --provider openai"
        fi
        ;;
    esac
  else
    log "An OpenAI auth profile already exists; leaving it alone"
  fi

  # Pin the profile explicitly. An unset auth order is the documented cause of
  # requests going out to api.openai.com with no Authorization header (401
  # "Missing bearer or basic authentication in header").
  as_agent openclaw doctor --fix >/dev/null 2>&1 || warn "openclaw doctor --fix reported issues; continuing."
  OPENAI_PROFILE="$(as_agent openclaw models auth list --provider openai --json 2>/dev/null \
    | jq -r '[.. | objects | .id? // empty | select(type=="string") | select(startswith("openai:"))] | first // empty')"
  [[ -n "$OPENAI_PROFILE" ]] || die "No openai:* auth profile found after login. Run: sudo -iu $AGENT_USER openclaw models auth list --provider openai"
  log "Pinning auth order to profile: $OPENAI_PROFILE"
  as_agent openclaw models auth order set --provider openai "$OPENAI_PROFILE" \
    || warn "Could not set the auth order; the agent may fall back to round-robin selection."

  # Live credential probe. Must run with the Gateway stopped: probing needs
  # exclusive ownership of the state directory.
  log "Probing the credential against OpenAI"
  as_agent openclaw models status --probe --probe-provider openai --probe-timeout 20000 \
    || warn "Credential probe was not clean; the end-to-end turn below is the authoritative check."
fi

########################################################################
# Exec policy and hooks
########################################################################

if (( ENABLE_FULL_ACCESS )); then
  log "Applying the full/no-prompt exec policy (YOLO preset)"
  as_agent openclaw exec-policy preset yolo
else
  log "Applying the cautious exec policy"
  as_agent openclaw exec-policy preset cautious
fi

as_agent openclaw hooks enable command-logger >/dev/null 2>&1 \
  || warn "Could not enable the command-logger hook; trace + audit ledger + auditd remain."

# When the UI is reached through the Caddy proxy, the browser's Origin is
# https://<vm-ip> or https://<hostname>, not a loopback origin. The Gateway
# stays bound to loopback; only the allowed-origins list changes.
VM_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
VM_FQDN="$(hostname -f 2>/dev/null || hostname)"
if (( WITH_DOCKER_CADDY )); then
  ORIGINS="[\"https://${VM_IP}\",\"https://${VM_FQDN}\",\"https://$(hostname)\",\"https://localhost\",\"https://127.0.0.1\"]"
  as_agent openclaw config set gateway.controlUi.allowedOrigins "$ORIGINS" --strict-json >/dev/null 2>&1 \
    || warn "Could not set gateway.controlUi.allowedOrigins; the Control UI may reject the proxied origin. Set it by hand if so."
fi

as_agent openclaw config validate || die "Configuration became invalid after CLI policy edits."

# The CLI rewrites config/openclaw.json above. Make sure it did not inline the
# gateway token into a file that is about to be committed.
if [[ -n "$GATEWAY_TOKEN" ]] && grep -qF "$GATEWAY_TOKEN" "$CONFIG_PATH"; then
  die "Gateway token was written in plaintext into $CONFIG_PATH; refusing to commit it."
fi
grep -qF '${OPENCLAW_GATEWAY_TOKEN}' "$CONFIG_PATH" \
  || warn "config/openclaw.json no longer references \${OPENCLAW_GATEWAY_TOKEN}; check gateway.auth.token."

########################################################################
# systemd user manager and units
########################################################################

log "Enabling lingering so the user manager survives logout and reboot"
loginctl enable-linger "$AGENT_USER" || die "loginctl enable-linger $AGENT_USER failed."
systemctl start "user@${AGENT_UID}.service" || die "Could not start user@${AGENT_UID}.service."
for _ in $(seq 1 30); do
  [[ -S "/run/user/$AGENT_UID/systemd/private" ]] && break
  sleep 1
done
[[ -S "/run/user/$AGENT_UID/systemd/private" ]] || die "systemd user manager for $AGENT_USER never came up."

user_systemctl() {
  runuser -u "$AGENT_USER" -- env \
    HOME="$AGENT_HOME" \
    XDG_RUNTIME_DIR="/run/user/$AGENT_UID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$AGENT_UID/bus" \
    PATH="$INSTALL_PREFIX/bin:/usr/local/bin:/usr/bin:/bin" \
    systemctl --user "$@"
}

# This VM uses a Git-tracked config outside ~/.openclaw. OpenClaw refuses native
# service management for such relocated identities, so own the unit ourselves —
# the documented custom-install pattern, with OPENCLAW_SERVICE_REPAIR_POLICY=external.
cat > "$REPO_ROOT/system/systemd/openclaw-gateway.service" <<EOF
[Unit]
Description=OpenClaw Gateway (lab agent VM)
After=network-online.target
Wants=network-online.target
StartLimitBurst=5
StartLimitIntervalSec=60

[Service]
Type=simple
Environment=HOME=$AGENT_HOME
Environment=PATH=$INSTALL_PREFIX/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=OPENCLAW_STATE_DIR=$STATE_DIR
Environment=OPENCLAW_CONFIG_PATH=$CONFIG_PATH
Environment=OPENCLAW_WORKSPACE_DIR=$WORKSPACE_DIR
Environment=OPENCLAW_SERVICE_REPAIR_POLICY=external
Environment=npm_config_cache=$STATE_DIR/.npm-cache
EnvironmentFile=-$ENV_FILE
WorkingDirectory=$WORKSPACE_DIR
ExecStart=$INSTALL_PREFIX/bin/openclaw gateway --port $GATEWAY_PORT
Restart=always
RestartSec=5
RestartPreventExitStatus=78
TimeoutStopSec=330
TimeoutStartSec=60
SuccessExitStatus=0 143
OOMPolicy=continue
KillMode=mixed

[Install]
WantedBy=default.target
EOF

cat > "$REPO_ROOT/system/systemd/openclaw-git-sync.service" <<EOF
[Unit]
Description=Checkpoint the OpenClaw agent repository to Git
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
Environment=PATH=$INSTALL_PREFIX/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=$REPO_ROOT/scripts/git-sync.sh
EOF

cat > "$REPO_ROOT/system/systemd/openclaw-git-sync.timer" <<'EOF'
[Unit]
Description=Periodic OpenClaw agent Git checkpoint

[Timer]
OnBootSec=3min
OnUnitActiveSec=5min
Persistent=true
RandomizedDelaySec=20s

[Install]
WantedBy=timers.target
EOF

for unit in openclaw-gateway.service openclaw-git-sync.service openclaw-git-sync.timer; do
  install -m 0644 -o "$AGENT_USER" -g "$AGENT_USER" \
    "$REPO_ROOT/system/systemd/$unit" "$USER_UNIT_DIR/$unit"
done
rm -rf "$USER_UNIT_DIR/openclaw-gateway.service.d"

user_systemctl daemon-reload
log "Starting the Gateway"
user_systemctl enable --now openclaw-gateway.service

# Wait for readiness rather than assuming it.
GATEWAY_UP=0
for _ in $(seq 1 60); do
  if user_systemctl is-active --quiet openclaw-gateway.service && as_agent openclaw gateway status >/dev/null 2>&1; then
    GATEWAY_UP=1; break
  fi
  sleep 2
done
if (( ! GATEWAY_UP )); then
  user_systemctl --no-pager --lines=40 status openclaw-gateway.service || true
  die "Gateway did not become healthy within 120s. See: sudo -iu $AGENT_USER journalctl --user -u openclaw-gateway.service"
fi
log "Gateway healthy on 127.0.0.1:$GATEWAY_PORT"

########################################################################
# Extras: Caddy HTTPS proxy, firewall, Ollama
########################################################################

CADDY_URL=""
if (( WITH_DOCKER_CADDY )); then
  log "Setting up the Caddy HTTPS proxy (443 → 127.0.0.1:$GATEWAY_PORT, self-signed)"
  if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE '[:.]443$'; then
    warn "Something is already listening on :443; Caddy will fail to bind. Skipping the proxy."
  else
    install -d -m 0755 -o "$AGENT_USER" -g "$AGENT_USER" "$REPO_ROOT/system/caddy"
    # 'tls internal' = Caddy's own self-signed CA. Redirect-on-:80 is disabled so
    # the container only needs 443. --network host lets it reach the loopback
    # Gateway without exposing the Gateway itself.
    cat > "$REPO_ROOT/system/caddy/Caddyfile" <<EOF
# Managed from $REPO_ROOT/system/caddy/Caddyfile
{
	auto_https disable_redirects
}

:443 {
	tls internal
	encode gzip
	reverse_proxy 127.0.0.1:$GATEWAY_PORT
}
EOF
    chown "$AGENT_USER:$AGENT_USER" "$REPO_ROOT/system/caddy/Caddyfile"
    docker rm -f openclaw-caddy >/dev/null 2>&1 || true
    if docker run -d --name openclaw-caddy --network host --restart unless-stopped \
         -v "$REPO_ROOT/system/caddy/Caddyfile:/etc/caddy/Caddyfile:ro" \
         -v openclaw-caddy-data:/data -v openclaw-caddy-config:/config \
         caddy:2 >/dev/null; then
      # Wait for TLS to come up; any HTTP status (even 401) means the proxy is live.
      CADDY_OK=0
      for _ in $(seq 1 30); do
        code="$(curl -sk -o /dev/null -w '%{http_code}' https://127.0.0.1/ 2>/dev/null || true)"
        [[ "$code" =~ ^[2345][0-9][0-9]$ ]] && { CADDY_OK=1; break; }
        sleep 1
      done
      if (( CADDY_OK )); then
        CADDY_URL="https://${VM_IP:-<this-vm>}/"
        log "Caddy proxy is live at $CADDY_URL (self-signed; your browser will warn once)"
      else
        warn "Caddy container started but did not answer on :443 within 30s. Check: docker logs openclaw-caddy"
      fi
    else
      warn "Could not start the Caddy container. Check: docker logs openclaw-caddy"
    fi
  fi
fi

if (( WITH_FIREWALL )) && command -v ufw >/dev/null 2>&1; then
  log "Configuring ufw: allow SSH + 443 only"
  ufw --force reset >/dev/null 2>&1 || true
  ufw default deny incoming  >/dev/null
  ufw default allow outgoing >/dev/null
  ufw allow OpenSSH >/dev/null 2>&1 || ufw allow 22/tcp >/dev/null
  (( WITH_DOCKER_CADDY )) && ufw allow 443/tcp >/dev/null
  ufw --force enable >/dev/null && log "ufw enabled (SSH$( (( WITH_DOCKER_CADDY )) && echo ', 443' ) allowed)"
fi

if (( WITH_OLLAMA )); then
  log "Installing Ollama (local-LLM runtime)"
  if command -v ollama >/dev/null 2>&1; then
    log "Ollama already present; leaving it alone"
  elif curl -fsSL https://ollama.com/install.sh | sh; then
    systemctl enable --now ollama >/dev/null 2>&1 || true
    log "Ollama installed. Later: sudo -iu $AGENT_USER $REPO_ROOT/scripts/switch-to-ollama.sh <model>"
  else
    warn "Ollama install failed; continuing without it."
  fi
fi

########################################################################
# Git repository (before the sync timer, so the timer never fires on a non-repo)
########################################################################

chown -R "$AGENT_USER:$AGENT_USER" "$REPO_ROOT"
if [[ ! -d "$REPO_ROOT/.git" ]]; then
  as_agent git -C "$REPO_ROOT" init -b "$BRANCH"
fi
as_agent git -C "$REPO_ROOT" config user.name "$GIT_NAME"
as_agent git -C "$REPO_ROOT" config user.email "$GIT_EMAIL"
as_agent git -C "$REPO_ROOT" add -A
if ! as_agent git -C "$REPO_ROOT" diff --cached --quiet; then
  as_agent git -C "$REPO_ROOT" commit -m "bootstrap: privileged OpenClaw lab agent VM"
fi
user_systemctl enable --now openclaw-git-sync.timer

if (( ENABLE_GITHUB )) && [[ -n "$GITHUB_REPO" ]]; then
  log "Configuring the GitHub remote: $GITHUB_REPO"
  if ! as_agent gh auth status --hostname github.com >/dev/null 2>&1; then
    if [[ -n "${GH_TOKEN:-}" ]]; then
      printf '%s\n' "$GH_TOKEN" | runuser -u "$AGENT_USER" -- env -C "$AGENT_HOME" HOME="$AGENT_HOME" PATH="/usr/bin:/bin" \
        gh auth login --hostname github.com --git-protocol https --with-token \
        || die "gh auth login with GH_TOKEN failed."
    else
      runuser -u "$AGENT_USER" -- env -C "$AGENT_HOME" HOME="$AGENT_HOME" PATH="/usr/bin:/bin" \
        gh auth login --hostname github.com --git-protocol https --web \
        || die "Interactive gh auth login did not complete."
    fi
  fi
  as_agent gh auth setup-git >/dev/null
  if as_agent gh repo view "$GITHUB_REPO" >/dev/null 2>&1; then
    if as_agent git -C "$REPO_ROOT" remote get-url origin >/dev/null 2>&1; then
      as_agent git -C "$REPO_ROOT" remote set-url origin "https://github.com/$GITHUB_REPO.git"
    else
      as_agent git -C "$REPO_ROOT" remote add origin "https://github.com/$GITHUB_REPO.git"
    fi
  else
    as_agent gh repo create "$GITHUB_REPO" --private --source "$REPO_ROOT" --remote origin
  fi
  as_agent git -C "$REPO_ROOT" push -u origin "$BRANCH" \
    || die "GitHub push failed. Local Git is intact; check the remote and rerun $REPO_ROOT/scripts/git-sync.sh."
elif (( ENABLE_GITHUB )); then
  warn "No --github-repo supplied; local Git only, no remote configured."
fi

as_agent "$REPO_ROOT/scripts/git-sync.sh" || warn "Final Git sync incomplete; see $LOG_DIR/git-sync.log."

########################################################################
# End-to-end verification
########################################################################

if (( SKIP_SMOKE )); then
  warn "Skipping the live agent turn. The VM is configured but unverified."
else
  log "Running a live agent turn through the Gateway (first run also fetches the Codex app-server)"
  SMOKE_OUT=""
  for attempt in 1 2; do
    SMOKE_OUT="$(as_agent openclaw agent --agent main \
        --session-key "bootstrap-smoke-$(date +%s)" \
        --message 'Reply with exactly: OPENCLAW_BOOTSTRAP_OK' \
        --json --timeout 300 2>&1 || true)"
    printf '%s' "$SMOKE_OUT" | grep -q 'OPENCLAW_BOOTSTRAP_OK' && break
    (( attempt == 1 )) && { warn "First agent turn did not succeed; retrying once."; sleep 10; }
  done
  if ! printf '%s' "$SMOKE_OUT" | grep -q 'OPENCLAW_BOOTSTRAP_OK'; then
    printf '%s\n' "$SMOKE_OUT" >&2
    echo >&2
    as_agent openclaw models status >&2 || true
    die "The agent could not complete a turn. Everything else is installed; diagnose with:
  sudo -iu $AGENT_USER $REPO_ROOT/scripts/doctor.sh
  sudo -iu $AGENT_USER journalctl --user -u openclaw-gateway.service -n 100"
  fi
  log "Live agent turn succeeded."
fi

finalize_log
trap - EXIT
banner "YAY I DON'T SUCK!"
cat <<EOF

════════════════════════════════════════════════════════════════════
OpenClaw lab agent VM is up$( (( SKIP_SMOKE )) && echo " (UNVERIFIED — smoke test skipped)" || echo " and verified end to end.")
════════════════════════════════════════════════════════════════════

Talk to it:
  sudo -iu $AGENT_USER openclaw tui

Re-verify at any time:
  sudo -iu $AGENT_USER $REPO_ROOT/scripts/verify.sh

$( if [[ -n "$CADDY_URL" ]]; then cat <<EOC
Reach the Control UI over HTTPS (self-signed cert — accept the browser warning once):
  $CADDY_URL     then paste the token from $ENV_FILE
  (The Gateway itself is still loopback-only; Caddy proxies 443 to it.)
EOC
else cat <<EOC
Reach the Control UI (loopback only — tunnel in):
  ssh -N -L $GATEWAY_PORT:127.0.0.1:$GATEWAY_PORT <admin-user>@$(hostname -f 2>/dev/null || hostname)
  open http://127.0.0.1:$GATEWAY_PORT/  and paste the token from $ENV_FILE
EOC
fi )

Give the agent access to other lab machines with this public key:
  $AGENT_HOME/.ssh/id_ed25519.pub

Git repo:               $REPO_ROOT
GitHub remote:          ${GITHUB_REPO:-none}
Config:                 $CONFIG_PATH
State/secrets:          $STATE_DIR   (never committed)
Trace log:              $LOG_DIR/openclaw.jsonl
Git sync log:           $LOG_DIR/git-sync.log
Audit log:              /var/log/audit/audit.log   (keys: openclaw_exec, openclaw_exec_uid)
Model:                  $MODEL_REF
Exec policy:            $([[ $ENABLE_FULL_ACCESS -eq 1 ]] && echo "FULL ACCESS (no prompts, NOPASSWD sudo)" || echo "cautious")
Extras:                 docker-caddy=$WITH_DOCKER_CADDY dev-tools=$WITH_DEV_TOOLS ollama=$WITH_OLLAMA firewall=$WITH_FIREWALL
Debug transcript:       ${DEBUG_LOG:-<none>}
EOF
