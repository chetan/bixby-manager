
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Monitoring extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/home"

    links:
      ".create_check_template": "mon_check_template_new"
      ".create_schedule_link":  "mon_oncalls_new"

    handoff: (oncall) ->
      s = "Every "
      p = oncall.get("rotation_period")
      if p == 1
        s += "day"
      else if p == 7
        s += "week"
      else if p == 14
        s += "two weeks"
      s += " on "

      switch oncall.get("handoff_day")
        when 1 then s += "Monday"
        when 2 then s += "Tuesday"
        when 3 then s += "Wednesday"
        when 4 then s += "Thursday"
        when 5 then s += "Friday"
        when 6 then s += "Saturday"
        when 7 then s += "Sunday"

      s += " at " + moment(oncall.get("handoff_time")).format("HH:mm Z")


    oncall_list: (oncall) ->
      users = _.mapR @, oncall.get("users"), (id) -> @users.get(id)
      users.map((u) -> u.get_name()).join(", ")

    user_for: (obj) ->
      if _.isNumber(obj)
        @users.get(obj)
      else
        @users.get(obj.get("current_user_id"))
