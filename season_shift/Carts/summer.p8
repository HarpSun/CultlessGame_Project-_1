pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-->main-0
--------------�🅾️��☉��▥�----------------
map_location ={
    x = 0,
    y = 0,
}
camera_location = {
  x = 0,
  y = 0,
}
changed_map = {}
cg = {
  first_map = 0,
  last_map = 0,
  timer = 0,
  over_func = function()
  end,
}
controller = {
  jump = function ()
    if player.state == "climb" then
      player.climb_jump()
      sfx(10)
    elseif player.can_jump <= player.max_jump and player.can_jump > 0 then
      player.vecter.y = cfg_jump_speed * -1
      direction_flag.y = "up"
      player.can_jump =  player.can_jump - 1
      if player.state ~= "jump" then
        player.state = "jump"
        change_animation(player, "jump")
        change_animation(tail, "jump")
      end
      sfx(11)
    end
  end,

  up = function()
    if player.state == "climb" then
       player.pos_y -= cfg_climb_speed
      local map_x = player.pos_x + (player.flip_x and -1 or (player.width*8))
      local map_y = player.pos_y + player.height*8 - 1
      go_sound.play()
      if get_map_flage(map_x, map_y) ~= player.climb_flag then
        player.state = "nomal"
        change_animation(player, "nomal")
        player.is_physic = true
        player.pos_x = player.pos_x + (player.flip_x and -1 or 1)
      end
    end
  end,
  down = function()
    player.new_ground = 1
    if player.state == "climb" then
        player.pos_y += cfg_climb_speed
      local map_y = player.pos_y + player.height + 10
      local map_x = player.pos_x  + (player.flip_x and -1 or (player.width*8))
      if get_map_flage(player.pos_x, map_y) == 1 or get_map_flage(map_x, map_y) ~= player.climb_flag or get_map_flage(player.pos_x, map_y) == player.climb_flag then
        player.state = "nomal"
        change_animation(player, "nomal")
        player.is_physic = true
      end
    end
  end,
  left = function()
    if player.state ~= "climb" then
      player.flip_x = true
      player_state_x_flag = "fast_go_left"
      if player.vecter.x <= -player_max_v then
        player_state_x_flag = "fast_go_stay"
        -- player.vecter.x = player_max_v
      end
      if player.state ~= "run" and player.state ~= "jump" then
        player.state = "run"
        change_animation(player, "run")
        change_animation(tail, "run")
      end
      if player.state == "run" then
        go_sound.play()
      end
    elseif player.state == "climb" and player.flip_x then
     player.pos_y -= cfg_climb_speed
     local map_x = player.pos_x + (player.flip_x and -1 or (player.width*8))
     local map_y = player.pos_y + player.height*8 - 1
     go_sound.play()
     if get_map_flage(map_x, map_y) ~= player.climb_flag then
       player.state = "nomal"
       change_animation(player, "nomal")
       player.is_physic = true
       player.pos_x = player.pos_x + (player.flip_x and -1 or 1)
     end
    end
  end,
  right = function()
    if player.state ~= "climb" then
      player.flip_x = false
      player_state_x_flag = "fast_go_right"
      if player.vecter.x >= player_max_v then
        player_state_x_flag = "fast_go_stay"
        -- player.vecter.x = player_max_v
      end
      if player.state ~= "run" and player.state ~= "jump" then
        player.state = "run"
        change_animation(player, "run")
        change_animation(tail, "run")
      end
      if player.state == "run" then
        go_sound.play()
      end
    elseif player.state == "climb" and not player.flip_x then
     player.pos_y -= cfg_climb_speed
     local map_x = player.pos_x + (player.flip_x and -1 or (player.width*8))
     local map_y = player.pos_y + player.height*8 - 1
     if get_map_flage(map_x, map_y) ~= player.climb_flag then
       player.state = "nomal"
       change_animation(player, "nomal")
       player.is_physic = true
       player.pos_x = player.pos_x + (player.flip_x and -1 or 1)
     end
     go_sound.play()
    end
  end,
}

function init_game()
  spx_timer = 0
  autumn_config = init_config(cfg_levels_autumn)
  winter_config = init_config(cfg_levels_winter)
  spring_config = init_config(cfg_levels_spring)
  summer_config = init_config(cfg_levels_summer)

  -- game_season = "autum"
  -- game_season = "winter"
  -- game_season = "spring"
  game_season = "summer"

  -- cfg_levels = autumn_config -- �⬅️天�█�⬅️
  -- cfg_levels = winter_config -- �●�天�█�⬅️
  -- cfg_levels = spring_config --�▤�天�█�⬅️
  cfg_levels = summer_config 

  game_level = 1

  direction_flag = {
    x,
    y,
  } --�∧��…➡️�♥签
  cloud = init_cloud()
  moon_map = init_moon()
  game_state_flag = "play"--游�☉◆�⌂��█▒�♥签
  gravity = cfg_gravity-- �♥♪�⌂�
  update_state_flag = "play"
  draw_state_flage = "play"
  player_state_x_flag = "nomal"
  player_acceleration_fast = cfg_player_acceleration_fast--�⌂��█�度
  player_acceleration_low = cfg_player_acceleration_low
  player_max_v = cfg_player_max_v

  go_sound = init_sound(33, 10)

  thief = init_thief()
  thief_event = true
  sandy = init_sandy()
  player = init_player()
  player.can_jump = player.max_jump
  mogu_hit = map_trigger_enter(player, 3, player.mogu_hit, "down")
  jinji_hit = map_trigger_enter(player, 7, game_over, "all")
  lupai_hit = map_trigger_stay(player, 6, function()
    if game_level == 4 or game_level == 9 then
        -- print("pass ❎", player.pos_x-5, player.pos_y - 8, 1)
        spr(175, player.pos_x, player.pos_y - 8)
        -- print("❎", player.pos_x, player.pos_y - 6, 1)
    end
    if btnp(5) then
      if game_level == 9 and player_pinecone == 5 then
        sandy.act = 'show'
      elseif game_level == 4 then
        game_level = 1
        change_level(1)
        -- local next_level = player_pinecone >= 10 then
        player.pos_x = 48
        player.pos_y = 80
      end
      sfx(29)
    end
  end, "all")

  tail = init_tail()

  change_camera = init_change_camera()
  tips = init_tips()

  snow = init_snow()
  -- leaves = init_leaves()
  shake = init_screen_shake()
  chest = init_chest()
  enemies = init_enemies(cfg_levels.level1.enemy_bees, cfg_levels.level1.enemy_catepillers)
  this_songzi_cfg = {}
  for k,v in pairs(cfg_levels.level1.songzi) do
    add(this_songzi_cfg, v)
  end
  if this_songzi_cfg then
    songzi = init_songzis(this_songzi_cfg)
  end
  boxs_table = init_boxs(cfg_levels.level1.box)
  ices_table = init_ices(cfg_levels.level1.ice)

  -- pinecones of whole level
  max_pinecone_num = 5
  player_pinecone = 0
  timer = newtimer()

  map_ani_1 = init_map_animation(7, 15, 2, false)
  map_ani_2 = init_map_animation(6, 15, 2, true)

  ontrigger_stay(player, chest, function()
    spr(175, chest.pos_x+5, chest.pos_y - 8)
    -- print("❎", chest.pos_x+5, chest.pos_y - 8, 1)
    if btnp(5) then
      if player_pinecone ~= 0 then
        player_pinecone -= 1
        chest.pinecone += 1
        sfx(29)
      end
    end
  end, 'chest_store')
  change_level(game_level)
  -- bin_kuai = init_spr("bin_kuai", 159, 240, 88, 1, 1, true)
  -- bin_kuai_2 = init_spr("bin_kuai", 159, 23*8, 88, 1, 1, true)
  -- box_1 = init_box(176, 72, bin_kuai_2)
  -- box_2 = init_box(224, 32, bin_kuai)

  music(0)
end

function _init()
  game_state_flag = "play"
  start_timer = 0
  -- load_level("summer.p8")
  init_game()
end

------------游�☉◆�⌂��█▒机-----------------
game_states = {
----------update�⌂��█▒机--------------
update_states = {
  start_update = function()
  end,

  change_level_update = function()
    if change_camera.update() then
      game_state_flag = "play"
    end
  end,

  play_update = function()
        player.check_position()
        player.update()
        map_ani_1.update()
        map_ani_2.update()
        player.vecter.y = player.vecter.y + (player.is_physic and gravity or 0)
        if (btnp (4) ) controller.jump()
        if (btn (2)) controller.up()
        if (btn (3)) controller.down()
        if (btn (0) ) controller.left()
        if (btn (1) ) controller.right()
        -- if (btnp (5)) season_shift("winter")
        -- if (btnp (5)) change_map(map_cfg)

        player.player_states.states_x[player_state_x_flag]()
        -- player_states.states_y[player_state_y_flag]()
        player.hit()

        for v in all(object_table) do
          if v.name ~= "player" then
              if v.name == "box" or v.name == "ice" then
                  v.vecter.y = v.vecter.y + (v.is_physic and cfg_box_gravity or 0)
                  if v.vecter.y >= cfg_box_max_y then
                    v.vecter.y = cfg_box_max_y
                  end
              else
                  v.vecter.y = v.vecter.y + (v.is_physic and gravity or 0)
              end
            hit(v, 1, "height", function()
              v.vecter.y = 0
            end)
            hit(v, 1, "width", function()
              v.vecter.x = 0
            end)
            hit(v, 14, "height", function()
              v.vecter.y = 0
            end)
            hit(v, 14, "width", function()
              v.vecter.x = 0
            end)
            v.pos_x = v.pos_x + v.vecter.x
            v.pos_y = v.pos_y + v.vecter.y
          end
        end
        boxs_table.update()
        ices_table.update()
        update_cllision()
        player.pos_x = player.pos_x + player.vecter.x
        player.pos_y = player.pos_y + player.vecter.y

        update_animation()
        if abs(player.vecter.x) < player_acceleration_low then
            player_state_x_flag = "nomal"
        else
            player_state_x_flag = "fast_back"
        end
        player.anction_range()
        if game_season == "winter" then
          snow.update()
        end
        -- leaves.update()
        timer.update()
        tail.update()
        enemies.update()
        if thief.act == 'run1' then
            thief.update_run1()
        elseif thief.act == 'run2' and game_level == 9 then
            thief.update_run2()
        end
        if sandy.act == 'show' then
            sandy.update()
        end
        if chest.pinecone == 10 and thief_event then
            game_level = 5
            change_level(5)
            timer.add_timeout('thief_show', 1, function()
                thief.act = 'run1'
                chest.pinecone -= 5
                music(5)
            end)
            thief_event = false
        end
        cloud.update()
        tips.update()
        shake.update()
        sound_update()
    end,

  },
  ---------------------------------

  -----------draw�⌂��█▒机-------------

  draw_states = {
    start_draw = function()
      if start_timer >= 80 then
        load_level("spring.p8")
        init_game()
        game_state_flag = "play"
      end
      start_timer += 1
      local x = flr(start_timer/10)*16
      map(x, 0)
    end,

    change_level_draw = function()
      nomal_draw()
    end,

    play_draw = function()
        nomal_draw()
    end,

  },
  -------------------------------
}
-----------------------------------
function nomal_draw()
    if game_season == "winter" then
      moon_map.draw()
    end
    shake.draw()
    map(map_location.x, map_location.y)
    cloud.draw()

    for v in all(object_table) do
      -- if v.flip_x then
        spr(v.sp, v.pos_x, v.pos_y, v.width, v.height, v.flip_x)
      -- else
          if v.name == 'thief' or v.name == "thief_songzi" then
              if thief.act ~= 'init' then
                  spr(v.sp, v.pos_x, v.pos_y, v.width, v.height)
              end
          -- else
          --   spr(v.sp, v.pos_x, v.pos_y, v.width, v.height)
          end
      -- end
    end
    if game_season == "winter" then
      snow.draw()
    end
    chest.draw()
    sandy.draw()
    if thief.act == 'run1' or thief.act == 'run2' then thief.draw_run1() end
    enemies.draw()
    draw_pinecone_ui()
    -- mogu_hit()
    -- jinji_hit()
    -- lupai_hit()
    update_map_trigger()
    update_trigger()
    -- map_col.update_trg()
    -- camera(player.pos_x-64, 0)

