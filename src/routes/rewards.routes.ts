import { Router } from 'express';
import {
  listRewards, createReward, redeemReward, getMyPoints,
  listMyRedemptions, listCompanyRedemptions, validateRedemption,
} from '../controllers/rewards.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

router.use(authenticate);

router.get('/',                  listRewards);
router.get('/my-points',         getMyPoints);
router.get('/my-redemptions',    listMyRedemptions);
router.get('/redemptions',       requireRole('company_admin', 'superadmin'), listCompanyRedemptions);
router.post('/',                 requireRole('company_admin', 'superadmin'), createReward);
router.post('/:id/redeem',       redeemReward);
router.patch('/redemptions/:id/validate', requireRole('company_admin', 'superadmin'), validateRedemption);

export default router;
