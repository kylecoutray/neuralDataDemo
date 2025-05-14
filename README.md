

Explanation and Demo Video Below:
[[LINK HERE](https://www.youtube.com/watch?v=2fx3IunkOzM)]

<a href="https://www.youtube.com/watch?v=2fx3IunkOzM" target="_blank">
  <img src="https://img.youtube.com/vi/2fx3IunkOzM/maxresdefault.jpg" alt="Watch the video" width="300"/>
</a>

---

This project analyzes single-unit recordings from the primate prefrontal cortex during a spatial working memory task. The goal is to quantify and visualize spatial tuning of neurons across different task epochs: **fixation**, **cue**, and **delay**.

It supports both **population-level summaries** and **individual neuron deep-dives**, with tools for computing spike-based tuning metrics, running ANOVA, and generating clean, interpretable figures.

---

## 📁 Folder Contents

| File                                | Description                                                                                  |
| ----------------------------------- | -------------------------------------------------------------------------------------------- |
| `analyzeAllEpochs.m`                | Main pipeline: processes all `.mat` neuron files and extracts tuning data per epoch.         |
| `analyzeEpochSpikes.m`              | Helper function: computes spike counts and real ANOVA per class for a given epoch.           |
| `enrichEpochSummary.m`              | Adds derived metrics like Selectivity Index (SI), tuning flags, and significance to results. |
| `generateSummaryFigures.m`          | Plots heatmaps, tuning distributions, and % of tuned neurons for population analysis.        |
| `plotSpatialTuningMap.m`            | Shows tuning maps + PSTH across epochs for a single neuron (all trials).                     |
| `plotSpatialTuningMap_Conditions.m` | Same as above, but split by **Match vs. Nonmatch** trials.                                   |
| `Neuron_Data_PSTHCue_All.m`         | Provided script for cue-aligned PSTH plotting (single neuron).                               |
| `Neuron_Data_RastersActive.m`       | Provided script for plotting spike rasters (single neuron).                                  |
| `NeuronList3_APostonly.xlsx`        | Excel metadata list of neurons (not required to run pipeline).                               |
| `epoch_spike_analysis.mat`          | Output file: spike tuning results for all neurons.                                           |
| `epoch_spike_analysis_enriched.mat` | Enriched output: includes selectivity metrics and p-values.                                  |
| `driveLink.txt`                     | Download link for sample neural data.                                                        |

---

## 📦 Requirements

* MATLAB R2020+
* All `.mat` neural data files (e.g., `ADR001_1_3000.mat`) should be placed in the working directory

---

## 🧭 How to Use

### 🔁 Full Analysis Pipeline

Run the following scripts **in order**:

1. **`analyzeAllEpochs.m`**
   → Loops through all neurons, extracts tuning vectors and ANOVA results for each epoch.

2. **`enrichEpochSummary.m`**
   → Adds Selectivity Index, tuning flags, and stores the final results table.

3. **`generateSummaryFigures.m`**
   → Produces heatmaps, SI distributions, and tuning proportions across the neuron population.

---

### 🔍 Optional: Deep-Dive Into Single Neurons

After generating the summary:

* Run **`plotSpatialTuningMap.m`**
  → View one neuron's tuning across epochs (Fixation, Cue, Delay) and its PSTH.

* Run **`plotSpatialTuningMap_Conditions.m`**
  → Split tuning/PSTH by **Match vs. Nonmatch** trials to identify condition-specific responses.

---

## 📊 Output Examples

* **Population heatmaps** of tuning (neurons × cue location)
* **Selectivity index histograms**
* **Tuning proportion bar plots**
* **Per-neuron spatial heatmaps and PSTHs**

Let me know if you have any issues or questions!
