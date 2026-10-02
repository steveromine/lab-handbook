---
title: 'Ask the handbook'
description: 'Ask questions about this lab and get answers drawn only from its own documentation - a local model, no tools, no outside access, and an honest refusal when the answer is not here.'
eyebrow: 'Ask'
hero_title: 'Ask the handbook'
hero_lede: 'A small assistant that answers from this lab's own documentation and nothing else. It runs on the lab's local model, has no tools, cannot reach the internet, and will tell you plainly when the answer is not here.'
---

## Ask a question

<form class="chat-form" id="chat-form" autocomplete="off">
  <label for="chat-q">Your question</label>
  <input id="chat-q" name="q" type="text" maxlength="500" required placeholder="e.g. What GPU does the lab use?">
  <button type="submit" id="chat-send">Ask</button>
  <p class="fine" id="chat-status" role="status" aria-live="polite"></p>
</form>

<div id="chat-log" class="chat-log" aria-live="polite"></div>

## What this is - and what it is not

**It is deliberately limited.** This is not a general assistant and it will not pretend to be one:

- **Answered only from this site.** Every answer is grounded in the handbook's own text, and the sources
  it used are listed beneath it.
- **A local model.** It runs on the lab's own GPU. No request of yours leaves the lab for another
  provider.
- **No tools, no internet.** It cannot browse, run commands, read files, or call anything. It can only
  read the documentation it is given.
- **It refuses.** If your question is not covered by the documentation, it says so rather than inventing
  an answer. A confident wrong answer would be worse than no answer.

## The honest caveats

- **It is a small local model** - modest capability, and it can misread even when the text is present.
- **Retrieval is simple**, so a question phrased unusually may miss the right page.
- **It is rate limited** to keep one visitor from monopolising the GPU the lab also uses.
- **If it says the answer is not covered**, check the handbook directly - and consider asking for the
  documentation through the [request page](/requests/). That is exactly what the backlog is for.
