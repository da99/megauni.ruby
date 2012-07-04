
* Architecture of Conversations

  Thread = Conversation = Message = Content = Object: logic + meta data(parend\_id) + content(title, body)
    |   (website | news article | event | project | private | random thought | magazine article | message/comment)
    | 
    CREATE:
    |     Validation -> Subscription -> Read Authorization -> Sorting -> Notification
    |          |                                                |
    |          |                                         |----------------|
    |          |                                      INBOX | CHAT/BOT | Website 
    |          |                                        /                  \
    |          |                                Mail | Event | River        River
    |          |
    |         Permission to comment on parent
    | 
    READ:
    |   Authen. -> Authorization.
    | 
    UPDATE:
    |   Authen. -> Authorization. -> Validation -> Create/Trash notification
    | 
    Trash:
        Authen. -> Authorization. -> Trash Notification
                               
                              
            -------------------------- \
           /                            \
   Arch. of                              \
   Convers.   Content                     /  *Everything becomes a threaded conversation:*
          \   Subscriptions               /     websites, events, random thoughts, magazine articles, priv. mess., etc.
           \  Notification               /   Exceptions: update history
            ---------------------------      Each object is stored with in the datastore as:
                                                 content(title, body, etc.) + 
                                                 meta(parent_id, created_at, published_at)
                                                 logic(validation, privacy, who can post comments, etc.)
                            

  * Lifes Inboxs
    
    all: 
      Stream of messages:
        [Text]
      [Unfollow website/author.] [Archive it.] [Quote it.]
                
    1: stream
    
      Priv. Mess.
        Write
        
      Drafts
      
      Website
        Write
        Settings
        
      Website
        Write
        Settings
        
      Trash
      
      Archive
        New Folder
        
      Settings: 
                Delete Life
                Change Username
      People
        Fans
        Friends
        Enemies
        [New Group]
      
    2: stream
      [expand]

    [New Life]
    [New Website]

    [Addons]
    [Mass Market Friend-to-Friend] $20-$60/mo
    [New Unibot]
    [etc].

    Account Settings:
  
  * chatroom
    * unibots
    * follow
    * multi-conversations/rooms
