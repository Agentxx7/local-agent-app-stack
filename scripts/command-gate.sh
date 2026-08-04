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

shell_uses_command_string() {
  index=$1
  shell_name=${2,,}
  shift 2
  local all=("$@") arg lower
  for arg in "${all[@]:index+1}"; do
    lower=${arg,,}
    case "$shell_name" in
      sh|bash|dash|zsh|ksh|fish|ash|csh|tcsh)
        if [[ "$arg" == -c || ( "$arg" == -?* && "$arg" != --* && "${arg#-}" == *c* ) ]]; then
          return 0
        fi
        ;;
      pwsh|powershell|powershell.exe)
        case "$lower" in
          -command|-encodedcommand) return 0 ;;
        esac
        ;;
      cmd|cmd.exe)
        case "$lower" in
          /c|/k) return 0 ;;
        esac
        ;;
    esac
  done
  return 1
}

interpreter_uses_command_string() {
  index=$1
  interpreter_name=$2
  shift 2
  local all=("$@") arg lower
  for arg in "${all[@]:index+1}"; do
    lower=${arg,,}
    [[ "$arg" == -- ]] && return 1
    case "$interpreter_name" in
      python|python[0-9]*)
        [[ "$arg" == -?* && "$arg" != --* && "${arg#-}" == *c* ]] && return 0
        ;;
      perl|ruby|lua|lua[0-9]*|R|Rscript|groovy)
        [[ "$arg" == -?* && "$arg" != --* && "${arg#-}" == *e* ]] && return 0
        ;;
      node|nodejs)
        [[ "$arg" == -?* && "$arg" != --* && "${arg#-}" == *e* ]] && return 0
        case "$lower" in --eval|--eval=*) return 0 ;; esac
        ;;
      php)
        [[ "$arg" == -?* && "$arg" != --* && "${arg#-}" == *r* ]] && return 0
        ;;
    esac
    [[ "$arg" != -* ]] && return 1
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
  local tail=("${all[@]:index+1}") global_args=()
  local sub= sub_index=-1 arg current_branch normalized target delete_mode=0
  local delete_targets=()
  local position=0
  while [[ "$position" -lt "${#tail[@]}" ]]; do
    arg=${tail[position]}
    case "$arg" in
      -C|-c|--git-dir|--work-tree|--namespace|--config-env)
        global_args+=("$arg")
        position=$((position + 1))
        [[ "$position" -lt "${#tail[@]}" ]] && global_args+=("${tail[position]}")
        ;;
      --git-dir=*|--work-tree=*|--namespace=*|--config-env=*|--no-pager|--paginate)
        global_args+=("$arg")
        ;;
      -*) ;;
      *)
        sub=$arg
        sub_index=$position
        break
        ;;
    esac
    position=$((position + 1))
  done
  current_branch=$(git "${global_args[@]}" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
  local sub_tail=()
  [[ "$sub_index" -ge 0 ]] && sub_tail=("${tail[@]:sub_index}")
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
      for arg in "${sub_tail[@]:1}"; do
        case "$arg" in
          --force|--force-with-lease|--force-with-lease=*|-f) set_classification BLOCK git-force-push; return ;;
          -[^-]*f*) set_classification BLOCK git-force-push; return ;;
          +*) set_classification BLOCK git-force-push; return ;;
          --all|--mirror|--tags|--follow-tags|--prune) set_classification BLOCK broad-git-push; return ;;
          -d|--delete) delete_mode=1 ;;
          -[^-]*)
            [[ "${#arg}" -gt 2 && "${arg#-}" == *d* ]] && delete_mode=1
            ;;
          --delete=*)
            delete_mode=1
            delete_targets+=("${arg#--delete=}")
            ;;
        esac
      done
      local positional=()
      local skip_next=0
      for arg in "${sub_tail[@]:1}"; do
        if [[ "$skip_next" -eq 1 ]]; then
          skip_next=0
          continue
        fi
        case "$arg" in
          --repo|--receive-pack|--exec)
            skip_next=1
            continue
            ;;
          --repo=*|--receive-pack=*|--exec=*|-u|-d|--set-upstream|--porcelain|--progress|--dry-run|--atomic|--follow-tags|--tags|--prune|--mirror|--no-verify|--ipv4|--ipv6|--delete|--delete=*)
            continue
            ;;
          -*) continue ;;
          *) positional+=("$arg") ;;
        esac
      done

      if [[ "$delete_mode" -eq 1 ]]; then
        [[ "${#positional[@]}" -gt 1 ]] && delete_targets+=("${positional[@]:1}")
        for target in "${delete_targets[@]}"; do
          normalized=${target#refs/heads/}
          if [[ "$normalized" == main || "$normalized" == "$current_branch" ]]; then
            set_classification BLOCK protected-branch-delete
            return
          fi
        done
        set_classification REVIEW branch-delete
        return
      fi

      local refspecs=()
      [[ "${#positional[@]}" -gt 1 ]] && refspecs=("${positional[@]:1}")
      for target in "${refspecs[@]}"; do
        if [[ "$target" == :* ]]; then
          normalized=${target#:}
          normalized=${normalized#refs/heads/}
          if [[ "$normalized" == main || "$normalized" == "$current_branch" ]]; then
            set_classification BLOCK protected-branch-delete
          else
            set_classification REVIEW branch-delete
          fi
          return
        fi
        if [[ "$target" == *:* ]]; then
          local source_ref=${target%%:*}
          normalized=${target##*:}
        else
          local source_ref=$target
          normalized=$target
        fi
        normalized=${normalized#refs/heads/}
        [[ "$normalized" == main ]] && { set_classification BLOCK push-to-main; return; }
        if [[ "$current_branch" != work/* || "$normalized" != "$current_branch" ]]; then
          set_classification BLOCK push-to-other-branch
          return
        fi
        source_ref=${source_ref#refs/heads/}
        if [[ "$source_ref" != HEAD && "$source_ref" != "$current_branch" ]]; then
          set_classification BLOCK push-from-other-source
          return
        fi
      done

      if [[ "$current_branch" == main ]]; then
        set_classification BLOCK push-from-main
      elif [[ "$current_branch" != work/* ]]; then
        set_classification BLOCK push-outside-work-branch
      elif [[ "${#refspecs[@]}" -gt 0 ]]; then
        set_classification ALLOW push-current-work-branch
      else
        local upstream
        upstream=$(git "${global_args[@]}" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
        if [[ "$upstream" == */"$current_branch" ]]; then
          set_classification ALLOW push-current-work-branch
        else
          set_classification REVIEW push-upstream-unverified
        fi
      fi
      ;;
    branch)
      if contains_arg -d "${sub_tail[@]}" || contains_arg -D "${sub_tail[@]}" || contains_arg --delete "${sub_tail[@]}"; then
        for target in "${sub_tail[@]:1}"; do
          [[ "$target" == -* ]] && continue
          normalized=${target#refs/heads/}
          if [[ "$normalized" == main || "$normalized" == "$current_branch" ]]; then
            set_classification BLOCK protected-branch-delete
            return
          fi
        done
        set_classification REVIEW branch-delete
      else
        set_classification REVIEW git-branch-change
      fi
      ;;
    merge)
      [[ "$current_branch" == main ]] && set_classification BLOCK merge-on-main || set_classification REVIEW work-branch-merge
      ;;
    rebase)
      set_classification REVIEW work-branch-rebase
      ;;
    add|commit)
      [[ "$current_branch" == work/* ]] && set_classification ALLOW work-branch-change || set_classification BLOCK change-outside-work-branch
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
      env)
        if [[ "$next" == -S || "$next" == --split-string || "$next" == --split-string=* ]]; then
          set_classification BLOCK split-command-string
          return
        fi
        ;;
      sh|bash|dash|zsh|ksh|fish|ash|csh|tcsh|pwsh|powershell|powershell.exe|cmd|cmd.exe)
        if shell_uses_command_string "$index" "$base" "${argv[@]}"; then
          set_classification BLOCK nested-shell
          return
        fi
        ;;
      python|python[0-9]*|perl|ruby|node|nodejs|php|lua|lua[0-9]*|R|Rscript|groovy)
        if interpreter_uses_command_string "$index" "$base" "${argv[@]}"; then
          set_classification BLOCK interpreter-command-string
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

# Redacted, deterministic evidence: a digest of the normalized argv supports
# later comparison against the exact scope an operator approved, without ever
# persisting raw arguments, reasons, or secrets in the log.
argv_digest=unavailable
if command -v sha256sum >/dev/null 2>&1; then
  argv_digest=$(printf '%s\0' "${command_argv[@]}" | sha256sum | cut -d' ' -f1)
fi
scope_digest=-
[[ -n "$decision_id" ]] && scope_digest=$argv_digest

mkdir -p -- "$log_dir" || { printf 'FAIL cannot create command-gate log directory\n' >&2; exit "$EXIT_USAGE"; }
printf '%s classification=%s category=%s mode=%s command=%s argc=%s decision=%s argv_digest=%s scope_digest=%s redaction=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$CLASSIFICATION" "$CATEGORY" "$mode" \
  "$safe_command" "${#command_argv[@]}" "${safe_decision:--}" "$argv_digest" "$scope_digest" \
  "argv-and-reason-omitted" >> "$log_file"

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
exec_status=$?
printf '%s event=result argv_digest=%s decision=%s exit_code=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$argv_digest" "${safe_decision:--}" "$exec_status" >> "$log_file"
exit "$exec_status"
