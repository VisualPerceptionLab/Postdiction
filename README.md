# Postdiction: Neural Decoding of Audiovisual Illusions

**An adapted high-performance pipeline for collecting and decoding ultra-high resolution brain activity data (7T fMRI & MEG).**

This repository contains the experimental code and analysis pipeline used to investigate *postdictive perception*—how the brain updates past perceptions based on future input. The codebase handles stimulus presentation with millisecond precision and performs high-dimensional time-series decoding to reconstruct visual illusions from neural activity. The code was adapted for previous experiments for stimuli presentation.

### 📄 Reference
**Barkema, P., et al. (2025).** *Deep layers of primary visual cortex encode postdictive perception.*
> Presented at **VSS (Visual Science Society)**, May 2025.
[Video Link](https://www.youtube.com/watch?v=UetvGUnviXQ)
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

## :open_book: Research
I was able to, for the first time in the field, successfully create illusions from this [experiment](https://www.youtube.com/watch?v=yCpsQ8LZOco) in two extremely complex SOTA environments for mapping the brain and its activity: the 7T fMRI scanner (unique hardware setup, millimeter precision, magnetic noise, hardware delays, unique setup) and MEG scanner (millisecond precision, noisy channels, movement artefacts), to get a real-time chart of brain information transmission. The code deals with precise presentation of tones and flashes at the same time with millisecond precision, taking into account fundamental problems, such as human-in-the-loop experiment, visual angles and screen refresh rates.

We used very precise brain mapping methods to reduce millions of brain activity data points to hundreds. We demonstrated that our perception is no livestream, but a post-hoc reconstructed **hallucination** in the brain, created through **faulty** post-hoc revision of incoming information by higher-up areas: like an overconfident boss convincing their expert employee that they are wrong, when they are not. We are now preparing to publish this important evidence on our brain's reality in a **high impact journal**.

## 📂 Repository Structure

```text
├── experiment/       # PsychToolBox scripts for stimulus presentation in 7T fMRI
├── analysis/         # Main decoding and GLM pipelines (MATLAB)
└── MEG/experiment    # PsychToolBox scripts for stimulus presentation in MEG
