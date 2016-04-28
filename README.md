# ASO
Advanced SAM Operators for DCS: World.

## Overview
Based on the idea of [Prof_hilactic's Smarter SAM script](http://forums.eagle.ru/showthread.php?t=115939), this script makes AI SAMs evade incoming ARM missiles. After a ARM missile has been fired the SAM will move into a random direction and shut off it's radar for a random time. Depending on the unit's skill the unit will need some seconds to detect incoming missiles.

## Requirements
This script requires [MIST](https://github.com/mrSkortch/MissionScriptingTools).

## Usage
Create a trigger with a DO SCRIPT FILE action pointing to this lua file. Make sure that MIST is loaded beforehand.

## Options
The following variables can be customized inside the script:

* ``aso.chance`` Chance of SAMs trying to defend ARM missiles, fired at a slant range which is smaller than
the missile's maximum range * aso.range_coef. Number between 0 and 1.

* ``aso.range_coef`` Maximum range coefficient. If a missile is fired inside this range the SAM might won't evade.

* ``aso.move_dist`` Distance the supressed SAM moves in meters.

* ``aso.move_speed`` Speed at which the suppressed SAM moves in km/h.

* ``aso.min_suppression`` Minimum suppression time in seconds

* ``aso.max_suppression`` Maximum suppression time in seconds

* ``aso.log_level`` Log verbosity. Can be "info", "warn", "error" or "none"


