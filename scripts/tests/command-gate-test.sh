#!/usr/bin/env bash
set -u

root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd -P) || exit 1
gate="$root/scripts/command-gate.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/command-gate-test.XXXXXX") || exit 1
trap 'find "$test_root" -depth -delete' EXIT
export COMMAND_GATE_LOG_DIR="$test_root/log"

passed=0
failed=0

expect_code() {
  name=$1
  expected=$2
  shift 2
  "$@" >"$test_root/stdout" 2>"$test_root/stderr"
  actual=$?
  if [[ "$actual" -eq "$expected" ]]; then
    printf 'PASS %s\n' "$name"
    passed=$((passed + 1))
  else
    printf 'FAIL %s expected=%s actual=%s\n' "$name" "$expected" "$actual"
    sed -n '1,4p' "$test_root/stderr"
    failed=$((failed + 1))
  fi
}

expect_code_in() {
  name=$1
  expected=$2
  directory=$3
  shift 3
  (
    cd "$directory" || exit 99
    "$@" >"$test_root/stdout" 2>"$test_root/stderr"
  )
  actual=$?
  if [[ "$actual" -eq "$expected" ]]; then
    printf 'PASS %s\n' "$name"
    passed=$((passed + 1))
  else
    printf 'FAIL %s expected=%s actual=%s\n' "$name" "$expected" "$actual"
    sed -n '1,4p' "$test_root/stderr"
    failed=$((failed + 1))
  fi
}

git_fixture="$test_root/git-fixture"
mkdir -p "$git_fixture"
git -C "$git_fixture" init -q -b main
git -C "$git_fixture" config user.name 'Command Gate Test'
git -C "$git_fixture" config user.email 'command-gate@example.invalid'
git -C "$git_fixture" commit -q --allow-empty -m baseline
git -C "$git_fixture" branch inactive
git -C "$git_fixture" switch -q -c work/TEST-CARD
git init -q --bare "$test_root/local-remote.git"
git -C "$git_fixture" remote add origin "$test_root/local-remote.git"
git -C "$git_fixture" push -q -u origin work/TEST-CARD

expect_code allow-git-status 0 bash "$gate" --check-only -- git status
expect_code allow-git-diff 0 bash "$gate" --check-only -- git diff --check
expect_code allow-git-check-ignore 0 bash "$gate" --check-only -- git check-ignore .local/command-gate.log
expect_code allow-structure-check 0 bash "$gate" --check-only -- bash scripts/verify-structure.sh --template
expect_code allow-operating-check 0 bash "$gate" --check-only -- bash scripts/verify-operating-model.sh
expect_code allow-gate-syntax-check 0 bash "$gate" --check-only -- bash -n scripts/command-gate.sh
expect_code allow-check-only-does-not-run 0 bash "$gate" --check-only -- printf 'CHECK_ONLY_SENTINEL\n'
if [[ -s "$test_root/stdout" ]]; then
  printf 'FAIL ALLOW check-only executed command\n'
  failed=$((failed + 1))
else
  printf 'PASS ALLOW check-only does not execute\n'
  passed=$((passed + 1))
fi

expect_code review-recursive-project-delete 20 bash "$gate" --check-only -- rm -r build
expect_code review-branch-delete 20 bash "$gate" --check-only -- git branch -d topic
expect_code review-pkill 20 bash "$gate" --check-only -- pkill worker
expect_code review-package-remove 20 bash "$gate" --check-only -- sudo apt remove package-name

