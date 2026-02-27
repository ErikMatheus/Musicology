"""
Extract NNLS-like chroma features from audio files using librosa,
saving output in the Sonic Visualiser NNLS Chroma CSV format that
compmus::compmus_wrangle_chroma() expects.

Expected CSV columns: TIME, C, C#, D, Eb, E, F, F#, G, Ab, A, Bb, B
"""

import sys
import numpy as np
import librosa
import csv
import os


PITCH_NAMES = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]

# Librosa internally uses: C C# D D# E F F# G G# A A# B
# We just rename D# -> Eb, G# -> Ab, A# -> Bb


def extract_chroma(audio_path: str, output_csv: str, hop_length: int = 512) -> None:
    print(f"Loading: {audio_path}")
    y, sr = librosa.load(audio_path, mono=True)
    duration = librosa.get_duration(y=y, sr=sr)
    print(f"Duration: {duration:.1f}s, sample rate: {sr}Hz")

    # Constant-Q chroma — closest standard equivalent to NNLS Chroma
    # n_octaves=7 gives better low-frequency resolution (important for bass)
    chroma = librosa.feature.chroma_cqt(
        y=y,
        sr=sr,
        hop_length=hop_length,
        bins_per_octave=36,   # 3 bins per semitone → smoother
        n_octaves=7,
    )  # shape: (12, n_frames)

    n_frames = chroma.shape[1]
    times = librosa.frames_to_time(np.arange(n_frames), sr=sr, hop_length=hop_length)

    print(f"Frames: {n_frames}, writing to: {output_csv}")

    with open(output_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["TIME"] + PITCH_NAMES)
        for i in range(n_frames):
            row = [f"{times[i]:.6f}"] + [f"{v:.6f}" for v in chroma[:, i]]
            writer.writerow(row)

    print("Done.")


if __name__ == "__main__":
    audio_dir = os.path.dirname(os.path.abspath(__file__))
    tracks = [
        ("do_i_wanna_know.wav", "do_i_wanna_know.csv"),
        ("chop_suey.wav",       "chop_suey.csv"),
    ]
    for wav, csv_out in tracks:
        wav_path = os.path.join(audio_dir, wav)
        csv_path = os.path.join(audio_dir, csv_out)
        if os.path.exists(wav_path):
            extract_chroma(wav_path, csv_path)
        else:
            print(f"File not found: {wav_path}")
