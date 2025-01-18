# MultiSV2 training data

MultiSV2 train is an extended version of the MultiSV train that is intended to enable training of up-to-date multi-channel embedding extractors. Similarly to MultiSV, it provides 4-channel simulated data with one source of speech and one noise source per example. 

## Speech data
The foreground speech was selected from VoxCeleb2 since it represents a large-scale dataset commonly used to train speaker embedding extractors. Therefore, it provides a wide enough set of recordings from which to select. When selecting speech data from VoxCeleb, there are two contradictory requirements. First, since the recordings serve as a source of speech in spatial simulation, they should be clean. Second, a substantial volume of data is needed to train embedding extractors based on up-to-date architectures. Our data selection relies on an SNR estimate; only recordings with the SNR higher than a threshold are preserved. As a trade-off, we chose a threshold of 15 dB. The data list is eventually post-processed to obtain a gender-balanced set of speakers.

### Statistics of speech data
| Attribute | Value |
| :------------ | :------------: |
| Audio [h] | 1,157 |
| Speech (after VAD) [h] | 1,012 |
| Female speakers | 2,304 |
| Male speakers | 2,304 |
| Files  | 512,604 |


## Noise data
Due to the extensive volume of speech data, we leveraged multiple corpora to obtain a comparable set of noise recordings in terms of duration: [FMA large](https://github.com/mdeff/fma "FMA large"), [WHAM!](http://wham.whisper.ai/ "WHAM!"), [CHiME-3](https://catalog.ldc.upenn.edu/LDC2017S24 "CHiME-3"), original MultiSV, and [FSD50K](https://zenodo.org/records/4060432 "FSD50K"). We did not employ all the clips from the datasets, but we performed a selection to avoid overlap with MultiSV development and evaluation data, diversify noises, and avoid human-vocalized sounds.

| Dataset | Selected data [h] | Selection |
| :------------ | :------------: | :------------ |
| FMA large | 734.0 | avoided overlap with MultiSV dev. and eval.; the selection keeps ratio between music and non-music noises w.r.t. the original MultiSV train |
| WHAM! | 78.5 | all noise data |
| CHiME-3 | 16.8 | noise data only; out of six channels, we always selected only two to limit repetitions  |
| MultiSV | 25.1 | all noise data from the training part |
| FSD50K | 75.9 | recordings containing instruments (except for impact sounds, such as crashes) and human-vocalized clips excluded |

# Simulation
Here, we provide a description of the MultiSV2_train.zip to allow for data preparation that makes use of the [RIR generator](https://github.com/ehabets/RIR-Generator "RIR generator") to simulate room impulse responses (i.e., reverberation).

| Attribute | Description |
| :------------ | :------------ |
| `speech` | relative path to a speech recording |
| `noise` | relative path to a noise recording |
| `noise_cuts` | definition of a noise cut (in seconds) in a form: `<start_time>-<end_time>` |
| `spk_id` | speaker identity string |
| <code>sp\_src\_(x &#124; y &#124;z)</code> | x, y, z coordinates of a speech source |
| <code>noi\_src\_(x &#124; y &#124; z)</code> | x, y, z coordinates of a noise source |
| <code>room\_(x &#124; y &#124; z)</code> | x, y, z dimensions of a room |
| `RT60` | RT60 reverberation time |
| `azim` | microphones' azimuth |
| `elev` | microphones' elevation |
| `polar_pattern` | microphone's polar pattern |
| <code>mic(0 &#124; 1 &#124; 2 &#124; 3)\_(x &#124; y &#124; z)</code>  | x, y, z coordinates of four microphones (indexed from 0 to 3) |
| <code>mic(0 &#124; 1 &#124; 2 &#124; 3)\_snr</code> | mixing SNRs |