end

-->8
--> global-1
object_table = {}
---------------计�❎��▥�-------------------
newtimer = function ()
    local o = {
        timers = {}
    }
    o.add_timeout = function (name, timeout, callback)
        local start = time()
        local t = {'timeout', start, timeout, callback}
        o.timers[name] = t
    end
    o.del = function (name)
        o.timers[name] = nil
    end
    o.update = function ()
        local now = time()
        for name, timer in pairs(o.timers) do
            local timer_type, timer_start, timeout, callback = timer[1], timer[2], timer[3], timer[4]
            if timer_type == 'timeout' then
                if now - timer_start >= timeout then
                    callback()
                    o.del(name)
                end
            end
        end
    end
    return o
end

----------------------------------------

----------------实�⬅️�😐∧对象---------------
--sp(图�웃♥索�ˇ)--pos_x,pos_y(实�⬅️�😐∧�…�♥)--width,height(图�웃♥�▤度�😐宽度)--
function init_spr(name, sp, pos_x, pos_y, width, height, is_physic, v_x, v_y)
    if not v_x then v_x = 0 end
    if not v_y then v_y = 0 end
    local animation_table = {}
    local animation
    local obj_idx = #object_table + 1
    local spr_obj = {name = name, sp = sp, pos_x = pos_x, pos_y = pos_y, height = height, width = width,
        vecter = {x = v_x, y = v_y},
        is_physic = is_physic,
        animation_table = animation_table,
        animation = animation,
        flip_x = false,
        flip_y = false,
    }
    spr_obj.destroy_cllision = {}
    spr_obj.destroy = function()
      if spr_obj.destroy_trigger_enter then
        spr_obj.destroy_trigger_enter()
      end
      if spr_obj.destroy_trigger_stay then
        spr_obj.destroy_trigger_stay()
      end
      if spr_obj.destroy_trigger_stay then
        spr_obj.destroy_trigger_stay()
      end
      if spr_obj.destroy_cllision then
          for v in all(spr_obj.destroy_cllision) do
              v()
          end
      end
      if spr_obj.destroy_map_enter then
        spr_obj.destroy_map_enter()
      end
      -- object_table[obj_idx] = nil
      del(object_table, spr_obj)
    end

    add(object_table, spr_obj)
    return spr_obj
end
----------------------------------------

-------------�★�⧗碰�★��☉触�◆➡️�⬅️�웃--------------
trigger_table = {}

function update_trigger()
    for _, v in pairs(trigger_table) do
        v()
    end
end

local function trigger(sprit_1, sprit_2, half_type)
    local hit = false

    local x1 = sprit_1.pos_x
    local x2 = sprit_2.pos_x
    local w1 = sprit_1.width * 8
    local w2 = sprit_2.width * 8
    local y1 = sprit_1.pos_y
    local y2 = sprit_2.pos_y
    local h1 = sprit_1.height * 8
    local h2 = sprit_2.height * 8

    if half_type == "up" then
        h1 = h1/2
        y1 = y1 + h1
    elseif half_type == "down" then
        h1 = h1/2
    elseif half_type == "left" then
        w1 = w1/2
        x1 = x1 + w1
    elseif half_type == "right" then
        w1 = w1/2
    end

    local xd = abs((x1 + (w1 / 2)) - (x2 + (w2 / 2)))
    local xs = w1 * 0.5 + w2 * 0.5 - 2
    local yd = abs((y1 + (h1 / 2)) - (y2 + (h2 / 2)))
    local ys = h1 / 2 + h2 / 2 - 2
    if xd < xs and yd < ys then
      hit = true
    end
    return hit
end

function ontrigger_enter(sprit_1, sprit_2, enter_func, trigger_name, half_type)
    local entered = false
    local is_trigger = false
    local function trigger_enter ()
        is_trigger = trigger(sprit_1, sprit_2, half_type)
        if not entered and is_trigger then
            enter_func()
            entered = true
        end
        if entered and not is_trigger then
            entered = false
        end
    end

    local idx = #trigger_table + 1
    add(trigger_table, trigger_enter)
    sprit_1.destroy_trigger_enter = function()
      trigger_table[idx] = nil
    end

    sprit_2.destroy_trigger_enter = function()
      trigger_table[idx] = nil
    end

    return trigger_enter
end

function ontrigger_stay(sprit_1, sprit_2, stay_func, trigger_name)
    local function trigger_stay()
        if trigger(sprit_1, sprit_2) then
            stay_func()
        end
    end

    local idx = #trigger_table + 1
    add(trigger_table, trigger_stay)
    sprit_1.destroy_trigger_stay = function()
      trigger_table[idx] = nil
    end

    sprit_2.destroy_trigger_stay = function()
      trigger_table[idx] = nil
    end

    return trigger_stay
end


-------------�★�⧗碰�★��☉碰�★��⬅️�웃--------------
cllision_table = {}
function update_cllision()
    for k, v in pairs(cllision_table) do
        v.width()
        v.height()
    end
end

function oncllision(sprit_1, sprit_2, cllision_func)
    local tbl = {
        width = function()
            local cllision_width = false
            local x1 = sprit_1.pos_x + sprit_1.vecter.x
            local w1 = sprit_1.width * 8

            local x2 = sprit_2.pos_x + sprit_2.vecter.x
            local w2 = sprit_2.width * 8

            local xd = abs((x1 + (w1 / 2)) - (x2 + (w2 / 2)))
            local xs = w1 * 0.5 + w2 * 0.5

            local cllision_height = false
            local y1 = sprit_1.pos_y
            local h1 = sprit_1.height * 8

            local y2 = sprit_2.pos_y
            local h2 = sprit_2.height * 8

            local yd = abs((y1 + (h1 / 2)) - (y2 + (h2 / 2)))
            local ys = h1 / 2 + h2 / 2

            -- print(xd)
            if xd <= xs and yd < ys then
                sprit_1.vecter.x = 0
                if cllision_func then
                    if cllision_func.width then cllision_func.width() end
                end
            end
        end,
        height = function()
            local cllision_height = false
            local y1 = sprit_1.pos_y + sprit_1.vecter.y
            local h1 = sprit_1.height * 8

            local y2 = sprit_2.pos_y + sprit_2.vecter.y
            local h2 = sprit_2.height * 8

            local yd = abs((y1 + (h1 / 2)) - (y2 + (h2 / 2)))
            local ys = h1 / 2 + h2 / 2

            local x1 = sprit_1.pos_x
            local w1 = sprit_1.width * 8

            local x2 = sprit_2.pos_x
            local w2 = sprit_2.width * 8

            local xd = abs((x1 + (w1 / 2)) - (x2 + (w2 / 2)))
            local xs = w1 * 0.5 + w2 * 0.5

            -- print(yd)
            if yd <= ys and xd < xs then
                sprit_1.vecter.y = 0
                if cllision_func then
                    if cllision_func.height then cllision_func.height() end
                end
            end
        end,
    }
    -- local idx = #cllision_table + 1
    add(cllision_table, tbl)

    local destroy_func = function()
        del(cllision_table, tbl)
    end
    add(sprit_1.destroy_cllision, destroy_func)

    add(sprit_2.destroy_cllision, destroy_func)

end
---------------------------------------

--------------地形碰�★�-------------------
--sprit_flag: palyer = 1, map = 2
function hit(sprit, hit_spr_flag, hit_side, hit_func, not_hit_func)
    local next_x = sprit.pos_x + sprit.vecter.x
    local next_y = sprit.pos_y + sprit.vecter.y
    local w = sprit.width * 8 - 1
    local h = sprit.height * 8 - 1
    local next_last_x = next_x + w
    local next_last_y = next_y + h
    -- if hit_spr_flag == 1 then
    --     next_y = next_y - 8
    -- end

    local function h_func()
        for i = sprit.pos_x, sprit.pos_x + w, w do
            if (get_map_flage(i, (next_y)) == hit_spr_flag) or (get_map_flage(i, (next_last_y)) == hit_spr_flag) then
                return true
            end
        end
        return false
    end

    local function w_func()
        for i = sprit.pos_y, sprit.pos_y + h, h do
            if ((get_map_flage((next_x), i)) == hit_spr_flag) or (get_map_flage((next_last_x), i) == hit_spr_flag) then
                -- x = fget(mget((next_x) / 8, i / 8))
                return true
            end
        end
        return false
    end

    local get_func_tbl = {
        height = function()
            if h_func() then
                hit_func()
            elseif not_hit_func then
                not_hit_func()
            end
        end,

        width = function()
            if w_func() then
                hit_func()
            elseif not_hit_func then
                not_hit_func()
            end
        end,

        all = function()
            if h_func() and w_func()then
                hit_func()
            elseif not_hit_func then
                not_hit_func()
            end
        end,
    }
    get_func_tbl[hit_side]()
end
------------------------------------------


----------------------�☉�建�⌂��⬆️�-------------------
function init_animation(spr_obj, first_spr, last_spr, play_time, ani_flag, loop)
    local update_time = 0
    local sp = first_spr
    local width = spr_obj.width
    local height = spr_obj.height
    local function next_ps(sprit)
        local next = sprit + width
        if next > 15 then next = flr(next / 15) * 16 + height end
        return (sprit + width)
    end
    local updat_v = 1
    spr_obj.animation_table[ani_flag] = function()
        update_time += updat_v
        if update_time == play_time then
            if sp == last_spr then
                sp = first_spr
                if not loop then
                    updat_v = 0
                end
            else
                sp = next_ps(sp)
            end
            update_time = 0
        end
        spr_obj.sp = sp
    end
    if spr_obj.animation == nil then
        spr_obj.animation = spr_obj.animation_table[ani_flag]
    end
