Advanced Topics in Control FS 2024 - Final Project 
=============

Description
-----------
 The scope of this project is the implementation on MATLAB of a distributed and decentralized nonlinear model predictive control that utilize a graph-based description of district heating networks.

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



