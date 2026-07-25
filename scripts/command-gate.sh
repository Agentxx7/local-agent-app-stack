#!/usr/bin/env bash
set -u

readonly EXIT_ALLOW=0
readonly EXIT_REVIEW=20
readonly EXIT_BLOCK=30
readonly EXIT_USAGE=64

usage() {
  printf '%s\n' \
    'Usage: scripts/command-gate.sh --check-only -- <command> <args...>' \
    '       scripts/command-gate.sh --operator-approved <decision-id> --reason <reason> -- <command> <args...>'
}

root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd -P) || exit "$EXIT_USAGE"
log_dir=${COMMAND_GATE_LOG_DIR:-"$root/.local"}
log_file="$log_dir/command-gate.log"

mode=execute
decision_id=
reason=
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --check-only)
      mode=check-only
      shift
      ;;
    --operator-approved)
      [[ "$#" -ge 2 ]] || { usage; exit "$EXIT_USAGE"; }
      decision_id=$2
      shift 2
      ;;
    --reason)
      [[ "$#" -ge 2 ]] || { usage; exit "$EXIT_USAGE"; }
      reason=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      printf 'FAIL unknown option: %s\n' "$1" >&2
      usage >&2
      exit "$EXIT_USAGE"
      ;;
  esac
done

[[ "$#" -gt 0 ]] || { printf 'FAIL command is required\n' >&2; usage >&2; exit "$EXIT_USAGE"; }
command_argv=("$@")

CLASSIFICATION=REVIEW
CATEGORY=unknown-or-ambiguous

set_classification() {
  CLASSIFICATION=$1
  CATEGORY=$2
}

has_option_with_letter() {
  wanted=$1
  shift
  local arg
  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      case "$wanted:$arg" in
        r:--recursive|f:--force|d:--delete) return 0 ;;
      esac
    elif [[ "$arg" == -* && "${arg#-}" == *"$wanted"* ]]; then
      return 0
    fi
  done
  return 1
}

contains_arg() {
  wanted=$1
  shift
  local arg
  for arg in "$@"; do
    [[ "$arg" == "$wanted" ]] && return 0
  done
  return 1
}

shell_has_command_option() {
  index=$1
  shift
  local all=("$@") arg
  for arg in "${all[@]:index+1}"; do
    if [[ "$arg" == -c || ( "$arg" == -?* && "$arg" != --* && "${arg#-}" == *c* ) ]]; then
      return 0
    fi
  done
  return 1
}

classify_rm_at() {
  index=$1
  shift
  local all=("$@")
  local tail=("${all[@]:index+1}")
  local recursive=0
  has_option_with_letter r "${tail[@]}" && recursive=1
  [[ "$recursive" -eq 1 ]] || { set_classification REVIEW file-removal; return; }

  local target canonical
  for target in "${tail[@]}"; do
    [[ "$target" == -* ]] && continue
    canonical=$(realpath -m -- "$target" 2>/dev/null || printf '%s' "$target")
    canonical=${canonical%/}
    [[ -n "$canonical" ]] || canonical=/
    if [[ "$canonical" == / || "$canonical" == "${HOME%/}" || "$canonical" == "${root%/}" ]]; then
      set_classification BLOCK protected-root-recursive-delete
      return
    fi
  done
  set_classification REVIEW recursive-delete
}

classify_git_at() {
  index=$1
  shift
  local all=("$@")
  local tail=("${all[@]:index+1}")
  local sub=${tail[0]:-}
  local arg
  case "$sub" in
    reset)
      contains_arg --hard "${tail[@]}" && set_classification BLOCK git-reset-hard || set_classification REVIEW git-reset
      ;;
    clean)
      if has_option_with_letter f "${tail[@]}" && has_option_with_letter d "${tail[@]}"; then
        set_classification BLOCK git-clean-destructive
      else
        set_classification REVIEW git-clean
      fi
      ;;
    checkout)
      if contains_arg -- "${tail[@]}" && contains_arg . "${tail[@]}"; then
        set_classification BLOCK git-broad-checkout
      else
        set_classification REVIEW git-checkout
      fi
      ;;
    restore)
      contains_arg . "${tail[@]}" && set_classification BLOCK git-broad-restore || set_classification REVIEW git-restore
      ;;
    push)
      for arg in "${tail[@]}"; do
        case "$arg" in
          --force|--force-with-lease|--force-with-lease=*|-f) set_classification BLOCK git-force-push; return ;;
          --delete) set_classification REVIEW branch-delete; return ;;
        esac
      done
      set_classification REVIEW git-push
      ;;
    branch)
      if contains_arg -d "${tail[@]}" || contains_arg -D "${tail[@]}" || contains_arg --delete "${tail[@]}"; then
        set_classification REVIEW branch-delete
      else
        set_classification REVIEW git-branch-change
      fi
      ;;
    status|diff|show|log|rev-parse|ls-files|check-ignore) set_classification ALLOW git-read ;;
    *) set_classification REVIEW git-other ;;
  esac
}

