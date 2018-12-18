table entry : { Id : int, Title : string, Created : time, Author : string, Body : string }
  PRIMARY KEY Id

sequence commentS
table comment : {Id : int, Entry : int, Created : time, Author : string, Body : string }
	PRIMARY KEY Id,
	CONSTRAINT Entry FOREIGN KEY Entry REFERENCES entry(Id)

style forumEntry
style forumComment
style commentForm


val forceUserName =
    u <- Auth.isLoged ();
    case u of
        None => error <xml>You must log in to proceed further.</xml>
      | Some u => return u


fun comments i : transaction xbody =
	queryX (SELECT * FROM comment WHERE comment.Entry = {[i]})
		(fn row =>
			<xml>
				<div class={forumComment}>
					<p>{[row.Comment.Body]}</p>
					<p>By {[row.Comment.Author]} at {[row.Comment.Created]}</p>
				</div>
			</xml>)

and handler r = 
	    id <- nextval commentS;
    		dml (INSERT INTO comment (Id, Entry, Author, Body, Created) VALUES ({[id]}, {[readError r.Entry]}, {[r.Author]}, {[r.Body]}, CURRENT_TIMESTAMP));
		(detail (readError r.Entry))

and mkCommentForm (id:int) s : xbody =
	<xml><form><hidden{#Entry} value={show id}/>
		<p>Your Name:<br/></p><textbox{#Author}/><br/>
		<p>Your Comment:<br/></p><textarea{#Body}/>
		<br/><br/>
      <submit value="Add Comment" action={handler}/>
		<button value="Cancel" onclick={ fn _ => set s False}/></form></xml>

and list () =
	c <- forceUserName;
    rows <- queryX (SELECT * FROM entry)
            (fn row => 
				<xml>
					<div class={forumEntry}>
						<h1><a link={detail row.Entry.Id}>{[row.Entry.Title]}</a></h1>
							<h2>By {[row.Entry.Author]} at {[row.Entry.Created]}</h2>
						<p>{[row.Entry.Body]}</p>
					</div>
				</xml>
            );
    Auth.displayIfAuthenticated (
    return 
	 	<xml>
		  <head>
				<title>All Posts</title>
		  </head>
		  <body>
			<h1>All Posts</h1>
			<p><a href="http://localhost:8080/Forum/admin">Post</a></p>
			<p><a link={Auth.logoff ()}>Log Out</a></p>
            {rows}
		  </body>
    	</xml>)

and detail (i:int) =
	res <- oneOrNoRows (SELECT * FROM entry WHERE entry.Id = {[i]});
	comm <- comments i;
	commentSource <- source False;
	return
	(case res of
		None => <xml>
					<head><title>Entry Not Found</title></head>
					<body>
						<h1>Entry not found</h1>
					</body>
				  </xml>
	 | Some r => <xml>
						<head>
							<title>{[r.Entry.Title]}</title>
						</head>
						<body>
						<h1>{[r.Entry.Title]}</h1>
						<h2>By {[r.Entry.Author]} at {[r.Entry.Created]}</h2>
						<div class={forumEntry}>
						<p>{[r.Entry.Body]}</p>
						<button value="Add Comment" onclick={ fn _ => set commentSource True}/>
						</div>
						<div class={commentForm}>
						<dyn signal={s <- signal commentSource;
                         if s then 
								 	return (mkCommentForm i commentSource) 
								 else return <xml/>}/>
						</div>
						{comm}
						<a link={list ()}>Back to Forum</a>
						</body>
					 </xml>)


open Crud.Make(struct
  val tab = entry
                          
  val title = "Add a Post"
                               
  val cols = {Title = Crud.string "Post Title",
              Created = Crud.time "Created",
              Author = Crud.string "Author",
              Body = {Nam = "Entry Body",
							 Show = fn b => <xml>{[String.length b]} characters</xml>,
							 Widget = fn [nm :: Name] => <xml><textarea{nm}/></xml>,
							 WidgetPopulated = 
							 	fn [nm :: Name] b => <xml><textarea{nm}>{[b]}</textarea></xml>,
                      Parse = readError,
                      Inject = _}
				}
end)



