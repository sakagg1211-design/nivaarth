---
name: Nivaarth
description: A portfolio auditor for Indian retail investors, built like a quiet desk at night.
colors:
  night-desk: "#0C0D10"
  audit-sheet: "#16171B"
  raised-sheet: "#23252B"
  hairline: "#282A30"
  hairline-strong: "#383A42"
  paper-white: "#FFFFFF"
  soft-ink: "#E5E7EB"
  margin-grey: "#8E929B"
  footnote-grey: "#858A94"
  ledger-gold: "#E5A93C"
  profit-mint: "#00E676"
  loss-red: "#FF5252"
  caution-orange: "#FF9800"
  heat-green: "#0C9F6E"
  heat-red: "#D64545"
typography:
  display:
    fontFamily: "Roboto (platform default)"
    fontSize: "36px"
    fontWeight: 800
    lineHeight: 1.05
  headline:
    fontFamily: "Roboto (platform default)"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.15
  title:
    fontFamily: "Roboto (platform default)"
    fontSize: "17px"
    fontWeight: 700
    lineHeight: 1.2
  metric:
    fontFamily: "Roboto (platform default)"
    fontSize: "24px"
    fontWeight: 800
    lineHeight: 1.05
  body:
    fontFamily: "Roboto (platform default)"
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.42
  caption:
    fontFamily: "Roboto (platform default)"
    fontSize: "12px"
    fontWeight: 600
    lineHeight: 1.25
rounded:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  card: "20px"
  xl: "24px"
  dialog: "28px"
  sheet: "32px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  xxl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.paper-white}"
    textColor: "{colors.night-desk}"
    rounded: "{rounded.lg}"
    height: "52px"
  card:
    backgroundColor: "{colors.audit-sheet}"
    rounded: "{rounded.card}"
    padding: "16px"
  input:
    backgroundColor: "{colors.audit-sheet}"
    textColor: "{colors.paper-white}"
    rounded: "{rounded.lg}"
    padding: "14px"
  chip-selected:
    backgroundColor: "{colors.raised-sheet}"
    textColor: "{colors.paper-white}"
    rounded: "{rounded.sm}"
---

# Design System: Nivaarth

## Overview

**Creative North Star: "The Auditor's Night Desk"**

A quiet desk late at night with one audit file open. The room is dark so the numbers can be bright. Nothing on the desk performs: no gradients for their own sake, no shadows, no celebration. The investor comes here for a short visit, often during market hours and sometimes in public, to find out what is true about their money.

Surfaces are flat sheets separated by hairlines. White carries the numbers and the main action. Ledger Gold is the auditor's pencil mark: it points at the one thing to look at. Green and red report direction and nothing else. Density is high but ordered, because an investor reads a table the way a clerk does.

The mood is calm and exact. Confidence comes from showing the working: a date on the data, a "—" where a number is missing, a sentence that says what a figure does not mean.

**Key Characteristics:**
- Dark only; no light theme exists.
- Flat, hairline-separated sheets, with no shadows.
- White for numbers and primary actions, gold for a single point of attention.
- Green and red mean up and down, and are never decoration.
- Percentages may be public; rupee amounts obey Privacy Mode.

## Colors

A near-black desk, charcoal sheets, white ink, one gold pencil, and two direction colours.

### Primary
- **Ledger Gold**: the single point of attention: the largest cell in a table, the Portfolio line on a chart, a selected language, the text cursor.

### Neutral
- **Night Desk**: the screen background.
- **Audit Sheet**: every card, input and dialog.
- **Raised Sheet**: a selected chip, a snackbar, a pill on a card.
- **Hairline** and **Hairline Strong**: card borders, dividers, drag handles.
- **Paper White** and **Soft Ink**: numbers, titles, the primary button.
- **Margin Grey** and **Footnote Grey**: supporting text, captions, axis labels.

### Status
- **Profit Mint** and **Loss Red**: direction of a price or P&L, in text and small marks.
- **Heat Green** and **Heat Red**: larger filled areas such as heatmap cells and mover bars, where the bright pair would glare.
- **Caution Orange**: a warning that is not a loss.

