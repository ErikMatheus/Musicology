# Musicology Portfolio

Corpus: my **most-liked** vs **most-skipped** tracks on Spotify.

| Track | Artist | Status |
|---|---|---|
| *Do I Wanna Know?* | Arctic Monkeys | Most-liked (285 plays, ~7% skip) |
| *Chop Suey!* | System of a Down | Most-skipped (100% skip rate) |

---

## Week 9 – Chromagrams, Cepstrograms, and Self-Similarity Matrices

### Chromagrams

![Chromagrams](chromagrams_w09.png)

**Do I Wanna Know?** shows a concentrated and stable harmonic profile throughout. The dominant pitch classes—G, F# and A—reflect the song's modal minor feel, rooted in the key of G minor. The chroma is remarkably consistent: the song barely modulates, and the guitar riff repeating over the whole track locks the chromagram into a near-static pattern.

**Chop Suey!** is strikingly different. The chroma energy is spread more broadly across pitch classes and shifts abruptly at several points (~60 s, ~120 s, ~155 s). These transitions correspond to the song's jarring structural jumps: the drop from the heavy verse into the quiet "Father into your hands" bridge, and back again. The broad chroma spread reflects the highly distorted, drop-D guitar tuning and fast harmonic movement.

---

### Cepstrograms

![Cepstrograms](cepstrograms_w09.png)

The cepstrogram shows how timbral texture (via MFCCs) changes over time.

**Do I Wanna Know?** has a relatively smooth cepstrogram. The low-order MFCCs (mfcc_02–mfcc_04) dominate and are steady, reflecting the track's consistent timbre: clean/slightly overdriven guitar, dry room, and a steady drum groove. The dramatic drop at ~130 s visible in mfcc_02 marks the brief outro where the band strips down to guitar only.

**Chop Suey!** shows violent, rapid fluctuations across all MFCC bands. Coefficients mfcc_02 and mfcc_03 spike sharply wherever the heavy distorted guitar hits, then collapse when the bridge quiets. The contrast between the loud, dense sections and the quiet vocal passages is the most prominent feature. This is exactly what you hear: the song is defined by extreme dynamic and timbral contrasts.

---

### Self-Similarity Matrices

#### Do I Wanna Know?

![SSM – Do I Wanna Know?](ssm_do_i_wanna_know_w09.png)

Both chroma and timbre SSMs reveal a clear block-diagonal structure corresponding to the verse–chorus–verse–chorus–outro form. The **chroma SSM** shows that the verses and choruses have distinct but internally consistent pitch content—the blocks are bright (self-similar) and the off-diagonal transitions are dark. The **timbre SSM** reinforces this: the recurring sections match each other in texture. Notice how the chorus returns are visible as bright off-diagonal rectangles in the timbre matrix, confirming repeated timbral sections (same mix, same instrumentation).

#### Chop Suey!

![SSM – Chop Suey!](ssm_chop_suey_w09.png)

The **chroma SSM** for Chop Suey! shows a more fragmented structure. The song has many short, distinct sections (intro, verse, pre-chorus, chorus, bridge, solo, outro), each with different harmonic content, resulting in smaller, less uniform blocks. The **timbre SSM** makes the contrast even starker: the quiet bridge (~100–140 s) is a clearly isolated dark block—almost nothing else in the song sounds like it timbrally. This matches what you hear: the "Father into your hands" section is almost whisperer-quiet and acoustically completely different from the surrounding wall-of-sound sections.

**Overall:** *Do I Wanna Know?* has clearer, more regular self-similarity structure (consistent timbral and harmonic identity across repeating sections). *Chop Suey!* has a more fragmented structure that reflects its genre—a metal track built on shock, contrast, and sudden dynamic shifts.

---

## Code

- [`compmus2026-w08.R`](compmus2026-w08.R) — Week 8 chromagram comparison
- [`compmus2026-w09.R`](compmus2026-w09.R) — Week 9: chromagrams, cepstrograms, SSMs
- [`compmus_audio/extract_chroma.py`](compmus_audio/extract_chroma.py) — CQT chroma extraction (librosa)
- [`compmus_audio/extract_mfcc.py`](compmus_audio/extract_mfcc.py) — MFCC timbre extraction (librosa)