expect_code block-root-delete 30 bash "$gate" --check-only -- rm -rf /
expect_code block-reset-hard 30 bash "$gate" --check-only -- git reset --hard
expect_code block-clean 30 bash "$gate" --check-only -- git clean -fdx
expect_code block-broad-checkout 30 bash "$gate" --check-only -- git checkout -- .
expect_code block-broad-restore 30 bash "$gate" --check-only -- git restore .
expect_code block-force-push 30 bash "$gate" --check-only -- git push --force origin main
expect_code block-force-with-lease 30 bash "$gate" --check-only -- git push --force-with-lease origin main
expect_code block-force-with-lease-scope 30 bash "$gate" --check-only -- git push --force-with-lease=main origin main
expect_code_in block-force-refspec 30 "$git_fixture" bash "$gate" --check-only -- git push origin +HEAD:main
expect_code_in block-force-refspec-work 30 "$git_fixture" bash "$gate" --check-only -- git push origin +HEAD:work/test
expect_code_in block-force-refspec-full 30 "$git_fixture" bash "$gate" --check-only -- git push origin +refs/heads/x:refs/heads/y
expect_code_in block-push-main 30 "$git_fixture" bash "$gate" --check-only -- git push origin main
expect_code_in block-push-head-main 30 "$git_fixture" bash "$gate" --check-only -- git push origin HEAD:main
expect_code_in block-push-head-full-main 30 "$git_fixture" bash "$gate" --check-only -- git push origin HEAD:refs/heads/main
expect_code_in block-push-other-work 30 "$git_fixture" bash "$gate" --check-only -- git push origin HEAD:work/OTHER-CARD
expect_code_in block-push-foreign-source 30 "$git_fixture" bash "$gate" --check-only -- git push origin main:work/TEST-CARD
expect_code_in block-push-all 30 "$git_fixture" bash "$gate" --check-only -- git push origin --all
expect_code_in block-push-mirror 30 "$git_fixture" bash "$gate" --check-only -- git push origin --mirror
expect_code_in block-push-tags 30 "$git_fixture" bash "$gate" --check-only -- git push origin --tags
expect_code_in block-push-prune 30 "$git_fixture" bash "$gate" --check-only -- git push origin --prune
expect_code_in allow-current-work-push 0 "$git_fixture" bash "$gate" --check-only -- git push origin work/TEST-CARD
expect_code_in allow-current-work-push-refspec 0 "$git_fixture" bash "$gate" --check-only -- git push origin HEAD:work/TEST-CARD
expect_code_in allow-plain-current-work-push 0 "$git_fixture" bash "$gate" --check-only -- git push
expect_code_in allow-current-work-commit 0 "$git_fixture" bash "$gate" --check-only -- git commit -m change
expect_code_in review-work-merge 20 "$git_fixture" bash "$gate" --check-only -- git merge inactive
expect_code_in review-work-rebase 20 "$git_fixture" bash "$gate" --check-only -- git rebase inactive
expect_code_in block-delete-current-branch 30 "$git_fixture" bash "$gate" --check-only -- git branch -D work/TEST-CARD
expect_code_in review-delete-inactive-branch 20 "$git_fixture" bash "$gate" --check-only -- git branch -D inactive
expect_code_in block-remote-delete-current 30 "$git_fixture" bash "$gate" --check-only -- git push origin --delete work/TEST-CARD
expect_code_in block-remote-delete-main 30 "$git_fixture" bash "$gate" --check-only -- git push origin --delete main
expect_code_in block-short-delete-current 30 "$git_fixture" bash "$gate" --check-only -- git push -d origin work/TEST-CARD
expect_code_in block-short-delete-current-after-remote 30 "$git_fixture" bash "$gate" --check-only -- git push origin -d work/TEST-CARD
expect_code_in block-delete-equals-current 30 "$git_fixture" bash "$gate" --check-only -- git push origin --delete=work/TEST-CARD
expect_code_in block-short-delete-main 30 "$git_fixture" bash "$gate" --check-only -- git push -d origin main
expect_code_in block-delete-equals-main 30 "$git_fixture" bash "$gate" --check-only -- git push origin --delete=refs/heads/main
expect_code_in block-delete-main-refspec 30 "$git_fixture" bash "$gate" --check-only -- git push origin :main
expect_code_in block-delete-current-refspec 30 "$git_fixture" bash "$gate" --check-only -- git push origin :work/TEST-CARD
expect_code_in block-delete-current-full-refspec 30 "$git_fixture" bash "$gate" --check-only -- git push origin :refs/heads/work/TEST-CARD
expect_code_in block-delete-main-full-refspec 30 "$git_fixture" bash "$gate" --check-only -- git push origin :refs/heads/main
expect_code_in review-delete-inactive-remote 20 "$git_fixture" bash "$gate" --check-only -- git push -d origin inactive
expect_code_in block-cluster-vd-current 30 "$git_fixture" bash "$gate" --check-only -- git push -vd origin work/TEST-CARD
expect_code_in block-cluster-dv-current 30 "$git_fixture" bash "$gate" --check-only -- git push -dv origin work/TEST-CARD
expect_code_in block-cluster-vd-main 30 "$git_fixture" bash "$gate" --check-only -- git push -vd origin main
expect_code_in review-cluster-dv-inactive 20 "$git_fixture" bash "$gate" --check-only -- git push -dv origin inactive
expect_code block-nested-shell 30 bash "$gate" --check-only -- bash -c 'printf bypass'
expect_code block-equivalent-shell 30 bash "$gate" --check-only -- sh -c 'printf bypass'
expect_code block-delayed-shell-option 30 bash "$gate" --check-only -- bash --noprofile -c 'printf bypass'
expect_code block-ash 30 bash "$gate" --check-only -- ash -c 'printf bypass'
expect_code block-csh 30 bash "$gate" --check-only -- csh -c 'printf bypass'
expect_code block-tcsh 30 bash "$gate" --check-only -- /bin/tcsh -c 'printf bypass'
expect_code block-pwsh-command 30 bash "$gate" --check-only -- pwsh -Command 'Write-Output bypass'
expect_code block-powershell-encoded 30 bash "$gate" --check-only -- powershell -EncodedCommand payload
expect_code block-powershell-exe 30 bash "$gate" --check-only -- /tool/powershell.exe -Command payload
expect_code block-cmd-c 30 bash "$gate" --check-only -- cmd /c 'echo bypass'
expect_code block-cmd-exe-k 30 bash "$gate" --check-only -- /tool/cmd.exe /k 'echo bypass'
expect_code block-env-shell 30 bash "$gate" --check-only -- env ash -c 'printf bypass'
expect_code block-env-split-string 30 bash "$gate" --check-only -- env -S 'ash -c printf-bypass'
expect_code block-busybox-shell 30 bash "$gate" --check-only -- busybox ash -c 'printf bypass'
expect_code block-python-command 30 bash "$gate" --check-only -- python -c 'print(1)'
expect_code block-python3-command 30 bash "$gate" --check-only -- /usr/bin/python3 -c 'print(1)'
expect_code block-perl-command 30 bash "$gate" --check-only -- perl -e 'print 1'
expect_code block-ruby-command 30 bash "$gate" --check-only -- ruby -e 'puts 1'
expect_code block-node-command 30 bash "$gate" --check-only -- node -e 'console.log(1)'
expect_code block-node-eval 30 bash "$gate" --check-only -- env nodejs --eval 'console.log(1)'
expect_code block-php-command 30 bash "$gate" --check-only -- php -r 'echo 1;'
expect_code block-lua-command 30 bash "$gate" --check-only -- lua5.4 -e 'print(1)'
expect_code block-r-command 30 bash "$gate" --check-only -- R -e 'print(1)'
expect_code block-rscript-command 30 bash "$gate" --check-only -- Rscript -e 'print(1)'
expect_code block-groovy-command 30 bash "$gate" --check-only -- groovy -e 'println 1'
expect_code review-python-script 20 bash "$gate" --check-only -- python script.py
expect_code review-node-script 20 bash "$gate" --check-only -- node script.js
expect_code review-python-script-c-argument 20 bash "$gate" --check-only -- python3 script.py -c config.toml
expect_code review-perl-script-e-argument 20 bash "$gate" --check-only -- perl script.pl -e value
expect_code review-php-script-r-argument 20 bash "$gate" --check-only -- php script.php -r value
expect_code review-python-double-dash-script 20 bash "$gate" --check-only -- python3 -- script.py -c config.toml
expect_code block-format 30 bash "$gate" --check-only -- mkfs /dev/example
expect_code block-dd-output 30 bash "$gate" --check-only -- dd if=/dev/zero of=/dev/example
expect_code block-shutdown 30 bash "$gate" --check-only -- shutdown now
expect_code block-docker-prune 30 bash "$gate" --check-only -- docker system prune -a
expect_code block-podman-prune 30 bash "$gate" --check-only -- podman system prune
expect_code block-namespace-delete 30 bash "$gate" --check-only -- kubectl delete namespace example
expect_code block-terraform-destroy 30 bash "$gate" --check-only -- terraform destroy
expect_code block-drop-database 30 bash "$gate" --check-only -- psql -c 'DROP DATABASE example'
expect_code block-drop-table 30 bash "$gate" --check-only -- psql -c 'DROP TABLE records'

