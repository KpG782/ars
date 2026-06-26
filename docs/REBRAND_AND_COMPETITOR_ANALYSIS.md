# ARS → Rebrand, Competitor Analysis & Feature/Flow Blueprint

> Strategy deliverable · Philippine on-demand **mechanic** marketplace
> Prepared from a code-grounded audit of this repo + competitor research (Angkas/Move It/Grab as structural refs; YourMechanic/Wrench/Urgent.ly/HONK as category refs).
> **Sequencing rule (from the team's own audit philosophy):** get the app *allowed on the shelf* (store-compliance) → make it *credible* (trust) → then *polish brand & growth*. The rebrand is real but it ships **alongside** the P0 fixes, not before them.

---

## 0. TL;DR — the one-screen version

**What ARS actually is:** "Grab/Angkas, but for mechanics" — a two-sided PH marketplace (vehicle owners ↔ TESDA-verified mechanics) with live map, ETA, in-app chat, an AI chatbot, a mechanic dashboard, and a 6-step mechanic verification flow. The bones are good; the *trust layer is collected-but-invisible* and the *money/compliance layer is placeholder.*

1. **Kill "ARS."** It's an opaque, non-Filipino acronym that reads as crude English slang — a liability at the most trust-sensitive moment in any consumer app (handing your keys / your stranded self to a stranger). Category winners own a short, native, **verb-able** word (Angkas = "ride pillion"). Lead direction: **Panday** (the master craftsman/smith) — *conditionally*, pending the trademark + "foodpanda-confusion" checks below. The package id `com.example.arsapplication` is itself a guaranteed store rejection, so the rename and the bundle-id fix ship together.
2. **You are NOT a rideshare clone.** Own the *mechanic* category ("tawag ng mekaniko"), never borrow a motion word (Move/Go/Sakay/Takbo) — that's the clone trap. Your real day-one competitor isn't Grab; it's the **free Facebook-group / Viber "On Call Mekaniko"** dispatch. You can't charge a take-rate until you beat *free* on trust + convenience.
3. **Three store ship-blockers are verified in this repo and will get you bounced regardless of features** (see §1). Fix them first.
4. **Your cheapest, highest-leverage win is to *surface trust you already collect*** — the Verified badge, ratings, and reviews exist in the data model and never reach the customer's eyes.
5. **The make-or-break product problem is pricing a repair sight-unseen.** Adopt the two-funnel model (flat-rate menu for known jobs + photo-triage → credited diagnostic for unknown ones) and the iron rule: *no work beyond the approved quote without in-app re-confirmation.*
6. **The existential risk is liquidity, not features.** Launch one city/barangay deep (15–20 verified mechanics per key category), recruited from the very FB groups you're displacing — and design the **"no mechanic available"** fallback *first*, because in a thin-supply broadcast model it's the most-hit state in the app.

---

## 1. P0 — Store-compliance ship-blockers (verified in this codebase)

These block the binary independent of everything else. All four are confirmed against the actual code, not assumed.

| Blocker | Evidence in repo | Why it's a hard rejection | Fix | Effort |
|---|---|---|---|---|
| **Customer cannot delete their account** | `lib/features/customer/.../firebase_auth_repository.dart` has **no** `deleteAccount`; only `lib/features/mechanic/...` does | Apple **5.1.1(v)** + Google Play Data-deletion both require in-app delete **and** a public web deletion URL | Add `deleteAccount()` + reauth-then-delete to customer `AuthRepository`, a Delete-Account screen in customer settings, server-side wipe (bookings/chat/Storage), and a public deletion URL | **M** |
| **iOS missing location usage string** | `ios/Runner/Info.plist` has Camera/Mic/Photo strings but **no** `NSLocationWhenInUseUsageDescription` — while live GPS/ETA is the headline feature | iOS crashes at the permission prompt → Apple **5.1.1 / 2.1** auto-reject | Add `NSLocationWhenInUseUsageDescription` ("…to find nearby mechanics and share live ETA"). Keep **foreground-only** to dodge heavier review; add Android prominent-disclosure for FINE location | **S** |
| **Placeholder bundle id** | `android/app/build.gradle*`: `applicationId = "com.example.arsapplication"` (+ placeholder Firebase + Maps key) | Apple & Google both reject `com.example.*` / placeholder configs | Real reverse-DNS id (e.g. `ph.panday.app`), real Firebase config, real Maps key; drop any `usesCleartextTraffic` | **S** |
| **Unmoderated user-generated content** | Customer + mechanic chat both allow image upload; no Report/Block/filter | Apple **1.2** UGC rule (needs report/block + moderation + EULA clause) | Add Report-message + Report/Block-user to both chat screens, an abuse queue + contact email, and an objectionable-content EULA clause | **M** |

**Also required before submission (flagged by the compliance pass, beyond the four above):**
- **Privacy policy + data-deletion URL**, plus a fully-filled **Google Play Data Safety form** and **Apple privacy nutrition labels** — you collect location, gov-ID, and license uploads (sensitive data), so these are hard gates and must *match* what the app actually collects.
- **PH Data Privacy Act / NPC**: a platform processing sensitive personal info (gov-ID, license) should plan for **NPC registration** and a lawful basis for storage. Regulatory, not store — but real.
- **Rotate the leaked key**: the orphan `BookingRequestMapScreen` hardcodes an OpenRouteService API key. Rotate it and delete the dead screen.

> **Good news on payments (the usual rejection trap):** ARS's core revenue — a customer paying for an on-site mechanic's labor + parts — is a **physical, real-world service**. Under Apple **3.1.5(a)/3.1.3(e)** and Google Play's physical-goods carve-out it **must NOT use IAP** (so you avoid the 30% cut). Use GCash/Maya/QR Ph/cards via PayMongo or Xendit, plus cash. App-review note to cite: *"On-demand marketplace; all payments are for in-person physical repair services by independent mechanics, consumed outside the app — equivalent to Uber/Grab/DoorDash under Guideline 3.1.5(a)."* The IAP line only gets crossed by **digital** add-ons — see §6.

---

## 2. Rebrand — positioning & name

### 2.1 Positioning: own the *mechanic* category, never clone the *ride*

> **Positioning statement —** *For Filipino drivers and riders who break down, need a repair, or dread being overcharged by an unknown talyer, **[BRAND]** is the on-demand mechanic marketplace that sends a TESDA-verified pro to wherever you are — with the price agreed before any work starts — unlike free Facebook-group mekaniko dispatch (no vetting, no protection, no recourse) or casa/insurer hotlines (car-only, slow, policy-gated).*

| Status-quo alternative | Why [BRAND] wins |
|---|---|
| **FB-group / Viber "On Call Mekaniko"** (free, familiar, viral; zero vetting, no payment protection, no ETA, no recourse) | Verified mechanics, agreed price up-front, live tracking, in-app payment + dispute support. *Recruit supply from these groups and out-trust them.* |
| **Casa / insurer roadside** (high trust; car-only, insured-only, tow-to-casa, slow) | Serves the uninsured, the **motorcycle mass market**, and *on-site* repair, instantly, no policy needed. |
| **Local app incumbents — MechaniGo.ph, Mekaniko.ph** (scheduled home PMS; card/cash) | Deeper verification surfaced as a *badge*, live tracking, GCash/Maya-first, a roadside/SOS angle they under-serve, + a workmanship guarantee. |

**Strategic wedge (so positioning is real, not aspirational):** lead **motorcycle-co-equal and maintenance-first**, not car-and-emergency-first. PH sells ~2.37M motorcycles/yr vs ~491k cars — the current car-framed product is a positioning mismatch. Wedge on predictable, parts-light, dispute-resistant jobs (oil change, PMS, tire, battery, brake, basic diagnostics) — the proven high-frequency lane — *then* layer roadside/SOS as the emotional hook.

### 2.2 Name — the honest, adversarially-checked shortlist

A brand pass generated candidates; a separate skeptical app-store/trademark pass scored them. **The verification caught real collisions the creative pass missed** — that reconciliation is the whole point:

| Name | Score | Verdict | The catch |
|---|---|---|---|
| **Panday** — master smith/craftsman | **6/10** | **VIABLE (lead, conditional)** | The exact "Angkas of mechanics" — names the trusted-master archetype, dignifies the mechanic, hard "P" wrench-monogram. **But**: clear vs **foodpanda/"panda"** at thumbnail size, run **IPOPHL** clearance (classes 9/35/37), expect a descriptive-mark objection → register a **distinctive figurative mark** (anvil/forge/wrench device), and gut-check the FPJ-film association. Fallbacks that keep the equity + gain distinctiveness: **Pandayan, PandayGo, Panday Auto, iPanday**. |
| **Kasangga** — your ally/partner who has your back | **6/10** | **VIABLE** | Strong trust word. **But** lock a category descriptor ("Kasangga — Mobile Mechanic"), check the **"Ang Kasangga" party-list** association, and skip the fintech-coded "kasangga mo sa buhay" tagline. |
| **Mekot** — coined from "mekaniko" | **5.5/10** | **VIABLE** | Filipino-flavored slang for mechanic without using the generic word. **But** clear vs **MEKO/Mekonomen** (automotive-class neighbor) and lock the wrench identity so it reads "mechanic." |
| **Agap** — promptness / quick rescue | **5/10** | **WEAK** | Great connotation (pairs with the SOS feature), **but category-silent** and collides with Agap.AI / a govt "AGAP". Only viable as **"Agap Auto/Mechanic"** with a descriptor. |
| **Husay** — skill/mastery | 4.5/10 | **WEAK** | **"Husay PH" already exists on both stores** (Spiderhook Inc.) and husay.ph is taken. Only a distinctive compound could survive. |
| **Saklolo** — help!/rescue | 4/10 | **WEAK** | Mis-sells a calm booking app as emergency rescue + collides with an existing PH emergency app. *Reconsider only if you pivot to roadside-SOS as the hero use case.* |
| **Ayos / Ayoska** — "fixed/sorted" | 3/10 | **REJECT** | Semantically perfect, **but "Ayos" is already a live, near-identical PH on-demand verified-repair marketplace** (customer + provider apps). Adopting it = brand confusion + ASO cannibalization + likely TM fight + looking like a clone. Keep "Ayos na!" as in-app copy only. |
| **Suki** — trusted regular | 3/10 | **REJECT** | Saturated: ShopSuki / MySuki / Suki-Card. Wrong category signal (retail loyalty) + TM collision. |

**Reconciled recommendation:**
- **Lead with Panday** as the creative direction — it's the only candidate that does what Angkas did (claim the category's native archetype word) and it flatters *both* sides of the marketplace (supply will be proud to be "a Panday"). **Treat it as conditional**: do not lock until IPOPHL clearance + the foodpanda-confusion check pass. If clearance is messy, move to a distinctive compound (**Pandayan / PandayGo**).
- **Hold Kasangga and "Agap Auto"** as cleaner-clearance fallbacks.
- **Note honestly:** nobody scored "strong" (8+). That's a signal, not a failure — the good generic Tagalog words are mostly *taken*, so the defensible play is a **distinctive coined/compound mark** you can actually own, validated with a real IPOPHL + SEC business-name + `.ph` domain + Play/App-Store-name availability check **before** any spend.

