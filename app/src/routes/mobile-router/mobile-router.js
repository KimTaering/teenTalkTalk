const path = require("path");
var express = require("express");
var router = express.Router();
var mobile_login_controller = require("../../controllers/mobile-controller/mobile-login-controller");
var mobile_policy_controller = require("../../controllers/mobile-controller/mobile-policy-controller");
// const routerUser = require("./src/routes/mobile-router/mobile-router");

const passport = require('passport');
const generateJsonWebToken = require("../../lib/generate_jwt");
const verifyToken = require("../../middleware/verify_token");


// router.use("/user",routerUser);


// 로그인 라우터
router.get('/login', function (req, res) {
  try{
    console.log('mobile-router login');
    // res.render('dataif/login');
  } catch(error) {
    console.log('mobile-router login error:'+error);
  }
});

// kth - mobile - verfiy email
router.get('/verify-email/:code/:email', async function(req, res) {
  let code = req.params.code;
  let email = req.params.email;
  
  console.log('mobile-router verifyEmail 실행');
  try{
    var result = await mobile_login_controller.verifyEmail(req, res);
    console.log('mobile-router verifyEmail result:', result);
    if (result == 0){
      res.json({
        resp : true,
        message: '성공적으로 검증되었습니다'
      });
    } else{
      res.json({
        resp : false,
        message : '확인 실패'
      })
    }
  } catch(err){
    res.json({
      resp : false,
      message : err
    })
  }
});

router.post("/login", async function(req, res) {
  try{
    // 로그인 확인을 위해 컨트롤러 호출
    console.log('mobile-router', req.body);
    var result = await mobile_login_controller.SignIn(req, res);
    // console.log("router.post-/login", result);
    // res.send(result);
    console.log('mobile-router result : ', result);
    let token = generateJsonWebToken(result);
    if (result.code == 0){
      res.json({
        resp : true,
        message : '로그인 성공',
        token : token
      })
    } else {
      res.json({
        resp : false,
        message : '로그인 실패',
        token : token
      })
    }
    
  } catch(error) {
    console.log('mobile-router login:'+error);
    if (result.code == 100){
      res.json({
        resp : false,
        message : '로그인 실패',
        token : token
      })
    }

  }
});

// kth - mobile - renew login
// router.get('renew-login', verifyToken, login_controller.renewLogin);



/*
const LocalStrategy = require('passport-local').Strategy;
passport.use('local-login', new LocalStrategy({
  usernameField: 'userid',
  passwordfield: 'password',
  passReqToCallback: true,
}, async function(req, username, password, done) {
  //console.log(username);
  try{
    var conn = await db.getConnection();
    const query = 'SELECT userid, password, salt, name FROM webdb.member where userid='+username;
    var rows = await conn.query(query);
    if (rows.length) {
      return done(null, {'userid': rows[0].userid})
    } else {
        return done(null, false, {'message': 'your userid is not found'})
    }
  } catch(error) {
    console.log('mobile-router login:'+error);
    return done(error);
  } finally {
    if (conn) conn.end();
  }
}));

//serialize 부분을 작성해야 server.js의 post에서 call한
//passport.authenticate 함수가 정상 작동한다.
passport.serializeUser((user,done)=>{ 
  //console.log('serializeUser:'+user.userid);
  done(null,user.userid);
});

passport.deserializeUser((userid,done)=>{
  //console.log('deserializeUser:'+user);
  done(null,userid);
});
*/
//이게 동작하면 authenticate() 메서드 실행되고 이 값처리는 위의 passport부분에서 실행한다. 

// router.post('/login', passport.authenticate('local-login', {
//   successRedirect: '/mobile/loginSuccess', //인증성공시 이동하는화면주소
//   failureRedirect: '/mobile/loginFailure', //인증실패시 이동하는화면주소
//   failureFlash: true //passport 인증하는 과정에서 오류발생시 플래시 메시지가 오류로 전달됨.
// }));

//이름 변경
router.get("/loginSuccess", function(req, res) {
  res.render('dataif/mem'); 
  redirect('/mobile/login');
  //res.json({msg:'0'});
});

router.get("/loginFailure", function(req, res) {
  var rtnMsg;
  var err = req.flash('error');
  if(err) rtnMsg = err;
  //res.json({success: false, msg: rtnMsg})
  res.redirect('/mobile/login');
  //res.json({errMsg:msg});
  
});

//로그인끝


