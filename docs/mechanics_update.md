# Mechanic Flow Update Plan

## Status

Planning document. The mechanic flow exists, but it needs a stronger completion, payment, chat, and earnings experience before it feels production-ready.

## Overview

The current mechanic journey is functional but too thin compared with the customer flow. A mechanic can move through basic states, but the app still needs clearer request acceptance, service completion, payment confirmation, chat, and earnings history.

## Current Gaps

### Payment and earnings

- No complete payment confirmation flow for mechanics after service completion.
- Earnings data is not yet tied to completed jobs.
- No transaction history, payout method, or fee breakdown.
- Tips, discounts, final price, and platform fee are not clearly represented.

### Service request handling

- Accept and reject actions need confirmation dialogs.
- Rejections should capture a reason such as too far, unavailable, or wrong service type.
- Mechanics need a fuller request preview before accepting.
- Active jobs need explicit status transitions so a mechanic cannot accidentally close or leave a job.

### Chat and coordination

- Mechanic-side chat is not fully integrated into the active service flow.
- Mechanics need a direct way to message, call, or receive customer updates after accepting a request.
- Chat notifications should be visible from the mechanic dashboard during active jobs.

### In-service experience

- The en-route state needs ETA, navigation, and live location controls.
- The working state needs a timer, work notes, completion photos, and a clear completion action.
- Completion needs a summary before final confirmation.

### Data model

`ServiceRequest` should eventually support:

- `actualPrice`
- `completionTime`
- `customerNotes`
- `mechanicNotes`
- `workPhotos`
- `tipAmount`
- `appliedPromoCode`
- `customerRating`
- `customerReview`
- `platformFee`
- `mechanicPayout`

## Target Flow

```text
Incoming request
  -> Request details and confirmation
  -> Accept or reject with reason
  -> En route with ETA, navigation, and chat
  -> Working with timer, notes, and photo upload
  -> Completion summary
  -> Payment confirmation
  -> Earnings history update
```

## Recommended Phases

### Phase 1: Payment and completion

- Create a mechanic payment confirmation screen.
- Show service details, final price, tips, platform fee, and mechanic payout.
- Update the completed-service path so every completed job has a payment summary.
- Add earnings history entries from completed jobs.

### Phase 2: Request acceptance

- Add a request details confirmation before accepting.
- Add reject-with-reason handling.
- Show service location, customer notes, distance, and estimated price before the mechanic commits.

### Phase 3: Chat

- Add a mechanic chat screen that mirrors the customer chat features.
- Link chat from accepted, en-route, and working states.
- Surface unread customer messages on the mechanic dashboard.

### Phase 4: Active service UX

- Add navigation and ETA to the en-route panel.
- Add timer, notes, and photo upload to the working panel.
- Protect active jobs from accidental navigation or status changes.

### Phase 5: Safety and quality

- Require confirmations for accept, reject, start work, complete service, and cancel.
- Store rejection and cancellation reasons.
- Add rating/review display after completion.

## Key Decisions

- Platform fee: decide the mechanic payout formula.
- Tips: decide whether mechanics receive 100% of tips.
- Cancellation: define whether mechanics can cancel after accepting and whether a penalty applies.
- Ratings: decide how ratings affect future request matching.
- Chat timing: decide whether chat opens automatically after accept or stays manually accessible.

## Testing Checklist

- Mechanic can accept a request only after seeing the request details.
- Mechanic can reject a request with a reason.
- Accepted request exposes chat and navigation.
- En-route and working states cannot be skipped accidentally.
- Completing a service opens a payment summary.
- Completed service appears in earnings history.
- Payment, tip, platform fee, and payout values are shown consistently.
