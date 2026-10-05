# The published website

This directory builds the public site from the handbook in this repository. It is deliberately boring: **no frameworks, no bundler, no third-party JavaScript, no
external fonts, and no network access at build time.** Node's standard library is the normal build toolchain. Diagram regeneration is a separate local Chromium/Mermaid step; committed SVGs need no browser-side library.

## Layout

| Path | What it is |
|---|---|
| `build.mjs` | The generator: reads `README.md` and `docs/*.md`, renders the story pages, writes assets, indexes, sitemap and robots, then runs the sanitisation gate. |
| `lib/md.mjs` | A small Markdown subset renderer (headings, lists, tables, blockquotes, code fences, inline code/emphasis/links). |
| `lib/render.mjs` | The HTML layout, navigation and shared fragments. |
| `lib/png.mjs` | A dependency-free PNG encoder plus a 5x7 bitmap font, used for the favicon, the Apple touch icon and the Open Graph card. |
| `content/*.md` | The curated **story** layer, with YAML front matter for the hero and metadata. |
| `assets/` | Hand-written CSS and vanilla JS copied verbatim into the build. |
| `dist/` | Build output (the published tree). Not committed. |

Two layers, one source of truth: the **story** pages are curated prose that links to the **reference**
layer, and the reference layer is generated from the existing handbook markdown. Facts are never
duplicated by hand where a link will do.

## Configuration

The public origin is injected at build time so this repository contains no real hostname:

```sh
SITE_URL=<public-origin> node site/build.mjs
```

Without it, the build falls back to a reserved, non-resolvable example origin. That is fine for
looking at layout locally, but **wrong for a real deploy** - a build that shipped the fallback once
published `lab-handbook.invalid` in every page's canonical/OG/Twitter URLs, in `robots.txt` and in
`sitemap.xml` (observed live 2026-10-02). The placeholder gate therefore **refuses** the fallback
host (exit 2); for a deliberate local layout build, opt in explicitly:

```sh
ALLOW_PLACEHOLDER_ORIGIN=1 node site/build.mjs
```

In CI the value comes from the repository variable `SITE_URL` (set it under Settings -> Actions ->
Variables); it is not a secret.

## Build

```sh
SITE_URL=<public-origin> node site/build.mjs
```

Output goes to `site/dist/`. The build **fails** (exit 2) if the sanitisation gate finds an IP address,
a private hostname, a non-public subdomain, key material or a token shape in the content, the assets,
or the generated output. Nothing is published from a failing build.

Gates run in order and each one fails the build closed with its own exit code: sanitisation (exit 2),
accessibility - WCAG 2.2 AA structure and contrast (exit 3), internal-link - no unrewritten relative
Markdown href survives (exit 4), **link-target** (exit 5) - every internal href must resolve to a
generated page and, when it carries a `#fragment`, to an anchor that exists in that page, so a
hand-written link to a renamed page or a mistyped anchor cannot ship as a 404 - and **asset-target**
(exit 6) - every internal `src`/`poster`/`srcset` must resolve to a generated file, so a renamed or
deleted image, script or audio file cannot ship as a broken resource - and **title** (exit 7) -
every generated page must carry a unique `<title>` (reference pages are titled `Handbook: <H1>` so
they can never collide with a story page of the same name), because two pages sharing a title
defeats bookmarks and screen-reader identification (WCAG 2.4.2) and reads to search engines as
duplicate content.

Pages are written into a staging tree (`site/dist.tmp/`) and every gate runs against it; only a
build that passes **all** gates is renamed over `site/dist/`. So a failed build leaves the previous
`site/dist/` untouched (never a half-gated tree), and a deploy that ignores the exit code cannot
ship a build that failed a gate.

Preview locally:

```sh
cd site/dist && python3 -m http.server 8099
```

## Deploy

Automatic: pushing to `main` runs `.github/workflows/site-deploy.yml`, which builds the site and
rsyncs `site/dist/` to the edge host over SSH using a **dedicated, restricted deploy key**.

Required repository secrets:

| Secret | Value |
|---|---|
| `EDGE_DEPLOY_KEY` | The private half of the deploy keypair. The public half is installed on the edge in a restricted `authorized_keys` entry. |
| `EDGE_HOST` | The edge host address. |
| `EDGE_USER` | The unprivileged deploy account on the edge. |

The deploy account has **no sudo**, is not the owner of anything else on the host, and its key entry
is pinned with `command="rrsync -wo <webroot>"` plus `no-port-forwarding`, `no-agent-forwarding`,
`no-pty`, `no-user-rc` and `no-X11-forwarding`. The worst a stolen deploy key can do is rewrite the
static site - it cannot open a shell, forward a port or reach anything else on the host.

Manual (what was done for the first deploy):

