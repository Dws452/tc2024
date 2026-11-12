param([string]$Start = "tc_4_2")
Set-Location $PSScriptRoot
$enc = New-Object System.Text.UTF8Encoding($true)

function W($p, $c){
  $d = Split-Path $p -Parent
  if($d){ New-Item -ItemType Directory -Force -Path $d | Out-Null }
  [IO.File]::WriteAllText((Join-Path (Get-Location) $p), $c, $enc)
}

function Branch($b){
  Write-Host ""
  Write-Host "============ ПУНКТ $b ============" -ForegroundColor Cyan
  git checkout -B $b 2>$null | Out-Null
  if($LASTEXITCODE -ne 0){ git checkout $b }
}

function Pak($p){ if($p){ npm install $p --save } }

function RunApp($b){
  taskkill /f /im node.exe 2>$null | Out-Null
  Start-Process cmd -ArgumentList '/k','npm start' -WorkingDirectory (Get-Location)
  Write-Host ">>> Открой в браузере localhost:3000 и проверь пункт $b" -ForegroundColor Yellow
  Read-Host ">>> Проверил? Нажми Enter — сервер остановится, работа закоммитится"
  taskkill /f /im node.exe 2>$null | Out-Null
}

function RunNode($f){
  Write-Host ">>> Запускаю node $f" -ForegroundColor Yellow
  node $f
  Read-Host ">>> Проверил результат? Нажми Enter"
}

function Finish($b){
  git add .
  git commit -m $b
  git push origin $b
  Write-Host "--- $b сохранён и запушен ---" -ForegroundColor Green
}

# --- mongod ---
New-Item -ItemType Directory -Force -Path C:\data\db | Out-Null
if(-not (Get-Process mongod -ErrorAction SilentlyContinue)){
  $mongo = "C:\Users\Sanitar_Anatoliy\Desktop\mongodb-win32-x86_64-windows-6.0.22\bin\mongod.exe"
  if(Test-Path $mongo){ Start-Process $mongo -ArgumentList '--dbpath','C:\data\db'; Start-Sleep 3 }
}

# ======== содержимое файлов (листинги пособия) ========

$APPBASE = @'
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
###EXTRA1###
var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var catsRouter = require('./routes/cats');

var app = express();

// view engine setup
###ENGINE###
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
###SESSION###
###COUNTER###
###MENU###
###USER###
app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/cats', catsRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};
  res.status(err.status || 500);
  res.render('error', { title: 'Three Cats' });
});

module.exports = app;
'@

function AppJs($extra1, $engine, $session, $counter, $menu, $user){
  $s = $APPBASE
  $s = $s.Replace('###EXTRA1###', $extra1)
  $s = $s.Replace('###ENGINE###', $engine)
  $s = $s.Replace('###SESSION###', $session)
  $s = $s.Replace('###COUNTER###', $counter)
  $s = $s.Replace('###MENU###', $menu)
  $s = $s.Replace('###USER###', $user)
  return $s
}

$E44  = @'
var engine = require('ejs-locals');
'@
$E81  = @'
var engine = require('ejs-locals');
var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/tc2024');
'@
$E91  = @'
var engine = require('ejs-locals');
var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/tc2024');
var session = require('express-session');
'@
$E93  = @'
var engine = require('ejs-locals');
var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/tc2024');
var session = require('express-session');
var MongoStore = require('connect-mongo');
'@
$ENGL = "app.engine('ejs', engine);"
$SES91 = @'
app.use(session({
  secret: "ThreeCats",
  cookie: {maxAge: 60*1000},
  resave: true,
  saveUninitialized: true
}))
'@
$SES93 = @'
app.use(session({
  secret: "ThreeCats",
  cookie: {maxAge: 60*1000},
  proxy: true,
  resave: true,
  saveUninitialized: true,
  store: MongoStore.create({mongoUrl: 'mongodb://localhost/tc2024'})
}))
'@
$CNT = @'
app.use(function(req, res, next){
  req.session.counter = req.session.counter + 1 || 1;
  next();
})
'@
$MENU = "app.use(require('./middlewares/createMenu.js'));"
$USER = "app.use(require('./middlewares/createUser.js'));"

