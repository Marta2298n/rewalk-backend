import { Request, Response } from 'express';
import * as rewardsService from '../services/rewards.service';
import type { RedemptionPeriod } from '../services/rewards.service';

export async function listRewards(req: Request, res: Response): Promise<void> {
  try {
    const rewards = await rewardsService.listRewards(req.user!.companyId);
    res.json({ rewards });
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar las recompensas' });
  }
}

export async function createReward(req: Request, res: Response): Promise<void> {
  try {
    const { title, description, points_cost, stock, max_per_user, redemption_period } = req.body;
    if (!title || !points_cost || stock === undefined) {
      res.status(400).json({ error: 'title, points_cost y stock son obligatorios' });
      return;
    }
    const validPeriods: RedemptionPeriod[] = ['none', 'monthly', 'yearly'];
    const period: RedemptionPeriod = validPeriods.includes(redemption_period) ? redemption_period : 'none';
    const reward = await rewardsService.createReward(req.user!.companyId, {
      title,
      description: description || '',
      points_cost: Number(points_cost),
      stock: Number(stock),
      max_per_user: max_per_user === null || max_per_user === undefined ? undefined : Number(max_per_user),
      redemption_period: period,
    });
    res.status(201).json(reward);
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al crear recompensa' });
  }
}

export async function redeemReward(req: Request, res: Response): Promise<void> {
  try {
    const result = await rewardsService.redeemReward(
      req.user!.userId,
      req.user!.companyId,
      req.params.id
    );
    res.json(result);
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al canjear' });
  }
}

export async function getMyPoints(req: Request, res: Response): Promise<void> {
  try {
    const result = await rewardsService.getMyPoints(req.user!.userId);
    res.json(result);
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar los puntos' });
  }
}

export async function listMyRedemptions(req: Request, res: Response): Promise<void> {
  try {
    const redemptions = await rewardsService.listMyRedemptions(req.user!.userId);
    res.json({ redemptions });
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar los canjes' });
  }
}

export async function listCompanyRedemptions(req: Request, res: Response): Promise<void> {
  try {
    const redemptions = await rewardsService.listCompanyRedemptions(req.user!.companyId);
    res.json({ redemptions });
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar los canjes' });
  }
}

export async function validateRedemption(req: Request, res: Response): Promise<void> {
  try {
    const result = await rewardsService.validateRedemption(
      req.params.id,
      req.user!.companyId,
      req.user!.userId
    );
    res.json(result);
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al validar' });
  }
}

// ── Vista por empleado (company_admin) ────────────────────────────────────────

export async function getEmployeeRedemptions(req: Request, res: Response): Promise<void> {
  try {
    const redemptions = await rewardsService.getEmployeeRedemptions(
      req.params.userId,
      req.user!.companyId
    );
    res.json({ redemptions });
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar los canjes del empleado' });
  }
}

export async function getEmployeeRewardLimits(req: Request, res: Response): Promise<void> {
  try {
    const limits = await rewardsService.getEmployeeRewardLimits(
      req.params.userId,
      req.user!.companyId
    );
    res.json({ limits });
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar los límites del empleado' });
  }
}

export async function upsertEmployeeLimit(req: Request, res: Response): Promise<void> {
  try {
    const { max_per_user, redemption_period } = req.body;
    if (!max_per_user || max_per_user < 1) {
      res.status(400).json({ error: 'max_per_user debe ser un número >= 1' });
      return;
    }
    const validPeriods: RedemptionPeriod[] = ['none', 'monthly', 'yearly'];
    const period: RedemptionPeriod = validPeriods.includes(redemption_period) ? redemption_period : 'none';
    await rewardsService.upsertEmployeeLimit(
      req.params.rewardId,
      req.params.userId,
      req.user!.companyId,
      Number(max_per_user),
      period
    );
    res.json({ ok: true });
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al guardar límite' });
  }
}

export async function deleteEmployeeLimit(req: Request, res: Response): Promise<void> {
  try {
    await rewardsService.deleteEmployeeLimit(
      req.params.rewardId,
      req.params.userId,
      req.user!.companyId
    );
    res.json({ ok: true });
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al eliminar límite' });
  }
}
