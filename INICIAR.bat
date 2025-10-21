@echo off
chcp 65001 >nul 2>&1
color 0B
cls
title MercadoLive - Iniciar Sistema

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║          🚀 MERCADOLIVE - INICIANDO SISTEMA                   ║
echo ║                                                                ║
echo ║  Pressione qualquer tecla para iniciar...                      ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
pause
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║          🚀 MERCADOLIVE - INICIANDO SISTEMA                   ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Verificar se Docker está rodando
echo [1/6] Verificando Docker Desktop...
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Docker Desktop nao esta rodando!
    echo.
    echo Abra o Docker Desktop e execute este script novamente.
    echo.
    pause
    exit /b 1
)
echo [OK] Docker Desktop detectado
echo.

REM Parar containers antigos
echo [2/6] Limpando containers antigos...
docker-compose down >nul 2>&1
echo [OK] Limpeza concluida
echo.

REM Verificar se precisa build
echo [3/6] Verificando imagens Docker...
docker images > temp_images.txt 2>&1
findstr "mercadolive" temp_images.txt >nul 2>&1
set BUILD_NEEDED=%errorlevel%
del temp_images.txt >nul 2>&1

if %BUILD_NEEDED% neq 0 (
    echo [INFO] Primeira execucao! Construindo imagens (3-5 min^)...
    echo.
    docker-compose build
    if errorlevel 1 (
        echo.
        echo [ERRO] Falha ao construir imagens!
        pause
        exit /b 1
    )
    echo.
    echo [OK] Imagens construidas
) else (
    echo [OK] Imagens encontradas
)
echo.

REM Iniciar containers
echo [4/6] Iniciando containers...
docker-compose up -d
if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falha ao iniciar containers!
    echo.
    echo Vendo logs:
    docker-compose logs --tail=30
    echo.
    pause
    exit /b 1
)
echo [OK] Containers iniciados
echo.

REM Aguardar containers iniciarem
echo [5/6] Aguardando servicos (30s)...
timeout /t 30 /nobreak >nul
echo [OK] Servicos prontos
echo.

REM Buscar URL do Cloudflare Tunnel
echo [6/6] Gerando URL publica gratuita...
timeout /t 8 /nobreak >nul
echo.

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                 ✅ SISTEMA INICIADO COM SUCESSO!              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │  🌐 URL PUBLICA DO SISTEMA:                                   │
echo │                                                                │

REM Buscar URL nos logs
docker-compose logs cloudflared 2>nul | findstr /C:"https://" | findstr /C:"trycloudflare.com" | findstr /v /C:"Thank you" | findstr /v /C:"developers.cloudflare" > temp_cloudflare_url.txt 2>nul

REM Verificar se encontrou URL
if exist temp_cloudflare_url.txt (
    for /f "tokens=*" %%i in (temp_cloudflare_url.txt) do (
        echo %%i
        goto :url_found
    )
)
:url_found
del temp_cloudflare_url.txt >nul 2>&1

echo │                                                                │
echo │  Execute VER-URL.bat para ver a URL novamente                  │
echo └────────────────────────────────────────────────────────────────┘
echo.
echo ┌────────────────────────────────────────────────────────────────┐
echo │  📊 URLs Locais (apenas neste computador):                    │
echo │                                                                │
echo │     Backend Python:   http://localhost:8383                   │
echo │     Backend WhatsApp: http://localhost:3030                   │
echo └────────────────────────────────────────────────────────────────┘
echo.

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  📝 PROXIMOS PASSOS:                                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo   1. Obtenha a URL publica do Cloudflare (instrucoes acima)
echo   2. Acesse a URL no navegador
echo   3. Va para aba "Conexao"
echo   4. Clique em "Conectar WhatsApp"
echo   5. Escaneie o QR Code
echo   6. Pronto! Sistema configurado!
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  ⚙️  COMANDOS UTEIS:                                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo   Parar sistema:  docker-compose stop  ou  stop.bat
echo   Ver logs:       docker-compose logs -f
echo   Status:         docker-compose ps
echo.

echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║  ✅ SISTEMA RODANDO!                                          ║
echo ║                                                                ║
echo ║  Esta janela pode permanecer aberta.                           ║
echo ║  Para fechar o sistema, execute: stop.bat                      ║
echo ║                                                                ║
echo ║  Pressione qualquer tecla para fechar SOMENTE esta janela...  ║
echo ║  (O sistema continuara rodando em segundo plano)              ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
pause