git -C "$git_fixture" switch -q main
expect_code_in block-plain-push-on-main 30 "$git_fixture" bash "$gate" --check-only -- git push
expect_code_in block-merge-on-main 30 "$git_fixture" bash "$gate" --check-only -- git merge inactive
expect_code_in block-delete-main 30 "$git_fixture" bash "$gate" --check-only -- git branch -D main
expect_code_in block-commit-on-main 30 "$git_fixture" bash "$gate" --check-only -- git commit -m forbidden
git -C "$git_fixture" switch -q work/TEST-CARD

approval_sentinel="$test_root/approval-block-sentinel"
expect_code block-despite-approval 30 bash "$gate" --operator-approved TEST-BLOCK-DECISION --reason 'must remain blocked' -- ash -c "touch $approval_sentinel"
expect_code_in block-delete-despite-approval 30 "$git_fixture" bash "$gate" --operator-approved TEST-DELETE-DECISION --reason 'must remain blocked' -- git push -d origin work/TEST-CARD
expect_code block-interpreter-despite-approval 30 bash "$gate" --operator-approved TEST-INTERPRETER-DECISION --reason 'must remain blocked' -- perl -e 'exit 0'
if [[ -e "$approval_sentinel" ]]; then
  printf 'FAIL approval bypassed BLOCK\n'
  failed=$((failed + 1))
