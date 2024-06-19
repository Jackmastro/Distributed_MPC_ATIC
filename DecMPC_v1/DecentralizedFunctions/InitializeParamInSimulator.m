function InitializeParamInSimulator(NameSimulatorFile, NameHouseSubSystem, obj)
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'rho', num2str(obj.rho_w));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'c_p', num2str(obj.cp_w));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'f_Darcy', num2str(obj.f_Darcy));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_F', num2str(obj.L_F));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_F', num2str(obj.D_F));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_R', num2str(obj.D_R));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_BYP', num2str(obj.L_BYP));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_BYP', num2str(obj.D_BYP));     
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_S1', num2str(obj.L_S1));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_S1', num2str(obj.D_S1));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_S2', num2str(obj.L_S2));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_S2', num2str(obj.D_S2));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_S3', num2str(obj.L_S3));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_S1', num2str(obj.h_S1));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_S2', num2str(obj.h_S2));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_b', num2str(obj.h_b));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_F', num2str(obj.h_F));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_R', num2str(obj.h_R));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'A_b', num2str(obj.A_b));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'C_b', num2str(obj.C_b));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_F', num2str(obj.D_F));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_R', num2str(obj.D_R));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_BYP', num2str(obj.L_BYP));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_BYP', num2str(obj.D_BYP));     
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_S1', num2str(obj.L_S1));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_S1', num2str(obj.D_S1));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_S2', num2str(obj.L_S2));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'D_S2', num2str(obj.D_S2));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'L_S3', num2str(obj.L_S3));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_S1', num2str(obj.h_S1));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_S2', num2str(obj.h_S2));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'h_b', num2str(obj.h_b)); 
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'T_F_0', num2str(obj.T_F_0));  
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'T_S1_0', num2str(obj.T_S1_0)); 
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'T_S2_0', num2str(obj.T_S2_0));  
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'T_S3_0', num2str(obj.T_S3_0));
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'T_b_0', num2str(obj.T_b_0));  
      set_param([NameSimulatorFile '/' NameHouseSubSystem], 'T_R_0', num2str(obj.T_R_0));

          



