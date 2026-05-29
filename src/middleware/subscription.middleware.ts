import { Request, Response, NextFunction } from 'express';
import { pool } from '../config/database';
import { PLANS, PlanName } from '../config/plans';

interface CompanyRow {
  subscription_status: string;
  plan: PlanName;
  trial_ends_at: Date | null;
}

export async function requireActiveSubscription(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { rows } = await pool.query<CompanyRow>(
      'SELECT subscription_status, plan, trial_ends_at FROM companies WHERE id = $1',
      [req.user!.companyId]
    );
    const company = rows[0];
    if (!company) { res.status(403).json({ error: 'Empresa no encontrada' }); return; }

    const { subscription_status, plan, trial_ends_at } = company;

    if (subscription_status === 'suspended') {
      res.status(403).json({ error: 'Cuenta suspendida. Contacta con Eco-Wellness para reactivarla.' });
      return;
    }
    if (subscription_status === 'cancelled') {
      res.status(403).json({ error: 'Cuenta cancelada. Contacta con Eco-Wellness.' });
      return;
    }

    // Trial expiry check
    if (plan === 'trial' && trial_ends_at && new Date() > new Date(trial_ends_at)) {
      res.status(403).json({ error: 'Tu periodo de prueba ha finalizado. Actualiza tu plan para continuar.' });
      return;
    }

    next();
  } catch {
    res.status(500).json({ error: 'Error al verificar suscripción' });
  }
}

export async function requirePlanCapacity(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { rows } = await pool.query<CompanyRow & { employee_count: number }>(
      `SELECT c.plan, c.trial_ends_at, c.subscription_status,
              COUNT(u.id) FILTER (WHERE u.role = 'employee' AND u.status = 'active')::INT AS employee_count
       FROM companies c
       LEFT JOIN users u ON u.company_id = c.id
       WHERE c.id = $1
       GROUP BY c.id`,
      [req.user!.companyId]
    );

    const company = rows[0];
    if (!company) { res.status(403).json({ error: 'Empresa no encontrada' }); return; }

    const planConfig = PLANS[company.plan];
    if (planConfig.maxEmployees !== null && company.employee_count >= planConfig.maxEmployees) {
      res.status(403).json({
        error: `Has alcanzado el límite de ${planConfig.maxEmployees} empleados del plan ${planConfig.label}. Actualiza tu plan para añadir más.`,
      });
      return;
    }

    next();
  } catch {
    res.status(500).json({ error: 'Error al verificar límite del plan' });
  }
}