$PAGEBASE = @'
<!DOCTYPE html>
<html>
<head>
<title><%= title %></title>
<link rel='stylesheet' href='/stylesheets/style.css' />
###BOOTCSS###
</head>
<body>
###NAV###
<%- body %>
###BOOTJS###
</body>
</html>
'@

$BSCSS = '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">'
$BSJS  = '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>'

$NAVBASE = @'
<nav class="navbar navbar-expand-lg bg-body-tertiary">
  <div class="container-fluid">
    <a class="navbar-brand" href="/">Три кота</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
###UL###
      </ul>
###NAVRIGHT###
    </div>
  </div>
</nav>
'@

$UL52 = @'
        <li class="nav-item">
          <a class="nav-link" href="/korzhik">Коржик</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="/karamelka">Карамелька</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="/kompot">Компот</a>
        </li>
'@
$UL84 = $UL52.Replace('href="/korzhik"','href="/cats/korzhik"').Replace('href="/karamelka"','href="/cats/karamelka"').Replace('href="/kompot"','href="/cats/kompot"')
$UL95 = @'
        <% if(typeof nav == 'object' && nav){
        nav.forEach(function(item){
        %>
        <li class="nav-item">
          <a class="nav-link" href="/cats/<%= item.nick %>"><%= item.title %></a>
        </li>
        <%
        })}
        %>
'@
$NR101 = @'
      <ul class="nav navbar-nav navbar-right">
        <li class="nav-item">
          <a class="nav-link" href="/logreg">Войти</a>
        </li>
      </ul>
'@
$NR107 = @'
      <ul class="nav navbar-nav navbar-right">
        <% if(user){ %>
        <form action="/logout" method="post">
          <li class="nav-item">
            <button type="submit" class="nav-link">Выйти</button>
          </li>
        </form>
        <% } else { %>
        <li class="nav-item">
          <a class="nav-link" href="/logreg">Войти</a>
        </li>
        <% } %>
      </ul>
'@

function BuildPage($ul, $navright, $boot){
  $p = $PAGEBASE
  if($boot){
    $p = $p.Replace('###BOOTCSS###', $BSCSS).Replace('###BOOTJS###', $BSJS)
  } else {
    $p = $p.Replace('###BOOTCSS###', '').Replace('###BOOTJS###', '')
  }
  if($ul -eq ''){ return $p.Replace('###NAV###', '') }
  $nav = $NAVBASE.Replace('###UL###', $ul).Replace('###NAVRIGHT###', $navright)
  return $p.Replace('###NAV###', $nav)
}

$idx42 = @'
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

/* Страница Коржика */
router.get('/korzhik', function(req, res, next) {
  res.send("<h1>Страница Коржика</h1>");
});

/* Страница Карамельки */
router.get('/karamelka', function(req, res, next) {
  res.send("<h1>Страница Карамельки</h1>");
});

/* Страница Компота */
router.get('/kompot', function(req, res, next) {
  res.send("<h1>Страница Компота</h1>");
});

module.exports = router;
'@

$idx43 = @'
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

/* Страница Коржика */
router.get('/korzhik', function(req, res, next) {
  res.render('cat', {
    title: 'Коржик',
    picture: "images/korzhik.png",
    desc: "Средний котёнок в семье. Очень любит футбол. Любит бегать, прыгать и веселиться. Иногда делает такие вещи, что из них приходится выбираться всей семье. Одет в форму моряка."
  });
});

