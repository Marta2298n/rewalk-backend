import { Request, Response } from 'express';
import * as activitiesService from '../services/activities.service';
import { CreateActivityDto } from '../types';

export async function createActivity(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.userId;
    const dto = req.body as CreateActivityDto;

    const { activity_type, distance_km, duration_seconds, start_time, end_time } = dto;
    if (!activity_type || !distance_km || !duration_seconds || !start_time || !end_time) {
      res.status(400).json({ error: 'activity_type, distance_km, duration_seconds, start_time and end_time are required' });
      return;
    }

    if (!['walk', 'run', 'cycle'].includes(activity_type)) {
      res.status(400).json({ error: 'activity_type must be walk, run or cycle' });
      return;
    }

    const activity = await activitiesService.createActivity(userId, dto);

    const message = activity.is_validated
      ? 'Activity recorded successfully'
      : 'Activity recorded but flagged for review (speed limit exceeded)';

    res.status(201).json({ message, activity });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Could not create activity';
    res.status(400).json({ error: message });
  }
}

export async function getMyActivities(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.userId;
    const activities = await activitiesService.getMyActivities(userId);
    res.json({ activities });
  } catch (err: unknown) {
    res.status(500).json({ error: 'Could not fetch activities' });
  }
}

export async function getCompanyLeaderboard(req: Request, res: Response): Promise<void> {
  try {
    const leaderboard = await activitiesService.getCompanyLeaderboard(req.user!.userId);
    res.json({ leaderboard });
  } catch {
    res.status(500).json({ error: 'Could not fetch leaderboard' });
  }
}

export async function getMyMonthlyStats(req: Request, res: Response): Promise<void> {
  try {
    const stats = await activitiesService.getMyMonthlyStats(req.user!.userId);
    res.json(stats);
  } catch {
    res.status(500).json({ error: 'Could not fetch stats' });
  }
}