end

-------------�☉♥�♪��⌂��⬆️�----------------
function change_animation(spr_obj, ani_flag)
    spr_obj.animation = spr_obj.animation_table[ani_flag]
end

-----------�⌂��⬆️��★��⬆️�---------------
function update_animation()
    for v in all(object_table) do
        if v.animation then
            v.animation()
        end
    end
end

function load_level (cart_name)
    -- load spritesheet
    reload(0x0, 0x0, 0x1000, cart_name)
	reload(0x1000, 0x1000, 0x1000, cart_name)
    -- load map
	reload(0x2000, 0x2000, 0x1000, cart_name)
    -- load flag
	reload(0x3000, 0x3000, 0x0100, cart_name)
end

function init_change_camera()
  local camera_pos = string_to_array(cfg_levels.level1.camera_pos)
  local old_camera_pos_x = camera_pos[1]*8
  local old_camera_pos_y = camera_pos[2]*8
  local now_camera_pos_x = camera_pos[1]*8
  local now_camera_pos_y = camera_pos[2]*8
  local flip_x = false
  local flip_y = false
  local fix_driction_x = 0
  local fix_driction_y = 0
  local reset_player = false
  local reset_player_x = 0
  local reset_player_y = 0
  local function change(level)
    local camera_pos = string_to_array(cfg_levels["level" .. level].camera_pos)
    now_camera_pos_x = camera_pos[1]*8
    now_camera_pos_y = camera_pos[2]*8
    flip_x = old_camera_pos_x > now_camera_pos_x
    flip_y = old_camera_pos_y > now_camera_pos_y
    fix_driction_x = now_camera_pos_x - old_camera_pos_x
    fix_driction_y = now_camera_pos_y - old_camera_pos_y
    if abs(fix_driction_x) > 130 or fix_driction_y ~= 0 then
        reset_player = true
        local player_start_pos = string_to_array(cfg_levels["level" .. level].player_start_pos)
        reset_player_x = player_start_pos[1]
        reset_player_y = player_start_pos[2]
    end
    shake.camera_x = now_camera_pos_x
  end
  local function update()
    local changed_x = false
    local changed_y = false
    if fix_driction_x * (flip_x and -1 or 1) > 0 then
      old_camera_pos_x = old_camera_pos_x + cfg_camera_move_speed.x * (flip_x and -1 or 1)
      fix_driction_x = fix_driction_x + cfg_camera_move_speed.x * (flip_x and 1 or -1)
    else
      changed_x = true
    end
    if fix_driction_y * (flip_x and -1 or 1) > 0 then
      old_camera_pos_y = old_camera_pos_y + cfg_camera_move_speed.y * (flip_y and -1 or 1)
      fix_driction_y = fix_driction_y + cfg_camera_move_speed.y * (flip_y and 1 or -1)
    else
      changed_y = true
    end
    camera_location.x = old_camera_pos_x
    camera_location.y = old_camera_pos_y
    if changed_x and changed_y then
        if reset_player then
            player.pos_x = reset_player_x*8 + camera_location.x
            player.pos_y = reset_player_y*8 + camera_location.y
            reset_player = false
        end
          old_camera_pos_x = now_camera_pos_x
          old_camera_pos_y = now_camera_pos_y
          camera_location.x = old_camera_pos_x
          camera_location.y = old_camera_pos_y
      return true
    else
      return false
    end
  end
  return {
    change = change,
    update = update,
  }
end

function game_over()
  sfx(13)
  if player.hand_songzi >0 then
    player_pinecone = player_pinecone - player.hand_songzi
  end
  change_level(game_level)
end

function change_level(level)
  if level == 12 and game_season == "winter" then
    season_shift("spring")
  end
  if game_level ~= level then
    local current_level_songzi = cfg_levels["level" .. game_level].songzi
    for i=1,#current_level_songzi do
      current_level_songzi[i] = this_songzi_cfg[i]
      this_songzi_cfg[i] = nil
    end
  end
  game_state_flag = "change_level"

  for v in all(enemies.enemies) do
      v.destroy()
  end
  songzi.destroy()
  if boxs_table then
      boxs_table.destroy()
  end
  if ices_table then
     ices_table.destroy()
 end
  for i = 1 ,#this_songzi_cfg do
    this_songzi_cfg[i] = nil
  end

  local level_cfg = cfg_levels["level" .. level]
  if level_cfg.change_map then
    change_map(level_cfg.change_map)
  end
  enemies = init_enemies(level_cfg.enemy_bees, level_cfg.enemy_catepillers)
  if level_cfg.ice and #level_cfg.ice ~= 0 then
      ices_table = init_ices(level_cfg.ice)
  end
  if level_cfg.box and #level_cfg.box ~= 0 then
      boxs_table = init_boxs(level_cfg.box)
  end
  if #level_cfg.songzi ~= 0 then
    for i = 1 ,#level_cfg.songzi do
      this_songzi_cfg[i] = level_cfg.songzi[i]
    end
    if #this_songzi_cfg ~= 0 then
      songzi = init_songzis(this_songzi_cfg)
    end
  end

  for v in all(changed_map) do
    mset(v[1], v[2], v[3])
    del(changed_map, v)
  end

  local camera_pos = string_to_array(level_cfg.camera_pos)
  local camera_pos_x = camera_pos[1]*8
  local camera_pos_y = camera_pos[2]*8
  if level == game_level then
    local player_pos = string_to_array(level_cfg.player_start_pos)
    player.pos_x = player_pos[1]*8 + camera_pos_x
    player.pos_y = player_pos[2]*8 + camera_pos_y
  end
  player.hand_songzi = 0
  change_camera.change(level)
  if game_season == "winter" then
    if level == 5 then
      shake.state = 'start'
      timer.add_timeout('shake', 2, function()
          shake.state = 'init'
          load_level("ruin.p8")
      end)
    elseif level == 6 then
      load_level("winter.p8")
    end
  end

end

local fadetable = {
    '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0',
    '1,1,1,1,1,1,1,0,0,0,0,0,0,0,0',
    '2,2,2,2,2,2,1,1,1,0,0,0,0,0,0',
    '3,3,3,3,3,3,1,1,1,0,0,0,0,0,0',
    '4,4,4,2,2,2,2,2,1,1,0,0,0,0,0',
    '5,5,5,5,5,1,1,1,1,1,0,0,0,0,0',
    '6,6,13,13,13,13,5,5,5,5,1,1,1,0,0',
    '7,6,6,6,6,13,13,13,5,5,5,1,1,0,0',
    '8,8,8,8,2,2,2,2,2,2,0,0,0,0,0',
    '9,9,9,4,4,4,4,4,4,5,5,0,0,0,0',
    '10,10,9,9,9,4,4,4,5,5,5,5,0,0,0',
    '11,11,11,3,3,3,3,3,3,3,0,0,0,0,0',
    '12,12,12,12,12,3,3,1,1,1,1,1,1,0,0',
    '13,13,13,5,5,5,5,1,1,1,1,1,0,0,0',
    '14,14,14,13,4,4,2,2,2,2,2,1,1,0,0',
    '15,15,6,13,13,13,5,5,5,5,5,1,1,0,0'
}

function fade(i)
    for c=0,15 do
        if flr(i+1)>=16 then
            pal(c,0)
        else
            pal(c,string_to_array(fadetable[c+1])[flr(i+1)])
        end
    end
end

function fade_out(season)
    for i=1,16 do
        timer.add_timeout('fade'..i, i*0.1, function()
            fade(i)
            if i == 16 and season then
              season_shift(season)
            end
        end)
    end
end

function string_to_array(str)
    local result = {}
    local num = ''
    for i=1,#str do
        local s = sub(str, i, i)
        if s ~= ',' then
            num = num..s
        else
            add(result, tonum(num))
            num = ''
        end
    end
    add(result, tonum(num))
    return result
end

function table_from_string(str)
  local tab, is_key = {}, true
  local key,val,is_on_key
  local function reset()
    key,val,is_on_key = '','',true
  end
  reset()
  local i, len = 1, #str
  while i <= len do
    local char = sub(str, i, i)
    -- token separator
    if char == '\31' then
      if is_on_key then
        is_on_key = false
      else
        tab[tonum(key) or key] = val
        reset()
      end
    -- subtable start
    elseif char == '\29' then
      local j,c = i,''
      -- checking for subtable end character
      while (c ~= '\30') do
        j = j + 1
        c = sub(str, j, j)
      end
      tab[tonum(key) or key] = table_from_string(sub(str,i+1,j-1))
      reset()
      i = j
    else
      if is_on_key then
        key = key..char
      else
        val = val..char
      end
    end
    i = i + 1
  end
  return tab
end

function init_config (config_table)
    local result = {}
    for level,data in pairs(config_table) do
        result[level] = table_from_string(data)
    end
    return result
end

function _update()
    update_state_flag = game_state_flag .. "_update"
    game_states.update_states[update_state_flag]()
end

function _draw()
    cls()
    camera(camera_location.x, camera_location.y)
    draw_state_flage = game_state_flag .. "_draw"
    game_states.draw_states[draw_state_flage]()
end

-->8
-->scene-2
function init_snow(speed, num, hit_spr_flag)
    if not speed then speed = 1 end
    if not hit_spr_flag then hit_spr_flag = 1 end
    if not num then num = 128 end
    local snows = {}
    for i = 1, num do
        local s = {
            n = i,
            x = rnd(128),
            y = rnd(128),
            speed = rnd(2) + speed
        }
        add(snows, s)
    end

    local function is_land(sp)
        if get_map_flage(sp.x, (sp.y + speed)) == hit_spr_flag then
            sp.y = flr((sp.y + speed) / 8) * 8 - 1
            return true
        end
    end

    local function update()
        for s in all(snows) do
            if not s.landed then
                s.y += s.speed
            end
            if is_land(s) and not s.landed then
                -- s.y = 100
                s.landed = true
                timer.add_timeout('snow_melt'..s.n, 1, function()
                    s.landed = false
                    s.y = camera_location.y
                    s.x = rnd(128)  + camera_location.x
                end)
            end
        end
    end

    local function draw()
        for s in all(snows) do
            pset(s.x, s.y, 6)
        end
    end

    return {
        update = update,
        draw = draw,
    }
end