/* Страница Карамельки */
router.get('/karamelka', function(req, res, next) {
  res.render('cat', {
    title: 'Карамелька',
    picture: "/images/karamelka.jpeg",
    desc: "Cамый младший член семьи. Коронная фраза — «Я знаю, что надо делать!». Носит красный бант и красное платье."
  });
});

/* Страница Компота */
router.get('/kompot', function(req, res, next) {
  res.render('cat', {
    title: 'Компот',
    picture: "/images/kompont.png",
    desc: "Cтарший котёнок в семье. Ходит в школу. Очень любит грибы, читает про них энциклопедии. Любит игры на логику. Когда очень сильно огорчается, восклицает «Ну вот!» и начинает плакать. Обожает вкусно поесть. Носит зелёный костюм и шапку."
  });
});

module.exports = router;
'@

$idx84 = @'
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

module.exports = router;
'@

$idx92 = @'
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.cookie('greeting', 'Hi!!!').render('index', { title: 'Express' });
});

module.exports = router;
'@

$idx93 = @'
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  req.session.greeting = "Hi!!!";
  res.render('index', { title: 'Express' });
});

module.exports = router;
'@

$idx94 = $idx93.Replace("res.render('index', { title: 'Express' });", "res.render('index', { title: 'Express', counter: req.session.counter });")

$idx101 = @'
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  req.session.greeting = "Hi!!!";
  res.render('index', { title: 'Express', counter: req.session.counter });
});

/* GET login/registration page. */
router.get('/logreg', function(req, res, next) {
  res.render('logreg', { title: 'Вход' });
});

module.exports = router;
'@

$idx104 = @'
var express = require('express');
var router = express.Router();
var User = require('../models/user').User;

/* GET home page. */
router.get('/', function(req, res, next) {
  req.session.greeting = "Hi!!!";
  res.render('index', { title: 'Express', counter: req.session.counter });
});

/* GET login/registration page. */
router.get('/logreg', function(req, res, next) {
  res.render('logreg', { title: 'Вход' });
});

/* POST login/registration page. */
router.post('/logreg', async function(req, res, next) {
  var username = req.body.username;
  var password = req.body.password;
  console.log(username);
  console.log(password);
  var users = await User.find({username: username});
  if(!users.length){
    var user = new User({username: username, password: password});
    await user.save();
    req.session.user_id = user._id;
    res.redirect('/');
  } else {
    res.send("<h1>Пользователь найден</h1>");
  }
});

module.exports = router;
'@

$idx106 = $idx104.Replace("res.render('logreg', { title: 'Вход' });", "res.render('logreg', { title: 'Вход', error: null });").Replace(@'
    res.send("<h1>Пользователь найден</h1>");
'@, @'
    var foundUser = users[0];
    if(foundUser.checkPassword(password)){
      req.session.user_id = foundUser._id;
      res.redirect('/');
    } else {
      res.render('logreg', { title: 'Вход', error: 'Пароль не верный' });
    }
'@)

$idx107 = $idx106 + @'

/* POST logout. */
router.post('/logout', function(req, res, next) {
  req.session.destroy();
  res.locals.user = null;
  res.redirect('/');
});
'@

$idxEjs44 = @'
<% layout('./layout/page.ejs') %>
<h1><%= title %></h1>
<p>Welcome to <%= title %></p>
'@
$idxEjs94 = @'
<% layout('./layout/page.ejs') %>
<h1><%= title %></h1>
<p>Welcome to <%= title %></p>
<p>Счетчик: <%= counter %></p>
'@
$idxEjs105 = @'
<% layout('./layout/page.ejs') %>
<% if(user) { %>
<h1>Привет <%= user.username %></h1>
<% } else { %>
<h1>Привет незалогиненный пользователь</h1>
<% } %>
<h1><%= title %></h1>
<p>Welcome to <%= title %></p>
'@

$cat43 = @'
<!DOCTYPE html>
<html>
<head>
<title><%= title %></title>
<link rel='stylesheet' href='/stylesheets/style.css' />
</head>
<body>
<h1><%= title %></h1>
<img src="<%= picture %>" alt=""/>
<h4>Несколько слов о нашем герое: <%=desc%></h4>
</body>
</html>
'@
$cat44 = @'
<% layout('./layout/page.ejs') %>
<h1><%= title %></h1>
<img src="<%= picture %>" alt=""/>
<h4>Несколько слов о нашем герое: <%=desc%></h4>
'@

$errEjs = @'
<% layout('./layout/page.ejs') %>
<h1><%= message %></h1>
<h2><%= error.status %></h2>
<pre><%= error.stack %></pre>
'@

$cats42 = @'
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('Новый маршрутизатор, для маршрутов, начинающихся с cats');
});