```sh
SITE_URL=<public-origin> node site/build.mjs && \   # the build refuses to emit the fallback origin
rsync -rlt --delete --chmod=D755,F644 -e "ssh -i ~/.ssh/lab-site-deploy -o IdentitiesOnly=yes" \
  site/dist/ <user>@<edge-host>:/
```

## Verifying a deploy

A 200 is not proof. Check the content:

```sh
BASE=https://<your-public-origin>
curl -sS -o /dev/null -w '%{http_code}\n' "$BASE/"
curl -sS "$BASE/" | grep -o '<title>[^<]*</title>'
curl -sS -o /dev/null -w 'deep %{http_code}\n' "$BASE/lessons/"
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "http://${BASE#https://}/"
```

## What the edge needs (first-deploy notes)

These are the one-time, hand-made changes on the edge host. They are deliberately small and
reversible; nothing else about the edge is touched.

| Piece | Value / action |
|---|---|
| Web root | `/var/www/lab-handbook`, owned by the deploy account, mode `755` (world-readable so the web server can serve it) |
| Deploy account | `labdeploy` - unprivileged, **no sudo**, shell for rsync only |
| Deploy key | A dedicated keypair; the public half is installed in the account's `authorized_keys` behind `command="rrsync -wo /var/www/lab-handbook"` plus `no-port-forwarding,no-agent-forwarding,no-pty,no-user-rc,no-X11-forwarding` |
| SSH admission | The host's hardening drop-in sets `AllowUsers`; the deploy account must be **added to that list** or sshd refuses it before it ever reads the key (`Permission denied (publickey)`, which looks like a bad key and is not) |
| Web server | One additive site block: `root * /var/www/lab-handbook`, `try_files {path} {path}/index.html`, `file_server`, and `handle_errors` rewriting to `/404.html`. Validate and **reload** - never restart, which would drop every other published site |

Prove the restriction rather than assuming it:

```sh
ssh -i <deploy-key> <deploy-user>@<edge> true   # must be REFUSED by rrsync
rsync -rlt --delete --chmod=D755,F644 -e "ssh -i <deploy-key>" site/dist/ <deploy-user>@<edge>:/
```

If a deploy has to happen before the restricted account exists, stream a tarball over an
administrative session and fix ownership afterwards:

```sh
tar czf - -C site/dist . | ssh <admin>@<edge> \
  'sudo rm -rf /var/www/lab-handbook && sudo mkdir -p /var/www/lab-handbook && \
   sudo tar xzf - -C /var/www/lab-handbook && sudo chmod -R a+rX /var/www/lab-handbook'
```

## Enabling the GitHub Actions deploy

The workflow is committed but idle until these exist on the repository:

| Setting | Kind | Value |
|---|---|---|
| `SITE_URL` | variable | The public origin, e.g. `https://<public-origin>` |
| `EDGE_HOST` | secret | The edge host address |
| `EDGE_USER` | secret | `labdeploy` |
| `EDGE_DEPLOY_KEY` | secret | The private half of the deploy keypair |

The private key is a secret to be added by the operator; it is never committed and never printed.


### Default appearance and request form (2026-10-05)

New visitors receive the **dark** palette (operator revision, 2026-10-05), rendered on the HTML element before
JavaScript runs. The Theme button still switches palettes and honours an explicitly saved choice.
The request form validates minimum lengths, prepares a fresh proof-of-work challenge on every
submission, prevents duplicate in-flight submissions, and displays the API error without discarding
entered text. Backend acceptance places requests in the private moderation queue, never the public backlog.


### Governance and visible diagrams

`/governance/` groups authority, safety, constraints, security, privacy, accessibility, agent reviews,
requests and known issues. Child pages keep their existing URLs and gain a Governance breadcrumb.
The top-level Governance menu is usable on desktop and within the mobile menu.

Mermaid fences render as committed, source-hashed SVG assets in `assets/diagrams/`, with expandable
source and a full-size link. The normal build fails if an edited diagram has no matching SVG.
Diagrams have their own high-contrast white canvas in every theme; wide figures scroll within the
panel rather than shrinking labels until they are unreadable. The hand-drawn architecture SVG keeps
an explicit dark canvas and brighter connectors. The dark-text logo gets a light canvas.

To regenerate after changing a Mermaid fence, run `scripts/render-diagrams.cjs` with
`MERMAID_BUNDLE` set to the local standalone Mermaid bundle and `PLAYWRIGHT_MODULE` to the installed
playwright-core package. `CHROMIUM_PATH` can select a local Chromium executable. The script verifies
the bundle SHA-256 recorded in `site/diagrams.json`, renders locally in strict mode, and rejects
scripts, event handlers, foreign objects and external asset references. No remote rendering or
cloud-generated media is involved; assets credit the local renderer, not an image model.
The renderer uses Mermaid's strict-mode API and generates standalone SVGs.
