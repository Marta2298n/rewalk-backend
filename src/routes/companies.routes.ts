import { Router } from 'express';
import { listCompanies, createCompany, updateSubscription, updatePlan } from '../controllers/companies.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

router.use(authenticate, requireRole('superadmin'));

router.get('/', listCompanies);
router.post('/', createCompany);
router.patch('/:id/subscription', updateSubscription);
router.patch('/:id/plan', updatePlan);

export default router;
