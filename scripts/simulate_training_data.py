import os
import argparse
import math

import numpy as np
import pandas as pd
import librosa

from audio_proc import convolve_rir, write_wav

def simulate_data(speech_dir, noise_dir, rir_dir, csv, out_dir, speech_ext, noise_ext, rir_ext, fs=16000, out_dtype='int16', save_mix=True, save_separate=True):
    os.makedirs(out_dir, exist_ok=True)
    missing_examples = 0

    simu_definition = pd.read_csv(csv)
    for _, row in simu_definition.iterrows():
        speech_path     = os.path.join(speech_dir, row['speech']      + '.' + speech_ext)
        noise_path      = os.path.join(noise_dir,  row['noise']       + '.' + noise_ext)
        speech_rir_path = os.path.join(rir_dir,    row['speech_RIR']  + '.' + rir_ext)
        noise_rir_path  = os.path.join(rir_dir,    row['noise_RIR']   + '.' + rir_ext)

        print('Simulating: {}, SNR={}'.format(row['speech'], row['SNR']))

        # check existence of files
        files = [speech_path, noise_path, speech_rir_path, noise_rir_path]
        files_exist = [os.path.exists(f) for f in files]
        if not all(files_exist):
            print('WARNING: Missing files detected:')
            print('  '+' '.join([f for idx, f in enumerate(files) if not files_exist[idx]]))
            print('  Please make sure that all files have been correctly downloaded. Current example will be skipped.')
            missing_examples += 1
            continue

        # load signals
        noise_offset = row['noise_start']/fs # [s] float
        noise_duration = (row['noise_end'] - row['noise_start'])/fs
        speech_sig, _      = librosa.load(speech_path,     sr=fs, dtype='float32') # (samples,)
        noise_sig, _       = librosa.load(noise_path,      sr=fs, dtype='float32', offset=noise_offset, duration=noise_duration) # (samples,)
        speech_rir_sig, _  = librosa.load(speech_rir_path, sr=fs, dtype='float32', mono=False) # (chans, samples)
        noise_rir_sig, _   = librosa.load(noise_rir_path,  sr=fs, dtype='float32', mono=False) # (chans, samples)
        
        # repetition of the noise that is smaller than the speech
        noise_sig = np.tile(noise_sig, math.ceil(len(speech_sig)/len(noise_sig)))[:len(speech_sig)]

        # convolve signals
        reverb_speech_sig = convolve_rir(speech_sig, speech_rir_sig) # (chans, samples)
        reverb_noise_sig  = convolve_rir(noise_sig,  noise_rir_sig)  # (chans, samples)

        for idx, (rev_speech, rev_noise) in enumerate(zip(reverb_speech_sig, reverb_noise_sig)):
            # centering
            rev_speech -= np.mean(rev_speech)
            rev_noise  -= np.mean(rev_noise)
    
            orig_max = np.max(np.abs(rev_speech))
            speech_power = np.mean(np.power(rev_speech, 2))
            noise_power  = np.mean(np.power(rev_noise, 2))
            # compute noise scalar
            c = (speech_power/noise_power)*10**(-float(row['SNR'])/10)
            rev_noise *= np.sqrt(c)

            mix = rev_speech + rev_noise
            scalar = orig_max/np.max(np.abs(mix))
            rev_speech *= scalar
            rev_noise  *= scalar

            if save_separate:
                out_speech_path = os.path.join(out_dir, row['speech'] + f'_{idx}_speech.wav')
                out_noise_path  = os.path.join(out_dir, row['speech'] + f'_{idx}_noise.wav')
                print('..saving separate files: {}, {}'.format(out_speech_path, out_noise_path))
                write_wav(out_speech_path, fs, rev_speech, out_dtype)
                write_wav(out_noise_path,  fs, rev_noise,  out_dtype)
            if save_mix:
                out_mix_path = os.path.join(out_dir, 'mix', row['speech'] + f'_{idx}.wav')
                print('..saving mixture file: {}'.format(out_mix_path))
                write_wav(out_mix_path, fs, mix*scalar, out_dtype)

    print('Simulation finished')
    if missing_examples != 0:
        print('  {} missing examples detected. Please see the log for more details.'.format(missing_examples))
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--speech_dir', required=True, help='Directory containing speech data')
    parser.add_argument('-n', '--noise_dir',  required=True, help='Directory containing noise data')
    parser.add_argument('-r', '--rir_dir',    required=True, help='Directory containing room impulse responses')
    parser.add_argument('-c', '--csv',        required=True, help='Definition of simulated files in a form of a CSV file')
    parser.add_argument('-o', '--out_dir',    required=True, help='A directory simulated files will be stored in')

    parser.add_argument('--fs',          default=16000, type=int, help='Target sampling frequency')
    parser.add_argument('--speech_ext',  default='m4a',           help='Extension of speech audio files')
    parser.add_argument('--noise_ext',   default='wav',           help='Extension of noise audio files')
    parser.add_argument('--rir_ext',     default='wav',           help='Extension of RIR audio files')
    parser.add_argument('--out_dtype',   default='int16',         help='Data type of the output files samples')
    parser.add_argument('--no_mix',      action='store_true',     help='Do not save mixed signals')
    parser.add_argument('--no_separate', action='store_true',     help='Do not save separate speech and noise signals')
    args = parser.parse_args()

    assert not (args.no_mix and args.no_separate), 'Will do nothing because both "--no_mix" and "--no_separate" were required.'

    # print CL arguments
    max_arg_len = max([len(k) for k in args.__dict__.keys()])
    print('='*80)
    print(__file__)
    print('-'*80)
    for a,v in args.__dict__.items():
        print('{}:{}{}'.format(a, ' '*(max_arg_len-len(a)+1), v))
    print('='*80)

    simulate_data(
        args.speech_dir,
        args.noise_dir,
        args.rir_dir,
        args.csv,
        args.out_dir,
        args.speech_ext,
        args.noise_ext,
        args.rir_ext,
        fs=args.fs,
        out_dtype=args.out_dtype,
        save_mix=(not args.no_mix),
        save_separate=(not args.no_separate),
    )
