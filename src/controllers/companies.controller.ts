import { Request, Response } from 'express';
import * as companiesService from '../services/companies.service';

export async function listCompanies(_req: Request, res: Response): Promise<void> {
  try {
    const companies = await companiesService.listCompanies();
    res.json({ companies });
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar las empresas' });
  }
}

export async function updateSubscription(req: Request, res: Response): Promise<void> {
  try {
    const { status } = req.body;
    if (!status) { res.status(400).json({ error: 'El campo status es obligatorio' }); return; }
    const result = await companiesService.updateSubscription(req.params.id, status);
    res.json(result);
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al actualizar' });
  }
}

export async function updatePlan(req: Request, res: Response): Promise<void> {
  try {
    const { plan } = req.body;
    if (!plan) { res.status(400).json({ error: 'El campo plan es obligatorio' }); return; }
    const result = await companiesService.updatePlan(req.params.id, plan);
    res.json(result);
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al actualizar plan' });
  }
}

export async function createCompany(req: Request, res: Response): Promise<void> {
  try {
    const { name, tax_id, admin_name, admin_email, admin_password } = req.body;
    if (!name || !tax_id || !admin_name || !admin_email || !admin_password) {
      res.status(400).json({ error: 'Todos los campos son obligatorios' });
      return;
    }
    const result = await companiesService.createCompany({ name, tax_id, admin_name, admin_email, admin_password });
    res.status(201).json(result);
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al crear empresa' });
  }
}
