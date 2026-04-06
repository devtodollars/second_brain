---
name: linkedin
description: Draft LinkedIn posts in Amirali's voice, or research people and companies for outreach prep. Uses the LinkedIn MCP for live data. Never sends or publishes anything — always drafts for review.
---

# LinkedIn Skill

Two modes: **post drafting** and **prospect research**. Detect which one the user wants from context, or ask if unclear.

**Hard rule: never send messages, post content, or connect with anyone autonomously. Always output drafts for Amirali to review and act on himself.**

---

## Before Doing Anything

Read `Memory/USER.md` and `Memory/MEMORY.md` to load context about Amirali, DevToDollars, current clients, and active projects. This powers both modes — posts are more relevant and research is more targeted when you know what's happening in the business.

---

## Mode 1: Draft LinkedIn Post

### When to use
User provides a topic, idea, rough notes, or says "write a post about X."

### Process

1. **Clarify intent** (if not obvious):
   - What's the core point or argument?
   - Is there a real example, story, or observation behind it?
   - Target audience: founders, developers, startup CTOs?

2. **Research if needed**
   - If the post is about a company, trend, or person — use `mcp__linkedin__get_company_posts` or `mcp__linkedin__get_company_profile` to gather real context before writing
   - Use `WebSearch` for recent news, stats, or quotes that strengthen the argument

3. **Write the draft**

   Follow Amirali's voice and style strictly:

   **Voice principles:**
   - Direct and opinionated — say what you actually think, not "it depends"
   - Technical depth when it adds credibility, but never jargon for its own sake
   - Business lens — connect technical observations to real-world impact (revenue, speed, risk)
   - No fluff openers — never start with "I've been thinking about..." or "Hot take:" or "Unpopular opinion:"
   - Short sentences. White space. Easy to scan on mobile.
   - First line must be a hook that stops the scroll — a bold claim, a surprising fact, or a sharp question
   - End with one clear takeaway or call to action — not a generic "what do you think?"

   **Post structure (default):**
   ```
   [Hook — 1 line, stops the scroll]

   [Context or setup — 2-3 lines max]

   [Core argument or observation — the meat]

   [Concrete example or evidence — real, specific]

   [Takeaway or implication — what should the reader do or think differently]

   [Optional: 3-5 relevant hashtags on the last line]
   ```

   **Format rules:**
   - 150–300 words is the sweet spot. Go longer only if the story demands it.
   - Use line breaks generously — no wall-of-text paragraphs
   - Avoid bullet lists unless comparing 3+ things directly
   - No em-dashes used as decoration
   - No rhetorical questions back-to-back

4. **Output**
   - Show the full draft
   - Add a one-line note on the angle/hook choice
   - Offer 1 alternative hook if the first is risky or polarizing

---

## Mode 2: Prospect Research

### When to use
User wants to learn about a specific person, company, or set of people before a call, proposal, or outreach.

### Process

1. **Identify what to look up**
   - Name of person → use `mcp__linkedin__search_people` then `mcp__linkedin__get_person_profile`
   - Company name → use `mcp__linkedin__get_company_profile` + `mcp__linkedin__get_company_posts`
   - Vague description ("a fintech startup in Toronto") → use `mcp__linkedin__search_people` with filters to find candidates

2. **Pull the data**
   - For people: current role, company, career history, recent activity if visible
   - For companies: size, industry, recent posts, what they're talking about publicly

3. **Synthesize a brief** — output a structured prospect brief:

   ```
   ## [Person / Company Name]

   **Who they are:** [1-2 sentence summary — role, company, what they do]

   **Relevance to DevToDollars:** [Why Amirali should care — is this a potential client, partner, referral source?]

   **Recent activity:** [Any notable posts, announcements, or signals from LinkedIn]

   **Talking points:** [2-3 specific things Amirali could reference in an outreach or conversation]

   **Suggested angle:** [One sentence on how to open if Amirali reaches out — what pain or opportunity to lead with]
   ```

4. **Draft outreach message (if requested)**
   - Write a short, direct connection note or DM (under 300 chars for connection requests, under 500 for DMs)
   - Personalized to what was found — not a template
   - Lead with relevance, not a sales pitch
   - **Output as a draft only** — never send via `mcp__linkedin__send_message` or `mcp__linkedin__connect_with_person` without explicit instruction from Amirali

---

## Available LinkedIn MCP Tools

| Tool | Use for |
|------|---------|
| `mcp__linkedin__search_people` | Find people by name, title, company, or keywords |
| `mcp__linkedin__get_person_profile` | Full profile for a specific person |
| `mcp__linkedin__get_company_profile` | Company overview, size, industry |
| `mcp__linkedin__get_company_posts` | Recent posts from a company page |
| `mcp__linkedin__get_sidebar_profiles` | Suggested profiles (discovery) |
| `mcp__linkedin__search_conversations` | Search existing LinkedIn message threads |
| `mcp__linkedin__get_inbox` | Check LinkedIn inbox |
| `mcp__linkedin__get_conversation` | Read a specific thread |
| `mcp__linkedin__send_message` | **DRAFT ONLY** — never use without explicit approval |
| `mcp__linkedin__connect_with_person` | **DRAFT ONLY** — never use without explicit approval |

---

## What This Skill Never Does

- Posts or publishes anything to LinkedIn
- Sends messages or connection requests without Amirali explicitly saying "send it"
- Writes posts in a generic corporate voice
- Adds filler phrases like "excited to share", "thrilled to announce", "game-changer", "leverage", "synergy"
- Uses more than 5 hashtags
