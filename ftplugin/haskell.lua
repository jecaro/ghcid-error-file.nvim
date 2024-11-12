vim.opt_local.errorformat = "" ..
    -- %W multi-line warning
    -- For some reason, %m doesn't work with %\\?, we need to add two lines for
    -- each case %l line number
    -- %c column number
    -- %k end line number
    -- %e end column number
    -- %m message
    "%W%f:(%l\\,%c)-(%e\\,%k): warning: %m," ..
    "%W%f:(%l\\,%c)-(%e\\,%k): warning:," ..
    "%W%f:%l:%c-%k: warning: %m," ..
    "%W%f:%l:%c-%k: warning:," ..
    "%W%f:%l:%c: warning: %m," ..
    "%W%f:%l:%c: warning:," ..

    -- %E multi-line error
    "%E%f:(%l\\,%c)-(%e\\,%k): error: %m," ..
    "%E%f:(%l\\,%c)-(%e\\,%k): error:," ..
    "%E%f:%l:%c-%k: error: %m," ..
    "%E%f:%l:%c-%k: error:," ..
    "%E%f:%l:%c: error: %m," ..
    "%E%f:%l:%c: error:," ..

    -- %Z Ends a multi-line message. We end it on the first line of the carret
    -- message.
    "%Z %\\+|%.%#," ..

    -- Continue a multi-line message
    "%C    %m," ..

    -- Swallow everything else
    "%-G%.%#"
