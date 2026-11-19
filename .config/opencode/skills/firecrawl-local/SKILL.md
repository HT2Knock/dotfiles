---
name: firecrawl-local
description: >-
  Read the web with Firecrawl Local. Use when a page comes back from webfetch
  with navigation noise, when one docs site needs many pages at once, when the
  task needs a site's URL list, or when a PDF or Office file must become
  markdown. Fetches and cleans on this machine.
---

# Firecrawl Local

`~/.cargo/bin/firecrawl-local` scrapes one page, crawls a site, lists a site's
URLs, and turns a document into markdown. Chrome renders pages that need
JavaScript. The main content is kept and the navigation is dropped.

## Pick the job

| Job                        | Command                                                                                 |
| -------------------------- | --------------------------------------------------------------------------------------- |
| One page as clean markdown | `firecrawl-local scrape <url> --public-only --markdown`                                 |
| Many pages of one site     | `firecrawl-local crawl <url> --public-only --limit 50 --out "$TMPDIR/firecrawl/<site>"` |
| The URL list of a site     | `firecrawl-local map <url> --search <text>`                                             |
| A local PDF, DOCX, or XLSX | serve the file on loopback, then `scrape` that URL (see below)                          |
| A screenshot or a click    | not this tool. Use the browser skill                                                    |

Reach for this tool first on documentation pages. On one Tailwind docs page it
returned 2,736 characters where `webfetch` returned the full navigation sidebar
and a repeated footer. Keep `webfetch` for JSON, plain text, and one small page
where the noise does not matter.

## Rules

- Pass `--public-only` when the URL comes from a page, a search result, or the
  model. The flag refuses `localhost` and private ranges, which closes the route
  a page with hidden instructions would use to reach your own network.
- Write crawl output to `$TMPDIR/firecrawl/<site>`. Crawl output is scratch
  data. It does not belong in a repo.
- Read the result before you rely on it. A blocked page returns a challenge body
  with a `200` status, not an error.
- `--browser auto` starts Chrome when the static fetch looks empty. Pass
  `--browser always` when you know the page writes its text with a script, and
  `--browser never` to keep a static page fast.
- Use the browser skill for a page behind a login. Firecrawl uses a throwaway
  profile and holds no session of the user.
- Ask before a crawl above about 100 pages. Each page is a network request, and
  a wide crawl on a small site is unfriendly.

## Examples

Scrape one page and check it has content:

```bash
out="$TMPDIR/firecrawl/page.md"
firecrawl-local scrape https://example.com/docs --public-only --markdown > "$out"
wc -c "$out"          # expect more than a few hundred bytes
head -20 "$out"       # expect a heading, not "Please enable JS"
```

Map first, then crawl the part you need:

```bash
firecrawl-local map https://docs.example.com --search guides --limit 200 > "$TMPDIR/urls.json"
python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["links"]))' "$TMPDIR/urls.json"

firecrawl-local crawl https://docs.example.com/guides \
  --public-only --limit 30 --max-depth 2 \
  --out "$TMPDIR/firecrawl/example-guides"
```

`map` returns `{"success": true, "links": []}` for a host it cannot read, so
check the count before the crawl. Zero there means no sitemap and no readable
start page, not an empty site.

`crawl` writes one page per file, named `0001-<host>_<path>.md`, prints one line
per saved page to stdout, and prints a summary line to stderr with page count,
rate, and errors. Zero errors and the expected page count is the check.

Fetch several known URLs in one call, which is cheaper than a loop. Drop
`--markdown` for more than one URL: without it the output is a JSON array with
one envelope per page, so you can tell the pages apart. With `--markdown` the
pages run together with no separator.

```bash
firecrawl-local scrape https://a.example.com https://b.example.com --public-only \
  | python3 -c 'import json,sys; [print(d["data"]["metadata"]["sourceURL"], len(d["data"]["markdown"])) for d in json.load(sys.stdin)]'
```

## Local files

`scrape` takes URLs only. A file path becomes a broken URL. Serve the file on
loopback, then scrape it. Drop `--public-only` for this call: the target is your
own machine, and the flag refuses it.

```bash
tmp="$TMPDIR/firecrawl/doc"
mkdir -p "$tmp" && cp ~/Downloads/report.pdf "$tmp/doc.pdf"
( cd "$tmp" && python3 -m http.server 8765 >/dev/null 2>&1 & echo $! > "$tmp/pid" )

firecrawl-local scrape http://127.0.0.1:8765/doc.pdf --markdown > "$tmp/doc.md"
kill "$(cat "$tmp/pid")"
```

A 1.3 MB PDF became 89 KB of markdown in about four seconds, with headings and
the table of contents intact.

## Failures

| Symptom                                                  | Cause                                          | Action                                                                                        |
| -------------------------------------------------------- | ---------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `dns error` on a path that starts with `/`               | `scrape` got a file path                       | serve the file on loopback                                                                    |
| `BLOCKED_TARGET ... private address`                     | `--public-only` with a loopback URL            | drop the flag for your own file                                                               |
| `unexpected argument '--public-only'`                    | `map` has no such flag                         | use `scrape` or `crawl` on the URLs that `map` returns                                        |
| Body says "Please enable JS", result has `blocked: true` | Bot wall. The local fetch got a challenge page | run `firecrawl-local login` once, so the cloud fallback can try. Some sites the cloud refuses |
| Empty output, no error                                   | Page needs a browser                           | add `--browser always`, then check with `wc -c`                                               |

## Limits

- Formats are `markdown`, `html`, `rawHtml`, and `links`. The `json` and
  `summary` formats, browser `actions`, and `interact` exist only on the cloud
  API.
- `map` reads sitemaps and the start page. It does not render JavaScript.
- `crawl` reads `robots.txt` unless you pass `--ignore-robots`.
- Local work needs no key and spends no credits. `search` and the fallback for a
  blocked page go to Firecrawl Cloud and spend credits.
- `--browser never` skips Chrome. Use it for a static page on a slow machine.
- The MCP lane (`firecrawl-local mcp`) is not used here. It starts the
  Node-based `firecrawl-mcp` server with 31 tools, most of them cloud-only. The
  commands above cover the local jobs.

## Configuration

| Variable                  | Effect                                                   |
| ------------------------- | -------------------------------------------------------- |
| `FIRECRAWL_CLOUD`         | `auto` (default), `search`, or `off`                     |
| `FIRECRAWL_LOCAL_BROWSER` | `auto` (default), `never`, or `always`                   |
| `FIRECRAWL_CHROME_PATH`   | Chrome or Chromium to use instead of the system one      |
| `FIRECRAWL_API_KEY`       | Key for the cloud calls, used instead of the saved login |

Sign in once with `firecrawl-local login`. It saves the key where the Firecrawl
CLI keeps it, and both tools then share it.
