# How to Generate JWT Secrets

## 🔐 Quick Method (On VPS Terminal)

### Step 1: Generate JWT_SECRET (for users)

Run this command on your VPS:

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**Example output:**
```
a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

**Copy this entire string** - this is your `JWT_SECRET`.

---

### Step 2: Generate ADMIN_JWT_SECRET (for admin dashboard)

Run the same command again (it will generate a different value):

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**Example output:**
```
f9e8d7c6b5a4321098765432109876543210fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba
```

**Copy this entire string** - this is your `ADMIN_JWT_SECRET`.

---

## 📋 Alternative Methods

### Method 2: Using OpenSSL (if Node.js not available)

```bash
# Generate JWT_SECRET
openssl rand -hex 64

# Generate ADMIN_JWT_SECRET (run again)
openssl rand -hex 64
```

---

### Method 3: Using Python (if available)

```bash
# Generate JWT_SECRET
python3 -c "import secrets; print(secrets.token_hex(64))"

# Generate ADMIN_JWT_SECRET (run again)
python3 -c "import secrets; print(secrets.token_hex(64))"
```

---

### Method 4: Using /dev/urandom (Linux)

```bash
# Generate JWT_SECRET
head -c 64 /dev/urandom | xxd -p -c 64

# Generate ADMIN_JWT_SECRET (run again)
head -c 64 /dev/urandom | xxd -p -c 64
```

---

## ✅ Recommended Method

**Use Node.js method** (Method 1) since you're deploying a Node.js backend:

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**Why?**
- ✅ Already have Node.js installed
- ✅ Simple one-line command
- ✅ Generates 128-character hex string (very secure)
- ✅ No additional tools needed

---

## 📝 Complete Example

Here's what the process looks like:

```bash
# On your VPS terminal
cd /var/www/silah_app/backend

# Generate first secret (for users)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
# Output: a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef

# Generate second secret (for admin)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
# Output: f9e8d7c6b5a4321098765432109876543210fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba
```

Then in your `.env` file:

```env
JWT_SECRET=a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
ADMIN_JWT_SECRET=f9e8d7c6b5a4321098765432109876543210fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba
```

---

## ⚠️ Important Notes

1. **Generate TWO different secrets** - One for users, one for admin
2. **Keep them secret** - Never share or commit to git
3. **Use different secrets** for development and production
4. **Length** - Should be at least 64 characters (128 hex = 64 bytes)
5. **Random** - Must be cryptographically random (not predictable)

---

## 🔍 Verify Node.js is Available

If the command doesn't work, check if Node.js is installed:

```bash
node --version
```

If not installed:
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## ✅ Quick Copy-Paste Commands

**For JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**For ADMIN_JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**That's it!** Just run these two commands and copy the outputs to your `.env` file.

---

**Last Updated:** 2025-01-22
