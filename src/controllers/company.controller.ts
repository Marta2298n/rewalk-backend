import { Request, Response } from 'express';
import * as companyService from '../services/company.service';

export async function getCompanyPlan(req: Request, res: Response): Promise<void> {
  try {
    const plan = await companyService.getCompanyPlan(req.user!.companyId);
    res.json(plan);
  } catch {
    res.status(500).json({ error: 'Could not fetch plan info' });
  }
}

export async function getDashboardMetrics(req: Request, res: Response): Promise<void> {
  try {
    const companyId = req.user!.companyId;
    const metrics = await companyService.getDashboardMetrics(companyId);
    res.json(metrics);
  } catch (err: unknown) {
    res.status(500).json({ error: 'Could not fetch dashboard metrics' });
  }
}
