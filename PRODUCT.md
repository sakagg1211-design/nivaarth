# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

The same Flutter code also ships a private web beta at nivaarth-beta.pages.dev, used by iPhone owners. At 1000px and wider the web and landscape tablets get a desktop layout. Below 1000px the phone layout is the reference.

## Users

Self-directed Indian retail investors who choose their own stocks, on one or more brokers, and want to know where their portfolio has mistakes and risks. Today the app is in a private beta with friends.

## Product Purpose

Nivaarth audits a retail investor's portfolio. It shows what each holding is worth, how sound it is by the numbers, and where the portfolio carries risk the investor may not have noticed. Success is an investor who can trust every number shown and comes back because the app keeps watching their holdings.

## Positioning

Most market apps answer "what should I buy?". Nivaarth answers "where are my mistakes and risks?". It is a portfolio auditor and risk detective, not a tips service. Every score can be opened and traced to the inputs behind it, and every number comes from the database. The AI only explains.

Order of priority: trust first (accurate data, explainable maths), stickiness second (holdings, alerts, corporate actions), differentiation third (AI co-pilot, what-if, stress test), compliance alongside all three.

## Operating Context

- Investors enter holdings by hand, trade by trade, or by importing a Zerodha tradebook (CSV or Excel). Trades are the source of truth for a holding.
- Prices come live from Yahoo Finance, with official NSE end-of-day data (bhavcopy) behind them. Fundamentals come from Screener exports.
- Checked on a phone, often in short visits during market hours (09:15 to 15:30 IST), and sometimes in public, which is why Privacy Mode hides rupee amounts.
- Backend jobs refresh prices every 5 minutes in market hours, load the bhavcopy each evening, and rescore stocks afterwards.

## Capabilities and Constraints

Built:

- Dashboard with portfolio value, health, market-cap and sector split, India VIX and market breadth.
- Portfolio with trades, closed positions, Zerodha import, bonus and split prompts.
- NV Score v2.8.0 (Quality 55, Valuation 30, Momentum 15) across about 3,150 NSE stocks, with a full breakdown and lender-specific scoring.
- Stock page with chart crosshair, score radar, factual badges, peer comparison and shareable cards with no rupee amounts.
- Price alerts in Notifications (in-app only, no push).
- NV Advisor: chat grounded in the user's portfolio and database facts, in English, Hindi or Hinglish.
- What-if and stress test based on one-year beta.

Constraints:

- SEBI: Nivaarth is not a registered adviser. No buy, sell, hold, add or trim instructions and no made-up "institutional" stories. Framing is diagnostic and educational. A test fails the build if banned phrases return to the app.
- No made-up numbers. Missing data shows as "—", never an assumed value or a hardcoded price.
- Licensing: a market-data licence is needed before any paid launch. FII/DII flows are left out until a licensed source exists.
- Privacy: each user sees only their own data; shareable cards never show rupee amounts.
- Terms: NV Score, NV Advisor, Privacy Mode, Trade jodo, Trade book, Closed positions.

Undecided or deferred: XIRR, family portfolio selector, English and Hinglish language switch (planned), BSE-only stocks (planned), Account Aggregator sync, pricing.

## Brand Commitments

- Name: Nivaarth. Logo at `assets/images/logo.jpg`.
- Voice: factual and plain, stating what the numbers show. Hinglish is a deliberate part of the product.

## Evidence on Hand

Real: the live stock universe, NV Score methodology and breakdowns, and the private beta itself (4 users, 44 distinct stocks held on 9 Nov 2026).

Absent, and must not be invented: testimonials, customer counts beyond the beta, performance claims, accuracy benchmarks, press, pricing.

## Product Principles

1. A single wrong number costs more than any missing feature. When unsure, show "—".
2. Show the working. Every score and warning can be traced to its inputs.
3. Describe, never instruct. The app says what is true; the investor decides.
4. Find what the investor did not ask about: concentration, weak holdings, pledges, stale data.
5. Speak the way Indian retail investors speak, without jargon they have to look up.
