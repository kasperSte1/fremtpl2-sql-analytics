# Findings

Portfolio-wide claim frequency: **0.1007** claims per policy-year (678,013 policies,
358,499 policy-years of exposure).

## By region (`q03_frequency_by_region.sql`)

Exposure-weighted claim frequency per region, with each region's relative standard error
beside it (100/sqrt(claims), in %). The query reports only regions whose frequency is
measured to better than 5% relative error, which means more than 400 claims. The threshold
is a chosen precision floor, not a result.

15 of the 22 regions pass. Among them:

- highest: **R11 at 0.1317**, 31% above the portfolio mean
- lowest: **R41 at 0.0753**, 25% below
- worst-to-best ratio: **1.75x**

The two regions with the highest raw frequency (R94, R21) fall below the threshold and
are excluded — the filter changes the ranking rather than tidying it.

## By driver age (`q04_frequency_by_age.sql`)

| Age band | Exposure | Claims | Frequency | vs mean | Rel. std. error |
|---|---|---|---|---|---|
| 18-24 | 12,489 | 2,364 | **0.1893** | **+88%** | 2.06% |
| 25-35 | 73,006 | 7,139 | 0.0978 | −3% | 1.18% |
| 36-44 | 78,985 | 7,402 | 0.0937 | −7% | 1.16% |
| 45-55 | 97,987 | 10,251 | 0.1046 | +4% | 0.99% |
| 56-65 | 51,776 | 4,748 | 0.0917 | **−9%** | 1.45% |
| 66+ | 44,258 | 4,198 | 0.0949 | −6% | 1.54% |

**One effect dominates.** Drivers under 25 have a claim frequency 88% above the
portfolio mean. Every other band sits within ±10% of it. Youngest to safest is a factor
of **2.06** (0.1893 vs 0.0917).

**No upturn at the oldest ages.** Risk is often expected to rise again among the oldest
drivers; it does not here — the 66+ band sits 6% below the portfolio mean.

## By vehicle age and engine power (`q05_risk_grid.sql`)

One variable at a time:

| Vehicle age | Claims | Exposure | Frequency | Rel. std. error |
|---|---|---|---|---|
| 0-2 | 10,904 | 79,176 | **0.1377** | 0.96% |
| 3-11 | 18,254 | 188,602 | 0.0968 | 0.74% |
| 12+ | 6,944 | 90,722 | **0.0765** | 1.20% |

| Engine power | Claims | Exposure | Frequency | Rel. std. error |
|---|---|---|---|---|
| 4-6 | 21,358 | 210,771 | 0.1013 | 0.68% |
| 7-11 | 13,989 | 139,856 | 0.1000 | 0.85% |
| 12-15 | 755 | 7,872 | 0.0959 | 3.64% |

Vehicle age spans 0.1377 to 0.0765 — a factor of 1.80. Engine power spans 0.1013 to
0.0959: the first two bands differ by 0.0013 on tens of thousands of claims each, and the
third rests on 755 claims, too few to say where it really sits. On its own the variable
says nothing.

Both variables together, number of claims behind each cell:

| vehicle age \ power | 4-6 | 7-11 | 12-15 |
|---|---|---|---|
| 0-2 | 6,470 | 4,173 | 261 |
| 3-11 | 10,968 | 6,908 | 378 |
| 12+ | 3,920 | 2,908 | 116 |

Claim frequency in each cell:

| vehicle age \ power | 4-6 | 7-11 | 12-15 |
|---|---|---|---|
| 0-2 | **0.1482** | 0.1270 | 0.0984 |
| 3-11 | 0.0946 | 0.0999 | 0.1078 |
| 12+ | 0.0766 | 0.0768 | **0.0677** |

Every cell outside the 12-15 power column holds more than 2,500 claims, so its relative
standard error stays under 2%. That column holds 755 claims in total, its three cells run
5-9%, and none of them passes the 400-claim threshold used in
`q03_frequency_by_region.sql`.

**Vehicle age is the stronger effect**, and it runs the opposite way to intuition: the
newest cars claim most often, the oldest least. Whether that is the car or the person who
drives an old car is not separable here.

**Engine power reverses direction between age bands.** Among new cars, more power means
fewer claims: 0.1482 against 0.1270, a gap of 7.9 standard errors. Among cars aged 3-11 it
means more claims: 0.0946 against 0.0999, a gap of 3.5. The second effect is much weaker
than the first, but both are too large for chance, and they point opposite ways.
Standard errors on the difference are computed in absolute units: SE(f) = f/√C for each cell,
combined as √(SE₁² + SE₂²). Both comparisons were chosen after inspecting the grid rather than specified
in advance, so the significance levels are optimistic. The stronger effect survives any correction for
multiple comparisons, the weaker one is closer to the line.

## Claim severity (`q06_severity.sql`)

Across the 26,444 claims in `core.claim`:

| | EUR |
|---|---|
| median | 1,172 |
| mean | 2,266 |
| 90th percentile | 2,768 |
| 99th percentile | 16,451 |
| maximum | 4,075,401 |

The mean is almost twice the median — the distribution is heavily right-skewed, so both
are reported: the median for a typical claim, the mean for total cost.

### Severity by driver age

| Age band | Claims | % of claims | % of cost | Mean (EUR) | Median (EUR) | 99th pct (EUR) |
|---|---|---|---|---|---|---|
| 18-24 | 2,011 | **7.6%** | **19.6%** | **5,839** | 1,172 | **28,595** |
| 25-35 | 5,559 | 21.0% | 18.7% | 2,010 | 1,128 | 15,542 |
| 36-44 | 5,606 | 21.2% | 18.5% | 1,974 | 1,172 | 15,012 |
| 45-55 | 7,331 | 27.7% | 22.3% | 1,825 | 1,172 | 15,569 |
| 56-65 | 3,316 | 12.5% | 10.5% | 1,890 | 1,172 | 12,228 |
| 66+ | 2,621 | 9.9% | 10.5% | 2,397 | 1,172 | 20,909 |

**Young drivers' claims differ in the tail, not in the middle.** The median is 1,172 EUR
in this band and in four of the other five — 1,128 in the 25-35 band — but the 99th
percentile reaches 28,595 against 12,000 to 21,000 elsewhere, and the mean is the highest
of the six. The single largest claim in the portfolio, 4,075,400.56 EUR, belongs to a
driver under 25 and carries 34.7% of the band's entire cost; excluding it the mean falls
from 5,838.56 to 3,813.90, still above the 2,287.85 of the next highest band. No other
band draws more than 7.0% from its own largest claim.

The relative standard error used for frequency (1/√N) does not apply to a mean of skewed
amounts, where uncertainty depends on the spread of the values rather than their count.

**Coverage differs across these bands.** Only 73% of the claims declared in `claim_nb`
have a matching row in `core.claim` — the rest were declared but carry no amount
(`sql/03_audit.sql`). The share is not constant: 85% of the claims declared by drivers
under 25 have an amount, against 62% for those over 65, falling monotonically in between.
Each row above is therefore computed from a different fraction of that band's claims,
and the differences between rows cannot be separated from the differences in coverage.

## What these numbers do not show

Every result above breaks the portfolio down by one or two variables at a time; everything
else is left to vary. The tables show that age, region and vehicle characteristics separate
the portfolio. They do not show that any of them causes the difference.

Young drivers also drive different cars, live in different places, and start near the top
of the bonus-malus scale, because they have not had years of claim-free driving to earn a
discount. These characteristics move together, so a difference attributed to age may belong
to any of them. Separating them is not attempted here.