function init_cloud()
  local function update_location(need_x, speed)
    local cloud_x = need_x
    if cloud_x < -128 then
      cloud_x = 0
    end
    cloud_x = cloud_x - speed
    return cloud_x
  end
  local maps = {}

  local function init_map(x, y, map_x, map_y, width, height, speed)
    local m = {
      x = x,
      y = y,
      map_x = map_x,
      map_y = map_y,
      width = width,
      height = height,
      speed = speed,
      ex_x = 0,
      ex_y = 0,
    }
    m.update = function()
      m.ex_x = update_location(m.ex_x, m.speed)
    end
    add(maps, m)
  end

  init_map(112, 21, 0, 8, 16, 3, 0.2)--2
  init_map(112, 21, 128, 8, 16,  3, 0.2)
  -- init_map(112, 24, 0, 16, 16, 4, 0.3) --3
  -- init_map(112, 24, 128, 16, 16, 4, 0.3)
  init_map(112, 16, 0, 0, 16, 3, 0.4)--1
  init_map(112, 16, 128, 0, 16, 3, 0.4)
  -- init_map(112, 28, 0, 24, 16, 4, 0.5)--4
  -- init_map(112, 28, 128, 24, 16, 4, 0.5)

  local function update()
    if game_season ~= "winter" then
      for v in all(maps) do
        v.update()
      end
    end
  end

  local function draw()
    if game_season ~= "winter" then
      for m in all(maps) do
        map(m.x, m.y, m.map_x + m.ex_x + camera_location.x, m.map_y + camera_location.y, m.width, m.height)
      end
    end
  end
  return {
    update = update,
    draw = draw,
  }
end

function init_moon()
  local moon = {}
    moon.x = 336
  moon.draw = function()
    moon.x -= 0.2
    if moon.x <= -128 then
      moon.x = 720
    end
    map(112, 16, moon.x, camera_location.y + 8)
  end

  return moon
end

function init_tips()
    local putin_tip = init_spr("putin_tip", 0, 12, 70, 1, 1, false, 0, 0)
    local putin_tiped = false
    init_animation(putin_tip, 0, 0, 5, "nomal", true)
    init_animation(putin_tip, 157, 158, 5, "shine", true)
    local function update()
        if not putin_tiped and player_pinecone == 5 then
            change_animation(putin_tip, "shine")
        end
        if putin_tiped and player_pinecone < 5 then
            change_animation(putin_tip, "nomal")
        end
    end
    return {
        update = update,
    }
end

function init_screen_shake()
    local shake = {}
    local offset = 0
    shake.state = 'init'
    shake.camera_x = 0
    shake.draw = function ()
        if shake.state == 'start' then
            local fade = 0.95
            local offset_x=shake.camera_x+16-rnd(32)
            local offset_y=16-rnd(32)
            offset_x*=offset
            offset_y*=offset
            camera(offset_x,offset_y)
            offset*=fade
            if offset<0.5 then
                offset=0
            end
        end
    end
    shake.update = function ()
        if shake.state == 'start' then offset = 1 end
    end
    return shake
end

function season_shift(season)
  if season == "winter" then
    cfg_levels = winter_config
    music(-1)
  elseif season == "spring" then
    cfg_levels = spring_config
    music(-1)
  elseif season == "summer" then
    cfg_levels = summer_config
    music(-1)
  end

  player_pinecone = 0
  load_level(season..".p8")
  game_level = 1
  change_level(1)
  game_season = season
  map_ani_1 = init_map_animation(7, 15, 2, false)
  map_ani_2 = init_map_animation(6, 15, 2, true)
  pal()
end

-->8
-->map-3
function get_map_flage(m_x, m_y)
  return fget(mget(m_x/8+map_location.x,m_y/8+map_location.y))
end

map_trigger_tbl = {}

function update_map_trigger()
  for v in all(map_trigger_tbl) do
    v()
  end
end

function map_trigger(obj, flag, direction)
    local x = obj.pos_x
    local y = obj.pos_y
    local w = obj.width * 8
    local h = obj.height * 8
    local x1, x2, y1, y2 = 0, 0, 0, 0
    if direction == 'left' then
        x1 = x
        y1 = y
        x2 = x
        y2 = y + h
    elseif direction == 'right' then
        x1 = x + w
        y1 = y
        x2 = x + w
        y2 = y + h
    elseif direction == 'up' then
        x1 = x
        y1 = y
        x2 = x + w
        y2 = y
    elseif direction == 'down' then
        x1 = x
        y1 = y + h
        x2 = x + w
        y2 = y + h
    elseif direction == 'all' then
        x1 = x + 2
        y1 = y + 2
        x2 = x + w - 2
        y2 = y + h - 2
    end

    -- if get_map_flage(x1, y1) == flag or get_map_flage(x2, y2) == flag
    --     or get_map_flage(x1, y2) == flag or get_map_flage(x2, y1) == flag then
    --         return true
    -- end
    if get_map_flage(x1, y1) == flag then
        return true, x1, y1
    end
    if get_map_flage(x2, y2) == flag then
        return true, x2, y2
    end
    if get_map_flage(x1, y2) == flag then
        return true, x1, y2
    end
    if get_map_flage(x2, y1) == flag then
        return true, x2, y1
    end
    return false, 0, 0
end

function map_trigger_enter(obj, map_flag, enter_func, direction)
    local entered = false
    local is_trigger = false
    local enter_x
    local enter_y
    local function trigger_enter ()
        is_trigger, enter_x, enter_y = map_trigger(obj, map_flag, direction)
        if not entered and is_trigger then
            enter_func(enter_x, enter_y)
            entered = true
        end
        if entered and not is_trigger then
            entered = false
        end
    end
    obj.destroy_map_enter = function()
      del(map_trigger_tbl, trigger_enter)
    end

    add(map_trigger_tbl, trigger_enter)
    return trigger_enter
end

function map_trigger_stay(obj, map_flag, stay_func, direction)
    local function trigger_stay()
        if map_trigger(obj, map_flag, direction) then
            stay_func()
        end
    end

    add(map_trigger_tbl, trigger_stay)
    return trigger_stay
end

function init_map_animation(map_ani_flag, update_time, max_sp, is_flip)
    local time = 0
    max_sp = max_sp*(is_flip and -1 or 1)
    local map_ani_table = {}
    local timer = 1
    for x=0, 127 do
        for y=0, 31 do
            if fget((mget(x, y)), map_ani_flag) then
                local one = {
                    x = x,
                    y = y,
                    sp = mget(x, y),
                }
                add(map_ani_table, one)
            end
        end
    end
    local function update()
        if timer <= update_time then
            timer = timer + 1
            return
        end
        for s in all(map_ani_table) do
            -- s.sp = s.sp + (time == 0 and 1 or -1)
            mset(s.x, s.y, s.sp + time)
        end
        time = time + (is_flip and -1 or 1)
        timer = 1
        if time == max_sp then
            time = 0
        end
    end
    return {
        update = update,
    }
end

function change_map(change_cfg)
  for v in all(change_cfg) do
    local sv = string_to_array(v)
    mset(sv[1], sv[2], sv[3])
  end
end

-->8
-- objects
function init_chest ()
    local c = init_spr("chest", 139, 9, 80, 2, 2, true, 0, 0)
     c.pinecone = 5
     c.draw = function ()
         print(c.pinecone..'/'..10, c.pos_x, c.pos_y, 4)
     end
     return c
end

function init_songzis(songzi_config)
  local s = {
    table = {},
  }
  for i = 1 , #songzi_config do
    local s_cfg = string_to_array(songzi_config[i])
    local pos_x, pos_y = s_cfg[1], s_cfg[2]
    local b = init_spr("songzi", 141, pos_x, pos_y, 1, 1, false, 0, 0)
    init_animation(b, 141, 142, 5, "move", true)
    ontrigger_enter(b, player, function()
      sfx(8)
      b.destroy()
      player_pinecone = player_pinecone + 1
      player.hand_songzi = player.hand_songzi + 1
      songzi_config[i] = nil
    end)
    add(s.table, b)
  end
  s.destroy = function()
    for v in all(s.table) do
      v.destroy()
    end
  end
  return s
end

-- enemy could be bee or catepiller, depends on type args
function init_enemy (pos_x, pos_y, max_range, speed, flip_x, flip_y, type)
    local e
    if type == 'bee' then
        e = init_spr("bee", 48, pos_x, pos_y, 1, 1, false, 0, 0)
        init_animation(e, 48, 50, 10, "move", true)
        ontrigger_enter(e, player, function()
          game_over()
        end)
        e.sound = init_sound(30, 50)
    elseif type == 'catepiller_x' then
        e = init_spr("catepiller_x", 34, pos_x, pos_y, 1, 1, true, 0, 0)
        init_animation(e, 34, 35, 10, "move", true)
        ontrigger_enter(e, player, function()
            game_over()
        end, "up")
    elseif type == 'catepiller_y' then
        e = init_spr("catepiller_y", 34, pos_x, pos_y, 1, 1, false, 0, 0)
        init_animation(e, 36, 37, 10, "move", true)
        ontrigger_enter(e, player, function()
            game_over()
        end, flip_x and "right" or "left")
    end


    e.flip_x = flip_x
    e.flip_y = flip_y
    e.update = function ()
        if e.name == 'catepiller_x' or e.name == 'bee' then
            if not e.flip_x and e.pos_x > pos_x + max_range then
                e.flip_x = true
            end
            if e.flip_x and e.pos_x < pos_x - max_range then
                e.flip_x = false
            end
            e.pos_x = e.pos_x + (e.flip_x and -speed or speed)
        elseif e.name == 'catepiller_y' then
            if not e.flip_y and e.pos_y < pos_y - max_range then
                e.flip_y = true
            end
            if e.flip_y and e.pos_y > pos_y + max_range then
                e.flip_y = false
            end
            e.pos_y = e.pos_y + (e.flip_y and speed or -speed)
        end
        if e.sound then
          e.sound.play()
        end
    end
    e.draw = function ()
        spr(e.sp, e.pos_x, e.pos_y, 1, 1, e.flip_x, e.flip_y)
    end
    return e
end

function init_enemies (bees_config, catepillers_config)
    local o = {
        enemies = {}
    }
    if bees_config then
      for i=1,#bees_config do
          local e = string_to_array(bees_config[i])
          local pos_x, pos_y, max_range, speed = e[1], e[2], e[3], e[4]
          local flip_x = e[5]==1 and true or false
          local flip_y = e[6]==1 and true or false
          local b = init_enemy(pos_x, pos_y, max_range, speed, flip_x, flip_y, 'bee')
          add(o.enemies, b)
      end
    end
    if catepillers_config then
      for i=1,#catepillers_config do
          local e = string_to_array(catepillers_config[i])
          local pos_x, pos_y, max_range, speed = e[1], e[2], e[3], e[4]
          local flip_x = e[5]==1 and true or false
          local flip_y = e[6]==1 and true or false
          local direction = e[7]==1 and 'y' or 'x'
          local c
          if direction == 'x' then
              c = init_enemy(pos_x, pos_y, max_range, speed, flip_x, flip_y, 'catepiller_x')
          elseif direction == 'y' then
              c = init_enemy(pos_x, pos_y, max_range, speed, flip_x, flip_y, 'catepiller_y')
          end
          add(o.enemies, c)
      end
    end
    o.update = function ()
        for i=1,#o.enemies do
            local e = o.enemies[i]
            e.update()
        end
    end
    o.draw = function ()
        for i=1,#o.enemies do
            local e = o.enemies[i]
            e.draw()
        end
    end
    return o
