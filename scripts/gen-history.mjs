#!/usr/bin/env node
// Generate the time-machine page from the repository history.
// Usage: node scripts/gen-history.mjs [repo-root]
import { execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.argv[2] || process.cwd();
const OUT = path.join(ROOT, 'site', 'content', 'time-machine.md');

function git(args) {
  return execSync('git -C ' + JSON.stringify(ROOT) + ' ' + args, { encoding: 'utf8' }).trim();
}

let rows = [];
try {
  const raw = git('log --date=short --pretty=format:%h%x1f%ad%x1f%s');
  rows = raw.split('\n').filter(Boolean).map((l) => {
    const [h, d, s] = l.split('\x1f');
    return { h, d, s };
  });
} catch (e) {
  rows = [];
}

const byDate = new Map();
for (const r of rows) {
  if (!byDate.has(r.d)) byDate.set(r.d, []);
  byDate.get(r.d).push(r);
}
const days = [...byDate.keys()].sort().reverse();

let body = '';
for (const d of days) {
  body += '## ' + d + '\n\n';
  for (const r of byDate.get(d)) {
    body += '- \`' + r.h + '\` — ' + r.s.replace(/\|/g, '/') + '\n';
  }
  body += '\n';
}

const count = rows.length;
const first = rows.length ? rows[rows.length - 1].d : 'unknown';
const last = rows.length ? rows[0].d : 'unknown';

const fm = `---
title: 'Time machine'
description: 'Every change to this site, from the first commit to now - the lab's own history, as far back as it goes.'
eyebrow: 'As far back as it goes'
hero_title: 'The time machine'
hero_lede: 'Nothing here is hidden behind a curtain. This is the full history of the handbook - ${count} recorded changes from ${first} to ${last} - so you can watch the thinking change, mistakes and all.'
---

Every commit to this site, newest first. The point is not that the lab got everything right; it is
that you can see **how it changed** - including the places it changed its mind.

`;

fs.writeFileSync(OUT, fm + body);
console.log('wrote', OUT, 'with', count, 'commits');
