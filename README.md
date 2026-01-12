# Postdiction: Neural Decoding of Audiovisual Illusions

**An adapted high-performance pipeline for collecting and decoding ultra-high resolution brain activity data (7T fMRI & MEG).**

This repository contains the experimental code and analysis pipeline used to investigate *postdictive perception*—how the brain updates past perceptions based on future input. The codebase handles stimulus presentation with millisecond precision and performs high-dimensional time-series decoding to reconstruct visual illusions from neural activity. The code was adapted for previous experiments for stimuli presentation.

### 📄 Reference
**Barkema, P., et al. (2025).** *Deep layers of primary visual cortex encode postdictive perception.*
> Presented at **VSS (Visual Science Society)**, May 2025.

---

## 🚀 Project Overview

This project was built to address the challenge of synchronizing rapid audiovisual stimuli with high-field neuroimaging. The pipeline consists of two main components:
1.  **Experimental Control:** Real-time generation of audiovisual illusions using PsychToolBox, synchronized with 7T fMRI and MEG acquisition triggers.
2.  **Analysis Pipeline:** A decoding framework that processes multi-terabyte neural time-series data to classify subjective perceptual states.

## ⚡ Key Features

* **Millisecond Precision:** Custom synchronization logic to align visual stimuli with scanner acquisition (TRs) with <1ms latency.
* **High-Res Decoding:** Pipelines for preprocessing and multivariate pattern analysis (MVPA) on 7T fMRI data.
* **Automated Workflow:** Bash scripts to automate the preprocessing of large-scale neuroimaging datasets on HPC clusters.

## 🛠️ Tech Stack

* **Languages:** MATLAB (Expert), Bash (Shell Scripting)
* **Libraries:** PsychToolBox (PTB-3), SPM (Statistical Parametric Mapping)
* **Hardware Targets:** Siemens 7T fMRI, MEG (CTF Systems)

## 📂 Repository Structure

```text
├── experiment/       # PsychToolBox scripts for stimulus presentation
├── analysis/         # Main decoding and GLM pipelines (MATLAB)
├── preprocessing/    # Bash/SPM scripts for motion correction and alignment
└── utils/            # Helper functions for timing and synchronization
