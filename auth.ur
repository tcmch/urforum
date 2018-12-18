table user : { Id : int, Username : string, Password : string }
	PRIMARY KEY Id

sequence userS
cookie userSession : {Username : string, Password : string}


fun isLoged () = 
	c' <- getCookie userSession;
	case c' of 
		None => return None
  	  | Some c => return (Some c.Username)


fun ifAuthenticated page row =
	re' <- oneOrNoRows1(SELECT user.Id
							   FROM user 
							   WHERE user.Username = {[row.Username]} 
							   AND user.Password = {[row.Password]});
	case re' of
		None => error <xml>Invalid Login</xml>
	  | Some re => 
	  		setCookie userSession 
					{Value = row, 
                Expires = None,
                Secure = False};
					 page
			

fun ifNewUser page row =
	re' <- oneOrNoRows1(SELECT user.Id
							   FROM user 
							   WHERE user.Username = {[row.Username]} 
							   AND user.Password = {[row.Password]});
	case re' of
		Some re => error <xml>User already exists!</xml> 
	  | None => 
			setCookie userSession {Value = row, Secure = False, Expires = None};
			id <- nextval userS;
			dml (INSERT INTO user (Id, Username, Password)
             		VALUES ({[id]}, {[row.Username]}, {[row.Password]}));
            page


fun displayIfAuthenticated page =
	c <- getCookie userSession;
	case c of
		None => return 
			<xml><head/>
				<body>
				<h1>Not logged in.</h1>
				<p><a link={login ()}>Login</a></p>
				</body>
			</xml>
	 | Some c' => ifAuthenticated page c'


and login () = return
	<xml>
		<head><title>Login to Forum</title></head>
		<body>
			<form>
				<p>Username:<br/><textbox{#Username}/><br/>
				   Password:<br/><password{#Password}/><br/>
					<submit value="Login" action={loginHandler}/>
				</p>
			</form>
			<a link={signup ()}>Sign Up</a>
		</body>
	</xml>

and signup () = return
	<xml>
		<head><title>Create new account</title></head>
		<body>
			<form>
				<p>Username:<br/><textbox{#Username}/><br/>
				   Password:<br/><password{#Password}/><br/>
					<submit value="Signup" action={signupHandler}/>
				</p>
			</form>
		</body>
	</xml>

and logoff () = 
	clearCookie userSession;
    return <xml><body>
	    	<p>You are logged off.</p>
	    	<a link={login ()}>Login</a>
    	</body></xml>

and signupHandler row = 
	ifNewUser (return <xml><head/>
			<body>
				<h1>Created Successfully.</h1>
				<p><a link={login ()}>Login</a></p>
			</body>
		</xml>) row

and loginHandler row = 
	ifAuthenticated (return <xml>
				<head><title>Logged in!</title></head>
				<body>
					<h1>Logged in</h1>
					<p><a href="http://localhost:8080/Forum/list">Explore Forum</a></p>
				</body>
			</xml>) row