else
  printf 'PASS BLOCK survives approval metadata\n'
  passed=$((passed + 1))
fi

block_sentinel="$test_root/block-sentinel"
expect_code block-never-executes 30 bash "$gate" -- bash -c "touch $block_sentinel"
if [[ -e "$block_sentinel" ]]; then
  printf 'FAIL BLOCK command executed\n'
  failed=$((failed + 1))
else
  printf 'PASS BLOCK never executes\n'
  passed=$((passed + 1))
fi

expect_code review-unknown 20 bash "$gate" --check-only -- unknown-command argument
expect_code review-without-decision 20 bash "$gate" -- rm -r "$test_root/nonexistent"
mkdir -p "$test_root/review-preserved"
expect_code review-without-decision-preserves-state 20 bash "$gate" -- rm -r "$test_root/review-preserved"
if [[ -d "$test_root/review-preserved" ]]; then
  printf 'PASS REVIEW without decision does not execute\n'
  passed=$((passed + 1))
else
  printf 'FAIL REVIEW without decision executed\n'
  failed=$((failed + 1))
fi

mkdir -p "$test_root/removable"
expect_code review-approved 0 bash "$gate" --operator-approved TEST-DECISION-1 --reason 'isolated test cleanup' -- rm -r "$test_root/removable"
if [[ -e "$test_root/removable" ]]; then
  printf 'FAIL approved REVIEW did not execute\n'
  failed=$((failed + 1))
