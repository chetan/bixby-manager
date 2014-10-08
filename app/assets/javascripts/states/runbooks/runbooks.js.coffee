
#= require_tree "./views"

Bixby.app.add_states { tab: "runbooks", views: [ _bv.PageLayout ] },

  "runbooks":
    url:    "runbooks"
    help:   "This page allows you to easily run a script on one or more of your servers.\n\nIn order to see your own custom scripts in the list below, you can attach a Git or Subversion repository by going to [Runbooks > Manage Repositories](/repository)."

    views:  B.RunCommand
    models: [ B.m.HostList, B.m.CommandList, B.m.UserList ]

    validate: ->
      if !(!@current_user.get("otp_required_for_login") || @password_confirmed == true)
        @transition "inventory"
        return false
      return true

  "runbooks_logs":
    url:  "runbooks/logs"
    help: "Logs of all commands that have been run on your servers"

    views: B.CommandLogs
    models: [ B.m.CommandLogList ]

  "runbooks_log":
    url:  "runbooks/logs/:command_log_id"
    help: "Logs of all commands that have been run on your servers"

    views: B.CommandLog
    models: [ B.m.CommandLog ]

  "scheduled_commands_history":
    url:  "runbooks/scheduled_commands/history"
    help: ""

    views:  B.ScheduledCommands
    models: [ B.m.ScheduledCommandHistoryList ]
    page_tab:    "history"

  "scheduled_commands":
    url:  "runbooks/scheduled_commands"
    help: ""

    views:  B.ScheduledCommands
    models: [ B.m.ScheduledCommandList ]
    page_tab:    "active"
