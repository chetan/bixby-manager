
class B.CheckTable extends Stark.View
  el: "div.monitoring_content"
  template: "monitoring/check_table"

  links:
    ".edit_checks": [ "mon_hosts_checks_edit", (el) -> return { host: @host, checks: @checks } ]
    ".add_check":   [ "mon_hosts_checks_new", (el) -> return { host: @host } ]
    ".add_trigger": [ "mon_hosts_triggers_new", (el) ->
      return { host: @host, metrics: @metrics, checks: @checks }
      ]