else
  printf 'PASS approved REVIEW executes argv\n'
  passed=$((passed + 1))
fi

secret='TEST_SECRET_DO_NOT_LOG_7f31'
bash "$gate" --operator-approved TEST-DECISION-2 --reason 'secret redaction test' -- printf '%s\n' "$secret" >"$test_root/secret-output" 2>"$test_root/secret-error"
if [[ "$(sed -n '1p' "$test_root/secret-output")" == "$secret" ]]; then
  printf 'PASS ALLOW executes unchanged argv\n'
  passed=$((passed + 1))
else
  printf 'FAIL ALLOW argv changed\n'
  failed=$((failed + 1))
fi
if grep -R -Fq -- "$secret" "$COMMAND_GATE_LOG_DIR"; then
  printf 'FAIL log contains test secret\n'
  failed=$((failed + 1))
else
  printf 'PASS log redacts command arguments\n'
  passed=$((passed + 1))
fi

if grep -Eq '(^|[^[:alnum:]_])eval[[:space:]]' "$gate"; then
  printf 'FAIL executable eval found\n'
  failed=$((failed + 1))
else
  printf 'PASS no executable eval\n'
  passed=$((passed + 1))
fi

candidate_code_is() {
  candidate=$1
  expected=$2
  shift 2
  bash "$candidate" "$@" >"$test_root/mutation-stdout" 2>"$test_root/mutation-stderr"
  [[ "$?" -eq "$expected" ]]
}

candidate_code_is_in() {
  candidate=$1
  expected=$2
  directory=$3
  shift 3
  (
    cd "$directory" || exit 99
    bash "$candidate" "$@" >"$test_root/mutation-stdout" 2>"$test_root/mutation-stderr"
  )
  [[ "$?" -eq "$expected" ]]
}

candidate_has_no_eval() {
  ! grep -Eq '(^|[^[:alnum:]_])eval[[:space:]]' "$1"
}

candidate_log_has_no_secret() {
  ! grep -R -Fq -- "$1" "$2"
}

mutation_caught() {
  name=$1
  shift
  if "$@"; then
    printf 'FAIL mutation survived: %s\n' "$name"
    failed=$((failed + 1))
  else
    printf 'PASS mutation caught: %s\n' "$name"
    passed=$((passed + 1))
  fi
}

fresh_mutant() {
  mutant="$test_root/mutated-gate.sh"
  cp "$gate" "$mutant"
}

fresh_mutant
sed -i 's/set_classification BLOCK git-reset-hard/set_classification ALLOW git-reset-hard/' "$mutant"
mutation_caught block-changed-to-allow candidate_code_is "$mutant" 30 --check-only -- git reset --hard

fresh_mutant
sed -i 's/if \[\[ "$mode" == check-only || -z "$decision_id" || -z "$reason" \]\]; then/if [[ "$mode" == check-only ]]; then/' "$mutant"
mutation_caught review-without-decision candidate_code_is "$mutant" 20 -- rm -r "$test_root/nonexistent-mutant"

fresh_mutant
printf '\neval "$*"\n' >> "$mutant"
mutation_caught executable-eval candidate_has_no_eval "$mutant"

fresh_mutant
sed -i 's/set_classification BLOCK nested-shell/set_classification ALLOW nested-shell/' "$mutant"
mutation_caught nested-shell-allowed candidate_code_is "$mutant" 30 --check-only -- bash -c 'printf bypass'

fresh_mutant
sed -i 's/set_classification REVIEW unknown-or-ambiguous/set_classification ALLOW unknown-or-ambiguous/g' "$mutant"
mutation_caught unknown-changed-to-allow candidate_code_is "$mutant" 20 --check-only -- unknown-command argument

