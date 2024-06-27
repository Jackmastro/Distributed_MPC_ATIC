function [outputObj] = CustomizedParamsA(A)

A.T_b_0 = 273 + 15;

A.params = [  A.rho_w; %1
              A.cp_w;
              A.V_F ;
              A.h_F ;
              A.A_F ; %5
              A.L_F ;
              A.D_F ;                          
              A.V_S1 ;
              A.h_S1 ;
              A.A_S1 ; %10
              A.L_S1 ;
              A.D_S1 ;
              A.V_S2 ;
              A.h_S2 ;
              A.A_S2 ; %15
              A.L_S2 ;
              A.D_S2 ;
              A.h_b  ;
              A.A_b  ;
              A.C_b  ; %20
              A.V_S3 ;
              A.h_S3 ;
              A.A_S3 ;
              A.L_S3 ;
              A.D_S3 ; %25
              A.V_R ;
              A.h_R ;
              A.A_R ;
              A.L_R ;
              A.D_R ; %30
              A.V_BYP ;
              A.h_BYP ;
              A.A_BYP ;
              A.L_BYP ;
              A.D_BYP ; %35                          
              A.f_Darcy;
              A.DeltaP_S1_max;
              A.DeltaP_S2_max;
              A.DeltaP_S3_max;
              A.T_set; %40 SPACE HOLDER
              A.T_amb; % SPACE HOLDER
              A.K;
              A.Ts;
              A.Q_disc;
              A.nx; %45
              A.ny;
              A.nu_mv;
              A.nu_md;
              A.is_bypass_house;
              A.is_first_house; %50
              A.delta_m_O_pred;
              A.delta_m_O_succ;
              A.delta_m_R_pred;
              A.delta_m_R_succ;
              A.delta_T_F_pred; %55
              A.delta_T_F_succ;
              A.delta_T_R_pred;
              A.delta_T_R_succ; %58
              A.Q_F;   
              A.Q_S1; % 60 
              A.Q_S3;  
              A.Q_R;  % 62 
              A.R_BYP;
              A.R_U
              A.T_F_HP_min; % 65
              A.T_F_HP_max;
              A.m_dot_F_HP_max;
              A.m_dot_F_HP_MaxRate; %68
              A.m_dot_F_HP_MinRate;
              A.T_F_HP_MaxRate; %70
              A.T_F_HP_MinRate];
A.paramsCell = {A.params};
A.nlobj = A.createNMPC();
outputObj = A;
end