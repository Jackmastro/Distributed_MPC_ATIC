function cineq = IneqConFunction_DecMPC(~, u, ~, ~, household)

    DeltaP_U = HouseholdPressureDrop_DecMPC(u, household);
  
    cineq = DeltaP_U - household.maxPressureDrop;

end