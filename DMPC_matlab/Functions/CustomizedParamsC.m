function [outputObj] = CustomizedParamsC(C)
C.Q_disc = 3*1e5;

delta_m = 5*1e4;
delta_T = 3.5*1e4;

C.delta_m_O_pred = delta_m;
C.delta_m_O_succ = delta_m;
C.delta_m_R_pred = delta_m;
C.delta_m_R_succ = delta_m;
C.delta_T_F_pred = delta_T;
C.delta_T_F_succ = delta_T;
C.delta_T_R_pred = delta_T;
C.delta_T_R_succ = delta_T;

C.params = [  C.rho_w; %1
              C.cp_w;
              C.V_F ;
              C.h_F ;
              C.A_F ; %5
              C.L_F ;
              C.D_F ;                          
              C.V_S1 ;
              C.h_S1 ;
              C.A_S1 ; %10
              C.L_S1 ;
              C.D_S1 ;
              C.V_S2 ;
              C.h_S2 ;
              C.A_S2 ; %15
              C.L_S2 ;
              C.D_S2 ;
              C.h_b  ;
              C.A_b  ;
              C.C_b  ; %20
              C.V_S3 ;
              C.h_S3 ;
              C.A_S3 ;
              C.L_S3 ;
              C.D_S3 ; %25
              C.V_R ;
              C.h_R ;
              C.A_R ;
              C.L_R ;
              C.D_R ; %30
              C.V_BYP ;
              C.h_BYP ;
              C.A_BYP ;
              C.L_BYP ;
              C.D_BYP ; %35                          
              C.f_Darcy;
              C.DeltaP_S1_max;
              C.DeltaP_S2_max;
              C.DeltaP_S3_max;
              C.T_set; %40 SPACE HOLDER
              C.T_amb; % SPACE HOLDER
              C.K;
              C.Ts;
              C.Q_disc;
              C.nx; %45
              C.ny;
              C.nu_mv;
              C.nu_md;
              C.is_bypass_house;
              C.is_first_house; %50
              C.delta_m_O_pred;
              C.delta_m_O_succ;
              C.delta_m_R_pred;
              C.delta_m_R_succ;
              C.delta_T_F_pred; %55
              C.delta_T_F_succ;
              C.delta_T_R_pred;
              C.delta_T_R_succ; %58
              C.Q_F;   
              C.Q_S1; % 60 
              C.Q_S3;  
              C.Q_R;  % 62 
              C.R_BYP;
              C.R_U
              C.T_F_HP_min; % 65
              C.T_F_HP_max;
              C.m_dot_F_HP_max;
              C.m_dot_F_HP_MaxRate; %68
              C.m_dot_F_HP_MinRate;
              C.T_F_HP_MaxRate; %70
              C.T_F_HP_MinRate];
C.paramsCell = {C.params};
C.nlobj = C.createNMPC();
outputObj = C;
end