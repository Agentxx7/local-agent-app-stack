# Definition of done

Record each state separately; none implies another.

- Implemented: The scoped change exists. Evidence:
- Tested: Relevant automated checks ran. Evidence:
- Manually verified: Relevant human or runtime checks ran. Evidence:
- Operator accepted: The operator recorded acceptance. Evidence:
- Committed: The exact change is in commit:
- Pushed: That commit is present at remote/ref:
- Promoted to main: Operator-approved work is merged at commit:
- Main verified after promotion: Relevant checks ran on main. Evidence:
- Clean worktree: Repository status was checked after completion. Evidence:
- Released: The accepted commit reached the identified release target. Evidence:

Do not report a later state from an earlier one. Green tests do not establish operator acceptance,
push, promotion, release, or a clean worktree. An agent reports these states but does not grant
operator acceptance.
