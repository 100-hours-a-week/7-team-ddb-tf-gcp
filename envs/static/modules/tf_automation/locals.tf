locals {
  per_action_maps = [
    for action, items in var.schedules : {
      for i, item in items :
      "${action}-${item.branch}-${i}" => {
        branch   = item.branch
        schedule = item.schedule
        action   = action
      }
    }
  ]
  flat_schedules = merge(local.per_action_maps...)
}