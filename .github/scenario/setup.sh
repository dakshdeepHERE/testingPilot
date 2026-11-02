#!/usr/bin/env bash
# Builds the practice scenario in a learner's copy of the repository:
#   - Issue #1 (the issue the learner completes)
#   - Pull request #2 from a "teammate" with a merge conflict and a failing build
#   - A short commit history on main and a first release
# Every step checks whether it has already happened, so it is safe to run again.
set -euo pipefail

BRANCH="add-aloe-plant"
ISSUE_TITLE='Rename the app to "Plant Pals" and add a tagline'
PLANTS="src/app/plants.ts"

# True when main already has the cactus fix, which means the history step has run.
main_has_fix() {
  [ -n "$(git log origin/main --grep="Fix cactus watering interval" --format=%H -n 1)" ]
}

git config user.name "Plant Pals Bot"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# Issue #1 first, so it gets number 1 and the pull request gets number 2.
if [ -z "$(gh issue list --state all --search "in:title Plant Pals" --json number --jq '.[].number')" ]; then
  gh issue create --title "$ISSUE_TITLE" --body-file .github/scenario/issue-1.md
fi

# The teammate's branch starts from today's main, before the history below is added.
if ! git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1 && ! main_has_fix; then
  git checkout -b "$BRANCH"
  python3 - "$PLANTS" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
text = text.replace("wateringEveryDays: 7, daysSinceWatered: 15", "wateringEveryDays: 10, daysSinceWatered: 15")
aloe = "  { id: 4, name: 'Aloe Vera', emoji: '🪴', wateringEveryDay: 10, daysSinceWatered: 4 },\n"
text = text.replace("];", aloe + "];")
open(path, "w", encoding="utf-8").write(text)
PY
  git commit -am "Add Aloe Vera plant"
  git push origin "$BRANCH"
  git checkout main
fi

# History on main, ending with the cactus fix that conflicts with the teammate's branch.
if ! main_has_fix; then
  python3 - <<'PY'
text = open("README.md", encoding="utf-8").read()
text = text.replace(
    "## Care guide\n",
    "## Care guide\n\nBasil does best on a sunny windowsill.\n",
)
open("README.md", "w", encoding="utf-8").write(text)
PY
  git commit -am "Add a note about basil to the care guide"

  python3 - "$PLANTS" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
text = text.replace("wateringEveryDays: 7, daysSinceWatered: 15", "wateringEveryDays: 14, daysSinceWatered: 15")
open(path, "w", encoding="utf-8").write(text)
PY
  git commit -am "Fix cactus watering interval to match the care guide"
  git push origin main
fi

# Open the teammate's pull request, then run the build on it. Pull requests created
# with the built-in token do not start workflows by themselves, so the run is requested here.
if [ -z "$(gh pr list --state all --head "$BRANCH" --json number --jq '.[].number')" ]; then
  gh pr create --base main --head "$BRANCH" --title "Add an Aloe Vera plant card" --body-file .github/scenario/pr-2.md
  gh workflow run build.yml --ref "$BRANCH"
fi

if ! gh release view v0.1.0 >/dev/null 2>&1; then
  gh release create v0.1.0 --target main --title "v0.1.0 First plants" \
    --notes "The first version of Plant Pals: three plants, a Happy or Thirsty badge on each card, and a Water now button."
fi
