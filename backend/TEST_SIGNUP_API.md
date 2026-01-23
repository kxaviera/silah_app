# Test Signup API - Proper Command

## Test with proper JSON escaping

```bash
curl -i https://api.rewardo.fun/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"fullName\":\"Test User\",\"email\":\"test123@example.com\",\"password\":\"Test1234\",\"role\":\"bride\"}"
```

Or use a file:

```bash
# Create test file
cat > /tmp/test_signup.json << 'EOF'
{
  "fullName": "Test User",
  "email": "test123@example.com",
  "password": "Test1234",
  "role": "bride"
}
EOF

# Test with file
curl -i https://api.rewardo.fun/api/auth/register \
  -H "Content-Type: application/json" \
  -d @/tmp/test_signup.json
```

---

## Expected Response

**Success:**
```json
{
  "success": true,
  "message": "Registration successful.",
  "token": "...",
  "user": {
    "id": "...",
    "email": "test123@example.com",
    "role": "bride",
    "fullName": "Test User",
    "isProfileComplete": false
  }
}
```

**Error:**
```json
{
  "success": false,
  "message": "..."
}
```