classify() {
  local argv=("$@")
  local joined_lower= token base next index
  printf -v joined_lower '%s ' "${argv[@]}"
  joined_lower=${joined_lower,,}

  if [[ "$joined_lower" == *"drop database"* || "$joined_lower" == *"drop table"* ]]; then
    set_classification BLOCK destructive-sql
    return
  fi

  for ((index=0; index<${#argv[@]}; index++)); do
    token=${argv[index]}
    base=${token##*/}
    next=${argv[index+1]:-}
    case "$base" in
      eval)
        set_classification BLOCK dynamic-execution
        return
        ;;
      sh|bash|dash|zsh|ksh|fish)
        if shell_has_command_option "$index" "${argv[@]}"; then
          set_classification BLOCK nested-shell
          return
        fi
        ;;
      mkfs|mkfs.*|shutdown|reboot|poweroff)
        set_classification BLOCK destructive-system-command
        return
        ;;
      dd)
        if [[ "$joined_lower" == *" of="* ]]; then
          set_classification BLOCK destructive-device-write
          return
        fi
        ;;
      rm)
        classify_rm_at "$index" "${argv[@]}"
        [[ "$CLASSIFICATION" == BLOCK ]] && return
        ;;
      git)
        classify_git_at "$index" "${argv[@]}"
        [[ "$CLASSIFICATION" == BLOCK ]] && return
        ;;
      docker|podman)
        if [[ "$next" == system && "${argv[index+2]:-}" == prune ]]; then
          set_classification BLOCK container-system-prune
          return
        fi
        ;;
      kubectl)
        if [[ "$next" == delete && "${argv[index+2]:-}" == namespace ]]; then
          set_classification BLOCK namespace-delete
          return
        fi
        ;;
      terraform)
        if [[ "$next" == destroy ]]; then
          set_classification BLOCK infrastructure-destroy
          return
        fi
        ;;
    esac
  done

  base=${argv[0]##*/}
  case "$base" in
    git)
      classify_git_at 0 "${argv[@]}"
      return
      ;;
    sh|bash)
      case "${argv[1]:-}" in
        scripts/verify-structure.sh|scripts/verify-operating-model.sh|scripts/tests/command-gate-test.sh)
          set_classification ALLOW registered-verification
          return
          ;;
        -n)
          case "${argv[2]:-}" in
            scripts/command-gate.sh|scripts/verify-structure.sh|scripts/verify-operating-model.sh|scripts/tests/command-gate-test.sh)
              set_classification ALLOW shell-syntax-check
              return
              ;;
          esac
          ;;
      esac
      ;;
    verify-structure.sh|verify-operating-model.sh|command-gate-test.sh)
      set_classification ALLOW registered-verification
      return
      ;;
    printf|true)
      set_classification ALLOW safe-builtin
      return
      ;;
    pkill|killall|kill|sudo)
      set_classification REVIEW privileged-or-process-control
      return
      ;;
    apt|apt-get|dnf|yum|apk|brew|npm|pnpm|yarn|cargo)
      case "${argv[1]:-}" in
        remove|purge|uninstall) set_classification REVIEW package-removal; return ;;
      esac
      ;;
    docker|podman)
      case "${argv[1]:-}" in
        rm|rmi) set_classification REVIEW container-removal; return ;;
        volume) [[ "${argv[2]:-}" == rm ]] && { set_classification REVIEW volume-removal; return; } ;;
      esac
      ;;
  esac

  if [[ "$joined_lower" == *"migrat"* && ( "$joined_lower" == *"rollback"* || "$joined_lower" == *" down"* ) ]]; then
    set_classification REVIEW destructive-migration
    return
  fi

  set_classification REVIEW unknown-or-ambiguous
}

classify "${command_argv[@]}"

safe_decision=${decision_id//[^A-Za-z0-9._:-]/_}
safe_command=${command_argv[0]##*/}
safe_command=${safe_command//[^A-Za-z0-9._+-]/_}
mkdir -p -- "$log_dir" || { printf 'FAIL cannot create command-gate log directory\n' >&2; exit "$EXIT_USAGE"; }
printf '%s classification=%s category=%s mode=%s command=%s argc=%s decision=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$CLASSIFICATION" "$CATEGORY" "$mode" \
  "$safe_command" "${#command_argv[@]}" "${safe_decision:--}" >> "$log_file"

printf '%s category=%s\n' "$CLASSIFICATION" "$CATEGORY" >&2

case "$CLASSIFICATION" in
  BLOCK)
    exit "$EXIT_BLOCK"
    ;;
  REVIEW)
    if [[ "$mode" == check-only || -z "$decision_id" || -z "$reason" ]]; then
      exit "$EXIT_REVIEW"
    fi
    ;;
  ALLOW)
    [[ "$mode" == check-only ]] && exit "$EXIT_ALLOW"
    ;;
esac

"${command_argv[@]}"
