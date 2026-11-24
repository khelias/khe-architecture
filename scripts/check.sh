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

# metrics/agent-loop.json, written by the weekly refresh (ADR-044): exactly the keys
# khe-sites reads, in the order khe-workspace scripts/agent-metrics.sh --json
# writes them (listed in a comment there): since, until, plans, planReview,
# planCheck, codeReview, securityReview, operator, push, pushedPlans,
# revertedPlans, planToPush; whole counts.
# The whole file, whitespace removed, has to match one pattern.
metrics() {
    f=metrics/agent-loop.json
    [ -f "$f" ] || { echo "MISSING $f"; return; }
    n='(0|[1-9][0-9]*)'
    d='"[0-9]{4}-[0-9]{2}-[0-9]{2}"'
    c="\\{\"acted\":$n,\"dropped\":$n,\"notRun\":$n,\"pending\":$n\\}"
    shape="^\\{\"since\":$d,\"until\":$d,\"plans\":$n,\"planReview\":$c,\"planCheck\":$c,\"codeReview\":$c,\"securityReview\":$c,"
    shape="$shape\"operator\":\\{\"acted\":$n,\"notRun\":$n,\"pending\":$n\\},"
    shape="$shape\"push\":\\{\"unchanged\":$n,\"changed\":$n,\"discarded\":$n,\"pending\":$n\\},"
    shape="$shape\"pushedPlans\":$n,\"revertedPlans\":$n,\"planToPush\":\\{\"count\":$n,\"medianMinutes\":$n\\}\\}$"
    sed -n 'H;${x;s/[[:space:]]//g;p;}' "$f" | grep -qE "$shape" ||
        echo "METRICS $f: not the keys khe-workspace agent-metrics.sh --json writes, in its order, with whole counts"
}

problems() {
    for f in decisions/*.md; do
        sed -n 1p "$f" | grep -qE '^# ADR-[0-9]{3}: .+' || echo "HEAD $f"
        n=$(basename "$f" | cut -c1-3)
        sed -n 1p "$f" | grep -q "^# ADR-$n: " || echo "NUMBER $f: heading does not match file name"
        status=$(sed -n 3p "$f")
        printf '%s\n' "$status" | grep -qE '^- \*\*Status:\*\* (Proposed|Accepted|Superseded|Moved|Deprecated) \([0-9]{4}-[0-9]{2}-[0-9]{2}\)$' || echo "STATUS $f"
        [ "$(wc -l <"$f")" -le 90 ] || echo "LONG $f (over 90 lines)"
        relative_links "$f" | while read -r l; do
            case "$l" in /* | ../../*) echo "LINK $f -> $l (outside the repo)" ;; esac
            [ -f "decisions/$l" ] || echo "LINK $f -> $l"
        done
        case "$status" in *Moved* | *Deprecated*) ;; *)
            sed -n 1,8p "$f" | grep -q '^- \*\*Moved to:\*\*' && echo "STATUS $f: a Moved to bullet needs Moved or Deprecated" ;;
        esac
        case "$status" in
        *Superseded* | *Moved* | *Deprecated*)
            sed -n '2,$p' "$f" | grep -qvE '^(- \*\*[A-Za-z ]+:\*\* .+)?$' && echo "STUB $f: a stub has no body"
            case "$status" in
            *Superseded*)
                by=$(bullet_links "$f" 'Superseded by' | head -1)
                if [ -z "$by" ]; then
                    echo "SUPERSEDED $f: no Superseded by link"
                elif [ ! -f "decisions/$by" ]; then
                    echo "SUPERSEDED $f -> $by does not exist"
                fi
                ;;
            *)
                sed -n 1,8p "$f" | grep -qE '^- \*\*(Superseded by|Moved to):\*\* .' ||
                    echo "STUB $f: no Superseded by or Moved to bullet"
                ;;
            esac
            ;;
        *)
            grep -q '^## ' "$f" || echo "SECTION $f: no sections"
            grep '^## ' "$f" | grep -vxE '## (Context|Decision|Alternatives considered|Consequences|References)' | sed "s|^|SECTION $f: |"
            ;;
        esac
        bullet_links "$f" 'Supersedes' | while read -r old; do
            [ -f "decisions/$old" ] || continue
            sed -n 3p "decisions/$old" | grep -q 'Superseded' || echo "SUPERSEDES $f: decisions/$old is not marked Superseded"
        done
    done
    grep -nE '\*Update|[Oo]perator|Horizon|khe-meta/ROADMAP|ROADMAP\.md`? ?§|§|plans/|house/|`[0-9a-f]{7,40}`|[Ww]ritten down|[0-9]{10,}|192\.168\.' decisions/*.md | sed 's/^/FORBIDDEN /'
    metrics
    [ -f ESTATE.md ] || echo "MISSING ESTATE.md"
    relative_links ESTATE.md 2>/dev/null | while read -r l; do
        case "$l" in /* | ../*) echo "LINK ESTATE.md -> $l (outside the repo)" ;; esac
        [ -e "$l" ] || echo "LINK ESTATE.md -> $l"
    done
}

out=$(problems)
[ -z "$out" ] && exit 0
printf '%s\n' "$out"
exit 1
