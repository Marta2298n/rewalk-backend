import { Router } from 'express';
import { getDashboardMetrics, getCompanyPlan } from '../controllers/company.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

router.get('/dashboard-metrics', authenticate, requireRole('company_admin', 'superadmin'), getDashboardMetrics);
router.get('/plan', authenticate, requireRole('company_admin', 'superadmin'), getCompanyPlan);

export default router;