fresh_mutant
sed -i '/^printf '\''%s classification=/i printf '\''args=%s\\n'\'' "${command_argv[*]}" >> "$log_file"' "$mutant"
mutant_log="$test_root/mutant-log"
COMMAND_GATE_LOG_DIR="$mutant_log" bash "$mutant" -- printf '%s\n' "$secret" >"$test_root/mutant-secret-output" 2>"$test_root/mutant-secret-error"
mutation_caught secret-written-to-log candidate_log_has_no_secret "$secret" "$mutant_log"

fresh_mutant
sed -i 's/+\*) set_classification BLOCK git-force-push/+*) set_classification REVIEW git-force-push/' "$mutant"
mutation_caught force-refspec-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push origin +HEAD:main

fresh_mutant
sed -i 's/set_classification BLOCK push-to-main/set_classification REVIEW push-to-main/' "$mutant"
mutation_caught push-to-main-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push origin HEAD:main

git -C "$git_fixture" switch -q main
fresh_mutant
sed -i 's/set_classification BLOCK merge-on-main/set_classification REVIEW merge-on-main/' "$mutant"
mutation_caught merge-on-main-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git merge inactive
git -C "$git_fixture" switch -q work/TEST-CARD

fresh_mutant
sed -i 's/set_classification BLOCK protected-branch-delete/set_classification REVIEW protected-branch-delete/g' "$mutant"
mutation_caught current-branch-delete-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git branch -D work/TEST-CARD

fresh_mutant
sed -i 's/|ash//g' "$mutant"
mutation_caught alternative-shell-protection candidate_code_is "$mutant" 30 --check-only -- ash -c 'printf bypass'

fresh_mutant
sed -i 's/-d|--delete) delete_mode=1/--delete) delete_mode=1/' "$mutant"
mutation_caught short-delete-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push -d origin work/TEST-CARD

fresh_mutant
sed -i 's/-d|--delete) delete_mode=1/-d) delete_mode=1/' "$mutant"
mutation_caught long-delete-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push origin --delete work/TEST-CARD

fresh_mutant
sed -i 's/--delete=\*)/--delete-disabled=*)/g' "$mutant"
mutation_caught delete-equals-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push origin --delete=work/TEST-CARD

fresh_mutant
sed -i '/if \[\[ "$target" == :\* \]\]; then/i\        [[ "$target" == :* ]] \&\& target="HEAD:${target#:}"' "$mutant"
mutation_caught delete-refspec-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push origin :work/TEST-CARD

fresh_mutant
sed -i 's/if \[\[ "$normalized" == main || "$normalized" == "$current_branch" \]\]; then/if [[ "$normalized" == main ]]; then/' "$mutant"
mutation_caught delete-current-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push -d origin work/TEST-CARD

fresh_mutant
sed -i 's/if \[\[ "$normalized" == main || "$normalized" == "$current_branch" \]\]; then/if [[ "$normalized" == "$current_branch" ]]; then/' "$mutant"
mutation_caught delete-main-protection candidate_code_is_in "$mutant" 30 "$git_fixture" --check-only -- git push -d origin main

fresh_mutant
sed -i 's/set_classification BLOCK interpreter-command-string/set_classification REVIEW interpreter-command-string/' "$mutant"
mutation_caught interpreter-c-protection candidate_code_is "$mutant" 30 --check-only -- python3 -c 'print(1)'
mutation_caught interpreter-e-protection candidate_code_is "$mutant" 30 --check-only -- perl -e 'print 1'
mutation_caught interpreter-r-protection candidate_code_is "$mutant" 30 --check-only -- php -r 'echo 1;'
mutation_caught interpreter-eval-protection candidate_code_is "$mutant" 30 --check-only -- node --eval 'console.log(1)'

fresh_mutant
sed -i 's/^  BLOCK)$/  BLOCK-disabled)/' "$mutant"
mutation_caught block-survives-approval candidate_code_is "$mutant" 30 --operator-approved MUTANT-DECISION --reason 'must not bypass' -- bash -c true

printf 'RESULT passed=%s failed=%s\n' "$passed" "$failed"
[[ "$failed" -eq 0 ]]