module.exports = router;
'@

$cats82 = @'
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('Новый маршрутизатор, для маршрутов, начинающихся с cats');
});

/* Страница котов */
router.get("/:nick", function(req, res, next) {
  res.send(req.params.nick);
});

module.exports = router;
'@

$cats83 = @'
var express = require('express');
var router = express.Router();
var Cat = require('../models/cat').Cat;

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('Новый маршрутизатор, для маршрутов, начинающихся с cats');
});

/* Страница котов */
router.get("/:nick", async function(req, res, next) {
  var cats = await Cat.find({nick: req.params.nick});
  console.log(cats);
  if(!cats.length) return next(new Error("Нет такого котенка в мультфильме Три кота"));
  var cat = cats[0];
  res.render('cat', {
    title: cat.title,
    picture: cat.avatar,
    desc: cat.desc
  });
});

module.exports = router;
'@

$cats108 = $cats83.Replace("var Cat = require('../models/cat').Cat;", "var Cat = require('../models/cat').Cat;`nvar checkAuth = require('../middlewares/checkAuth.js');").Replace('router.get("/:nick", async function', 'router.get("/:nick", checkAuth, async function')

$logreg101 = @'
<% layout('/layout/page.ejs') %>
<div class="conteiner">
<h1>Регистрация и вход</h1>
<p>Введите имя пользователя и пароль, если такого пользователя нет, то он будет создан.</p>
<form class="form-horizontal">
<div class="form-group">
<label class="control-label col-sm-1">Имя</label>
<div class="col-sm-5">
<input class="form-control" type="text" placeholder="Введите имя"/>
</div>
</div>
<div class="form-group">
<label class="control-label col-sm-1">Пароль</label>
<div class="col-sm-5">
<input class="form-control" type="password" placeholder="Введите пароль"/>
</div>
</div>
<div class="form-group">
<div class="col-sm-offset-1 col-sm-5">
<input class="btn btn-primary" type="submit" value="Войти"/>
</div>
</div>
</form>
</div>
'@

$logreg103 = $logreg101.Replace('<form class="form-horizontal">', '<form class="form-horizontal" action="/logreg" method="post">').Replace('placeholder="Введите имя"/>', 'placeholder="Введите имя" name="username"/>').Replace('placeholder="Введите пароль"/>', 'placeholder="Введите пароль" name="password"/>')

