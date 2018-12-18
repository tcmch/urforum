SET storage_engine=InnoDB;

CREATE TABLE uw_auth_user(uw_id bigint NOT NULL, 
                                                       uw_username
                                                        longtext NOT NULL, 
                                                       uw_password
                                                        longtext NOT NULL,
                             PRIMARY KEY (uw_id)
                              
                             );
                             
                             CREATE TABLE uw_auth_users (uw_id INTEGER PRIMARY KEY AUTO_INCREMENT);
                              
                              CREATE TABLE uw_forum_entry(uw_id bigint NOT NULL,
                                                                                
                                                           uw_title
                                                            longtext NOT NULL, 
                                                           uw_created
                                                            timestamp NOT NULL, 
                                                           uw_author
                                                            longtext NOT NULL, 
                                                           uw_body
                                                            longtext NOT NULL,
                               PRIMARY KEY (uw_id)
                                
                               );
                               
                               CREATE TABLE uw_forum_comments (uw_id INTEGER PRIMARY KEY AUTO_INCREMENT);
                                
                                CREATE TABLE uw_forum_comment(uw_id
                                                               bigint NOT NULL, 
                                                               uw_entry
                                                                bigint NOT NULL,
                                                                                
                                                               uw_created
                                                                timestamp NOT NULL,
                                                                                   
                                                               uw_author
                                                                longtext NOT NULL,
                                                                                  
                                                               uw_body
                                                                longtext NOT NULL,
                                 PRIMARY KEY (uw_id),
                                  CONSTRAINT uw_forum_comment_Entry
                                   FOREIGN KEY (uw_entry) REFERENCES uw_forum_entry (uw_id)
                                 );
                                 
                                 CREATE TABLE uw_forum_seq (uw_id INTEGER PRIMARY KEY AUTO_INCREMENT);
                                  
                                  