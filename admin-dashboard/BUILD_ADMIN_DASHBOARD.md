# Build Admin Dashboard on VPS

## Steps

1. **Navigate to admin dashboard directory:**
   ```bash
   cd /var/www/silah_app/admin-dashboard
   ```

2. **Build the admin dashboard:**
   ```bash
   npm run build
   ```

3. **Set correct permissions:**
   ```bash
   sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist
   ```

4. **Reload Nginx:**
   ```bash
   sudo systemctl reload nginx
   ```

---

## Quick Copy-Paste Commands

```bash
cd /var/www/silah_app/admin-dashboard && npm run build && sudo chown -R www-data:www-data dist && sudo systemctl reload nginx
```

---

## Verify Build

After building, check if files were created:
```bash
ls -la /var/www/silah_app/admin-dashboard/dist/
```

You should see:
- `index.html`
- `assets/` directory with JS and CSS files