end

function draw_pinecone_ui()
    local ui_x = 125
    for i = 1, max_pinecone_num do
        if i <= player_pinecone then
            spr(142, ui_x - 6 * i + camera_location.x, 2)
        else
            spr(143, ui_x - 6 * i + camera_location.x, 2)
        end
    end
end

function init_player()
  local player = init_spr("player", 192, 30, 10, 1, 1, true)
  player.state = "nomal"
  player.ground = 1
  player.new_ground = 2
  player.max_jump = 1
  player.can_jump = 1
  player.hand_songzi = 0
  player.on_ground = false
  player.climb_flag = 1

  player.anction_range = function()
    if (player.pos_x < 0) player.pos_x = 1
    if game_level == 9 and game_season == "autum" then
        if (player.pos_x < 515) player.pos_x = 516
        if (player.pos_x > 624) player.pos_x = 624
    end
  end

  player.player_states = {
    states_x = {
      nomal = function()
        player.vecter.x = 0
      end,
      fast_go_left = function()
        player.vecter.x -= player_acceleration_fast
      end,
      fast_back = function()
        if abs(player.vecter.x) < player_acceleration_low then
          player_state_x_flag = "nomal"
        else
          if (player.vecter.x > 0) then
            player.vecter.x -= player_acceleration_low
          elseif (player.vecter.x < 0) then
            player.vecter.x += player_acceleration_low
          end
        end
      end,
      fast_go_right = function()
        player.vecter.x += player_acceleration_fast
      end,
      fast_go_stay = function()
        player.vecter.x = player.vecter.x > 0 and player_max_v or (-1 * player_max_v)
      end
    },
    states_y = {},
  }

  player.on_ground_function = function()
    player.can_jump = player.max_jump
    if player.state ~= "nomal" and player.vecter.y > 0 then
      if player.vecter.x == 0 then
        player.state = "nomal"
        change_animation(player, "nomal")
        change_animation(tail, "nomal")
      else
        player.state = "run"
        change_animation(player, "run")
        change_animation(tail, "run")
      end
    end
    player.new_ground = 2

    if player.vecter.y ~= 0 then
        player.pos_y = (player.vecter.y>0) and flr((player.pos_y + player.vecter.y)/8)*8 or flr((player.pos_y + player.vecter.y)/8)*8 + 8
    end

    player.vecter.y = 0
    player.on_ground = true
  end

  player.climb_function = function(map_flag)
      local map_y = player.pos_y + player.height*8+7
      if player.state == "jump" and get_map_flage(player.pos_x, map_y) ~= map_flag then-- (mget(player.pos_x, map_y - 6, 1) or get_map_flage(player.pos_x + (player.flip_x and -3 or (player.width*8 + 2)), player.pos_y - 8) == 1) and
        -- local map_x = player.pos_x + (player.flip_x and 0 or (player.width*8))

        player.state = "climb"
        player.can_jump = 1
        change_animation(player, "climb")
        change_animation(tail, "climb")
        player.is_physic = false
        player.vecter.y = 0
        player.climb_flag = map_flag
      end
  end

  player.update = function()
  end

  player.hit = function()
    hit(player, 1, "height", function()
        player_acceleration_fast = cfg_player_acceleration_fast
        player_acceleration_low = cfg_player_acceleration_low
        player_max_v = cfg_player_max_v
      player.on_ground_function()
      player.on_floor = 0
    end)
    hit(player, 1, "width", function()
      if player.vecter.x ~= 0 then
        player.pos_x = (player.vecter.x>0) and flr((player.pos_x + player.vecter.x)/8)*8 or flr((player.pos_x + player.vecter.x)/8)*8 + 8
      end
      player.vecter.x = 0

      player.climb_function(1)
    end)
    hit(player, player.new_ground, "height", function()
      player.can_jump = player.max_jump
      player.vecter.y = 0
    end)
    hit(player, player.new_ground, "width", function()
      player.vecter.x = 0
    end)

    hit(player, 14, "height", function()
        player_acceleration_fast = cfg_ice_acceleration_fast
        player_acceleration_low = cfg_ice_acceleration_low
        player_max_v = cfg_ice_max_v
        player.on_ground_function()
        player.on_ice = 0
    end)
    hit(player, 14, "width", function()
        if player.vecter.x ~= 0 then
          player.pos_x = (player.vecter.x>0) and flr((player.pos_x + player.vecter.x)/8)*8 or flr((player.pos_x + player.vecter.x)/8)*8 + 8
        end
        player.vecter.x = 0

        player.climb_function(14)
    end)
  end

  player.climb_jump = function()
    local btn_num = player.flip_x and 1 or 0
    local not_btn = player.flip_x and 0 or 1
    if btn(not_btn) then
      player.state = "nomal"
      change_animation(player, "nomal")
      change_animation(tail, "nomal")
    else
      player.state = "jump"
      change_animation(player, "jump")
      change_animation(tail, "jump")
      player.vecter.y = -3

      player.vecter.x = player.vecter.x + (player.flip_x and 2 or -2)
    end
    player.flip_x = not player.flip_x
    player.is_physic = true
  end

  player.mogu_hit = function(mogu_x, mogu_y)
      player.vecter.y = -1*cfg_mogu_jump
      change_animation(player, "jump")
      player.state = "jump"
      player.can_jump = 0
      mset(mogu_x/8, mogu_y/8, 85)
      sfx(10)
      timer.add_timeout("mogu_hit", 0.1, function()
          mset(mogu_x/8, mogu_y/8, 84)
      end)
  end

  player.check_position = function()
    if player.pos_x + 3 > camera_location.x + 128 then
      change_level(game_level+1)
      game_level = game_level + 1
    end
    if  player.pos_x + 8 < camera_location.x then
      -- printh("game_level- = " .. game_level, "dri")
      change_level(game_level-1)
      game_level = game_level - 1
    end
  end

  init_animation(player, 128, 130, 10, "nomal", true)
  init_animation(player, 151, 154, 10, "run", true)
  init_animation(player, 135, 138, 10, "jump", true)
  init_animation(player, 144, 145, 10, "climb", true)
  -- init_animation(player, )
  return player
end

function init_tail()
  if not player then
    return
  end
  local tail = init_spr("tail", 224, player.pos_x - 8, player.pos_y, 1, 1, false, 0, 0)
  tail.update = function()
    tail.flip_x = player.flip_x
    tail.pos_x = player.pos_x + (tail.flip_x and 8 or - 8)
    tail.pos_y = player.pos_y
  end
  init_animation(tail, 0, 0, 10, "nomal", true)
  init_animation(tail, 147, 150, 10, "run", true)
  init_animation(tail, 131, 134, 10, "jump", true)
  init_animation(tail, 0, 0, 10, "climb", true)
  return tail
end

function init_thief ()
    local thief = init_spr("thief", 160, 20, 60, 1, 1, true)
    local thief_songzi = init_spr("thief_songzi", 141, thief.pos_x, thief.pos_y, 1, 1, false)
    init_animation(thief_songzi, 141, 142, 5, "nomal", true)
    thief.act = 'init'
    thief.mogu_jump_event = false
    thief.fall_event = false
    thief.flip_x = false
    thief.draw_run1 = function ()
        -- thief_mogu_hit()
        spr(thief.sp, thief.pos_x, thief.pos_y, 1, 1)
        thief_songzi.pos_x = thief.pos_x
        thief_songzi.pos_y = thief.pos_y - 6
    end
    local tail = init_spr("tail", 224, thief.pos_x - 8, thief.pos_y, 1, 1, false, 0, 0)
    init_animation(tail, 0, 0, 10, "nomal", true)
    init_animation(tail, 179, 182, 10, "run", true)
    init_animation(tail, 163, 166, 10, "jump", true)
    init_animation(tail, 0, 0, 10, "climb", true)
    tail.update = function()
      tail.flip_x = thief.flip_x
      tail.pos_x = thief.pos_x + (tail.flip_x and 8 or - 8)
      tail.pos_y = thief.pos_y
    end
    thief.update_run1 = function ()
        if not thief.mogu_jump_event then
            thief.state = 'run'
            change_animation(thief, 'run')
            change_animation(tail, 'run')
            thief.pos_x += 2
        end
        if thief.pos_x >= 68 and not thief.mogu_jump_event then
            thief.vecter.y -= 4
            thief.vecter.x += 0.5
            thief.mogu_jump_event = true
        end
        if thief.pos_x >= 96 then
            hit(thief, 1, "width", function()
                thief.vecter.x = 0
                thief.vecter.y = -3
                timer.add_timeout('thief_move', 0.1, function()
                    thief.vecter.x = 2
                end)
            end)
        end
        tail.update()
        if thief.pos_x >= 520 then
            thief.vecter.x = 0
            thief.act = 'run2'
        end
    end
    thief.mogu_hit = function()
        change_animation(thief, 'jump')
        change_animation(tail, 'jump')
        thief.vecter.y = -5
        timer.add_timeout('thief_jump', 0.1, function()
            thief.vecter.x = 1
        end)
    end
    thief.draw_run2 = function ()
    end
    thief.update_run2 = function ()
        if not (thief.pos_x >= 584) then
            change_animation(thief, 'run')
            change_animation(tail, 'run')
            thief.pos_x += 2
        else
            if not thief.fall_event then
                thief.state = 'fall'
                thief.vecter.x = 0
                change_animation(thief, 'fall')
                change_animation(tail, 'nomal')
                timer.add_timeout('thief_run', 1, function()
                    change_animation(thief, 'run')
                    change_animation(tail, 'run')
                    thief.state = 'run'
                    init_songzis({
                      '584,88',
                      '600,88',
                      '552,88',
                      '576,88',
                      '616,88',
                    })
                    thief_songzi.destroy()
                end)
                thief.fall_event = true
            end
            if thief.state ~= 'fall' then thief.pos_x += 2 end
        end
        tail.update()
    end
    thief_mogu_hit = map_trigger_enter(thief, 3, thief.mogu_hit, "down")
    -- init_animation(thief, 160, 162, 10, "nomal", true)
    init_animation(thief, 167, 170, 10, "run", true)
    init_animation(thief, 183, 186, 10, "jump", true)
    init_animation(thief, 176, 177, 10, "climb", true)
    init_animation(thief, 178, 178, 10, "fall", false)
    return thief
end

