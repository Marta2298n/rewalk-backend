import { Router } from 'express';
import { registerEmployee, listEmployees } from '../controllers/users.controller';
import {
  getEmployeeRedemptions,
  getEmployeeRewardLimits,
  upsertEmployeeLimit,
  deleteEmployeeLimit,
} from '../controllers/rewards.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';
import { requireActiveSubscription, requirePlanCapacity } from '../middleware/subscription.middleware';

const router = Router();

// Only company_admin or superadmin can register employees
router.post(
  '/register-employee',
  authenticate,
  requireRole('company_admin', 'superadmin'),
  requireActiveSubscription,
  requirePlanCapacity,
  registerEmployee
);

router.get(
  '/employees',
  authenticate,
  requireRole('company_admin', 'superadmin'),
  listEmployees
);

// Vista por empleado: canjes y límites
router.get(
  '/:userId/redemptions',
  authenticate,
  requireRole('company_admin', 'superadmin'),
  getEmployeeRedemptions
);

router.get(
  '/:userId/reward-limits',
  authenticate,
  requireRole('company_admin', 'superadmin'),
  getEmployeeRewardLimits
);

router.put(
  '/:userId/reward-limits/:rewardId',
  authenticate,
  requireRole('company_admin', 'superadmin'),
  upsertEmployeeLimit
);

router.delete(
  '/:userId/reward-limits/:rewardId',
  authenticate,
  requireRole('company_admin', 'superadmin'),
  deleteEmployeeLimit
);

export default router;