router.post("/login-check", async function(req, res) {
  try{
    // 로그인 확인을 위해 컨트롤러 호출
    console.log('mobile-router login-check');
    var result = await mobile_login_controller.login_check(req, res);
    //console.log('mobile-router login-check result:'+result);
    switch(result){
      case 1 : res.json({success: false, msg: '해당 유저가 존재하지 않습니다.'}); break;
      //case 2 : res.json({success: false, msg: '해당 유저가 존재하지 않거나 비밀번호가 일치하지 않습니다.'}); break;
      case 2 : 
      case 3 : res.json({success: true}); break;
    }
  } catch(error) {
    console.log('mobile-router login-check error:'+error);
  }
});

router.post("/signup-check", async function(req, res) {
  try{
    // 회원 확인을 위해 컨트롤러 호출
    var result = await mobile_login_controller.login_check(req, res);
    //console.log('mobile-router signup-check result:'+result);
    switch(result){
      case 1 : res.json({success: true}); break;
      case 2 : 
      case 3 : res.json({success: false, msg: '해당 유저가 존재합니다.'}); break;
    }
  } catch(error) {
    console.log('mobile-router signup-check error:'+error);
  }
});


// 로그아웃
router.get("/logout", function(req, res) {
  //console.log("clear cookie");
  // 로그아웃 쿠키 삭제
  res.clearCookie('userid');
  res.clearCookie('username');
  // 세션정보 삭제
  //console.log("destroy session");
  req.session.destroy();
  //res.sendFile(path.join(__dirname, "../public/login.html"));
  req.logout();
  res.redirect('/');
});


// 사용자등록
router.get("/signup", function(req, res) {
  res.render('dataif/signup');
});

router.post("/signup", async function(req, res) {
  try{
    // 사용자등록 컨트롤러 호출
    
    var result = await mobile_login_controller.signUp(req, res);
    // console.log(3);
    //res.send({errMsg:result});
    //if(result==0) res.json({success: true, msg:'등록하였습니다.'});
    //else res.json({success: false, msg:'등록실패하였습니다.'});
    if(result==0){
      console.log('mobile-router signup success');
      // res.redirect('/mobile/auth/login');
      res.json({
        resp: true,
        message: '성공적으로 등록된 사용자'
      }); // kth
    }
    else{
      console.log('mobile-router signup fail');
      // res.redirect('/mobile/auth/signup');
      res.json({
        resp: false,
        message: '등록 실패'
    }); // kth
    }
  } catch(error) {
    console.log('mobile-router signup error:'+error);
  }
});

// router.get('/policy/get-all-policy', mobile_policy_controller.getAllPolicy); // verifyToken

router.get('/policy/get-all-policy', async function(req, res){
  try{
    var result = await mobile_policy_controller.getAllPolicy(req,res);
    // console.log('mobile-router get-all-policy result : ', result);
    // res.render('policy/get-all-policy', {
    //     posts:result,
    //     user:req.user
    // }
    // );
    res.json({
      resp:true,
      message : 'get all policies',
      policies : result
    })
} catch(error) {
    console.log('policy-router get-all-plicy error:'+error);
    res.json({
      resp:false,
      message : 'Failure get all policies'
    })
}
});

router.get('/policy/get-search-policy/:searchValue', async function(req, res) {
  console.log('mobile-router', req.params.searchValue );
  try{
    var result = await mobile_policy_controller.getSearchPolicy(req,res);
    // console.log('mobile-router get-search-policy result : ', result);

    res.json({
      resp:true,
      message : 'get search policies',
      policies : result
    })
} catch(error) {
    console.log('policy-router get-search-policy error:'+error);
    res.json({
      resp:false,
      message : 'Failure get search policies'
    })
}
})

router.get('/policy/get-all-policy-for-search', async function(req, res) {
  try{
    var result = await mobile_policy_controller.getAllPolicyForSearch(req,res);
    // console.log('mobile-router get-all-posts-for-search result : ', result);

    res.json({
      resp:true,
      message : 'get-all-posts-for-search policies',
      policies : result
    })
} catch(error) {
    console.log('policy-router get-search-policy error:'+error);
    res.json({
      resp:false,
      message : 'Failure get-search-policy policies'
    })
}
})

// 배너 이미지, 링크
router.get('/banner', async function (req, res) {
  try{
      var result = await mobile_policy_controller.getBannerData(req,res);
      // res.render('policy/banner', {banner:result});
      res.json({
        resp:true,
        message : 'get banner data',
        banners : result
      })
      }
  catch(error) {
      console.log('mobile-router banner error:'+error);
      res.json({
        resp:false,
        message : 'Failure get-policy-banner policies'
      })
  }
});

module.exports = router;