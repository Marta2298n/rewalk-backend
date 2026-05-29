import { Router } from 'express';
import { listChallenges, createChallenge, joinChallenge, leaveChallenge, updateChallengeStatus, deleteChallenge } from '../controllers/challenges.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

router.use(authenticate);

router.get('/',                         listChallenges);
router.post('/',                        createChallenge);
router.post('/:id/join',               joinChallenge);
router.post('/:id/leave',              leaveChallenge);
router.patch('/:id/status',            requireRole('company_admin', 'superadmin'), updateChallengeStatus);
router.delete('/:id',                  deleteChallenge);

export default router;
