# The published website

This directory builds the public site at <https://lab.steveromine.com/> from the handbook in this
repository. It is deliberately boring: **no frameworks, no bundler, no third-party JavaScript, no
external fonts, and no network access at build time.** Node's standard library is the whole toolchain.

## Layout

| Path | What it is |
|---|---|
| `build.mjs` | The generator: reads `README.md` and `docs/*.md`, renders the story pages, writes assets, indexes, sitemap and robots, then runs the sanitisation gate. |
| `lib/md.mjs` | A small Markdown subset renderer (headings, lists, tables, blockquotes, code fences, inline code/emphasis/links). |
| `lib/render.mjs` | The HTML layout, navigation and shared fragments. |
| `lib/png.mjs` | A dependency-free PNG encoder plus a 5x7 bitmap font, used for the favicon, the Apple touch icon and the Open Graph card. |
| `content/*.md` | The curated **story** layer, with YAML front matter for the hero and metadata. |
| `assets/` | Hand-written CSS and vanilla JS copied verbatim into the build. |
| `dist/` | Build output. Not committed. |

Two layers, one source of truth: the **story** pages are curated prose that links to the **reference**
layer, and the reference layer is generated from the existing handbook markdown. Facts are never
duplicated by hand where a link will do.

## Build

```sh
node site/build.mjs
```

Output goes to `site/dist/`. The build **fails** (exit 2) if the sanitisation gate finds an IP address,
a private hostname, a non-public subdomain, key material or a token shape in the content, the assets,
or the generated output. Nothing is published from a failing build.

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
node site/build.mjs
rsync -rlt --delete --chmod=D755,F644 -e "ssh -i ~/.ssh/lab-site-deploy -o IdentitiesOnly=yes" \
  site/dist/ <user>@<edge-host>:/
```

## Verifying a deploy

A 200 is not proof. Check the content:

```sh
curl -sS -o /dev/null -w '%{http_code}\n' https://lab.steveromine.com/
curl -sS https://lab.steveromine.com/ | grep -o '<title>[^<]*</title>'
curl -sS https://lab.steveromine.com/handbook/ops-llm-check 2>/dev/null || true
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' http://lab.steveromine.com/
```
