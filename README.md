Wield Light [![](https://img.shields.io/badge/license-WTFPL-green.svg?style=flat-square)](http://www.wtfpl.net/)
===========

This modification  for [minetest](http://minetest.net/)  adds ability  to wield
light  and be  able to  see stuff  in the  dark. Makes  sense until  [this pull
request](https://github.com/minetest/minetest_game/pull/188)  is merged  (and I
hope it  will be merged  soon). By default, only  torch, fire, lava  source and
bucket with lava are registered as light sources.

API
---

- `wield_light.register_source('default:torch')`
- `wield_light.unregister_source('default:torch')`
