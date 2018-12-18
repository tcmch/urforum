val displayIfAuthenticated : transaction page -> transaction page
val signup : unit -> transaction page
val logoff : unit -> transaction page
val login : unit -> transaction page
val isLoged : unit -> transaction (option string)