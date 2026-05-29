# eco-wellness-backend — API REST del producto Rewalk

## Qué es
API REST en Node.js + TypeScript que da soporte a:
- **rewalk-app** (app móvil de empleados)
- **eco-wellness-panel** (panel web de administración de empresa)

Stack: Express · PostgreSQL · JWT · bcrypt · TypeScript

## URLs
- **Producción:** `https://rewalk-backend.onrender.com` (Render, free tier)
- **BD producción:** Neon PostgreSQL (`ep-calm-wave-alpj46bo.c-3.eu-central-1.aws.neon.tech`)
- **Repos:** `https://github.com/Marta2298n/rewalk-backend`

## Arrancar en local
```bash
npm run dev          # ts-node-dev con hot reload, puerto 3000
```
Requiere PostgreSQL corriendo y `.env` configurado (ver `.env.example`).

## Variables de entorno (.env)
```
PORT=3000
NODE_ENV=development
DATABASE_URL=postgresql://user:password@localhost:5432/eco_wellness_db
JWT_SECRET=tu-clave-secreta
JWT_EXPIRES_IN=7d
```

## Estructura
```
src/
  app.ts                 — Entry point, monta rutas y middleware
  config/
    database.ts          — Pool de conexión pg
    plans.ts             — Definición de planes (trial/basic/premium/total/completo)
  controllers/           — Lógica de request/response
  services/              — Lógica de negocio y acceso a BD
  routes/                — Mapeo de endpoints a controllers
  middleware/
    auth.middleware.ts   — Verifica JWT Bearer token
    role.middleware.ts   — Comprueba rol (employee/company_admin/superadmin)
    subscription.middleware.ts — Bloquea si suscripción suspendida/cancelada
  types/index.ts         — Tipos globales (User, Activity, JwtPayload…)
migrations/              — SQL de PostgreSQL en orden numérico
```

## Endpoints principales
| Método | Ruta | Quién |
|--------|------|-------|
| POST | `/api/auth/login` | todos |
| GET | `/api/company/dashboard-metrics` | company_admin |
| POST | `/api/users/register-employee` | company_admin |
| GET | `/api/users/employees` | company_admin |
| POST | `/api/activities` | employee |
| GET | `/api/activities/me` | employee |
| GET | `/api/activities/my-stats` | employee |
| GET | `/api/activities/leaderboard` | employee |
| GET/POST | `/api/rewards` | employee/company_admin |
| POST | `/api/rewards/:id/redeem` | employee |
| GET | `/api/rewards/my-points` | employee |
| GET | `/api/rewards/my-redemptions` | employee |
| GET | `/api/rewards/redemptions` | company_admin |
| PATCH | `/api/rewards/redemptions/:id/validate` | company_admin |
| GET/POST | `/api/challenges` | employee/company_admin |
| POST | `/api/challenges/:id/join` | employee |
| POST | `/api/challenges/:id/leave` | employee |
| DELETE | `/api/challenges/:id` | creador o company_admin |
| GET | `/api/companies` | superadmin |
| POST | `/api/companies` | superadmin |
| PATCH | `/api/companies/:id/subscription` | superadmin |
| PATCH | `/api/companies/:id/plan` | superadmin |

## Migraciones
Ejecutar en orden:
```bash
psql $DATABASE_URL -f migrations/001_initial_schema.sql   # tablas base + seed superadmin
psql $DATABASE_URL -f migrations/002_points_and_rewards.sql
psql $DATABASE_URL -f migrations/003_plans.sql
psql $DATABASE_URL -f migrations/004_redemption_codes.sql
psql $DATABASE_URL -f migrations/005_challenges.sql
```
Seed de demo con datos de Telefónica: `seed_demo_telefonica.sql`

## Roles y JWT
El token JWT lleva: `{ userId, companyId, role, email }`
- `superadmin` — gestiona todas las empresas (solo via panel)
- `company_admin` — gestiona su empresa, empleados, recompensas, retos
- `employee` — solo puede usarse en la app móvil (LoginScreen lo rechaza si no es employee)

## Planes
Definidos en `src/config/plans.ts`:
| Plan | Max empleados |
|------|--------------|
| trial | ilimitado (10 días) |
| basic | 5 |
| premium | 25 |
| total | 100 |
| completo | ilimitado |

Los planes del panel de marketing (Equipo/Pyme/Empresa) mapean a estos internos.

## Datos calculados
- `co2_avoided_kg` — calculado al registrar actividad (caminar/correr/ciclismo)
- `points_earned` — calculado por distancia/tipo de actividad
- `calories_burned` — calculado al guardar actividad

## Superadmin de sistema
Email: `admin@eco-wellness.io` / contraseña por defecto en seed (cambiar en producción).
Empresa asociada: UUID `00000000-0000-0000-0000-000000000001`.
