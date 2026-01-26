# IP Address & Access Logging (Compliance)

## Requirement

Store the **IP address of the user at the time of profile creation** and **access logs (date and time)** for a **minimum of one year from the date the account is deactivated**.

## Implementation

### 1. Profile creation (registration)

- **User model**: `registrationIp` stores the client IP when the user signs up (email/password or Google first-time).
- **UserAccessLog**: One record with `action: 'registration'` at signup (IP + timestamp + optional userAgent).

### 2. Access logs

- **UserAccessLog** collection: Each login (email/password or Google) creates a record with:
  - `userId`
  - `ipAddress`
  - `userAgent` (optional)
  - `action`: `'registration' | 'login' | 'google_login'`
  - `createdAt` (automatic)

### 3. Client IP

- Taken from `X-Forwarded-For` (first segment when behind proxy) or `req.ip` / socket.
- Ensure the app runs with Express `trust proxy` enabled if behind Nginx/load balancer so `req.ip` is correct.

## Retention (1 year from deactivation)

- **Deactivation** = user soft-delete (`User.deletedAt` set).
- Data must be **kept for at least one year** after `deletedAt`.
- After that, you **may** purge to reduce storage.

### Optional: Purge after retention

Run periodically (e.g. daily cron) to delete access logs and clear `registrationIp` only when the user was deactivated more than 1 year ago:

```js
// Pseudocode / script idea:
// 1. Find users where deletedAt exists and deletedAt + 365 days < now
// 2. Delete UserAccessLog documents where userId is in that set
// 3. Optionally clear User.registrationIp for those users (or leave it for audit)
```

Example using MongoDB shell or a Node script:

```javascript
const cutoff = new Date();
cutoff.setFullYear(cutoff.getFullYear() - 1);
// Users deactivated before this date
const userIds = await User.find({ deletedAt: { $exists: true, $lt: cutoff } }).distinct('_id');
await UserAccessLog.deleteMany({ userId: { $in: userIds } });
// Optional: User.updateMany({ _id: { $in: userIds } }, { $unset: { registrationIp: 1 } });
```

Keep backups and comply with local law before purging.
