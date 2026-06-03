# paullockett.github.io

Personal research and reports site for Paul Lockett.

**Live URL:** https://paullockett.github.io/

This repo hosts self-published static reports as a small hub site served by GitHub Pages. Each report lives in its own subfolder with an `index.html`, so the URL pattern is:

```
https://paullockett.github.io/<report-slug>/
```

## Reports

| Slug | Title | Date |
| --- | --- | --- |
| `adem-construction-decade` | Alabama Construction Stormwater Permit Analysis: 2009–2026 | 2026-04-28 |

## Adding a new report

1. Create a new folder at the repo root using a kebab-case slug, e.g. `my-new-report/`.
2. Drop the report's HTML inside as `index.html`. Keep any sibling assets (images, CSS, data) next to it inside the same folder.
3. Add a row to the table above and a card to the root `index.html` hub page.
4. Commit and push to `main`. GitHub Pages will redeploy within a minute.

## Local preview

From the repo root:

```
python3 -m http.server 8000
```

Then open http://localhost:8000/ in a browser.

## Publishing

This site is served from the `main` branch root via GitHub Pages. After the initial push, no manual deploy step is needed — every push to `main` triggers a redeploy.