function init_sandy ()
    local sandy = {x=600, y=88}
    sandy.act = 'init'
    sandy.draw = function ()
        spr(187, sandy.x, sandy.y, 1, 1, true)
        sspr(16, 32, 16, 16, 600, 80)
    end
    sandy.update = function ()
        sandy.x -= 0.1
        if sandy.x <= 592 then
            sandy.x = 592
            fade_out("winter")
            sandy.act = 'init'
            -- season_shift("winter")

        end
    end
    return sandy
end

function init_comoon_box(box)
    box.down_dis = 0
    box.can_hit = false
    -- box.can_move = true
    map_trigger_enter(box, 7, function(zhui_x, zhui_y)
      -- printh("box_enter==============", "dir")
      local x, y = zhui_x/8, zhui_y/8
      local one = {x, y, mget(x, y)}
      add(changed_map, one)
      mset(x, y, 0)
    end, "all")
    oncllision(box, player, {
      height = function()
        player.on_ground_function()
        player.vecter.y = box.vecter.y
      end,
      width = function()
          -- if not box.can_move then
          --     player.vecter.x = 0
          -- end
          local player_v_x = player.vecter.x
          if abs(player_v_x) >= cfg_box_max_v then
              player.vecter.x = player_v_x > 0 and cfg_box_max_v or -1*cfg_box_max_v
          end
          box.vecter.x = player_v_x
      end,
    })
    box.update = function()
      hit(box, 1, "height", function()
        box.down_dis = 0
        box.can_hit = false
      end, function()
        if box.down_dis >= 13 then box.can_hit = true end
        box.down_dis = box.down_dis + box.vecter.y
      end)

      -- hit(box, 1, "width", function()
      --     box.can_move = false
      -- end)
      box.vecter.x = 0
    end
end

function init_ices(ice_config)
    local ices = {
      table = {},
    }
    local function init_ice(pos_x, pos_y, is_songzi)
        local sp = is_songzi and 196 or 212
        local ice = init_spr("ice", sp, pos_x, pos_y, 1, 1, true, 0, 0)
        init_comoon_box(ice)
        ice.is_songzi = is_songzi

        for v in all(ices.table) do
            oncllision(ice, v, {
                width = function()
                  -- ice.can_move = false
                  ice.vecter.x = 0
                end,
                height = function()
                    ice.pos_y = v.pos_y - 8
                    ice.vecter.y = 0
                    ice.down_dis = 0
                    if ice.can_hit or v.can_hit then
                        v.destroy()
                        ice.destroy()
                    end
                end,}
            )
        end
        return ice
    end

    if ice_config then
        for i = 1 , #ice_config do
            local cfg_tbl = string_to_array(ice_config[i])
            local pos_x, pos_y, is_songzi = cfg_tbl[1], cfg_tbl[2], cfg_tbl[3]
            ice = init_ice(pos_x, pos_y, is_songzi)
            ice.idx = i
            add(ices.table, ice)
        end
    end

    ices.destroy = function()
        for v in all(ices.table) do
            v.destroy()
        end
    end

    ices.update = function()
        for v in all(ices.table) do
            hit(v, 1, "height", function()
                if v.can_hit then
                    v.destroy()
                end
            end)
            v.update()
        end
    end

    return ices
end

function init_boxs(box_config)
  local boxs = {
    table = {},
  }

  local function init_box(pos_x, pos_y)
    local box = init_spr("box", 192, pos_x, pos_y, 1, 1, true, 0, 0)

    init_comoon_box(box)

    for bin_kuai in all(ices_table.table) do
        oncllision(box, bin_kuai, {
            width = function()
              -- box.pos_x = bin_kuai.pos_x + (box.pos_x > bin_kuai.pos_x  and 8 or -8)
              -- box.can_move = false
              box.vecter.x = 0
            end,
          height = function()
            bin_kuai.pos_y = bin_kuai.pos_y - bin_kuai.vecter.y
            local b_y, k_y = box.pos_y, bin_kuai.pos_y
            box.pos_y = k_y + ((b_y > k_y) and 8 or -8) + cfg_box_gravity
            -- box.pos_y = k_y - 8
            box.vecter.y = 0
            box.down_dis = 0
            bin_kuai.vecter.y = 0
            bin_kuai.down_dis = 0
            if box.can_hit then bin_kuai.destroy() end
            box.can_hit = false
            bin_kuai.can_hit = false
          end,
        })
    end

    for v in all(boxs.table) do
        oncllision(box, v, {
          width = function()
              box.vecter.x = v.vecter.x
              -- box.can_move = false
          end,
          height = function()
            box.pos_y = v.pos_y - 8
            box.vecter.y = 0
          end,
        })
    end

    return box
  end

  for i = 1 , #box_config do
    local cfg_tbl = string_to_array(box_config[i])
    local b_x, b_y = cfg_tbl[1], cfg_tbl[2]
    local box = init_box(b_x, b_y, bin_kuai)
    box.idx = i
    add(boxs.table, box)
  end

  boxs.destroy = function()
      for v in all(boxs.table) do
          v.destroy()
      end
  end

  boxs.update = function()
      for v in all(boxs.table) do
          v.update()
      end
  end

  return boxs
end

-->8
-->game_cfg

cfg_player_acceleration_fast = 0.25 -- �➡️步�⌂��█�度
cfg_player_acceleration_low = 0.5 -- �➡️步�♥◆�█�度
cfg_player_max_v = 1.5 -- �█大�█�度
cfg_ice_acceleration_fast = 0.1--�●�面�⌂��█�度
cfg_ice_acceleration_low = 0.1--�●�面�♥◆�█�度
cfg_ice_max_v = 3 -- �●�面�█大�█�度

cfg_jump_speed = 2.5 -- 跳�⬇️�█�度
cfg_climb_speed = 1.6 -- �☉��▥�█�度
cfg_gravity = 0.2 -- �♥♪�⌂�(�…➡️�⬅️�░�⌂��█�度)

cfg_mogu_jump = 3.5 -- �♥♥�▤➡️�◆♥跳�⬇️�█�度
cfg_camera_move_speed = { -- �☉♥�♪�地图�❎��ˇ�头移�⌂��█�度
  x = 5,
  y = 5,
}

cfg_box_gravity = 0.1 --箱�…�░�♥♪�⌂�
cfg_box_max_v = 1.5 --�🅾️�箱�…�█大�█�度
cfg_box_max_y = 3 --箱�…�★😐�●��❎y轴�░�█大�█�度

cfg_levels_autumn = {
  level1 = 'enemy_catepillerscamera_pos0,0icesboxsongzi140,88enemy_beesplayer_start_pos0,7',
  level2 = 'songzi1208,48icesenemy_catepillersenemy_beescamera_pos16,0player_start_pos0,7box',
  level3 = 'player_start_pos0,7icesenemy_beessongzi1288,642352,48camera_pos32,0boxenemy_catepillers',
  level4 = 'songzi1432,72icescamera_pos48,0player_start_pos0,7enemy_bees1432,64,24,0.5,0enemy_catepillers1432,72,24,0.5,1box',
  level5 = 'player_start_pos0,7camera_pos0,0songzienemy_catepillersicesboxenemy_beeschange_map123,11,2224,11,2342,7,16442,8,16542,9,16642,10,16763,9,16863,10,16963,11,16',
  level6 = 'songzienemy_catepillers1216,48,8,0.5player_start_pos0,5enemy_beesboxicescamera_pos16,0',
  level7 = 'boxenemy_bees1280,64,16,0.52336,48,16,0.5songzicamera_pos32,0player_start_pos0,5icesenemy_catepillers1336,64,8,0.5,1,1,1',
  level8 = 'boxcamera_pos48,0icessongziplayer_start_pos0,5enemy_catepillers1432,72,24,0.5,02432,72,24,0.5,1enemy_bees1464,64,24,0.6',
  level9 = 'boxenemy_beesplayer_start_pos0,5songziicesenemy_catepillerscamera_pos64,0'
}

cfg_levels_winter = {
  level1 = 'camera_pos0,0songzi140,88enemy_catepillersplayer_start_pos0,7boxicesenemy_bees',
  level2 = 'enemy_beesboxicesplayer_start_pos0,7songzi1224,80camera_pos16,0enemy_catepillers',
  level3 = 'enemy_catepillerssongzi1336,48player_start_pos0,7ice1264,642352,803344,48boxcamera_pos32,0enemy_bees',
  level4 = 'camera_pos48,0box1416,40ice1416,64songzi1496,80player_start_pos0,8enemy_catepillersenemy_bees',
  level5 = 'iceboxenemy_catepillersplayer_start_pos0,7songzienemy_beescamera_pos0,0',
  level6 = 'enemy_catepillersbox1104,176ice140,184232,216,truesongzienemy_beescamera_pos0,16player_start_pos0,7',
  level7 = 'camera_pos16,16enemy_beesice1184,2162184,2083192,1924192,1685176,200,trueenemy_catepillersbox1176,168player_start_pos0,7songzi',
  level8 = 'songzi1288,192iceenemy_beesplayer_start_pos0,5enemy_catepillersbox1296,168camera_pos32,16',
  level9 = 'camera_pos48,16enemy_catepillersplayer_start_pos0,5box1416,168ice1424,216,trueenemy_beessongzi',
  level10='boxsongzienemy_beesice1552,168player_start_pos0,5enemy_catepillerscamera_pos64,16',
  level11='icebox1672,1522712,152enemy_catepillerssongziplayer_start_pos0,5enemy_beescamera_pos80,16',
}

cfg_levels_spring = {
  level1 = 'camera_pos0,0songzi140,88enemy_catepillersplayer_start_pos0,7boxicesenemy_bees',
  level2 = 'enemy_beesboxicesplayer_start_pos0,7songzi1224,80camera_pos16,0enemy_catepillers',
  level3 = 'enemy_catepillerssongzi1336,48player_start_pos0,7ice1264,642352,803344,48boxcamera_pos32,0enemy_bees',
  level4 = 'camera_pos48,0box1416,40ice1416,64songzi1496,80player_start_pos0,8enemy_catepillersenemy_bees',
  level5 = 'iceboxenemy_catepillersplayer_start_pos0,7songzienemy_beescamera_pos0,0',
  level6 = 'enemy_catepillersbox1104,176ice140,184232,216,truesongzienemy_beescamera_pos0,16player_start_pos0,7',
  level7 = 'camera_pos16,16enemy_beesice1184,2162184,2083192,1924192,1685176,200,trueenemy_catepillersbox1176,168player_start_pos0,7songzi',
  level8 = 'songzi1288,192iceenemy_beesplayer_start_pos0,5enemy_catepillersbox1296,168camera_pos32,16',
  level9 = 'camera_pos48,16enemy_catepillersplayer_start_pos0,5box1416,168ice1424,216,trueenemy_beessongzi',
  level10='boxsongzienemy_beesice1552,168player_start_pos0,5enemy_catepillerscamera_pos64,16',
  level11='icebox1672,1522712,152enemy_catepillerssongziplayer_start_pos0,5enemy_beescamera_pos80,16',
    
}

