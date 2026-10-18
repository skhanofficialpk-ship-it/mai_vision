# Deployment Guide — MAI Coaching Academy

This guide walks through deploying the MAI Coaching Academy Flutter Web app to Firebase Hosting.

There are two ways to deploy:
- **Method A — GitHub Actions (recommended)**: GitHub's servers build and deploy your app automatically every time you push code. This completely avoids local CLI authentication problems some networks run into with `firebase login` / `firebase deploy`.
- **Method B — Local Firebase CLI**: Deploy directly from your own machine. Simpler in concept, but depends on your local network reaching Google's authentication servers reliably.

If you've been getting `Error: Invalid response body... Premature close` or `Failed to authenticate, have you run firebase login?` errors when deploying locally, that's a network-level issue between your machine and Google's OAuth servers — not a problem with this project. **Use Method A instead.**

---

## Method A — Deploy via GitHub Actions (recommended)

This repo already includes a ready-to-use workflow at `.github/workflows/firebase-deploy.yml`. It builds the Flutter web app and deploys it to Firebase Hosting automatically whenever you push to the `main` branch.

### A.1 — Create a GitHub repository

1. Go to [github.com/new](https://github.com/new) and create a new repository (e.g. `mai-vision-academy`). Keep it **Private** if you prefer — that's fine, this workflow works either way.
2. Don't initialize it with a README (you already have project files).

### A.2 — Push this project to GitHub

From PowerShell, in your `D:\mai_vision` folder:

```powershell
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/mai-vision-academy.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username. If `git` isn't installed, get it from [git-scm.com](https://git-scm.com/download/win) first.

> ⚠️ Your `key.json` is excluded from Git automatically (see `.gitignore`) — it will **not** be uploaded to GitHub as a file. You'll add its contents as a GitHub *Secret* instead (next step), which is the secure way to do this.

### A.3 — Add your service account key as a GitHub Secret

1. Open `D:\mai_vision\key.json` in Notepad and copy its **entire contents** (Ctrl+A, Ctrl+C).
2. On GitHub, go to your repository → **Settings** tab → **Secrets and variables** → **Actions**.
3. Click **New repository secret**.
4. Name: `FIREBASE_SERVICE_ACCOUNT`
5. Value: paste the entire JSON content from `key.json`.
6. Click **Add secret**.

### A.4 — Trigger the deploy

The workflow runs automatically on every push to `main`. Since you already pushed in step A.2, check progress at:

```
https://github.com/YOUR_USERNAME/mai-vision-academy/actions
```

You'll see a workflow run in progress. Click it to watch the build and deploy logs live. It typically takes 2–4 minutes.

If you need to trigger it again without a new commit (e.g. to test), go to the **Actions** tab → **Deploy to Firebase Hosting** workflow → **Run workflow** button.

### A.5 — Future updates

Every time you make changes locally, just commit and push:

```powershell
git add .
git commit -m "Update content"
git push
```

GitHub Actions will rebuild and redeploy automatically — no local `firebase deploy` ever needed again.

---

## Method B — Deploy via local Firebase CLI

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later) installed and on your PATH
- [Node.js](https://nodejs.org) (for Firebase CLI)
- A Google account for Firebase Console

Verify your Flutter setup:
```bash
flutter doctor
```

---

## Step 1 — Install the Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

This opens a browser window to authenticate your Google account.

> **Windows PowerShell users:** Run these exact commands from your project folder (e.g. `D:\mai_vision`):
> ```powershell
> npm install -g firebase-tools
> firebase login
> firebase use mai-vision-academy
> ```
> If `firebase login` doesn't open a browser or seems stuck, run `firebase logout` first, then `firebase login --reauth`.

### ⚠️ Common mistake: `--service-account` is not a real flag

There is **no `--service-account` option** on `firebase deploy` — running it throws `error: unknown option '--service-account'`. That flag exists on Google's `gcloud` CLI, not on `firebase-tools`. Use the `GOOGLE_APPLICATION_CREDENTIALS` environment variable instead — **not** a CLI flag.

### ⚠️ Known bug: `firebase login` fails with "credentials are no longer valid" / "Unable to authenticate using the provided code"

This is a confirmed, active bug in recent `firebase-tools` versions on Windows (see [firebase-tools#10681](https://github.com/firebase/firebase-tools/issues/10681)) — the OAuth token exchange fails with a network-level `Premature close` error during login. It is **not** caused by anything in this project. It happens whether you use the browser flow, `--no-localhost`, or `--reauth`.

**The reliable fix is to skip `firebase login` entirely** and authenticate with a service account key instead — this path doesn't go through the buggy OAuth flow at all.

**One-time setup (recommended) — Windows PowerShell:**
```powershell
# Sets the variable permanently for your Windows user account.
[System.Environment]::SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", "D:\mai_vision\key.json", "User")
```
Close and reopen PowerShell after running this once. Verify it stuck:
```powershell
echo $env:GOOGLE_APPLICATION_CREDENTIALS
```

**Per-session only (if you don't want it permanent):**

**Windows PowerShell:**
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="D:\mai_vision\key.json"
firebase deploy --only firestore,hosting --project mai-vision-academy
```

**Windows Command Prompt (cmd.exe):**
```cmd
set GOOGLE_APPLICATION_CREDENTIALS=D:\mai_vision\key.json
firebase deploy --only firestore,hosting --project mai-vision-academy
```

**macOS / Linux:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
firebase deploy --only firestore,hosting --project mai-vision-academy
```

Where to get `key.json` if you don't have one: Firebase Console → ⚙️ Project Settings → Service Accounts tab → **Generate new private key**. Treat this file like a password — it grants full admin access to your Firebase project.

> 🔒 **Security:** Never commit `key.json` to Git or share it. This project's `.gitignore` already excludes `key.json` and common service-account filename patterns.

For most people building locally on their own machine, plain `firebase login` (Option A above) is simpler than managing a service account key — use the key.json route only if you specifically need non-interactive/CI deployment.

---

## Step 2 — Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Make sure `$HOME/.pub-cache/bin` is on your PATH so the `flutterfire` command is available.

---

## Step 3 — Create the Firebase Project

Option A — via Console (recommended for first-timers):
1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Name it `mai-vision-academy` (or your preferred name)
4. Disable Google Analytics (optional, not required for this project)

Option B — via CLI:
```bash
firebase projects:create mai-vision-academy
```

---

## Step 4 — Enable Firebase Services

In the Firebase Console for your project:

1. **Authentication**
   - Go to Build → Authentication → Get Started
   - Enable the **Email/Password** provider
   - Go to "Users" tab → Add User → enter the admin email and a password
     - Email: `skhanofficial.pk@gmail.com`

2. **Firestore Database**
   - Go to Build → Firestore Database → Create Database
   - Start in **Production mode**
   - Choose a region close to Pakistan (e.g. `asia-south1`)

3. **Hosting**
   - Go to Build → Hosting → Get Started
   - You can skip the CLI instructions shown here since we already have a configured project

> ⚠️ Do **not** enable Firebase Storage. This project never uses it, and enabling it is unnecessary — everything runs on the free **Spark plan** using only Authentication, Firestore, and Hosting.

---

## Step 5 — Connect Your Local Project to Firebase

From the project root directory:

```bash
flutterfire configure
```

You'll be prompted to:
1. Select your Firebase project (`mai-vision-academy`)
2. Select platforms — choose **web** at minimum
3. Confirm the Android package name / iOS bundle ID if you selected those platforms

This regenerates `lib/config/firebase_options.dart` with real credentials. **This step is mandatory** — the file shipped in this project contains placeholder values.

---

## Step 6 — Install Dependencies

```bash
flutter pub get
```

---

## Step 7 — Run Locally to Test

```bash
flutter run -d chrome
```

Test the following before deploying:
- [ ] Home page loads with hero, founder section, courses
- [ ] Admissions form submits successfully (check Firestore Console for the new document)
- [ ] Certificate verification page returns "No results found" for a fake ID
- [ ] `/login` page loads, and logging in with your admin credentials redirects to `/admin`
- [ ] Admin dashboard shows stats and admissions list

---

## Step 8 — Build for Production

```bash
flutter build web --release
```

This outputs static files into `build/web/`.

---

## Step 9 — Deploy Firestore Rules & Hosting

The project already includes `firebase.json`, `.firebaserc`, `firestore.rules`, and `firestore.indexes.json`. From the project root:

```bash
firebase deploy --only firestore,hosting
```

This deploys:
- Firestore security rules
- Firestore composite indexes
- The compiled web app to Firebase Hosting

This project intentionally never enables Firebase Storage or any other paid/Blaze-only service — it runs entirely on the **Spark (free) plan**.

If this is the first deploy and `.firebaserc` doesn't match your actual project ID, update it:
```json
{
  "projects": {
    "default": "YOUR-ACTUAL-PROJECT-ID"
  }
}
```

---

## Step 10 — Verify the Live Site

After deployment finishes, the CLI prints a Hosting URL like:
```
https://mai-vision-academy.web.app
```

Visit it and re-run the checklist from Step 7 against the live site.

---

## Step 11 — (Optional) Connect a Custom Domain

1. In Firebase Console → Hosting → Add custom domain
2. Enter your domain (e.g. `maivisionacademy.com`)
3. Follow the DNS verification steps (add the TXT and A records shown)
4. Wait for SSL provisioning (can take up to 24 hours)

Once connected, update the canonical URLs in `web/index.html`, `web/sitemap.xml`, and `web/robots.txt` to match your real domain.

---

## Ongoing Updates

Whenever you make code changes:

```bash
flutter build web --release
firebase deploy --only hosting
```

If you change `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `error: unknown option '--service-account'` | This flag doesn't exist in `firebase-tools`. Use `GOOGLE_APPLICATION_CREDENTIALS` instead (see Step 1) |
| `Authentication Error: Your credentials are no longer valid` / `Unable to authenticate using the provided code` during `firebase login` | Known CLI bug, not project-related. Skip login entirely — set `GOOGLE_APPLICATION_CREDENTIALS` to your service account key path instead (see Step 1) |
| `flutterfire: command not found` | Add `$HOME/.pub-cache/bin` to your PATH |
| `Error: Failed to authenticate, have you run firebase login?` | Run `firebase login` again. If using PowerShell on Windows and it hangs, run `firebase login --no-localhost` and paste the URL into your browser manually |
| `Error: Project mai-vision-academy not found` | Run `firebase projects:list` to confirm the exact project ID, then `firebase use <correct-id>` |
| Blank page after deploy | Check browser console; usually a missing/incorrect `firebase_options.dart` |
| Admin login fails | Confirm the user exists under Authentication → Users in Firebase Console |
| Admissions not saving | Check Firestore rules are deployed (`firebase deploy --only firestore:rules`) and that the `admissions` collection allows public `create` |
| 404 on page refresh (e.g. `/courses`) | Confirm `firebase.json` has the rewrite rule routing all paths to `/index.html` (already included) |
