"""
Extract MFCC (timbre) features from audio files using librosa,
saving output in the Sonic Visualiser MFCC [libextract] CSV format that
compmus::compmus_wrangle_timbre() expects.

Expected CSV columns: TIME, BIN1, BIN2, ..., BIN21
(compmus drops BIN1/mfcc_01 and nests BIN2-BIN21 as the timbre vector)
"""

import sys
import numpy as np
import librosa
import csv
import os

N_MFCC = 21   # compmus expects BIN1..BIN21; it drops BIN1 and uses BIN2-BIN21


def extract_mfcc(audio_path: str, output_csv: str, hop_length: int = 512) -> None:
    print(f"Loading: {audio_path}")
    y, sr = librosa.load(audio_path, mono=True)
    duration = librosa.get_duration(y=y, sr=sr)
    print(f"Duration: {duration:.1f}s, sample rate: {sr}Hz")

    mfccs = librosa.feature.mfcc(
        y=y,
        sr=sr,
        n_mfcc=N_MFCC,
        hop_length=hop_length,
    )  # shape: (N_MFCC, n_frames)

    n_frames = mfccs.shape[1]
    times = librosa.frames_to_time(np.arange(n_frames), sr=sr, hop_length=hop_length)

    bin_names = [f"BIN{i}" for i in range(1, N_MFCC + 1)]

    print(f"Frames: {n_frames}, writing to: {output_csv}")
    with open(output_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["TIME"] + bin_names)
        for i in range(n_frames):
            row = [f"{times[i]:.6f}"] + [f"{v:.6f}" for v in mfccs[:, i]]
            writer.writerow(row)

    print("Done.")


if __name__ == "__main__":
    audio_dir = os.path.dirname(os.path.abspath(__file__))
    tracks = [
        ("do_i_wanna_know.wav", "do_i_wanna_know_timbre.csv"),
        ("chop_suey.wav",       "chop_suey_timbre.csv"),
    ]
    for wav, csv_out in tracks:
        wav_path = os.path.join(audio_dir, wav)
        csv_path = os.path.join(audio_dir, csv_out)
        if os.path.exists(wav_path):
            extract_mfcc(wav_path, csv_path)
        else:
            print(f"File not found: {wav_path}")