cfg_levels_summer = {
  level1 = 'songzienemy_catepillersenemy_beesboxplayer_start_pos0,11icecamera_pos0,16',
  level2 = 'enemy_beesplayer_start_pos0,10iceboxenemy_catepillerscamera_pos16,16songzi1192,184',
  level3 = 'songzicamera_pos32,16enemy_catepillersboxenemy_beesplayer_start_pos0,10ice',
  level4 = 'enemy_catepillersicesongzi1408,2162488,216player_start_pos0,10box1424,1762464,216camera_pos48,16enemy_bees',
  level5 = 'enemy_catepillers1560,216,24,0.5,0,0,02624,200,8,0.5,1,0,1iceplayer_start_pos0,10enemy_bees1536,200,16,0.5,0boxcamera_pos64,16songzi1528,216',
  level6 = 'camera_pos80,16enemy_catepillersiceboxsongzi1760,160player_start_pos0,8enemy_bees',

}

-->8
-->sound
sound_table = {}

function init_sound(num, timer)
  local sound_player = {}
  sound_player.timer = -1
  sound_player.play = function()
    if sound_player.timer < 0 then
      sfx(num)
      sound_player.timer = timer
    end
  end
  sound_player.update = function()
    if sound_player.timer >= 0 then
      sound_player.timer -= 1
    end
  end

  add(sound_table, sound_player)
  return sound_player
end

function sound_update()
  for v in all(sound_table) do
    v.update()
  end
end

