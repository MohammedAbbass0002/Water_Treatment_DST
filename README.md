# Decision-Support Tool (DST) for Wastewater Treatment Plant Retrofitting

A MATLAB-based dynamic decision-support framework designed to evaluate legacy wastewater treatment plants (WWTPs) and optimize structural upgrades to meet **Egyptian Code (ECP 501-2015) Grade A** standards for unrestricted agricultural reuse.

## 🧪 Mathematical Methodology
The tool integrates advanced environmental engineering models to ensure predictive accuracy:
* **Biological Kinetics:** Utilizes first-order decay kinetics to dynamically size biological reactors for organic removal.
* **Disinfection Modeling:** Applies the Chick-Watson law to determine precise UV radiation doses required for pathogen inactivation.
* **Multi-Objective Optimization:** Implements a Mixed-Integer Linear Programming (MILP) algorithm to minimize CAPEX/OPEX and specific energy consumption (SEC) while maximizing resource recovery.

## 🏭 Empirical Validation (Case Studies)

### 1. Zenin WWTP Analysis
Diagnostic phase revealed adequate organic performance but a critical failure in microbial safety standards.

**Baseline Diagnostic vs. Egyptian Code:**
<p align="center">
  <img src="images/ZENIN before Modifications.jpeg" width="800">
</p>
*The system identified a microbial gap, with Coliform counts exceeding regulatory safety thresholds.*

**Optimization Results (Baseline vs. Predicted):**
<p align="center">
  <img src="images/ZENIN with Modifications.jpeg" width="800">
</p>
*By applying a targeted UV dose of 29.8 mJ/cm^2, the tool predicted a compliant microbial output.*

---

### 2. Abu Rawash WWTP Analysis
This facility faced a catastrophic organic crisis (BOD at 240 mg/L), requiring a comprehensive engineering overhaul.

**Baseline Diagnostic vs. Egyptian Code:**
<p align="center">
  <img src="images/ABU RAWASH before Modifications.jpeg" width="800">
</p>
*Dashboard visualization showing extreme non-compliance across BOD, TSS, and Pathogen parameters.*

**Optimization Results (Baseline vs. Predicted):**
<p align="center">
  <img src="images/ABU RAWASH with Modifications.jpeg" width="800">
</p>
*The proposed advanced secondary treatment achieved a 96.8% BOD removal efficiency and enabled significant energy recovery.*

## 💡 Key Project Impact
* ✅ **Regulatory Compliance:** Ensures 100% alignment with ECP 501-2015 Grade A.
* ⚡ **Operational Efficiency:** Reduces OPEX by up to 35% through energy-optimized retrofitting.
* 🌱 **Sustainable Reclamation:** Transforms hazardous effluent into a safe water resource.

## 🛠 Requirements
* MATLAB (R2021a or later).
* Optimization Toolbox.
* Statistics and Machine Learning Toolbox.

---
*Developed as part of the Wastewater Engineering Research & Development Initiative.*