**Do not pick:** any motion word (Grab-clone trap), `Bolt`/`Pitstop` (taken/global TM), `Mekaniko`/`Mechanigo`/`CarFix` (taken or unprotectable), or `-ly/-ify` coinages (dated, clonable).

### 2.3 Visual identity — evolve, don't discard

**Flip the hierarchy: make trust-teal `#3DB3A9` the primary brand color and demote orange `#F97316` to energy/CTA accent.** In a category whose entire reason to exist is *trust*, lead with the trust color (Grab proved green = "go/safe" is ownable; teal is *more* defensible than category-default orange, which reads food-delivery and which Angkas/JoyRide already crowd).

| Token | Today | New role | Use |
|---|---|---|---|
| **Trust Teal `#3DB3A9`** | secondary | **Primary brand** | wordmark, Verified badge, headers, "approve quote" |
| **Orange `#F97316`** | primary | **Accent/energy** | primary CTAs ("Tawag ng Panday"), ETA highlights, active-job pulse |
| **Emergency Red** | *dead token* | **Activate** | SOS / breakdown entry — real urgency only |
| Slate neutrals | keep | keep | type, surfaces, maps |
| **Brass/gold** | new | trust seal | "Verified Panday" badge (nods to the smith heritage) |

**Icon:** the **"P" as a wrench or anvil** — owns "repair," clean monogram, passes the Angkas-"A"/Grab-"G" 1× glyph bar. **Avoid** helmet / motorcycle / car / lone lightning-bolt (clone or "Bolt" tells).