**The One Pencil Rule.** Gold marks one thing per card. If two things are gold, neither is the point.

**The Direction Only Rule.** Green and red say up or down. They never mean brand, selection or series identity, and a direction is never told by colour alone: a sign or arrow goes with it.

## Typography

**Body Font:** Roboto, the platform default. No custom font is loaded.

**Character:** One family, working hard through weight. Heavy numbers against medium-weight grey explanation.

### Hierarchy
- **Display** (800, 36px, 1.05): the largest figure on a hero card.
- **Metric** (800, 24px, 1.05): a key figure inside a card.
- **Headline** (800, 22px, 1.15): screen and section headings.
- **Title** (700, 17px, 1.2): card titles and app bars.
- **Body** (500, 14px, 1.42): explanations.
- **Caption** (600, 12px, 1.25): labels, dates, sources. Most supporting text sits at 11 to 13px.

**The Number Comes First Rule.** Within a card the figure is the heaviest thing. Words explain it and stay lighter.

## Layout

Phone is the reference. Content runs in a single column of cards with 16px gaps. At 1000px and wider the app gains a left sidebar and a centred column capped at 1200px; Dashboard and Stock Detail go two-column and the Portfolio grid three-column. Below 1000px the phone layout does not change. Interactive targets are at least 48px tall even when the visible chip is smaller.

Spacing steps are 4, 8, 12, 16, 24 and 32.

## Elevation & Depth

None. Depth is tonal: Night Desk, then Audit Sheet, then Raised Sheet, with a hairline where two sheets meet.

**The Flat Desk Rule.** Nothing casts a shadow. If something must sit above the page, it is a bottom sheet or a dialog with a lighter sheet colour.

## Shapes

Generous, consistent curves on containers and tighter ones on what sits inside them: cards at 20px, inputs and buttons at 16px, chips at 8px, bottom sheets at 32px on their top corners, pills fully round.

## Components

Quiet and exact. Components are recognisably Material 3, themed rather than reinvented.

### Buttons
- **Shape:** gently rounded (16px).
- **Primary:** Paper White fill, Night Desk text, full width, 52px tall, weight 800. White, not gold, so gold keeps its meaning.
- **Secondary:** text or outlined, without a fill.

### Chips
- **Style:** small rounded label inside a 48px touch area.
- **State:** selected takes a Raised Sheet fill and white bold text; unselected is Margin Grey on nothing.

### Cards
- **Corner Style:** 20px.
- **Background:** Audit Sheet with a faint white border at 6% opacity or Hairline.
- **Internal Padding:** 16px.

### Inputs
- **Style:** Audit Sheet fill, Hairline stroke, 16px corners.
- **Focus:** the stroke turns Paper White at 1.2px.
- **Error:** the stroke turns Loss Red, with the message near the field.

### Navigation
- **Phone:** bottom bar with Dashboard, Portfolio, NV Advisor and Search.
- **Wide:** left sidebar.

### Charts
Lines are 2px and never curved on the comparison chart. The Portfolio is solid Ledger Gold and the benchmark dashed white at 54%, so the two read apart without colour. Tooltips use white text, and values come with a legend that names each line.

### Heatmap
Boxes sized by share of the portfolio. Colour strength grows with the size of the move, reaching full strength at 2%.

## Do's and Don'ts

### Do:
- **Do** show a date on anything that can go stale.
- **Do** write "—" for a missing number.
- **Do** say on the card what a figure is not, when it could be misread.
- **Do** use the tokens in `lib/core/theme` instead of a colour literal.
- **Do** keep touch targets at 48px or more.

### Don't:
- **Don't** add shadows or decorative gradients to surfaces.
- **Don't** use gold for a second thing on the same card.
- **Don't** use green or red to mean anything except direction.
- **Don't** put rupee amounts on a shareable card.
- **Don't** add a light theme without replacing this document.
