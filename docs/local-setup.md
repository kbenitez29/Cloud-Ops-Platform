# Local Development

## Frontend

```bash
cd app/frontend
npm install
npm run dev
```

Runs on `http://localhost:5173`. Note: `/api/*` calls won't resolve locally since there's no ALB routing in dev mode — this is purely for UI/component development.

## API

```bash
cd app/api
npm install
node server.js
```

Runs on `http://localhost:3000`. AWS SDK calls will fail locally unless you have valid AWS credentials configured (`aws configure`) — the production container gets credentials automatically from its ECS task role.

## Infrastructure

```bash
cd terraform/environments/staging
terraform init
terraform plan
```

Requires `terraform.tfvars` (not committed) with `db_password`, `project`, and `alert_email` set.
