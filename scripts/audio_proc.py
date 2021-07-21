import os
import numpy as np
import scipy.signal as scisig
import scipy.io.wavfile as wavio

def convolve_rir(sig, rir):
    if sig.ndim == 1:
        sig = sig[None,:] # (1, samples)
    if rir.ndim == 1:
        rir = rir[None,:] # (1, samples)

    orig_max = np.max(np.abs(sig), axis=1, keepdims=True)
    orig_len = sig.shape[-1]
    convolved = scisig.fftconvolve(sig, rir, mode='full', axes=1)[:, :orig_len]
    out_max = np.max(np.abs(convolved), axis=1, keepdims=True)
    return convolved / out_max * orig_max # (chans, samples)

def write_wav(fname, fs, sig, out_dtype):
    # we do not use librosa.output.write_wav since it will be removed in version 0.8
    out_dtype = np.dtype(out_dtype)
    if np.issubdtype(out_dtype, np.integer):
        sig = ( sig*(-np.iinfo(out_dtype).min) ).astype(out_dtype)
    elif not np.issubdtype(out_dtype, np.floating):
        raise ValueError('Output data type not understood: {}. Please use integer (int16, ...) or floating point (float32, ...) types.'.format(out_dtype))
    os.makedirs(os.path.dirname(fname), exist_ok=True)
    wavio.write(fname, fs, sig)
