import { Request, Response } from 'express';
import * as svc from '../services/challenges.service';

export async function listChallenges(req: Request, res: Response): Promise<void> {
  try {
    const challenges = await svc.listChallenges(req.user!.companyId, req.user!.userId);
    res.json({ challenges });
  } catch {
    res.status(500).json({ error: 'No se pudieron cargar los retos' });
  }
}

export async function createChallenge(req: Request, res: Response): Promise<void> {
  try {
    const { title, description, type, date, location, max_participants } = req.body;
    if (!title || !type) {
      res.status(400).json({ error: 'title y type son obligatorios' });
      return;
    }
    const challenge = await svc.createChallenge(req.user!.companyId, req.user!.userId, {
      title, description, type, date, location,
      max_participants: max_participants ? Number(max_participants) : undefined,
    });
    res.status(201).json(challenge);
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al crear' });
  }
}

export async function joinChallenge(req: Request, res: Response): Promise<void> {
  try {
    await svc.joinChallenge(req.params.id, req.user!.userId, req.user!.companyId);
    res.json({ ok: true });
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al apuntarse' });
  }
}

export async function leaveChallenge(req: Request, res: Response): Promise<void> {
  try {
    await svc.leaveChallenge(req.params.id, req.user!.userId);
    res.json({ ok: true });
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al salir' });
  }
}

export async function updateChallengeStatus(req: Request, res: Response): Promise<void> {
  try {
    const { status } = req.body;
    if (status !== 'completed' && status !== 'cancelled') {
      res.status(400).json({ error: 'Estado no válido' });
      return;
    }
    await svc.updateChallengeStatus(req.params.id, req.user!.companyId, status);
    res.json({ ok: true });
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al actualizar' });
  }
}

export async function deleteChallenge(req: Request, res: Response): Promise<void> {
  try {
    await svc.deleteChallenge(req.params.id, req.user!.userId);
    res.json({ ok: true });
  } catch (err: unknown) {
    res.status(400).json({ error: err instanceof Error ? err.message : 'Error al eliminar' });
  }
}
