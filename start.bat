@echo off
REM Script de inicialização para n8n Yazaki Demo (Windows)

setlocal enabledelayedexpansion

echo ================================
echo   n8n Yazaki Demo - Setup Local
echo ================================
echo.

REM Verificar Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [X] Docker nao esta instalado. Por favor, instale Docker primeiro.
    echo     Visite: https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)

REM Verificar Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [X] Docker Compose nao esta instalado. Por favor, instale Docker Compose primeiro.
    echo     Visite: https://docs.docker.com/compose/install/
    pause
    exit /b 1
)

echo [OK] Docker e Docker Compose encontrados
echo.

REM Verificar se .env existe
if not exist .env (
    echo [!] Arquivo .env nao encontrado. Criando a partir de .env.example...
    copy .env.example .env >nul
    echo [OK] .env criado com valores padrao
    echo.
)

REM Iniciar containers
echo [>>] Iniciando containers...
echo.

docker-compose up -d

echo.
echo ================================
echo   Aguardando inicializacao...
echo ================================
echo.

REM Aguardar n8n ficar pronto
setlocal enabledelayedexpansion
for /L %%i in (1,1,30) do (
    curl -s http://localhost:5678/api/v1/info >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] n8n esta online!
        goto :success
    )
    echo   [..] Tentativa %%i/30... aguardando n8n...
    timeout /t 2 /nobreak >nul
)

:success
echo.
echo ================================
echo   [OK] Setup concluido com sucesso!
echo ================================
echo.
echo [*] Acesse o n8n em:
echo     http://localhost:5678
echo.
echo [*] Banco de dados (PostgreSQL):
echo     Host: localhost:5432
echo     Usuario: n8n
echo     Senha: n8n_password
echo.
echo [*] Para mais informacoes, leia README.md
echo.
echo [*] Para parar, execute:
echo     docker-compose down
echo.
pause
