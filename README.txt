Advanced Topics in Control FS 2024 - Final Project 
=============

Description
-----------
This project presents a distributed nonlinear model predictive control for district heating networks. Exploiting a graph-based modeling of the thermal dynamics, our controller optimizes the mass flow absorption of buildings in a distributed cooperative scheme that mediates between the superior performance of the centralized control and the privacy preservation of the decentralized schemes.
A benchmark three-building network simulation is used to compare the performance of the proposed solution with a decentralized model predictive control scheme.


Folders structure
------------
1. DecMPC
	main_DecMPC		: The nmpc MATLAB is initialized and the Simulink simulation set up. 
	Simulator_DecMPC	: The DecMPC is implemented and simulated in Simulink. 
	DecentralizedFunctions	: All functions, namely cost, state, constraints,... are defined in this folder.

2. DMPC_matlab
	main_DMPC		: The nmpc MATLAB is initialized, the ADMM implemented and the simulation set up. 
	DistributedFunctions	: All functions, namely cost, state, constraints,... are defined in this folder.

3. DMPC
	The DMPC is partially implemented also in Simulink, but for time reasons the implementation is not completed.


4. Plant 
	Plant refernece model defined in Simulink.

5. Plots

6. Results

7. .gitignore

8. setup 
	This code must be run once before the others to set all the necessary parameters and folders



