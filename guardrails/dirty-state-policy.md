# Dirty-state policy

Inspect status and diff before writing. Unknown changes block. Record ownership and base identity
for known dirty files. A file allowed by the current card may still contain another card's work;
that overlap requires separation or an explicit operator decision. Never stage a whole mixed file
when only a bounded patch was reviewed.