$logreg106 = $logreg103.Replace(@'
</form>
'@, @'
<% if(error){ %>
<div class="alert alert-danger"><%= error %></div>
<% } %>
</form>
'@)

$DATA = @'
var data = [
{
  title: 'Карамелька',
  nick: 'karamelka',
  avatar: '/images/karamelka.jpeg',
  desc: 'Cамый младший член семьи. Коронная фраза — «Я знаю, что надо делать!». Носит красный бант и красное платье.'
},
{
  title: 'Компот',
  nick: 'kompot',
  avatar: '/images/kompont.png',
  desc: 'Cтарший котёнок в семье. Ходит в школу. Очень любит грибы, читает про них энциклопедии. Любит игры на логику. Когда очень сильно огорчается, восклицает «Ну вот!» и начинает плакать. Обожает вкусно поесть. Носит зелёный костюм и шапку.'
},
{
  title: 'Коржик',
  nick: 'korzhik',
  avatar: '/images/korzhik.png',
  desc: 'Средний котёнок в семье. Очень любит футбол. Любит бегать, прыгать и веселиться. Иногда делает такие вещи, что из них приходится выбираться всей семье. Одет в форму моряка.'
}
];
module.exports.data = data;
'@

$cdb61 = @'
const { MongoClient } = require('mongodb');
// Connection URL
const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);
// Database Name
const dbName = 'test2024';
async function main() {
  await client.connect();
  console.log('Connected successfully to server');
  const db = client.db(dbName);
  const collection = db.collection('documents');
  const insertResult = await collection.insertMany([{ a: 1 }, { a: 2 }, { a: 3 }]);
  console.log('Inserted documents =>', insertResult);
  return 'done.';
}
main()
.then(console.log)
.catch(console.error)
.finally(() => client.close());
'@

$cdb62 = @'
var data = require("./data.js").data;
console.log(data)

// const { MongoClient } = require('mongodb');
// const url = 'mongodb://localhost:27017';
// const client = new MongoClient(url);
// const dbName = 'test2024';
// async function main() {
//   await client.connect();
//   console.log('Connected successfully to server');
//   const db = client.db(dbName);
//   const collection = db.collection('documents');
//   const insertResult = await collection.insertMany([{ a: 1 }, { a: 2 }, { a: 3 }]);
//   console.log('Inserted documents =>', insertResult);
//   return 'done.';
// }
// main()
// .then(console.log)
// .catch(console.error)
// .finally(() => client.close());
'@

$cdb63 = @'
const { MongoClient } = require('mongodb');
var data = require("./data.js").data;
// Connection URL
const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);
// Database Name
const dbName = 'tc2024';
async function main() {
  await client.connect();
  console.log('Connected successfully to server');
  const db = client.db(dbName);
  const collection = db.collection('cats');
  const insertResult = await collection.insertMany(data);
  console.log('Inserted documents =>', insertResult);
  return 'done.';
}
main()
.then(console.log)
.catch(console.error)
.finally(() => client.close());
'@

$t71 = @'
const mongoose = require('mongoose');
mongoose.connect('mongodb://127.0.0.1:27017/testMongoose2024');
const Cat = mongoose.model('Cat', { name: String });
const kitty = new Cat({ name: 'Пушок' });
kitty.save().then(() => console.log('Мяу'));
'@

$t72 = @'
const mongoose = require('mongoose');
mongoose.connect('mongodb://127.0.0.1:27017/testMongoose2024');
var schema = mongoose.Schema({ name: String })
schema.methods.meow = function(){
  console.log(this.name + " сказал мяу")
}
const Cat = mongoose.model('Cat', schema);
const kitty = new Cat({ name: 'Пушок' });
kitty.save().then(() => kitty.meow());
'@

$t73 = @'
const mongoose = require('mongoose');
mongoose.connect('mongodb://127.0.0.1:27017/testMongoose2024');
var Cat = require('./models/cat.js').Cat
var cat = new Cat({
  title: "Коржик",
  nick: "korzhik",
})
cat.save().then(() => console.log('Сохранено'));
'@

$catModel = @'
var mongoose = require('mongoose')
var Schema = mongoose.Schema

var catSchema = new Schema({
  title: String,
  nick: {
    type: String,
    unique: true,
    required: true
  },
  avatar: String,
  desc: String,
  created: {
    type: Date,
    default: Date.now
  }
})

module.exports.Cat = mongoose.model("Cat", catSchema)
'@

$user102 = @'
var mongoose = require('mongoose')
var Schema = mongoose.Schema

var userSchema = new Schema({
  username: {
    type: String,
    unique: true,
    required: true
  },
  hashedPassword: {
    type: String,
    required: true
  },
  salt: {
    type: String,
    required: true
  },
  created: {
    type: Date,
    default: Date.now
  }
})

