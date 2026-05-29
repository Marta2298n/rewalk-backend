import 'dotenv/config';
import express from 'express';
import cors from 'cors';

import authRoutes from './routes/auth.routes';
import usersRoutes from './routes/users.routes';
import activitiesRoutes from './routes/activities.routes';
import companyRoutes from './routes/company.routes';
import rewardsRoutes from './routes/rewards.routes';
import companiesRoutes from './routes/companies.routes';
import challengesRoutes from './routes/challenges.routes';

const app = express();

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (_req, res) => res.json({ status: 'ok' }));

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/company', companyRoutes);
app.use('/api/rewards', rewardsRoutes);
app.use('/api/companies', companiesRoutes);
app.use('/api/challenges', challengesRoutes);

// 404
app.use((_req, res) => res.status(404).json({ error: 'Not found' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  const db = process.env.DATABASE_URL;
  const dbStatus = db ? `✅ DATABASE_URL set (host: ${db.split('@')[1]?.split('/')[0] ?? '?'})` : '❌ DATABASE_URL NOT SET';
  console.log(`Eco-Wellness API running on port ${PORT}`);
  console.log(dbStatus);
});

export default app;
