export type PlanName = 'trial' | 'basic' | 'premium' | 'total' | 'completo';

export interface PlanConfig {
  label: string;
  maxEmployees: number | null; // null = ilimitado
  trialDays?: number;
}

export const PLANS: Record<PlanName, PlanConfig> = {
  trial:    { label: 'Trial',    maxEmployees: null, trialDays: 10 },
  basic:    { label: 'Equipo',   maxEmployees: 25 },
  premium:  { label: 'Pyme',     maxEmployees: 75 },
  total:    { label: 'Empresa',  maxEmployees: 125 },
  completo: { label: 'Completo', maxEmployees: null },
};
