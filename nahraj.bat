@echo off
chcp 65001 >nul
title Petrom Stážka – Nahrání na GitHub

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║     PETROM STAVBY KADAŇ – Nahrání na GitHub         ║
echo ╚══════════════════════════════════════════════════════╝
echo.

:: ─── KONTROLA GIT ───────────────────────────────────────────────────────────
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [CHYBA] Git neni nainstalovan!
    echo.
    echo Stahnete Git z: https://git-scm.com/download/win
    echo Po instalaci spustte tento soubor znovu.
    echo.
    pause
    exit /b 1
)
echo [OK] Git nalezen.

:: ─── KONTROLA NODE/NPM ──────────────────────────────────────────────────────
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [CHYBA] Node.js / npm neni nainstalovan!
    echo.
    echo Stahnete Node.js z: https://nodejs.org  (verze LTS)
    echo Po instalaci spustte tento soubor znovu.
    echo.
    pause
    exit /b 1
)
echo [OK] Node.js / npm nalezen.

:: ─── VSTUP OD UZIVATELE ─────────────────────────────────────────────────────
echo.
echo ── NASTAVENÍ GITHUBU ──────────────────────────────────
echo.
set /p GH_USER="Zadejte vase GitHub uzivatelske jmeno: "
set /p GH_REPO="Zadejte nazev repozitare (napr. petrom-stazka): "
set /p GH_EMAIL="Zadejte vas GitHub email: "
set /p GH_NAME="Zadejte vase jmeno (pro Git commit): "

echo.
echo ── KONTROLA STRUKTURY SOUBORU ─────────────────────────

:: Zkontroluj ze jsme ve spravne slozce
if not exist "package.json" (
    echo [CHYBA] Soubor package.json nenalezen!
    echo.
    echo Ujistete se, ze spoustite tento .bat soubor
    echo ze slozky petrom-stazka\ kde jsou vsechny soubory.
    echo.
    pause
    exit /b 1
)

if not exist "index.html" (
    echo [CHYBA] Soubor index.html nenalezen!
    pause
    exit /b 1
)

if not exist "src\petrom-stazka.jsx" (
    echo [CHYBA] Soubor src\petrom-stazka.jsx nenalezen!
    echo.
    echo Ujistete se ze slozka src\ obsahuje:
    echo   - petrom-stazka.jsx
    echo   - main.jsx
    echo.
    pause
    exit /b 1
)

echo [OK] Struktura souboru je v poradku.

:: ─── VYTVORENI .GITIGNORE ────────────────────────────────────────────────────
echo.
echo ── VYTVÁŘENÍ .gitignore ───────────────────────────────
if not exist ".gitignore" (
    (
        echo node_modules/
        echo dist/
        echo .env
        echo .env.local
        echo .DS_Store
        echo Thumbs.db
        echo *.log
    ) > .gitignore
    echo [OK] .gitignore vytvoren.
) else (
    echo [OK] .gitignore jiz existuje, preskakuji.
)

:: ─── VYTVORENI README ────────────────────────────────────────────────────────
if not exist "README.md" (
    (
        echo # Petrom Stavby Kadaň – Elektronická stážka mechaniků
        echo.
        echo Webová PWA aplikace pro evidenci výkonů automechaniků.
        echo.
        echo ## Spuštění
        echo.
        echo ```bash
        echo npm install
        echo npm run dev
        echo ```
        echo.
        echo Aplikace poběží na http://localhost:5173
        echo.
        echo ## Technologie
        echo - React 18 + Vite
        echo - Offline-first ^(IndexedDB^)
        echo - Responzivní design pro telefon / tablet / desktop
        echo - Integrace s DMD systémem přes REST API
    ) > README.md
    echo [OK] README.md vytvoren.
)

:: ─── NPM INSTALL ─────────────────────────────────────────────────────────────
echo.
echo ── INSTALACE ZÁVISLOSTÍ (npm install) ─────────────────
echo    Muze trvat 1-2 minuty...
echo.
npm install
if %errorlevel% neq 0 (
    echo [CHYBA] npm install selhal!
    pause
    exit /b 1
)
echo.
echo [OK] Zavislosti nainstalovany.

:: ─── GIT KONFIGURACE ─────────────────────────────────────────────────────────
echo.
echo ── KONFIGURACE GITU ───────────────────────────────────
git config user.email "%GH_EMAIL%"
git config user.name "%GH_NAME%"
echo [OK] Git uzivatele nastaven.

:: ─── GIT INIT + COMMIT ───────────────────────────────────────────────────────
echo.
echo ── INICIALIZACE GIT REPOZITÁŘE ────────────────────────

if exist ".git" (
    echo [INFO] Git repozitar uz existuje, preskakuji init.
) else (
    git init
    echo [OK] Git repozitar inicializovan.
)

git add .
git commit -m "první verze aplikace – Petrom Stážka mechaniků"
if %errorlevel% neq 0 (
    echo [INFO] Nic noveho k commitnuti, nebo commit jiz existuje.
)

git branch -M main

:: ─── REMOTE ORIGIN ───────────────────────────────────────────────────────────
echo.
echo ── PŘIPOJENÍ K GITHUBU ────────────────────────────────

git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Remote origin uz existuje, aktualizuji URL...
    git remote set-url origin https://github.com/%GH_USER%/%GH_REPO%.git
) else (
    git remote add origin https://github.com/https://github.com/zsiska/IES_Kadan.git
)
echo [OK] Remote origin nastaven na: https://github.com/https://github.com/zsiska/IES_Kadan.git

:: ─── PUSH ────────────────────────────────────────────────────────────────────
echo.
echo ── NAHRÁVÁNÍ NA GITHUB (git push) ─────────────────────
echo.
echo    Prohlizec se muze otevrit pro prihlaseni do GitHubu.
echo    Pouzijte sve GitHub heslo nebo Personal Access Token.
echo.

git push -u origin main
if %errorlevel% neq 0 (
    echo.
    echo [CHYBA] Push selhal!
    echo.
    echo Mozne priciny:
    echo  1. Repozitar "%GH_REPO%" neexistuje na GitHubu
    echo     → Vytvorte ho na: https://github.com/new
    echo     → Nazev: %GH_REPO%
    echo     → Nechte prazdny (bez README, bez .gitignore^)
    echo.
    echo  2. Spatne prihlasovaci udaje
    echo     → Pouzijte Personal Access Token misto hesla
    echo     → Vytvorit token: GitHub → Settings → Developer settings
    echo       → Personal access tokens → Tokens (classic^) → New token
    echo       → Zatrhnete: repo (cely checkbox^)
    echo.
    pause
    exit /b 1
)

:: ─── HOTOVO ──────────────────────────────────────────────────────────────────
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║                    HOTOVO!                          ║
echo ╚══════════════════════════════════════════════════════╝
echo.
echo  Repozitar: https://github.com/%GH_USER%/%GH_REPO%
echo.
echo  Spusteni aplikace lokalne:
echo    npm run dev
echo    → http://localhost:5173
echo.
echo  Pro pristup z tabletu/mobilu ve stejne siti:
echo    Pouzijte IP adresu pocitace misto localhost
echo    napr. http://192.168.1.100:5173
echo.

set /p OPEN="Otevrit repozitar v prohlizeci? (a/n): "
if /i "%OPEN%"=="a" (
    start https://github.com/https://github.com/zsiska/IES_Kadan.git
)

echo.
pause