module.exports.User = mongoose.model("User", userSchema)
'@

$user104 = $user102.Replace(@'
module.exports.User = mongoose.model("User", userSchema)
'@, @'
userSchema.methods.encryptPassword = function(password){
  return crypto.createHmac('sha1', this.salt).update(password).digest('hex');
}

userSchema.virtual('password')
  .set(function(password){
    this._plainPassword = password;
    this.salt = Math.random() + '';
    this.hashedPassword = this.encryptPassword(password);
  })
  .get(function(){
    return this._plainPassword;
  })

userSchema.methods.checkPassword = function(password){
  return this.encryptPassword(password) === this.hashedPassword;
}

module.exports.User = mongoose.model("User", userSchema)
'@).Replace('var mongoose = require(''mongoose'')', 'var crypto = require("crypto");' + [Environment]::NewLine + 'var mongoose = require(''mongoose'')')

$checkUser = @'
var mongoose = require("mongoose")
mongoose.connect("mongodb://localhost/tc2024")
var User = require("./models/user.js").User

var first_user = new User({
  username: "Vasya",
  password: "qwerty"
})

first_user.save().then(() => console.log('Пользователь создан'));
'@

$createMenu = @'
var Cat = require("../models/cat").Cat

module.exports = async function(req, res, next){
  res.locals.nav = []
  var menu = await Cat.find(null, {_id: 0, title: 1, nick: 1});
  console.log(menu);
  if(menu.length != 0){
    res.locals.nav = menu;
  }
  next();
}
'@

$createUser = @'
var User = require("../models/user").User

module.exports = async function(req, res, next){
  req.user = res.locals.user = null;
  if(!req.session.user_id) return next();
  var user = await User.findById(req.session.user_id);
  if(user){
    req.user = res.locals.user = user;
  }
  next();
}
'@

$checkAuth = @'
module.exports = function(req, res, next){
  if(!req.session.user_id){
    res.redirect('/');
  }
  next();
}
'@

# ======== выполнение пунктов ========

$steps = @('tc_4_2','tc_4_3','tc_4_4','tc_5_1','tc_5_2','tc_6_1','tc_6_2','tc_6_3','tc_7_1','tc_7_2','tc_7_3','tc_8_1','tc_8_2','tc_8_3','tc_8_4','tc_9_1','tc_9_2','tc_9_3','tc_9_4','tc_9_5','tc_10_1','tc_10_2','tc_10_3','tc_10_4','tc_10_5','tc_10_6','tc_10_7','tc_10_8')
$i = [array]::IndexOf($steps, $Start)
if($i -lt 0){ $i = 0 }

for(; $i -lt $steps.Count; $i++){
  $b = $steps[$i]
  Branch $b
  switch($b){
    'tc_4_2' {
      W 'routes/index.js' $idx42
      W 'routes/cats.js' $cats42
      W 'app.js' (AppJs '' '' '' '' '' '')
      RunApp $b
    }
    'tc_4_3' {
      W 'views/cat.ejs' $cat43
      W 'routes/index.js' $idx43
      RunApp $b
    }
    'tc_4_4' {
      Pak 'ejs-locals'
      W 'app.js' (AppJs $E44 $ENGL '' '' '' '')
      W 'views/layout/page.ejs' (BuildPage '' '' $false)
      W 'views/index.ejs' $idxEjs44
      W 'views/cat.ejs' $cat44
      W 'views/error.ejs' $errEjs
      RunApp $b
    }
    'tc_5_1' {
      W 'views/layout/page.ejs' (BuildPage '' '' $true)
      W 'views/index.ejs' $idxEjs44
      RunApp $b
    }
    'tc_5_2' {
      W 'views/layout/page.ejs' (BuildPage $UL52 '' $true)
      RunApp $b
    }
    'tc_6_1' {
      Pak 'mongodb'
      W 'createDB.js' $cdb61
      RunNode 'createDB.js'
    }
    'tc_6_2' {
      W 'data.js' $DATA
      W 'createDB.js' $cdb62
      RunNode 'createDB.js'
    }
    'tc_6_3' {
      W 'createDB.js' $cdb63
      RunNode 'createDB.js'
    }
    'tc_7_1' {
      Pak 'mongoose'
      W 'testMongoose.js' $t71
      RunNode 'testMongoose.js'
    }
    'tc_7_2' {
      W 'testMongoose.js' $t72
      RunNode 'testMongoose.js'
    }
    'tc_7_3' {
      W 'models/cat.js' $catModel
      W 'testMongoose.js' $t73
      RunNode 'testMongoose.js'
    }
    'tc_8_1' {
      W 'app.js' (AppJs $E81 $ENGL '' '' '' '')
      RunApp $b
    }
    'tc_8_2' {
      W 'routes/cats.js' $cats82
      RunApp $b
    }
    'tc_8_3' {
      W 'routes/cats.js' $cats83
      RunApp $b
    }
    'tc_8_4' {
      W 'views/layout/page.ejs' (BuildPage $UL84 '' $true)
      W 'routes/index.js' $idx84
      RunApp $b
    }
    'tc_9_1' {
      Pak 'express-session'
      W 'app.js' (AppJs $E91 $ENGL $SES91 '' '' '')
      RunApp $b
    }
    'tc_9_2' {
      W 'routes/index.js' $idx92
      RunApp $b
    }
    'tc_9_3' {
      Pak 'connect-mongo'
      W 'app.js' (AppJs $E93 $ENGL $SES93 '' '' '')
      W 'routes/index.js' $idx93
      RunApp $b
    }
    'tc_9_4' {
      W 'app.js' (AppJs $E93 $ENGL $SES93 $CNT '' '')
      W 'routes/index.js' $idx94
      W 'views/index.ejs' $idxEjs94
      RunApp $b
    }
    'tc_9_5' {
      W 'middlewares/createMenu.js' $createMenu
      W 'app.js' (AppJs $E93 $ENGL $SES93 $CNT $MENU '')
      W 'views/layout/page.ejs' (BuildPage $UL95 '' $true)
      RunApp $b
    }
    'tc_10_1' {
      W 'views/logreg.ejs' $logreg101
      W 'routes/index.js' $idx101
      W 'views/layout/page.ejs' (BuildPage $UL95 $NR101 $true)
      RunApp $b
    }
    'tc_10_2' {
      W 'models/user.js' $user102
      W 'checkUser.js' $checkUser
      RunNode 'checkUser.js'
    }
    'tc_10_3' {
      W 'views/logreg.ejs' $logreg103
      RunApp $b
    }
    'tc_10_4' {
      W 'models/user.js' $user104
      W 'routes/index.js' $idx104
      RunApp $b
    }
    'tc_10_5' {
      W 'middlewares/createUser.js' $createUser
      W 'app.js' (AppJs $E93 $ENGL $SES93 $CNT $MENU $USER)
      W 'views/index.ejs' $idxEjs105
      RunApp $b
    }
    'tc_10_6' {
      W 'routes/index.js' $idx106
      W 'views/logreg.ejs' $logreg106
      RunApp $b
    }
    'tc_10_7' {
      W 'views/layout/page.ejs' (BuildPage $UL95 $NR107 $true)
      W 'routes/index.js' $idx107
      RunApp $b
    }
    'tc_10_8' {
      W 'middlewares/checkAuth.js' $checkAuth
      W 'routes/cats.js' $cats108
      RunApp $b
    }
  }
  Finish $b
}

Write-Host ""
Write-Host "=== ВСЕ ПУНКТЫ ГОТОВЫ ===" -ForegroundColor Green
