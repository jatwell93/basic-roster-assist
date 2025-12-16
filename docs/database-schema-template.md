# Database schema (template)

**Source of truth**: `db/schema.rb` (or `db/structure.sql`)  
**Last reviewed**: YYYY-MM-DD  
**Database**: Postgres | MySQL | SQLite (pick one)  
**Primary key type**: bigint | uuid (pick one)

## Purpose
- Provide a human-readable overview of the data model.
- Document non-obvious constraints, invariants, and “why” decisions.
- Make it easy to spot missing indexes and risky relationships.

## How to update (process)
1. Make the schema change via migration.
2. Run migrations locally and ensure `db/schema.rb` / `db/structure.sql` is updated.
3. Update this document (only the tables impacted).
4. Add notes for any data migrations, backfills, or rollouts.

## High-level model map
Describe the main bounded contexts and how data flows.

- **Accounts/Billing**: Account → Subscription → Invoice
- **Identity/Access**: User → Membership → Role
- **Content**: Post → Comment → Reaction

(Optional) Add an ERD screenshot/link:
- `docs/diagrams/erd.png` (or link to dbdiagram.io)

---

## Tables

### `users`
**Purpose**: Stores application users and identity profile.

#### Columns
| Column | Type | Null | Default | Notes |
|---|---|---:|---|---|
| id | bigint/uuid | NO |  | Primary key |
| email | string | NO |  | Unique, normalized |
| encrypted_password | string | YES/NO |  | If using Devise |
| created_at | datetime | NO |  |  |
| updated_at | datetime | NO |  |  |

#### Indexes
| Name | Columns | Unique | Notes |
|---|---|---:|---|
| index_users_on_email | email | YES | Case-insensitive? |

#### Foreign keys
- (none)

#### Relationships (Rails)
- `has_many :memberships, dependent: :destroy`
- `has_many :accounts, through: :memberships`

#### Validations / invariants (Rails)
- `email` must be present, unique, normalized (lowercased, stripped).
- Add any invariants that matter to business logic.

#### Data lifecycle
- Soft delete? (`deleted_at`)
- Archival? (`archived_at`)
- PII retention policy?

#### Notes
- Add “why” explanations (e.g., “email uniqueness is case-insensitive via CITEXT”).

---

### `accounts`
**Purpose**: Tenant / organization container.

#### Columns
| Column | Type | Null | Default | Notes |
|---|---|---:|---|---|
| id | bigint/uuid | NO |  | Primary key |
| name | string | NO |  | Display name |
| created_at | datetime | NO |  |  |
| updated_at | datetime | NO |  |  |

#### Indexes
| Name | Columns | Unique | Notes |
|---|---|---:|---|
| index_accounts_on_name | name | NO | If searching frequently |

#### Foreign keys
- (none)

#### Relationships (Rails)
- `has_many :memberships, dependent: :destroy`
- `has_many :users, through: :memberships`

#### Notes
- Describe tenancy strategy: row-level scoping, `current_account`, etc.

---

### `memberships`
**Purpose**: Join table between users and accounts.

#### Columns
| Column | Type | Null | Default | Notes |
|---|---|---:|---|---|
| id | bigint/uuid | NO |  | Primary key |
| user_id | bigint/uuid | NO |  | FK → users |
| account_id | bigint/uuid | NO |  | FK → accounts |
| role | string/enum | NO | member | Authorization role |

#### Indexes
| Name | Columns | Unique | Notes |
|---|---|---:|---|
| index_memberships_on_user_id | user_id | NO |  |
| index_memberships_on_account_id | account_id | NO |  |
| index_memberships_on_user_id_account_id | user_id, account_id | YES | Prevent duplicates |

#### Foreign keys
- `memberships.user_id → users.id`
- `memberships.account_id → accounts.id`

#### Notes
- Document role strategy (enum vs string, how it maps to authorization).

---

## Cross-cutting concerns checklist
- Index all foreign keys.
- Add unique indexes for business identifiers.
- Avoid polymorphic associations unless needed; document why if used.
- Use database constraints for invariants that must never break (NOT NULL, CHECK, FK).
- Consider counter caches and denormalization explicitly (document tradeoffs).