### 2.4 Brand voice & in-app copy rewrites

*Rule: Taglish for warmth, English for trust-and-money. Never a dead-end state.* (Names below use "Panday" as a placeholder for the final brand.)

**Onboarding (replaces "Book Repairs Instantly / Find Local Experts / Track Everything"):**
| Slide | Headline | Subcopy |
|---|---|---|
| Trust | **"Verified Panday, hindi basta-basta."** | "Every mechanic is TESDA-certified, licensed, and ID-checked — vetted before they ever reach you." |
| Price | **"Alam mo ang presyo, bago pa magsimula."** | "See an upfront estimate and approve the quote before any work starts. Walang sorpresa." |
| Anywhere | **"Stranded o scheduled — andiyan kami."** | "Roadside, home, or office. Track live ETA, chat in-app, pay by GCash, Maya, or cash." |

**Role select:** Customer → **"Magpa-ayos"** *(Find a verified Panday near you)* · Mechanic → **"Maging Panday"** *(Get verified, get jobs, get paid — keep 100% of parts cost)*.
**Service header:** **"Ano'ng kailangan ng sasakyan mo?"** — *"Alam mo na ang problema? Get an instant estimate. Hindi sigurado? Book a diagnostic visit — credited to your repair."*

**Degraded states (currently undesigned — the biggest flow hole):**
| State | Copy |
|---|---|
| Searching | **"Hinahanap ang pinakamalapit na Panday…"** + live count ("3 verified nearby") — never a silent spinner |
| **No mechanic available** | **"Walang available na Panday ngayon dito."** `[Notify me]` `[Widen search]` — never spin forever |
| Payment failed | **"Hindi natuloy ang bayad. Walang siningil."** `[Try GCash / Maya / cash]` |
| GPS denied / offline | **"Kailangan namin ang location mo para hanapin ang pinakamalapit na Panday."** `[Enable]` / **"Walang connection — subukan ulit."** `[Retry]` |
| SOS / breakdown | **"Sira sa kalsada? Saklolo, one tap."** *"Share your live location + Panday details to a trusted contact. For life-threatening emergencies, call 911."* (the disclaimer is also the Apple compliance fix) |

