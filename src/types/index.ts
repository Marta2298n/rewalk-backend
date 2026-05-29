export type UserRole = 'superadmin' | 'company_admin' | 'employee';
export type ActivityType = 'walk' | 'run' | 'cycle' | 'swim';
export type RewardClaimStatus = 'pending' | 'redeemed';

export interface JwtPayload {
  userId: string;
  companyId: string;
  role: UserRole;
  email: string;
}

export interface Company {
  id: string;
  name: string;
  tax_id: string;
  subscription_status: string;
  created_at: Date;
}

export interface User {
  id: string;
  company_id: string;
  name: string;
  email: string;
  password_hash: string;
  role: UserRole;
  status: string;
  created_at: Date;
}

export interface Activity {
  id: string;
  user_id: string;
  activity_type: ActivityType;
  distance_km: number;
  duration_seconds: number;
  calories_burned: number;
  co2_avoided_kg: number;
  start_time: Date;
  end_time: Date;
  is_validated: boolean;
  created_at: Date;
}

export interface CreateActivityDto {
  activity_type: ActivityType;
  distance_km: number;
  duration_seconds: number;
  start_time: string;
  end_time: string;
}

export interface RegisterEmployeeDto {
  name: string;
  email: string;
  password: string;
}

// Augment Express Request to carry the decoded JWT
declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}
