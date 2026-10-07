#!/usr/bin/env bash
# Format and publication checks for the ADRs and the estate index.
# Prints one line per problem and exits 1 if it printed anything. Needs only
# bash, grep and sed, so CI runs it on a bare runner.
set -u
cd "$(dirname "$0")/.." || exit 2

# Relative markdown link targets in $1, anchors and external links dropped.
relative_links() {
    grep -oE '\]\([^)]+\)' "$1" | sed -E 's/^\]\(//; s/\)$//; s/[[:space:]].*$//; s/#.*$//' |
        grep -vE '^$|^[a-z]+:' || true
}

# Link targets of the "- **<label>:**" bullet in the header block of $1.
bullet_links() {
    sed -n "1,8p" "$1" | grep -E "^- \*\*$2:\*\*" | grep -oE '\]\([^)#]+' | sed 's/^](//'
}

problems() {
    for f in decisions/*.md; do
        sed -n 1p "$f" | grep -qE '^# ADR-[0-9]{3}: .+' || echo "HEAD $f"
        n=$(basename "$f" | cut -c1-3)
        sed -n 1p "$f" | grep -q "^# ADR-$n: " || echo "NUMBER $f: heading does not match file name"
        sed -n 3p "$f" | grep -qE '^- \*\*Status:\*\* (Proposed|Accepted|Superseded|Deprecated) \([0-9]{4}-[0-9]{2}-[0-9]{2}\)$' || echo "STATUS $f"
        grep '^## ' "$f" | grep -vxE '## (Context|Decision|Alternatives considered|Consequences|References)' | sed "s|^|SECTION $f: |"
        max=120
        case "$f" in *008-*) max=150 ;; esac
        [ "$(wc -l <"$f")" -le "$max" ] || echo "LONG $f (over $max lines)"
        relative_links "$f" | while read -r l; do
            [ -f "decisions/$l" ] || echo "LINK $f -> $l"
        done
        if sed -n 3p "$f" | grep -q 'Superseded'; then
            by=$(bullet_links "$f" 'Superseded by' | head -1)
            if [ -z "$by" ]; then
                echo "SUPERSEDED $f: no Superseded by bullet"
            elif [ ! -f "decisions/$by" ]; then
                echo "SUPERSEDED $f -> $by does not exist"
            fi
        fi
        bullet_links "$f" 'Supersedes' | while read -r old; do
            [ -f "decisions/$old" ] || continue
            sed -n 3p "decisions/$old" | grep -q 'Superseded' || echo "SUPERSEDES $f: decisions/$old is not marked Superseded"
        done
    done
    grep -nE '\*Update|[Oo]perator|Horizon|khe-meta/ROADMAP|ROADMAP\.md`? ?§|§|plans/|house/|`[0-9a-f]{7,40}`|[Ww]ritten down|[0-9]{10,}|192\.168\.' decisions/*.md | sed 's/^/FORBIDDEN /'
    [ -f ESTATE.md ] || echo "MISSING ESTATE.md"
    relative_links ESTATE.md 2>/dev/null | while read -r l; do
        [ -e "$l" ] || echo "LINK ESTATE.md -> $l"
    done
}

out=$(problems)
[ -z "$out" ] && exit 0
printf '%s\n' "$out"
exit 1
