import { Router } from 'express';
import { createActivity, getMyActivities, getMyMonthlyStats, getCompanyLeaderboard } from '../controllers/activities.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireActiveSubscription } from '../middleware/subscription.middleware';

const router = Router();

router.use(authenticate);

router.post('/', requireActiveSubscription, createActivity);
router.get('/me', getMyActivities);
router.get('/my-stats', getMyMonthlyStats);
router.get('/leaderboard', getCompanyLeaderboard);

export default router;