### 2.5 Messaging pillars (each tied to a shippable feature)

1. **Verified, hindi basta-basta** *(Trust)* → surface the Verified badge + ratings + past-work photos; ongoing random selfie checks.
2. **No-surprise pricing** *(Transparency)* → two-tier quote approved in-app before work; line-item breakdown; **"no surge on emergencies"** (turns the LTFRB surge crackdown into your differentiator); mechanics keep 100% of parts cost.
3. **Andiyan kami, kahit saan** *(Rescue & Reach)* → live ETA; one-tap SOS/Saklolo; **motorcycle-co-equal** coverage; roadside + home + scheduled in **one app** (never split apps — the Move It mistake).
4. **Ayos na, covered ka** *(Guarantee)* → workmanship guarantee + per-job micro-insurance (Angkas's ₱0.52/ride model via Igloo/Singlife/Malayan); before/after photos + itemized receipt as dispute defense.

---

## 3. Competitor matrix

Legend: ✅ present/strong · 🟡 partial/placeholder/collected-but-invisible · ❌ absent.
PH ride-hailing = *structural* refs (marketplace plumbing); mobile-mechanic apps = *category* refs; **the free FB/Viber status quo is the real day-one rival** and is included as the benchmark every feature must beat.

| Capability | **ARS today** | **FB/Viber dispatch** (status quo) | Angkas / Grab PH | YourMechanic / Wrench | Urgent.ly / HONK |
|---|---|---|---|---|---|
| **Matching/dispatch** | 🟡 Broadcast to all mechanics in 10 km, first-to-accept; accept is a non-transactional `update()` (**double-accept race**) | ❌ Manual "sino diyan?" | ✅ Nearest / batched | ✅ Quote→schedule→assign | ✅ Geo-fenced nearest-qualified |
| **Live tracking + ETA** | ✅ OSRM + ETA, 30 s refresh — but recomputed from a **static** `mechanic.location`, no live GPS stream | ❌ "malapit na po" | ✅ Best-in-class | ✅ Arrival window | ✅ Live ETA |
| **Pricing transparency** | ❌ Price fields exist; no quote shown, no engine | ❌ Haggled on arrival | ✅ Fixed fare up-front | ✅ Two-funnel quote | ✅ Flat-rate |
| **In-app payment** | ❌ Placeholder; `tipAmount` schema-only | 🟡 GCash-by-number | ✅ Wallet + cash | ✅ Card | ✅ Cashless |
| **Ratings/reviews** | 🟡 Collected, **never surfaced, never ranks** | ❌ Word-of-mouth | ✅ Shown | ✅ Per-mechanic | ✅ CSAT-driven |
| **Trust/safety + SOS** | 🟡 TESDA+license+gov-ID verified but **no badge in UI**; breakdown-emergency request partly built, **personal-safety SOS absent** | ❌ None | ✅ Training + insurance + SOS + re-verify | ✅ Background check + warranty | ✅ Live track + vetted |
| **Warranty/dispute** | ❌ No warranty; `cancellationReason` field unused | ❌ None | 🟡 Insurance/report | ✅ 12-mo workmanship | 🟡 Enterprise SLA |
| **Supply onboarding** | ✅ 6-step + 1–3 day review; no fast-track | n/a | ✅ Doc→SMS→training→activate | ✅ Selective vet as marketing | ✅ Aggregates incumbents |
| **Growth loop** | ❌ `appliedPromoCode`/referral fields unwired; garage/history inert | ✅ Viral/free | ✅ Rewards + referrals | 🟡 SEO | 🟡 B2B2C |

**Three readings:**
1. **ARS's only genuine strength is live tracking — and even that is half-real** (static-point recompute, not a stream). "Track Everything" is the one tagline the code nearly keeps.
2. **Everything that builds trust is collected-but-invisible.** Verification, ratings, the emergency token — all in the data, none reach the customer's eyes. *Surfacing what you already have is the cheapest, highest-leverage fix in the product.*
3. **Two categories are absent, not partial:** pricing transparency and payments — the exact things the category refs win on and where the free status quo is *free*.

---

## 4. Flow alignment — step-by-step gaps & fixes

### 4.1 Customer flow (`user_*`)
| ARS step | Gap | Fix |
|---|---|---|
| Onboarding → role select | English taglines read foreign; "ARS" opaque/crude | Taglish copy + rename; **one app + role-switch** (avoid Move It split-app trap) |
| Signup/login | **No customer account-deletion** (P0) | Add delete flow + web URL + server wipe |
| Service selection | No price signal; all 4 tiles car-first despite ~4–5× motorcycle | Show estimated **range** per service; add **Motorcycle as a first-class lane**, not a buried specialization |
| Location select | **iOS missing location usage string** (P0) | Add `NSLocationWhenInUseUsageDescription`; foreground-only |
| Live map + ETA | Static-point recompute; "searching" can **spin forever** | Stream live GPS during enRoute; animate marker; **server-side TTL** flips `pending→expired` and offers "widen radius / notify me" |
| Chat | **No moderation** (P0) | Report/Block + abuse queue + EULA clause |
| Payment | Placeholder; no GCash/Maya/cash/escrow | PayMongo/Xendit → GCash+Maya+cards+QR Ph + **cash-on-completion first-class**; authorize-then-capture; tip here (never skim) |
| Feedback | Rating goes into a void | Surface star + count on selection/tracking; use as dispatch tiebreaker; min-N gating |
| Extras (chatbot, garage, history) | Inert | Wire garage/history → maintenance reminders + rebook; **repurpose the AI chatbot as the diagnosis front-door** (§4.3) |

### 4.2 Mechanic flow (`mechanic_*`)
| ARS step | Gap | Fix |
|---|---|---|
| Onboarding (1–3 day review) | High friction vs zero-friction FB group → starves cold-start supply | **Provisional "pending-verified" tier** for limited jobs; fast-track hand-recruited launch mechanics |
| Doc uploads | Effort invisible to customers | Surface as **Verified badge** on the mechanic card |
| Verification status | No ongoing re-verification | Grab-style **random selfie checks** during active periods |
| Dashboard/map | Customer pin **leaks to every mechanic in 10 km** before accept; no push | Sequential nearest-first + specialization filter; **don't reveal precise pin until accept**; FCM push (`notification_service` exists) |
| Accept/decline | Non-transactional `update()` → **two mechanics both "win"** | **Firestore transaction guarded on `status==pending`**; per-offer countdown + auto-fallthrough |
| Status (en route/working) | No fee for wasted travel on en-route cancel | **Mechanic go-fee** (fuel/jeepney time is real PH cost); bidirectional no-show penalties |
| Completion summary | No mandatory proof-of-work | Require before/after photos (`workPhotos` exists) + itemized parts receipt |
| Earnings | Balance **re-queried** from completed jobs (not a ledger); withdrawals request-only | **Append-only `earnings_ledger`**; same-day GCash cashout (free weekly + small-fee instant) |

### 4.3 The diagnosis/quoting problem ("how do you price a repair sight-unseen?")
This is the make-or-break trust mechanic and ARS has **zero** logic for it. Borrow Wrench/YourMechanic's **two-funnel** model + ARS's existing AI chatbot:
- **Funnel A — "I know what I need" → flat-rate menu.** Productized, parts-light jobs (oil change, PMS, tire, battery, brake pads, jumpstart) get a **fixed up-front price**. This is also where you should *lead* (high margin, dispute-resistant, proven PH demand). Maps onto the existing Tire/Brake tiles.
- **Funnel B — "I don't know what's wrong" → photo-triage → paid diagnostic, credited.** Route Engine/"Other" through the **AI chatbot as a photo+symptom triage front-door**, then book a **diagnostic visit at a transparent flat fee, credited toward the repair** if the customer proceeds. The mechanic builds an **itemized in-app quote on-site** the customer **approves before any work begins.**
- **Non-negotiable:** *no work beyond the approved quote without in-app re-confirmation.* This defuses the #1 PH fear (overcharging) and pays for the truck-roll even when it doesn't convert. **Do not** offer instant fixed prices on genuinely diagnosis-dependent jobs (engine/electrical) — that guarantees disputes.

---

## 5. "Best setup" feature blueprint + prioritized roadmap

**(a) Trust & safety** — Verified badge everywhere a mechanic appears · activate the dead `emergency` token into **SOS** (share live location + mechanic identity to a contact + surface 911; "does not replace 911") · Share-My-Repair link · 12-month workmanship guarantee (near-term) → per-job micro-insurance (stretch) · random selfie re-verification.
**(b) Pricing & payments** — two-tier transparent quote (§4.3) · GCash/Maya/cards/QR Ph + **cash-on-completion** (net platform fee from mechanic wallet on cash jobs) · authorize-then-capture light escrow · 100%-pass-through tipping.
**(c) Matching & tracking** — broadcast → **sequential nearest-first-with-timeout** + specialization filter · transactional accept · server TTL expiry · FCM push · **continuous GPS stream** + animated marker. (Don't build Uber-style ML batching — useless under ~10-mechanic density.)
**(d) Ratings & reputation** — surface rating + count · **two-way** rating · min-N gating · rating as dispatch tiebreaker.
**(e) Growth & retention** — **mechanic-refers-mechanic** paid on the referee's *completed* jobs (fraud-proof; cheapest supply growth) · customer service-credit referral · **maintenance reminders → one-tap rebook** from garage+history (highest-ROI demand lever; data already ready).
**(f) Supply-side tools** — append-only earnings ledger · same-day GCash cashout · job-acceptance SLA + reliability score · provisional-verified tier.

### Roadmap
**P0 — submittable + credible:** the four §1 blockers · rotate/delete the leaked ORS key · **surface Verified badge + ratings** (S) · **transactional accept + TTL expiry** (M).
**P1 — parity:** PH payments + escrow + tipping (L) · two-tier transparent quote via AI photo-triage (L) · continuous GPS stream (M) · sequential nearest-first dispatch + push + pin-privacy (M) · earnings ledger + cashout (M) · SOS + share-trip + warranty (M) · cancellation/no-show policy + go-fee (M) · provisional-verified tier (S).
**P2 — growth/differentiation:** **cold-start playbook** (one barangay, 15–20 verified mechanics/category, founder manual dispatch) — *the actual existential risk* · two-sided referral (M) · maintenance reminders → rebook (S) · motorcycle-first lane (M) · rename + Taglish brand (M) · B2B2C/white-label for insurers/fleets — the durable revenue layer (L) · random selfie re-verification (M).

---

## 6. Monetization — store-compliance flags

> Rule of thumb: **if the charge dispatches/schedules a real mechanic or delivers real parts → external (PayMongo/GCash/cash), never IAP.** If the charge unlocks something **consumed inside the app** (premium status, AI credits, training content, paid loyalty perks, boosts, badges) → **IAP/Play Billing, no exceptions.**

| Idea | Flag | Note |
|---|---|---|
| Platform take-rate on labor (mechanic keeps 100% parts) | **OK** | Physical service. Keep low + transparent + line-item to out-recruit FB groups |
| Diagnostic/call-out fee (credited to repair) | **OK** | Monetizes non-converting visits |
| Cash-on-completion w/ fee netted from mechanic wallet | **OK** | No store involvement; mandatory for PH |
| Tipping (100% pass-through) | **OK** | Never skim |
| Cancellation/no-show + mechanic go-fee | **OK** | Service charge, not digital content |
| Instant-cashout convenience fee (mechanic) | **OK** | Payout fee |
| Per-job micro-insurance / workmanship-guarantee fee | **RISK (regulatory)** | PH **Insurance Commission** — needs a licensed partner; a plain "guarantee" w/ clear terms is lower-risk than selling "insurance" |
| Mechanic subscription (priority dispatch / lower take-rate) | **RISK → IAP** | If it unlocks **in-app/digital** perks (badges, analytics) → IAP on iOS. If purely real-world routing, argue physical-service — structure carefully |
| Fleet/B2B SaaS dashboard | **OK** | Sell **via web checkout**, outside the consumer app → no IAP |
| Consumer "[Brand]+" membership | **RISK** | Discounts on real repairs → physical-service; any digital perk → Apple may demand **IAP**. Keep perks strictly service-side |
| Featured/priority mechanic placement (paid) | **IAP** | Selling in-app visibility = digital content → IAP if sold in-app. Sell via web/invoice instead |
| Paid Mechanic Academy / training content | **IAP** | In-app digital content. Keep training **free** or sell B2B on web |
| Paid/premium AI chatbot, extra-message packs, boosts | **IAP** | Pure digital goods. **Today the chatbot is free → fine; the instant you paywall it in-app, it must use IAP** |

**Net:** moving money for a physical repair is **OK** (and dodges the 30%); selling a digital/in-app benefit tips into **IAP** → route those through web checkout. Insurance is a **regulatory** flag, not a store one.

---

## 7. Coherence corrections (from the completeness pass — so the deliverable "matches and flows")

- **Be precise on emergency vs SOS.** This repo *does* have `emergency_panel.dart` + `EMERGENCY_REQUEST_IMPLEMENTATION.md` + a wired `BookingStatus.emergency`. So: **breakdown-emergency *request* = partially built; personal-safety SOS (share-trip to a contact / call-authorities) = absent.** Two different features — don't conflate them.
- **Design degraded states first.** Offline / GPS-denied / empty / **no-mechanic-available** / payment-failed / verification-rejected are largely undesigned. In a thin-supply broadcast model, **"no mechanic available within N seconds" is the modal launch outcome** — it must have a real fallback (queue, widen radius, notify-when-available, fall back to scheduled), not a silent dead-end.
- **The rebrand must propagate.** New name → onboarding copy, role-select, the orphaned `emergency` red token re-cast as the SOS/rescue color, and Taglish taglines. Brand and product move together or not at all.
- **Make the motorcycle wedge real in the UI.** The strategy argues motorcycle-co-equal, but the service picker is still 4 car-first tiles. Add a motorcycle-specific taxonomy where the user actually chooses.

### Single most important next action
**Design the "no mechanic available within N seconds" fallback — paired with the early-supply plan (15–20 verified mechanics/category recruited from the FB/Viber groups you're displacing).** In a broadcast, first-to-accept marketplace with thin launch supply, this is the most-hit state, the moment that decides whether a stranded user ever trusts the app again, and the exact point where "beat free" is won or lost. Everything else (payments, rebrand polish, growth loops) is moot if the core request silently dead-ends.

---

*Method note: grounded in a direct read of this repo (flows, theme tokens, auth repos, Info.plist, bundle id, emergency files) + a multi-agent research/synthesis pass with an adversarial name-verification and store-compliance review. Where a claim is code-verified it is stated as fact; trademark/availability claims are flagged as **requiring a formal IPOPHL + store-name check before any spend.***
