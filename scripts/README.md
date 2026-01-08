# Scripts — Urban PM2.5 Methodology

This directory contains the executable scripts implementing the analytical pipeline of the Urban PM2.5 Methodology project.

The scripts are designed to be executed sequentially and produce all results programmatically.  
They prioritise reproducibility and methodological coherence over model optimisation.

---

## Script list

### 01_data_and_preprocessing.R
- Loads and cleans the raw PM2.5 dataset.
- Handles missing values and temporal parsing.
- Produces the clean dataset used by all subsequent analyses.

**Output**
- `data/PM25_EscuelasAguirre_Daily_2021_2023_clean.csv`

---

### 02_exploratory_and_correlation_analysis.R
- Performs exploratory analysis of the PM2.5 time series.
- Generates descriptive statistics and visualisations.
- Identifies seasonal patterns and missing temporal segments.

**Output**
- Figures stored in `figures_tiff/`

---

### 03_modelling_and_evaluation.R
- Implements simple classical models (baseline and linear).
- Applies time-based train–test splitting.
- Reports MAE and RMSE for methodological evaluation.

---

### 04_quantum_exploratory_analysis_qiskit.py
- Demonstrates the integration of a quantum architecture within the pipeline.
- Uses a quantum kernel-based regression under NISQ constraints.
- Training is performed on a reduced subset by design.

**Note**
This script is demonstrative and does not claim quantum advantage.

---

## Execution order

1. `01_data_and_preprocessing.R`  
2. `02_exploratory_and_correlation_analysis.R`  
3. `03_modelling_and_evaluation.R`  
4. `04_quantum_exploratory_analysis_qiskit.py`

---

## Execution environments

- Scripts 01–03: **R**
- Script 04: **Python (conda environment with Qiskit)**

Refer to the main project documentation for methodological context.


