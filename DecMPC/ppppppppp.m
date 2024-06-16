function [DeltaP_House,DeltaP_tot] = fcn(m_dot_U, m_dot_F, f_Darcy, L_S1, L_S2, L_S3, L_F, L_R, D_S1, D_S2, D_S3, D_F, D_R, rho, pi)
      DeltaP_S1= 8*f_Darcy*L_S1*m_dot_U^2/(rho*pi^2*D_S1^5);
      DeltaP_S2= 8*f_Darcy*L_S2*m_dot_U^2/(rho*pi^2*D_S2^5); 
      DeltaP_S3= 8*f_Darcy*L_S3*m_dot_U^2/(rho*pi^2*D_S3^5); 
      DeltaP_F= 8*f_Darcy*L_F*m_dot_F^2/(rho*pi^2*D_F^5); 
      DeltaP_R= 8*f_Darcy*L_R*m_dot_F^2/(rho*pi^2*D_R^5); 
DeltaP_House = DeltaP_S1+DeltaP_S2+DeltaP_S3;
DeltaP_tot = DeltaP_House+DeltaP_F+DeltaP_R;