--[[--
## Overview
Advanced SAM Operators. This scripts tries to make SAM operators more self-preservative.

@author lukrop
@copyright 2016, lukrop
@license GPL v3. See LICENSE file.
]]

aso = {}

--- Chance of SAMs trying to defend ARM missiles, fired at a slant range which is smaller than
-- the missile's maximum range * aso.range_coef. Number between 0 and 1.
aso.chance = 0.5

--- Maximum range coefficient
aso.range_coef = 0.2

--- Distance the supressed SAM moves in meters.
aso.move_dist = 200

--- Speed at which the suppressed SAM moves in km/h.
aso.move_speed = 50

--- Minimum suppression time in seconds
aso.min_suppression = 35

--- Maximum suppression time in seconds
aso.max_suppression = 150

--- Log verbosity. Can be "info", "warn", "error" or "none"
aso.log_level = "info"

aso.log = mist.Logger:new("ASO", aso.log_level)

do
  local function setActive(group, active)
    if not group then aso.log:warn("Couldn't find group.") end
    if group:isExist() then
      if active then
        group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)
        aso.log:info("$1 going active.", group:getName())
      else
        group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
        aso.log:info("$1 going inactive.", group:getName())
      end
    end
  end

  local function evadeMissile(group)
    if not group then aso.log:warn("Couldn't find group.") end
    if group:isExist() then
      -- move into a random direction for aso.move_dist with aso.move_speed
      mist.groupRandomDistSelf(group, aso.move_dist, 'Cone', math.random(360), aso.move_speed)
      -- set unit alarm state to green, making them turning off their radar.
      setActive(group, false)
      -- set active after a random suppression time.
      suppression_time = math.random(aso.min_suppression, aso.max_suppression)
      mist.scheduleFunction(setActive, {group, true}, suppression_time)
      aso.log:info("$1 evading. Suppressed for $2 seconds", group:getName(), suppression_time)
    end
  end

  local function handleShot(event)
    if event.id == world.event.S_EVENT_SHOT and event.weapon and event.initiator then
      local missile = event.weapon:getTypeName()
      -- check if fired missile is a ARM
      if missile == "KH-58" or missile == "KH-25MPU"
         or missile == "AGM-88" or missile == "KH-31P"
         or missile == "ALARM" then
        -- get SAM unit and launcher unit
        local target = event.weapon:getTarget()
        if not target then
          aso.log:info("$1 fired at no target")
          return
        end
        local target_grp = target:getGroup()
        local launcher = event.initiator
        local launcher_grp = launcher:getGroup()

        -- get the max range of the fired missile
        local msl_desc = event.weapon:getDesc()
        local msl_max_range = msl_desc.rangeMaxAltMax
        local slant_range = mist.utils.get3DDist(target:getPoint(), launcher:getPoint())

        if not launcher_grp:isExist() then
          aso.log:warn("Launcher group doesn't exist. Probably bug 31682.")
          aso.log:info("ARM $1 fired on $2 ($3) at a range of $4.", missile, target_grp:getName(),
                      target:getName(), slant_range)
        else
          aso.log:info("ARM $1 fired on $2 ($3) by $4 ($5) at a range of $6.", missile, target_grp:getName(),
                      target:getName(), launcher_grp:getName(), launcher:getName(), slant_range)
        end

        local target_skill = mist.DBs.unitsByName[target:getName()].skill
        local detect_time = 1
        if target_skill == "Average" then
          detect_time = detect_time + math.random(2, 5)
        elseif target_skill == "Good" then
          detect_time = detect_time + math.random(2, 4)
        elseif target_skill == "High" then
          detect_time = detect_time + math.random(1, 3)
        elseif target_skill == "Excellent" then
          detect_time = detect_time + math.random(1)
        end

        -- if slant range is below max_range * range_coef and random chance don't try to evade
        if slant_range < msl_max_range * aso.range_coef then
          if not (math.random(1) <= aso.chance) then return end
        end
        mist.scheduleFunction(evadeMissile, {target_grp}, detect_time)
        aso.log:info("$1 trying to evade in $2 seconds", target_grp:getName(), detect_time)
      end
    end
  end

  -- add our event handler
  mist.addEventHandler(handleShot)
  aso.log:msg("Advanced SAM Operators initialized.")
end

-- vim: sw=2:ts=2
