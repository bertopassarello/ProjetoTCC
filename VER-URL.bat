@echo off
chcp 65001 >nul 2>&1
color 0B
cls
title MercadoLive - Ver URL Pública

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║          🌐 MERCADOLIVE - URL PÚBLICA DO SISTEMA              ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Verificar se containers estão rodando
docker ps | findstr "mercadolive-cloudflared" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Sistema não está rodando!
    echo.
    echo Execute: INICIAR.bat
    echo.
    pause
    exit /b 1
)

echo [INFO] Buscando URL pública...
echo.

REM Buscar URL nos logs do cloudflared
docker-compose logs cloudflared 2>nul | findstr /C:"https://" | findstr /C:"trycloudflare.com" > temp_url.txt

REM Ler a última linha (URL mais recente)
for /f "tokens=*" %%a in (temp_url.txt) do set LAST_LINE=%%a
del temp_url.txt >nul 2>&1

REM Extrair apenas a URL
echo %LAST_LINE% | findstr /C:"https://" >nul 2>&1
if %errorlevel% equ 0 (
    echo ┌────────────────────────────────────────────────────────────────┐
    echo │  ✅ SISTEMA RODANDO EM:                                       │
    echo │                                                                │
    for /f "tokens=*" %%u in ('docker-compose logs cloudflared 2^>nul ^| findstr /C:"https://" ^| findstr /C:"trycloudflare.com" ^| findstr /v /C:"Thank you" ^| findstr /v /C:"developers.cloudflare"') do (
        set URL_LINE=%%u
        goto :found
    )
    :found
    REM Extrair apenas a URL da linha
    echo !URL_LINE! | findstr /C:"https://" >nul
    echo │  %URL_LINE%
    echo │                                                                │
    echo └────────────────────────────────────────────────────────────────┘
) else (
    echo [AVISO] URL ainda não foi gerada.
    echo.
    echo Aguarde alguns segundos e tente novamente.
)

echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │  📝 LOGIN:                                                     │
echo │     Email: luizfelipeflorindodasilva@gmail.com                 │
echo │     Senha: Conci12345678987654321@                             │
echo └────────────────────────────────────────────────────────────────┘
echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │  ⚠️  IMPORTANTE:                                               │
echo │     A URL muda cada vez que você reinicia o container!         │
echo │     Execute este arquivo sempre que precisar ver a URL.        │
echo └────────────────────────────────────────────────────────────────┘
echo.

pause
