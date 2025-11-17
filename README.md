# Ambisource – Ambisonic Source Detection Toolkit

Ambisource is a MATLAB-based command-line toolkit for detecting and visualizing sound sources using **First-Order Ambisonics (FOA)**.
It provides tools for:

* **Single-source localization** on a sphere
* **Multi-source localization**
* **Space localization using two FOA recorders**
* **Visualization** of detected directional paths

This repository contains a modular CLI (`ambisource.m`) and all detection and visualization subcommands.

---

## 0. Start MATLAB in CLI mode (recommended)

```bash
matlab -nodesktop
```

This opens MATLAB without GUI, ideal for command-line workflows and batch processing.

---

## 1. Launch Ambisource

Inside MATLAB:

```matlab
ambisource
```

This displays the main help page, lists all detection and visualization commands, and shows usage patterns.

---

## Installation

Clone the repository from GitHub:

```bash
git clone https://github.com/basemare/ambisource.git
```

Then add the folder to your MATLAB path:

```matlab
addpath(genpath('ambisource'));
savepath;
```

---

# Detection Tools

### 1) Single-Source Detection on One Sphere

**JSON output (full range):**

```bash
ambisource detect single sphere example_rec.wav 48000 out json res=1 fps=30
```

Creates:

```
out/directions.json
```

**PNG generation (time-range 3m25s to 3m35s):**

```bash
ambisource detect single sphere example_rec.wav 48000 out pngs res=1 fps=30 t0=3:25 t1=3:35
```

Creates:

```
out/frames/*.png
```

---

### 2) Multi-Source Detection on One Sphere

(Not implemented yet, help available)

```bash
ambisource detect multiple sphere
```

---

### 3) Single-Source Localization in Space (Two FOA Spheres)

(Not implemented yet)

```bash
ambisource detect single space
```

---

### 4) Multi-Source Localization in Space

(Not implemented yet)

```bash
ambisource detect multiple space
```

---

# Visualization Tools

Visualization converts **directions.json** to images.

### 1) Visualize Single-Sphere Directions

```bash
ambisource visualize single sphere examples/directions.json
```

Creates:

```
directions.png
```

This is an **equirectangular (360×180) point-based path plot** of azimuth and elevation.

---

### 2) Other Visualization Modes

Help available:

```bash
ambisource visualize multiple sphere
ambisource visualize single space
ambisource visualize multiple space
```

---

# File Structure

```
ambisource.m
detect_single_sphere.m
detect_multiple_sphere.m
detect_single_space.m
detect_multiple_space.m
visualize_single_sphere.m
visualize_multiple_sphere.m
visualize_single_space.m
visualize_multiple_space.m
examples/
    example_rec.wav
    directions.json
```

---

# Notes

* All help messages come from each script’s top comment block.
* Options are passed as `key=value` (e.g., `res=2 fps=15`).
* Time ranges accept **seconds** or **MM:SS** formats.

---


# Repository

GitHub:
**[https://github.com/basemare/ambisource.git](https://github.com/basemare/ambisource.git)**

