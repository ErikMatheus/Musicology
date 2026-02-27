library(readr)
library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(stringr)
library(compmus)

# ── Load data ──────────────────────────────────────────────────────────────────

diw_chroma   <- read_csv("compmus_audio/do_i_wanna_know.csv")
chop_chroma  <- read_csv("compmus_audio/chop_suey.csv")
diw_timbre   <- read_csv("compmus_audio/do_i_wanna_know_timbre.csv")
chop_timbre  <- read_csv("compmus_audio/chop_suey_timbre.csv")


# ── 1. Chromagrams ─────────────────────────────────────────────────────────────

make_chromagram <- function(dat, label) {
  dat |>
    compmus_wrangle_chroma() |>
    mutate(pitches = map(pitches, compmus_normalise, "manhattan")) |>
    compmus_gather_chroma() |>
    mutate(track = label)
}

bind_rows(
  make_chromagram(diw_chroma,  "Do I Wanna Know? — Arctic Monkeys"),
  make_chromagram(chop_chroma, "Chop Suey! — System of a Down")
) |>
  mutate(
    track      = factor(track, levels = unique(track)),
    pitch_class = factor(
      pitch_class,
      levels = c("C","C#","D","Eb","E","F","F#","G","Ab","A","Bb","B")
    )
  ) |>
  ggplot(aes(x = start + duration / 2, width = duration,
             y = pitch_class, fill = value)) +
  geom_tile() +
  facet_wrap(~track, ncol = 1, scales = "free_x") +
  scale_fill_viridis_c(option = "magma", name = "Magnitude\n(Manhattan)") +
  scale_x_continuous(name = "Time (s)", expand = expansion(mult = 0)) +
  labs(title = "Chromagrams", y = NULL) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid       = element_blank(),
    strip.text       = element_text(face = "bold", size = 9),
    legend.position  = "right"
  )

ggsave("chromagrams_w09.png", width = 11, height = 6.5, dpi = 180)
message("Saved chromagrams_w09.png")


# ── 2. Cepstrograms ────────────────────────────────────────────────────────────

make_cepstrogram <- function(dat, label) {
  dat |>
    compmus_wrangle_timbre() |>
    mutate(timbre = map(timbre, compmus_normalise, "manhattan")) |>
    compmus_gather_timbre() |>
    mutate(track = label)
}

bind_rows(
  make_cepstrogram(diw_timbre,  "Do I Wanna Know? — Arctic Monkeys"),
  make_cepstrogram(chop_timbre, "Chop Suey! — System of a Down")
) |>
  mutate(track = factor(track, levels = unique(track))) |>
  ggplot(aes(x = start + duration / 2, width = duration,
             y = mfcc, fill = value)) +
  geom_tile() +
  facet_wrap(~track, ncol = 1, scales = "free_x") +
  scale_fill_viridis_c(option = "plasma", name = "Magnitude\n(Manhattan)") +
  scale_x_continuous(name = "Time (s)", expand = expansion(mult = 0)) +
  labs(title = "Cepstrograms (MFCC timbre features)", y = "MFCC coefficient") +
  theme_minimal(base_size = 11) +
  theme(
    plot.title      = element_text(face = "bold"),
    panel.grid      = element_blank(),
    strip.text      = element_text(face = "bold", size = 9),
    legend.position = "right"
  )

ggsave("cepstrograms_w09.png", width = 11, height = 6.5, dpi = 180)
message("Saved cepstrograms_w09.png")


# ── 3. Self-similarity matrices (chroma + timbre, side by side) ───────────────

ssm_pair <- function(chroma_dat, timbre_dat, title_label) {
  bind_rows(
    chroma_dat |>
      compmus_wrangle_chroma() |>
      filter(row_number() %% 50L == 0L) |>
      mutate(pitches = map(pitches, compmus_normalise, "manhattan")) |>
      compmus_self_similarity(pitches, "manhattan") |>
      filter(!is.na(d)) |>
      mutate(d = d / max(d), type = "Chroma"),
    timbre_dat |>
      compmus_wrangle_timbre() |>
      filter(row_number() %% 50L == 0L) |>
      mutate(timbre = map(timbre, compmus_normalise, "euclidean")) |>
      compmus_self_similarity(timbre, "cosine") |>
      filter(!is.na(d)) |>
      mutate(d = d / max(d), type = "Timbre")
  ) |>
    ggplot(aes(
      x      = xstart + xduration / 2,
      width  = 100 * xduration,
      y      = ystart + yduration / 2,
      height = 100 * yduration,
      fill   = d
    )) +
    geom_tile() +
    coord_fixed() +
    facet_wrap(~type) +
    scale_fill_viridis_c(guide = "none") +
    theme_classic() +
    labs(title = title_label, x = "Time (s)", y = "Time (s)") +
    theme(
      plot.title  = element_text(face = "bold"),
      strip.text  = element_text(face = "bold")
    )
}

ssm_diw  <- ssm_pair(diw_chroma,  diw_timbre,
                     "Self-similarity matrices — Do I Wanna Know?")
ssm_chop <- ssm_pair(chop_chroma, chop_timbre,
                     "Self-similarity matrices — Chop Suey!")

ggsave("ssm_do_i_wanna_know_w09.png", ssm_diw,  width = 10, height = 5, dpi = 180)
ggsave("ssm_chop_suey_w09.png",       ssm_chop, width = 10, height = 5, dpi = 180)
message("Saved ssm_do_i_wanna_know_w09.png and ssm_chop_suey_w09.png")
