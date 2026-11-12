@echo off
chcp 65001 >nul
cd /d %~dp0
set START=tc_4_2
if not "%~1"=="" set START=%~1
start "mongo" cmd /c "C:\Users\Sanitar_Anatoliy\Desktop\mongodb-win32-x86_64-windows-6.0.22\bin\mongod.exe --dbpath C:\data\db"
if not exist views\layout mkdir views\layout
if not exist models mkdir models
if not exist middlewares mkdir middlewares
set SKIP=1
call :pt tc_4_2 "routes\index.js routes\cats.js app.js" server "routes\index.js" ""
call :pt tc_4_3 "views\cat.ejs routes\index.js" server "routes\index.js" ""
call :pt tc_4_4 "app.js views\layout\page.ejs views\index.ejs views\cat.ejs views\error.ejs" server "app.js" "ejs-locals"
call :pt tc_5_1 "views\layout\page.ejs views\index.ejs" server "views\layout\page.ejs" ""
call :pt tc_5_2 "views\layout\page.ejs" server "views\layout\page.ejs" ""
call :pt tc_6_1 "createDB.js" node "createDB.js" "mongodb"
call :pt tc_6_2 "data.js createDB.js" node "createDB.js" ""
call :pt tc_6_3 "createDB.js" node "createDB.js" ""
call :pt tc_7_1 "testMongoose.js" node "testMongoose.js" "mongoose"
call :pt tc_7_2 "testMongoose.js" node "testMongoose.js" ""
call :pt tc_7_3 "models\cat.js testMongoose.js" node "testMongoose.js" ""
call :pt tc_8_1 "app.js" server "app.js" ""
call :pt tc_8_2 "routes\cats.js" server "routes\cats.js" ""
call :pt tc_8_3 "routes\cats.js" server "routes\cats.js" ""
call :pt tc_8_4 "views\layout\page.ejs routes\index.js app.js" server "app.js" ""
call :pt tc_9_1 "app.js" server "app.js" "express-session"
call :pt tc_9_2 "routes\index.js" server "routes\index.js" ""
call :pt tc_9_3 "app.js routes\index.js" server "app.js" "connect-mongo"
call :pt tc_9_4 "app.js routes\index.js views\index.ejs" server "app.js" ""
call :pt tc_9_5 "middlewares\createMenu.js app.js" server "app.js" ""
call :pt tc_10_1 "views\logreg.ejs routes\index.js" server "routes\index.js" ""
call :pt tc_10_2 "models\user.js checkUser.js" node "checkUser.js" ""
call :pt tc_10_3 "views\logreg.ejs" server "views\logreg.ejs" ""
call :pt tc_10_4 "routes\index.js models\user.js" server "routes\index.js" ""
call :pt tc_10_5 "middlewares\createUser.js app.js views\index.ejs" server "app.js" ""
call :pt tc_10_6 "routes\index.js views\logreg.ejs" server "routes\index.js" ""
call :pt tc_10_7 "views\layout\page.ejs routes\index.js" server "routes\index.js" ""
call :pt tc_10_8 "middlewares\checkAuth.js routes\cats.js" server "routes\cats.js" ""
echo === ВСЕ ПУНКТЫ ГОТОВЫ ===
goto :eof

:pt
if "%SKIP%"=="1" if not "%~1"=="%START%" goto :eof
set SKIP=0
echo.
echo ============ ПУНКТ %~1 ============
git checkout -b %~1 2>nul
git checkout %~1
if not "%~5"=="" npm install %~5 --save
for %%f in (%~2) do notepad "%%f"
if "%~3"=="server" (
  start "server" cmd /c "npm start"
  echo === Открой localhost:3000 в браузере и проверь пункт ===
  set /p DUMMY=Проверил? Нажми Enter — сервер остановится, работа закоммитится: 
  taskkill /f /im node.exe >nul 2>&1
) else (
  node %~4
  echo === Проверь вывод выше и базу в mongosh ===
  set /p DUMMY=Проверил? Нажми Enter: 
)
git add .
git commit -m %~1
git push origin %~1
echo --- пункт %~1 сохранён и запушен ---
goto :eof
