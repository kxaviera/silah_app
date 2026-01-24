# Release signing (Play Store)

To upload an **Android App Bundle** to Google Play, you must sign it in **release** mode.  
Right now the app uses **debug** signing; Play Console rejects that.

## 1. Create a release keystore (one-time)

From the **project root** (`D:\Silah\SIlah`), run:

```powershell
keytool -genkeypair -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- Use a **strong password** for the keystore and the key (you can use the same).
- Remember the **alias** you choose (e.g. `upload`).
- `upload-keystore.jks` is already gitignored; **never commit it**.

## 2. Create `key.properties`

1. Copy the example:

   **PowerShell:**
   ```powershell
   Copy-Item android/key.properties.example android/key.properties
   ```

2. Edit `android/key.properties` and set:

   - `storePassword` – keystore password
   - `keyPassword` – key password (often same as `storePassword`)
   - `keyAlias` – alias you used (e.g. `upload`)
   - `storeFile` – path to the `.jks` file **relative to the `android/` folder**

   Example (keystore in `android/upload-keystore.jks`):

   ```properties
   storePassword=your_actual_password
   keyPassword=your_actual_password
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

`key.properties` is gitignored; **do not commit it**.

## 3. Build the release App Bundle

From the **project root**:

```powershell
flutter clean
flutter pub get
flutter build appbundle
```

The signed bundle is at:

```
build/app/outputs/bundle/release/app-release.aab
```

Upload **this file** to Play Console. It will be signed in **release** mode.

---

**Backup:** Store `upload-keystore.jks` and `key.properties` (or the passwords) somewhere safe.  
If you lose them, you cannot sign updates for the same app on Play Store.
