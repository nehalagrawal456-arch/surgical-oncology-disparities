# Rural-Urban Differences in Breast Cancer Surgery Type (SEER)

**Question:** Among women with early-stage (localized) breast cancer, does the chance of mastectomy, rather than breast-conserving surgery, change as counties become more rural?

**Data:** SEER Research Data, 17 Registries (Nov 2025 submission). Women diagnosed 2004-2022 with localized breast cancer. Patient-level data are not included in this repository, in line with the SEER data use agreement.

**Methods:** R (tidyverse). Surgery codes from RX Summ--Surg Prim Site were grouped as breast-conserving (20-24) and mastectomy (30-80). Counties were classified by the Rural-Urban Continuum Code.

**Preliminary result (unadjusted):** Among 704,242 women who had surgery, the percentage having a mastectomy ranged from about 32% in mid-size metropolitan counties to about 38% in nonmetropolitan counties.

**Status:** Adjusted analysis (age, race, marital status, year of diagnosis) is in progress.

**Related work:** Ayub S, et al. Rurality and income on breast cancer outcomes: an analysis of the SEER database. Ann Surg Oncol. 2026;33(5):4595-4603. This project is a replication and extension of that line of work.

**Files:** `seer_breast_analysis.R` (analysis script), `mastectomy_by_county.png` (figure)