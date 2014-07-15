
class B.CheckTable extends Stark.View
  el: "div.monitoring_content"
  template: "monitoring/check_table"

  links:
    "a.return_host": [ "mon_view_host", (el) -> return {host: @host} ]