__gfx__
00000000bbbbbbbb0800210066666666777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd100002106dddddd6777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
00000000dddd3ddd210811106d6dd6d6c777c777c777c77777c777c777c777c70000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd021222216ddd6dd6cc7ccc7ccc7ccc7c7ccc7ccc7ccc7ccc0000000000000000000000000000000000000000000000000000000000000000
00000000d3dddddd001200806dd6ddd6cccc7ccccccccccccc7ccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd001200006d6dd6d6cccccccccccccc7ccccccccccccc7ccc0000000000000000000000000000000000000000000000000000000000000000
00000000ddddd3dd010101206dddddd6ccccccccc7ccccccccccccc7cccccccc0000000000000000b000000000bbb00000000000000000000000000000000000
00000000dddddddd2002100166666666ccccccc7ccccccccccccc7cccccccccc00000000000000000bb00000bbbbb00000000000000000000000000000000000
ccccccccbbbbbbbb0000000077777777cccccccccccccccccccccccccccccccc00000000000000000bb0000bbbbbbb0000000000000000000000000000000000
ccccccccbbb3bbbb0000000077777777cc7ccccccccccccc7ccccccccccccccc0000000000000000000000bbb33bbbb00000bbb0000000007700000000000000
cccccccc3b3d3b3b0000000077777777ccccccccccccccccccccccccccccccc700000000000000000000bbbbb33bb33bb00b33bb000000077070000000000000
ccccccccd3dd3b330000000077777777cccccccccccccccccccccccccccccccc0000000000000000000bbbbb3333b3333bb33333bb0007777700000000000000
ccccccccddddd3dd0008000077777777cccccccccccccccccccccccccccccccc000000000000000000bbbbbb33333333333333333b0000777700000000000000
ccccccccdddddddd0087800077777777ccccc7ccccccccccccc7cccccccccccc00000000000000000000bb333333333333bbb333bbb000bbbb00000000000000
ccccccccd3dddddd0888880077777777cccccccccccccccccccccccccccccccc00000000000000000000bb3333333333333b33333bbbbbbbbb00000000000000
ccccccccdddddd3d0077700077777777cccccccccccccccccccccccccccccccc00000000000000000bbbb33333333333333333333333bbbbbb00000000000000
77777777dddddddd00000000000000008800000088000000000b0000000b00000000000b0000000bbb33333333b3333333333333333333bbbb00000000000000
77777777dddddddd0000000000000000dd000000dd000000000b00000000b000000000bbb000003bbb33333bbb3333333333333333b33333bb00000000000000
77777777ddddd3dd00000000000000008800000008800000000bb0000000bb00000000000000033333333333bb333333333333333bb333333bb0000000b00000
77777777dddddddd0000000000000000dd00000000dd0000000b00000000b0000000000000000333333333333b33333333333333bbbb333333b000000bb00000
77777777dddddddd000000000000d000880000000880000000bb0000000bb00000000000000b33333333333333333333333333333bbbb333333bb00000000000
77777777d3dddddd000000000008d8008800000088000000000bbb000000bb000000000000b33333333333333333333333333333333333333333b00000000000
77777777dddddddd08882828088808d88800000088000000000b0b00000b0000000000000b333333333333333333333333333333333b33333333333000000000
66666666dddddddd08882828088000d80000000000000000000b0000000b000000000000b33333333b33333333333333b33333b33333333333333bb300000000
000000000000000000000000e777777777777777000b0000cccbcccc777b777700000000b333333333bb333333333333bb333b33333333333333bbb300000000
760006706660006676000670deeeeee772777277000b00007ccbcccc777b777700000000b3333333333bb333777333333bbbb333333333333333333330000000
776067707776067777606770deeeeee72d272d26000b0000cccbcccccc7b7cc700000000b3333333333bb3377077333333bbb33333333333333b33333b000000
0760670007779c4c07606700deeeeee72dddddd6000b0000cccbcccccc7bcccc000000003333333333b3333377777333333b3333334333333bbbb33b3b000000
0079c4c0000550000079c4c0deeeeee72dddddd6000b0000cccbcccccccbcccc000000000b3333333b333333777733333333333334333333bbbbb333b0000000
005500000009900000550000deeeeee72dddddd6000b0000cccb7ccccccbcccc0000000003b33333333333333343333333333333433333333333b33300000000
009900000000500000099000deeeeee72dddddd6000b0000cccbcccccccbcccc00000000003bbb33333333333444b3333333333b433333333333333300000000
000570000000070000000570deeeeee72dddddd6000b0000cccbcccccccbcccc0000000b333bbbbb33333333333443333333333f44333b333333bb3000000000
00000000000a0000007700000000000000080000000000000000ddddd70000000000000b3333bbbbb33333333333444bb3333bb433333bb33333b00000000000
000a000000aaa0000007008880000000008e8000000008000000ddddd7000000000000b333333333b3333333333333344b3334f33333bbb333333b0000000000
00a7a0000aa7aa0000070888880000000008080000808e80000ddddddd700000000000b333333334b333333333333334443334433333337733333b3000000000
0a777a00aa777aa00007888788800000080bb00008e8b8b8000077777700000000000b33333333334b333333334b333344344f33333337707343333000000000
00a7a0000aa7aa0000088877788800008e8b00000080b000000770770770000000000b3333333333443333333334bb3334444f333337777734333b3330000000
000a000000aaa000008887777788800008bb000000bbb000007777799977000000000b333333333334333333333344b33444ff333333777743333bb333000000
00000000000a000008887777777888000b0bb0000b00b000000777777770000000000bb333333333344333333333334f3444ff3344444444b3bbbbbb33300000
00000000000000008887777777778800000b0000000b00000000777777000000000000b33333b3b33334443333333344f444f334fff43bbbbbbbbbbb33300000
00000000000000008877777777777880000000000000000000088888888000700000333333333b3773333444333333344444444ff33333333bbbbbbbb3300000
00000000000000000077e8777777700000bbbbb00000000000088888888000d0000bb333333333707733334444333334444444f33333333333bbbb3333300000
000000000000000000778877777770000bbbbb7b00bbbbb00067788777760dd0000bb33333b33337777734bbb44f333b44444ff33333333b333bb33333000000
00a0e000000e0a000077777755577000bbbbbbbb0bbbbb7b067778877777dd000000bbb333333337777334bbbb44fb3b44444fb333333333bbbb333333000000
00070000000070000077777755577000bbbbbbbbbbbbbbbb06777887677dd6000000bbbbbb3333333bf34bb333444ffb444444bb333333333bbb333330000000
00e3a000000a3e0000777777555770003bbbbbb3bbbbbbbb677777777777760000000bbbbbbb3b33ff444bbb333444ff4444444ffff3333333b3333330000000
00030000000030000777777755d77700033b33003bbbbbb36777777767777660000000bbbbbb33bb44bbbbbbb333444444444444444ff77f33333333b0000000
00030000000300007777777755577770000b0000033b330066777777777777600000000bbbbbbbbbbbbbbbb33333344444444bbbbbbb3bbbb333333b00000000
0000b0000000b0000000b0000000b0000444440004444400000aaaa000000000000000000bbbbbbbbbbbb3333333304444444bbbbbb33303b3bb33bb00000000
0000b0000000b000000bb000000bb00044555440445554400000aaaaaa0000000000000000000000000003333000000444444000003330000bbbb3b000000000
000bbbb000bbbb000000b00000000b004449444044494440000000aaaaaa000000000000000000000000000000000004444440000000000000003b0000000000
0000b000000b00000000e00000000e0004444400044444000000000aaaaaa0000000000000000000000000000000000444444000000000000000000000000000
00ebb0000ebb00000000000000000000000400000004000000000000aaaaaaa00000000000000000000000000000000444444000000000000000000000000000
0000be000000be0000000000000000000004000000040000000000000a77aaa00000000000000000000000000000000f44444000000000000000000000000000
0000b0000000b00000000000000000007774000000040000000000000aa7aaaa0000000000000000000000000000000f44444000000b00000000000000000000
000bb0e0000bb0e00000000000000000bbb4bbbb000400000000000000a7aaaa00000000000000000000000000000044444440000000bb000000000000000000
0000000000000000000000000000000000000000000000000000000000a7aaaa00000000000000000000000000000444444440000000bb000000000000000000
000000000000000000000000000000000000000000000000000000000077aaaa0000000000000000000000000000444444444000000000000000000000000000
000000000000000000000000000000000000000000000000000000000aaaaaa0000000000000000000000000000ff44444444400000000000000000000000000
000000000000000000000000000000000000000000000000000000000aaaaaa0000000000000000000000000444444f444444400000000000000000000000000
0000000000000000000000000000000000000000000000000aa00000aaaaaa000000000000000000000000ffff3fffbbb44bbf333bbbbbbbb000000000000000
00000000000000000000000000000000000000000000000000aaaaaaaaaa000000000000000bb0000000bbbbbb3bbbbb44bbbbff33bbbbbbb000000000000000
000000000000000000000000000000000000000000000000000aaaaaaa000000000bbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbb000000000000
000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbb3bbbbbbbbbbbbbb0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000009a00000000000000000000000000000000000000000000
00600000006600000066600000000000000000000066000000060000000060000000060009aa0000009900000000000000000000000000000006600000066000
0600060006f0000006ff06000000000000666600000f666000006600000aff000066aff00996a6000060a0000000000000000000000000000063b60000600600
6f000ff06f0000606f000000000666000000ff6000000ff600000f609aaf000006fa70006f7f7ff006f60a6000000000000000000003b00006333b6006000060
6f00f7006f00afff60000a600060ff60000000f600000000000000f699f7f000f9a0f0000ff0f000f770f7ff000000000000000000333b000611136006000060
6f067af0060af700066fafff000000f6000000000000000000000000ff700f000990000000000f000ff00f000000000000660000001113000611136006000060
069aa00000f9aff00f9af700000000000000000000000000000000000f00000000f0000000000000000000f00000066006796000001113000061160000600600
0099f00000f9900000990ff00000000000000000000000000000000000f00000000000000000000000000000000067966a999600000110000006600000066000
00000060000000600000000000000000000000000000000000000000000000000000000000000000000000000006a99969442600000000000007800007f07f00
000600ff000600ff000000000000000000000000000000000000000000000000000000000000000000000000000644426944260000078000000e8000feefee20
00600f7000600f700066600000600000000000000000000000066000000000000009a0000000000000000000006644a967927960000e800000e88e008eeeee20
06f0a6ff06f0a6f006ff0600000660000060000000066600006ff600009a00000009900000000000009a000006799799949a999600e88e007888888208eee200
06f06a7006f06a7f6f00009a0000f60000066600006fff6000000f600099a0600000a000009a0060009900606a449a4424494426788888820e888820008e2000
00f09a7000f09a706000069900000ff60000fff600f00006000000f6066f0aff0f660a600699a0ff0660a6ff64449944244944260e88882000e8820000020000
000699f0000699ff066faff600000000000000000000000000000000f770f700f770f7ffff77fa006f7ffa00062246226296426000e88200000e200000000000
0000000f00000000ff7af766000000000000000000000000000000000ff060f00f060f6060ff0ff00ff60f600066606606606600000e20000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000007d7000007d7000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000006f00000007d7d70007d7d700
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0060000606f00000007ddd70007dd7700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600f7006f0006ff6000006007d7d70007d7d700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f067f006f06670060660fff06777600067d7600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f06700006f70f000677f7000066600000666000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f0ff0000f000f00ff000f00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000eff00000f0000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ef00f00ef000f000e00f0000077700000777000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ef000ee0f000fee0ef00ee0007d7d70007d7d700
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fe00fe7ee00fe77ef00fe7e0077d7700077d7700
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0ffe700e0fe70e0e0fe709707d7d700077d7700
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0ee7ee0fef7ee00f0e7eee90677760006777600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fe700000fe700000fe700490066600000666000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eee00000eee00000eee0000000000000000000
00776d00001212000021210000d67700000000000000000990000000000000000000000000004000000400000004000000040000000400000000700000000e00
07d6d6d00d51d120021d15d00d6d6d7000000000000009998990000777000000000000000044440000404040044040400440044009400400070767007eeee880
6d6d6d51d6dd1d1221d1dd6d15d6d6d600000000000099e878999007700000000000000000994900044999004900999049000990940009907776777088888888
d6dddd126d6dd152251dd6d621dddd6d000000000009977787799997700000000000000000994900049447904904479949004799490049796777676027722772
6d6dd15176ddd512215ddd67151dd6d6300000000999a777777e799c700000000000000000949900049449004944790049447900904497000767777070007007
55d515127d6d6d5115d6d6d721515d5533000000999b777777e7e787800000000000000000949900049494900499949404997990409979900777676070007007
0151512007d6d510015d6d700215151033300e0989c77777777e777cf90000000000000000947900094790009479000009490000049700006767777070777007
00121200006d65000056d600002121003330e7e8787777777777fff7799000000000000000900900099094009449440009494400009990000606666007070770
00000000000000000000000000000000b3300e0b877777777777ddd770e000000000000000000000000000000000000000000000000000000007000000007000
000000000000000000000000000000003330000a777777799777ddd7700000000000000000000000000000000000000000000000000000000008e00000008e00
00000000000000000000000000000000330000a7a7777799997777777000000000000000000000000000000000000000000000000000000000e88e00000e88e0
000000000000000000000000000000003300000a7777799779977777700000000000000000000000000000000000000000000000000000007e8888e007e8888e
00000000000000000000000000000000300000007777997777997777700000000000000000000000000000000000000000000000000000008888882008888882
00000000000000000000000000000000300000007779977777799777700000000000000000000000000000000000000000000000000000000028820000028820
00000000000000000000000000000000b00000007799777777779977700000000000000000000000000000000000000000000000000000000008200000008200
00000000000000000000000000000000000000007997777777777997700000000000000000000000000000000000000000000000000000000002000000002000
00000000000000000000000000000000000000009977777477777799700000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000099777774447777779900000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000997777779997777777990000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000977777779997777777799000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009977777777777777777779900000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099777777777777777777777990000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000777777fffffff77fffff7000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000007777777ddddd7777ddd77000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000007777777ddddd7777ddd77000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000007787777ddddd777777777000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000007878777ddddd777777777000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000007787777dddd977777e777000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000e0077b7777ddddd7777e7e77000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000a7e077bb777ddddd77777e779000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007a777bb7777ddddd7777bb797977000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000077b7777b7777ddddd77777b77b777700000000000000000000000000000000000000000000000000000000000000000
__gff__
0001070200000000000000000000000000010000070707070000000000000000000100000000808000000000000000000000000101000000000000000000000080800000808000400000000000000000804000000303004000000000000000000000000006060000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101060106010101010100160101010101010101010601060101010101010101010101010101010101010101010101010106010601010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101060106010101010101060101010101010101010601060101010101010101010101010101010101010101010101010106010601010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101060106040101010101060101010101010101010601060101010101010101010101010101010101010401010101010106010604010101010101010101010101010101010101000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101062106010100000101060101010101010101010601060101010101010101010101010107110101010101000101010101010601010101010101010101010100010100000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
000000000000630010000010106210101010101040101010106010101010100010101010101010711010101010101010101010104060100010d01010101010101010080000000000000f101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
18191a1b1c1d1e1f4010101071101010401010101010101010101010101010101010101010100000101010101000d0d0d010100010001010d23410101010101010101800000000000000000010001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
28292a2b2c2d2e2f10101010011010101010101010101010101010101010101010101010101000000000000010d233333410103434001010d9d910101010101000100000000000000000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
38393a3b3c3d3e3f10101010101010107310101010101010101000101010101010101000001000001000343400d233333410000000001010d9d910101010101010100000000000000000101000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
48494a4b4c4d4ec4c5c6c775101044101010101010107110101010101010101010101010101010001010000000d233340010101010101010101010101010000010100000000000000000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
58595a5b5c5d5ed4d5d6d7101034343410dadadadadadadadadadadadadada1034340000000000d23434000000d234340010343434001010101010101010000010000000000000000000100010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
68276a6b6c6d6ee4e5e6e7333333100010da1068dadada101010dadada001010003434341010000000000000000010101034343400d00000000010001064000000000000000000000000000000101010101010010101010101010101010101011010101010101010101010101010101010101010101010101010101010101010
27267a7b7c7d64f4f5f6f710101010101010101010100000dada00001010100000001034d0d0d0d0d0d0d03434343434343434d0d034d0d0d0d0d0d03434340000000000000000000000000000000000101010212121212121212121212121211010101010101010101010101010101010101010101010101010101010101010
1111111111111111111111111106060601010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000001000212121212121212121212121211010101010101010101010101010101010101010101010101010101010101010
2121212121212121212121212116161621212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121000000000000000000000000101000212121212121212121212121211010101010101010101010101010101010101010101010101010101010101010
2121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121000000000000000000000000101000212121212121212121212121211010101010101010101010101010101010101010101010101010101010101010
2121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121000000000000000000000000000000212121212121212121212121211010101010101010101010101010101010101010101010101010101010101010
0000000000006000000000000060000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000343434343434343434343434343410101010101010101010101010101000000000000000000000000000000000
0000000000006000000000000060004000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000007200000000000000000010101010101010101010101010101000007100000073000000720000000000
0000000000006000000000000060000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000010101010101010101010101010101000000000000000000000000000000000
0000000000006300004000000060000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000073730200000000000000000010101010101010101010101010101000000000000000000066670000000000
00000000000000000000000000620000000000000000000000000000000000000040000000000000000000004000000000000000000000000040000000000000000000000000000000000000000040000000004000540002d8540000000000000010101010101010101010101010101000000000000000000076770000000000
18191a1b1c1d1e1f00000000000000000000400000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000003500d8d8350000000000343400101010101010101010101010101000000000000071000000000000000000
28292a2b2c2d2e2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054000000350200000002340000101010101010101010101010101071000073000000000000000000000000
38393a3b3c3d3e3f000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000343434343434340000000000000000000000000000000000000034000000000035000000350200540034340010101010101010101010101010101000000000000000000000000000000000
48494a4b4c4d4ec4c5c6c7000000720000000000007200003434004400000000000000000000000000020200000000000000000000000002020202343400000000000000343434000040000000000034000000000035000000350200350234340010101010101010101010101010101000000000000000000000000000000000
58595a5b5c5d5ed4d5d6d7000072727200540034343473020033333300000000000000000000340054343400000034343434343400000000000000003434000000000000000000000000000000000034340000000235000054350200353434340010101010101010101010101010101000000000000000000000000000000000
68446a6b6c6d6ee4e5e6e7727272000000354434000054540000003434340000000000540000340035000000000034110101113402000000000000020034340000343400000000343434000000000034340000000235000035350200353400340010101010101010101010101010101000000000000000000000000000000000
44267a7b7c7d64f4f5f6f7000054000000353434000035350054000000333333335473350054343435343402540234212121210002000034d80000020000343434340000000000000000000054343434343454000235540035350202353400340010101010101010101010101010101000000000000000000000000000000000
1111111111111111111111111137050607370101070437370737050601010101013704360437111136111106370411212121113402003434343434027211005454541111010101111111010135000011010437060737370637370506370101010010101010101010101010101010101000000000000000000000000000000000
2121212121212121212121212136151616362121361436361736151617212121143614361736151436141514361415212121210134341111010111011111543535355400212121212100000035540054541436161737361636361516362121210010101010101010101010101010101000000000000000000000000000000000
2121212121212121212121212136161616361521171436361714151617142121173614361736151636141514171415212104050601012105060706060404373737373706070421210704050637370537371415361714361636141516362121210010101010101010101010101010101000000000000000000000000000000000
2121212121212121212121212114151616141521171436161714153617142121141614361714153636151514171415211714151617213615161516151414361636363615171415211714151636361516361436361714151636141516362121210010101010101010101010101010101000000000000000000000000000000000
