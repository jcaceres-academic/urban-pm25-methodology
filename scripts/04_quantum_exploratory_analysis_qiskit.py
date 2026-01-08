############################################################
# Script 04 – Quantum architecture demonstration (NISQ)
# Project: Urban PM2.5 Methodology
#
# Methodological role:
# - Demonstrate the integration of a quantum-based model
#   within an existing analytical pipeline.
# - This script does NOT aim to outperform classical models.
# - No performance comparison is intended.
#
# Pipeline stage:
# Modelisation and analysis – Advanced architectures
############################################################

# ----------------------------------------------------------
# 1. Imports and environment configuration
# ----------------------------------------------------------

import numpy as np
import pandas as pd

from sklearn.preprocessing import MinMaxScaler
from sklearn.svm import SVR
from sklearn.metrics import mean_absolute_error, mean_squared_error

from qiskit_aer import Aer
from qiskit.circuit.library import zz_feature_map
from qiskit_machine_learning.kernels import FidelityQuantumKernel


# ----------------------------------------------------------
# 2. Load clean dataset (same source as classical pipeline)
# ----------------------------------------------------------

data_file = "../data/PM25_EscuelasAguirre_Daily_2021_2023_clean.csv"

pm25 = pd.read_csv(data_file, parse_dates=["date"])
pm25 = pm25.sort_values("date")

print("Dataset loaded successfully.")
print("Number of observations:", len(pm25))

# ----------------------------------------------------------
# 3. Minimal feature selection (low-dimensional by design)
# ----------------------------------------------------------
# Note:
# Low dimensionality is required due to NISQ constraints.
# This choice is methodological, not performance-driven.

pm25["lag_1"] = pm25["pm25_ug_m3"].shift(1)
pm25["month"] = pm25["date"].dt.month

pm25 = pm25.dropna()

X = pm25[["lag_1", "month"]].values
y = pm25["pm25_ug_m3"].values

# Feature scaling is required for quantum encoding
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)

# ----------------------------------------------------------
# 4. Time-based train–test split (pipeline consistency)
# ----------------------------------------------------------

train_mask = pm25["date"] < "2023-01-01"

X_train, X_test = X_scaled[train_mask], X_scaled[~train_mask]
y_train, y_test = y[train_mask], y[~train_mask]

print("Train samples:", X_train.shape[0])
print("Test samples :", X_test.shape[0])

# ----------------------------------------------------------
# Subsample training data (NISQ constraint)
# ----------------------------------------------------------

max_train_samples = 50  # intentionally small for NISQ feasibility

X_train = X_train[:max_train_samples]
y_train = y_train[:max_train_samples]

print("Quantum training samples used:", X_train.shape[0])

# ----------------------------------------------------------
# 5. Quantum feature map and kernel definition
# ----------------------------------------------------------
# The quantum circuit is executed on a simulator.
# No claim of quantum advantage is made.

feature_map = zz_feature_map(
    feature_dimension=2,
    reps=1
)

backend = Aer.get_backend("statevector_simulator")

quantum_kernel = FidelityQuantumKernel(
    feature_map=feature_map
)

print("Quantum kernel successfully initialised.")

# ----------------------------------------------------------
# 6. Hybrid classical–quantum regression model
# ----------------------------------------------------------

qsvr = SVR(kernel=quantum_kernel.evaluate)

qsvr.fit(X_train, y_train)
y_pred = qsvr.predict(X_test)

print("Quantum-based regression executed successfully.")

# ----------------------------------------------------------
# 7. Methodological evaluation (sanity check)
# ----------------------------------------------------------
# Metrics are reported for stability verification only.
# They are NOT intended for comparison with classical models.

mae = mean_absolute_error(y_test, y_pred)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))

print("\nMethodological evaluation (quantum architecture):")
print("MAE :", round(mae, 3))
print("RMSE:", round(rmse, 3))

print(
    "\nNote: These results are reported solely to verify "
    "the functional integration of a quantum model within "
    "the analytical pipeline under NISQ constraints."
)

# ----------------------------------------------------------
# End of Script 04
# ----------------------------------------------------------
