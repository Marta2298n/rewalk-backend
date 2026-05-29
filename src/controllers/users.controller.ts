import { Request, Response } from 'express';
import * as usersService from '../services/users.service';

export async function listEmployees(req: Request, res: Response): Promise<void> {
  try {
    const companyId = req.user!.companyId;
    const employees = await usersService.listEmployees(companyId);
    res.json({ employees });
  } catch {
    res.status(500).json({ error: 'Could not fetch employees' });
  }
}

export async function registerEmployee(req: Request, res: Response): Promise<void> {
  try {
    const companyId = req.user!.companyId;
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      res.status(400).json({ error: 'name, email and password are required' });
      return;
    }

    const employee = await usersService.registerEmployee(companyId, { name, email, password });
    res.status(201).json(employee);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Registration failed';
    res.status(400).json({ error: message });
  }
}
