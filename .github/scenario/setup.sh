#!/usr/bin/env bash
# Builds the practice scenario in a learner's copy of the repository:
#   - Issue "Rename the app to Plant Pals": the issue the learner completes
#   - Issue "Add a tab icon": a second small issue the learner can pick up
#   - Issue "Add an Aloe Vera plant", with an open pull request that closes it. The pull request
#     has a merge conflict and a failing build, so the learner repairs it.
#   - Issue "Cactus watering interval...", with a pull request that is already merged. It changed
#     the same line of the same file first, which is why the Aloe pull request conflicts.
#   - A first release
# Every step checks whether it has already happened, so it is safe to run again.
set -euo pipefail

RENAME_TITLE='Rename the app to "Plant Pals"'
FAVICON_TITLE='Add a tab icon for the app'
ALOE_TITLE='Add an Aloe Vera plant'
CACTUS_TITLE="Cactus watering interval doesn't match the care guide"
ALOE_BRANCH="add-aloe-plant"
CACTUS_BRANCH="fix-cactus-interval"
PLANTS="src/app/features/plants/data/plants.ts"
SCENARIO=".github/scenario"
BODIES=$(mktemp -d)

git config user.name "Plant Pals Bot"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# The number of the issue with exactly this title, or nothing.
issue_number() {
  gh issue list --state all --limit 100 --json number,title | python3 -c '
import json, sys
for item in json.load(sys.stdin):
    if item["title"] == sys.argv[1]:
        print(item["number"])
        break
' "$1"
}

# Creates the issue if it does not exist yet, and prints its number.
ensure_issue() {
  local number
  number=$(issue_number "$1")
  if [ -z "$number" ]; then
    number=$(gh issue create --title "$1" --body-file "$2" | grep -o '[0-9]*$')
  fi
  echo "$number"
}

# The number of the pull request opened from this branch, or nothing.
pr_number() {
  gh pr list --state all --head "$1" --json number --jq '.[0].number // empty'
}

# Fills in the issue number that a pull request description closes.
render() {
  sed "s/{{ISSUE}}/$2/g" "$1"
}

# Pushes a branch that makes one edit to the plants file, if the branch does not exist yet.
make_branch() {
  local branch="$1" message="$2"
  git checkout -q main
  git checkout -q -b "$branch"
  python3 - "$PLANTS" "$branch" "$ALOE_BRANCH" <<'PY'
import sys
path, branch, aloe_branch = sys.argv[1:4]
text = open(path, encoding="utf-8").read()
old = "wateringEveryDays: 7, daysSinceWatered: 15"
assert old in text
if branch == aloe_branch:
    # The teammate also changed the cactus interval by accident, and mistyped a field name.
    text = text.replace(old, "wateringEveryDays: 10, daysSinceWatered: 15")
    aloe = "  { id: 4, name: 'Aloe Vera', emoji: '🪴', wateringEveryDay: 10, daysSinceWatered: 4 },\n"
    text = text.replace("];", aloe + "];")
else:
    text = text.replace(old, "wateringEveryDays: 14, daysSinceWatered: 15")
open(path, "w", encoding="utf-8").write(text)
PY
  git commit -q -am "$message"
  git push -q origin "$branch"
  git checkout -q main
}

merge_pr() {
  local attempt
  for attempt in 1 2 3 4 5 6; do
    if gh pr merge "$1" --squash --delete-branch; then
      return 0
    fi
    sleep 5
  done
  return 1
}

# Issues first, so the learner's issue is Issue #1.
RENAME_NUMBER=$(ensure_issue "$RENAME_TITLE" "$SCENARIO/issue-rename.md")
ensure_issue "$FAVICON_TITLE" "$SCENARIO/issue-favicon.md" > /dev/null
ALOE_NUMBER=$(ensure_issue "$ALOE_TITLE" "$SCENARIO/issue-aloe.md")
CACTUS_NUMBER=$(ensure_issue "$CACTUS_TITLE" "$SCENARIO/issue-cactus.md")

# Both branches start from the same main, so the two pull requests change the same line.
ALOE_PR=$(pr_number "$ALOE_BRANCH")
CACTUS_PR=$(pr_number "$CACTUS_BRANCH")

if [ -z "$ALOE_PR" ]; then
  if ! git ls-remote --exit-code --heads origin "$ALOE_BRANCH" >/dev/null 2>&1; then
    make_branch "$ALOE_BRANCH" "Add Aloe Vera plant"
  fi
fi
if [ -z "$CACTUS_PR" ]; then
  make_branch "$CACTUS_BRANCH" "Fix cactus watering interval to match the care guide"
fi

if [ -z "$ALOE_PR" ]; then
  render "$SCENARIO/pr-aloe.md" "$ALOE_NUMBER" > "$BODIES/pr-aloe.md"
  gh pr create --base main --head "$ALOE_BRANCH" --title "Add an Aloe Vera plant card" --body-file "$BODIES/pr-aloe.md"
  ALOE_PR=$(pr_number "$ALOE_BRANCH")
  # Pull requests created with the built-in token do not start workflows by themselves, and a
  # pull request that conflicts never runs its checks, so the build is requested here.
  gh workflow run build.yml --ref "$ALOE_BRANCH"
elif [ "$(gh pr view "$ALOE_PR" --json state --jq .state)" = "OPEN" ]; then
  render "$SCENARIO/pr-aloe.md" "$ALOE_NUMBER" > "$BODIES/pr-aloe.md"
  gh pr edit "$ALOE_PR" --body-file "$BODIES/pr-aloe.md"
fi

if [ -z "$CACTUS_PR" ]; then
  render "$SCENARIO/pr-cactus.md" "$CACTUS_NUMBER" > "$BODIES/pr-cactus.md"
  gh pr create --base main --head "$CACTUS_BRANCH" --title "Fix cactus watering interval to match the care guide" --body-file "$BODIES/pr-cactus.md"
  CACTUS_PR=$(pr_number "$CACTUS_BRANCH")
fi

# Merge the cactus fix now that the Aloe branch has started from the old main. This is what
# makes the Aloe pull request conflict.
if [ "$(gh pr view "$CACTUS_PR" --json state --jq .state)" = "OPEN" ]; then
  merge_pr "$CACTUS_PR"
fi

if ! gh release view v0.1.0 >/dev/null 2>&1; then
  gh release create v0.1.0 --target main --title "v0.1.0 First plants" \
    --notes "The first version of Plant Pals: three plants, a Happy or Thirsty badge on each card, and a Water now button."
fi
