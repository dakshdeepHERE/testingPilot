# Plant Pals

A small web app that tracks when your houseplants need water. Each plant has a card with a **Happy** or **Thirsty** badge and a **Water now** button.

This repository is the practice project for the course *AI-Assisted GitHub Fundamentals*. You will work on it the way a team works on any project: from an issue, through a branch and a pull request, to a merge, with GitHub Copilot helping at each step.

## Get started

1. **Turn on GitHub Pages** so you can see the app: go to **Settings → Pages** and set **Source** to **GitHub Actions**.
2. **Let the practice scenario set itself up.** A workflow called **Set up practice scenario** runs when you create your copy of this repository. After a minute or two you will see an issue and a pull request. If you don't, open the **Actions** tab, choose **Set up practice scenario**, and click **Run workflow**.
3. Open the **Issues** tab and start with Issue #1.

## How the app decides a plant is thirsty

A plant is **Thirsty** when the number of days since it was last watered is the same as or more than its watering interval. Clicking **Water now** resets the days since watered to 0.

## Care guide

| Plant | Water every |
| --- | --- |
| Spike the Cactus | 14 days |
| Fernando the Fern | 3 days |
| Basil | 2 days |
| Aloe Vera | 10 days |

## Project layout

- `src/index.html` holds the page title.
- `src/app/app.html` holds the page heading and the plant cards.
- `src/app/plants.ts` holds the list of plants.
- `.github/workflows/` holds the automated checks.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
