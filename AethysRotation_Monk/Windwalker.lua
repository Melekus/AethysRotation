
---- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- AethysRotation
local AR = AethysRotation;
-- Lua
local pairs = pairs;

--- ============================ CONTENT ============================
--- ======= APL LOCALS =======
local Everyone = AR.Commons.Everyone;
local Monk = AR.Commons.Monk;
-- Spells
if not Spell.Monk then Spell.Monk = {}; end
Spell.Monk.Windwalker = {

  -- Racials
  Bloodlust                       = Spell(2825),
  ArcaneTorrent                   = Spell(25046),
  Berserking                      = Spell(26297),
  BloodFury                       = Spell(20572),
  GiftoftheNaaru 									= Spell(59547),
  Shadowmeld 											= Spell(58984),
  QuakingPalm 										= Spell(107079),

  -- Abilities
  TigerPalm 											= Spell(100780),
  RisingSunKick 									= Spell(107428),
  FistsOfFury 										= Spell(113656),
  SpinningCraneKick 							= Spell(101546),
  StormEarthAndFire 							= Spell(137639),
  FlyingSerpentKick 							= Spell(101545),
  FlyingSerpentKick2 							= Spell(115057),
  TouchOfDeath 										= Spell(115080),
  CracklingJadeLightning 					= Spell(117952),
  BlackoutKick 										= Spell(100784),
  BlackoutKickBuff 								= Spell(116768),

  -- Talents
  ChiWave 												= Spell(115098),
  InvokeXuentheWhiteTiger 				= Spell(123904),
  RushingJadeWind 								= Spell(116847),
  HitCombo 												= Spell(196741),
  Serenity 												= Spell(152173),
  WhirlingDragonPunch 						= Spell(152175),
  ChiBurst 												= Spell(123986),

  -- Artifact
  StrikeOfTheWindlord 						= Spell(205320),

  -- Defensive
  TouchOfKarma 										= Spell(122470),
  DiffuseMagic 										= Spell(122783), --Talent
  DampenHarm 											= Spell(122278), --Talent

  -- Utility
  Detox 													= Spell(218164),
  Effuse 													= Spell(116694),
  EnergizingElixir 								= Spell(115288), --Talent
  TigersLust 											= Spell(116841), --Talent
  LegSweep 												= Spell(119381), --Talent
  Disable 												= Spell(116095),
  HealingElixir 									= Spell(122281), --Talent
  Paralysis 											= Spell(115078),

  -- Legendaries
  TheEmperorsCapacitor 						= Spell(235054),

};
local S = Spell.Monk.Windwalker;
-- Items
if not Item.Monk then Item.Monk = {}; end
Item.Monk.Windwalker = {
  -- Legendaries
  DrinkingHornCover 							= Item(137097, {9}),
  TheEmperorsCapacitor 						= Item(144239, {5}),
	KatsuosEclipse									= Item(137029, {8}),
};
local I = Item.Monk.Windwalker;
-- Rotation Var

-- GUI Settings
local Settings = {
  General = AR.GUISettings.General,
  Commons = AR.GUISettings.APL.Monk.Commons,
  Windwalker = AR.GUISettings.APL.Monk.Windwalker
};

--- ======== FUNCTIONS =========

function Spell:IsReadyChanneling ()
  if Player:IsCasting() or Player:IsChanneling() then
    return self:IsLearned() and (not self:IsOnCooldown() or (self:CooldownRemains() < Player:CastRemains())) and self:IsUsable();
  else
    return self:IsLearned() and not self:IsOnCooldown() and self:IsUsable();
  end
end

--- ======= ACTION LISTS =======

local function single_target ()
	-- actions.st+=/tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy.time_to_max<=0.5&chi.max-chi>=2
  if S.TigerPalm:IsReady() and not Player:PrevGCD(1, S.TigerPalm) and Player:EnergyTimeToMax() <= 0.5 and Player:ChiDeficit() >= 2 then
    if AR.Cast(S.TigerPalm) then return ""; end
  end
  -- actions.st+=/strike_of_the_windlord,if=!talent.serenity.enabled|cooldown.serenity.remains>=10
  if S.StrikeOfTheWindlord:IsReadyChanneling() and not S.Serenity:IsAvailable() or S.Serenity:CooldownRemains() >= 10 then
    if AR.Cast(S.StrikeOfTheWindlord) then return ""; end
  end
  -- actions.st+=/rising_sun_kick,cycle_targets=1,if=((chi>=3&energy>=40)|chi>=5)&(!talent.serenity.enabled|cooldown.serenity.remains>=6)
  if S.RisingSunKick:IsReadyChanneling() and ((Player:Chi() >= 3 and Player:Energy() >= 40) or Player:Chi() >= 5) and
	(not S.Serenity:IsAvailable() or S.Serenity:CooldownRemains() >= 6) then
    if AR.Cast(S.RisingSunKick) then return ""; end
  end
  -- actions.st+=/fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
  if S.FistsOfFury:IsReadyChanneling() and S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and
	S.Serenity:CooldownRemains() >= 5 and Player:EnergyTimeToMax() > 2 then
    if AR.Cast(S.FistsOfFury) then return ""; end
  end
  -- actions.st+=/fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
  if S.FistsOfFury:IsReadyChanneling() and S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and
	(S.Serenity:CooldownRemains() >= 15 or S.Serenity:CooldownRemains() <= 4) and Player:EnergyTimeToMax() > 2 then
    if AR.Cast(S.FistsOfFury) then return ""; end
  end
  -- actions.st+=/fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
  if S.FistsOfFury:IsReadyChanneling() and not S.Serenity:IsAvailable() and Player:EnergyTimeToMax() > 2 then
    if AR.Cast(S.FistsOfFury) then return ""; end
  end
  -- actions.st+=/rising_sun_kick,cycle_targets=1,if=!talent.serenity.enabled|cooldown.serenity.remains>=5
  if S.RisingSunKick:IsReadyChanneling() and not S.Serenity:IsAvailable() or S.Serenity:CooldownRemains() >= 5 then
    if AR.Cast(S.RisingSunKick) then return ""; end
  end
	-- actions.st+=/whirling_dragon_punch
  if S.WhirlingDragonPunch:IsReadyChanneling() and S.RisingSunKick:CooldownRemains() > Player:CastRemains() and S.FistsOfFury:CooldownRemains() > Player:CastRemains() then
    if AR.Cast(S.WhirlingDragonPunch) then return ""; end
  end
	-- actions.st+=/crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
  if S.CracklingJadeLightning:IsReady() and I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStack(S.TheEmperorsCapacitor) >= 19 and Player:EnergyTimeToMax() > 3 then
    if AR.Cast(S.CracklingJadeLightning) then return ""; end
  end
  -- actions.st+=/crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
  if S.CracklingJadeLightning:IsReady() and I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStack(S.TheEmperorsCapacitor) >= 14 and
	S.Serenity:CooldownRemains() < 13 and S.Serenity:IsAvailable() and Player:EnergyTimeToMax() > 3 then
    if AR.Cast(S.CracklingJadeLightning) then return ""; end
  end
  -- actions.st+=/spinning_crane_kick,if=(active_enemies>=3|spinning_crane_kick.count>=3)&!prev_gcd.1.spinning_crane_kick
  if AR.AoEON() and S.SpinningCraneKick:IsReady() and Cache.EnemiesCount[8] >= 3 and not Player:PrevGCD(1, S.SpinningCraneKick) and
	GetSpellCount("Spinning Crane Kick") >= 2 then
    if AR.Cast(S.SpinningCraneKick) then return ""; end
  end
  -- actions.st+=/rushing_jade_wind,if=chi.max-chi>1&!prev_gcd.1.rushing_jade_wind
  if S.RushingJadeWind:IsReadyChanneling() and Player:ChiDeficit() > 1 and not Player:PrevGCD(1, S.RushingJadeWind) then
    if AR.Cast(S.RushingJadeWind) then return ""; end
  end
  -- actions.st+=/blackout_kick,cycle_targets=1,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&
  -- ((cooldown.rising_sun_kick.remains>1&(!artifact.strike_of_the_windlord.enabled|cooldown.strike_of_the_windlord.remains>1)|chi>2)&(cooldown.fists_of_fury.remains>1|chi>3)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
  if S.BlackoutKick:IsReadyChanneling() and (Player:Chi() > 1 or Player:Buff(S.BlackoutKickBuff) or (S.EnergizingElixir:IsAvailable() and S.EnergizingElixir:CooldownRemains() < S.FistsOfFury:CooldownRemains())) and
  ((S.RisingSunKick:CooldownRemains() > 1 and (not S.StrikeOfTheWindlord:IsAvailable() or S.StrikeOfTheWindlord:CooldownRemains() > 1) or Player:Chi() > 2) and (S.FistsOfFury:CooldownRemains() > 1 or
  Player:Chi() > 3) or Player:PrevGCD(1, S.TigerPalm)) and not Player:PrevGCD(1, S.BlackoutKick) then
    if AR.Cast(S.BlackoutKick) then return ""; end
  end
  -- actions.st+=/chi_wave,if=energy.time_to_max>1
  if S.ChiWave:IsReadyChanneling() and Player:EnergyTimeToMax() > 1 then
    if AR.Cast(S.ChiWave) then return ""; end
  end
  -- actions.st+=/chi_burst,if=energy.time_to_max>1
  if S.ChiBurst:IsReadyChanneling() and Player:EnergyTimeToMax() > 1 then
    if AR.Cast(S.ChiBurst) then return ""; end
  end
  -- actions.st+=/tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&(chi.max-chi>=2|energy.time_to_max<1)
  if S.TigerPalm:IsReady() and not Player:PrevGCD(1, S.TigerPalm) and (Player:ChiDeficit() >= 2 or Player:EnergyTimeToMax() < 1) then
    if AR.Cast(S.TigerPalm) then return ""; end
  end
	-- Fallbacks - Used to predict during downtime
	-- actions.st+=/tiger_palm
  if not S.TigerPalm:IsUsable() and not Player:PrevGCD(1, S.TigerPalm) and
	Player:EnergyTimeToX(50,0) < S.RisingSunKick:CooldownRemains() and
	(Player:EnergyTimeToX(50,0) < S.WhirlingDragonPunch:CooldownRemains() and S.WhirlingDragonPunch:IsUsable()) and
	(S.ChiWave:IsAvailable() and Player:EnergyTimeToX(50,0) < S.ChiWave:CooldownRemains() or
	S.ChiBurst:IsAvailable() and Player:EnergyTimeToX(50,0) < S.ChiBurst:CooldownRemains()) then
    if AR.Cast(S.TigerPalm) then return ""; end
  end
	-- actions.st+=/rising_sun_kick
	if S.RisingSunKick:IsUsable() and not Player:PrevGCD(1,S.RisingSunKick) and
	(S.RisingSunKick:CooldownRemains() < S.WhirlingDragonPunch:CooldownRemains() and S.WhirlingDragonPunch:IsUsable()) and
	(S.ChiWave:IsAvailable() and S.RisingSunKick:CooldownRemains() < S.ChiWave:CooldownRemains() or
	S.ChiBurst:IsAvailable() and S.RisingSunKick:CooldownRemains() < S.ChiBurst:CooldownRemains()) then
    if AR.Cast(S.RisingSunKick) then return ""; end
  end
	-- actions.st+=/whirling_dragon_punch
  if S.WhirlingDragonPunch:IsUsable() and S.WhirlingDragonPunch:CooldownRemains() < S.ChiWave:CooldownRemains() and
	S.WhirlingDragonPunch:CooldownRemains() < S.ChiBurst:CooldownRemains() then
    if AR.Cast(S.WhirlingDragonPunch) then return ""; end
  end
	-- actions.st+=/blackout_kick
  if S.BlackoutKick:IsReady() and (Player:Chi() > 1 or Player:Buff(S.BlackoutKickBuff) or (S.EnergizingElixir:IsAvailable() and S.EnergizingElixir:CooldownRemains() < S.FistsOfFury:CooldownRemains())) and
  ((S.RisingSunKick:CooldownRemains() > 1 and (not S.StrikeOfTheWindlord:IsAvailable() or S.StrikeOfTheWindlord:CooldownRemains() > 1) or Player:Chi() > 2) and (S.FistsOfFury:CooldownRemains() > 1 or
  Player:Chi() > 3) or Player:PrevGCD(1, S.TigerPalm)) and not Player:PrevGCD(1, S.BlackoutKick) then
    if AR.Cast(S.BlackoutKick) then return ""; end
  end
	-- actions.st+=/chi_wave
	if S.ChiWave:IsReady() then
    if AR.Cast(S.ChiWave) then return ""; end
  end
  -- actions.st+=/chi_burst
  if S.ChiBurst:IsAvailable() then
    if AR.Cast(S.ChiBurst) then return ""; end
  end
	return false;
end

--- ======= MAIN =======
-- APL Main
local function APL ()
  -- Unit Update
  AC.GetEnemies(5);
  AC.GetEnemies(8);
  Everyone.AoEToggleEnemiesUpdate();

  if Everyone.TargetIsValid() then
    -- actions.st+=/chi_wave
    if S.ChiWave:IsReadyChanneling() and not Target:IsInRange(5) then
      if AR.Cast(S.ChiWave) then return ""; end
    end
    -- actions.st+=/chi_burst
    if S.ChiBurst:IsReadyChanneling() and not Target:IsInRange(5) then
      if AR.Cast(S.ChiBurst) then return ""; end
    end
    -- actions+=/touch_of_death,if=target.time_to_die<=9
    if AR.CDsON() and S.TouchOfDeath:IsReadyChanneling() and Target:TimeToDie() >= 9 then
      if AR.CastLeft(S.TouchOfDeath) then return ""; end
    end
		-- actions.sef+=/storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
	  if AR.CDsON() and not Player:Buff(S.StormEarthAndFire) then
	    if AR.CastLeft(S.StormEarthAndFire) then return ""; end
	  end
		-- actions.sef=tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy=energy.max&chi<1
		if S.TigerPalm:IsReady() and not Player:PrevGCD(1, S.TigerPalm) and not S.Serenity:IsAvailable() and Player:EnergyPercentage() == 100 and Player:Chi() < 1 then
	    if AR.Cast(S.TigerPalm) then return ""; end
	  end
		-- actions.st+=/energizing_elixir,if=chi<=1&(cooldown.rising_sun_kick.remains=0|(artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains=0)|energy<50)
	  if S.EnergizingElixir:IsReadyChanneling() and Player:Chi() <= 1 and AC.CombatTime() > 8 and Player:EnergyDeficit() >= 20 and (S.RisingSunKick:CooldownRemains() <= 0 or
	  (S.StrikeOfTheWindlord:IsAvailable() and S.StrikeOfTheWindlord:CooldownRemains() <= 0) or Player:Energy() < 50) then
	    if AR.Cast(S.EnergizingElixir) then return ""; end
	  end
		-- actions.st+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
	  if S.ArcaneTorrent:IsReadyChanneling() and Player:ChiDeficit() >= 1 and Player:EnergyTimeToMax() >= 0.5 then
	    if AR.CastSuggested(S.ArcaneTorrent) then return ""; end
	  end
    -- actions+=/call_action_list,name=st
    ShouldReturn = single_target ();
    if ShouldReturn then return ShouldReturn; end
    return;
  end
end

AR.SetAPL(269, APL);

-- # Executed before combat begins. Accepts non-harmful actions only.
-- actions.precombat=flask
-- actions.precombat+=/food
-- actions.precombat+=/augmentation
-- # Snapshot raid buffed stats before combat begins and pre-potting is done.
-- actions.precombat+=/snapshot_stats
-- actions.precombat+=/potion
-- actions.precombat+=/chi_burst
-- actions.precombat+=/chi_wave
--
-- # Executed every time the actor is available.
-- actions=auto_attack
-- actions+=/spear_hand_strike,if=target.debuff.casting.react
-- actions+=/touch_of_karma,interval=90,pct_health=0.5
-- actions+=/potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
-- actions+=/touch_of_death,if=target.time_to_die<=9
-- actions+=/call_action_list,name=serenity,if=(talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up
-- actions+=/call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
-- actions+=/call_action_list,name=sef,if=!talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=18&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=25|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
-- actions+=/call_action_list,name=sef,if=!talent.serenity.enabled&!equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=14&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=15|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
-- actions+=/call_action_list,name=st
--
-- actions.cd=invoke_xuen_the_white_tiger
-- actions.cd+=/use_item,name=specter_of_betrayal,if=(cooldown.serenity.remains>10|buff.serenity.up)|!talent.serenity.enabled
-- actions.cd+=/use_item,name=vial_of_ceaseless_toxins,if=(buff.serenity.up&!equipped.specter_of_betrayal)|(equipped.specter_of_betrayal&(time<5|cooldown.serenity.remains<=8))|!talent.serenity.enabled
-- actions.cd+=/blood_fury
-- actions.cd+=/berserking
-- actions.cd+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
-- actions.cd+=/touch_of_death,cycle_targets=1,max_cycle_targets=2,if=!artifact.gale_burst.enabled&equipped.hidden_masters_forbidden_touch&!prev_gcd.1.touch_of_death
-- actions.cd+=/touch_of_death,if=!artifact.gale_burst.enabled&!equipped.hidden_masters_forbidden_touch
-- actions.cd+=/touch_of_death,cycle_targets=1,max_cycle_targets=2,if=artifact.gale_burst.enabled&((talent.serenity.enabled&cooldown.serenity.remains<=1)|chi>=2)&(cooldown.strike_of_the_windlord.remains<8|cooldown.fists_of_fury.remains<=4)&cooldown.rising_sun_kick.remains<7&!prev_gcd.1.touch_of_death
--
-- actions.sef=tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy=energy.max&chi<1
-- actions.sef+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
-- actions.sef+=/call_action_list,name=cd
-- actions.sef+=/storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
-- actions.sef+=/call_action_list,name=st
--
-- actions.serenity=tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy=energy.max&chi<1&!buff.serenity.up
-- actions.serenity+=/call_action_list,name=cd
-- actions.serenity+=/serenity
-- actions.serenity+=/spinning_crane_kick,if=buff.serenity.remains<=1&cooldown.rising_sun_kick.remains>=0.25&equipped.drinking_horn_cover&!prev_gcd.1.spinning_crane_kick
-- actions.serenity+=/rising_sun_kick,cycle_targets=1,if=active_enemies<3
-- actions.serenity+=/strike_of_the_windlord
-- actions.serenity+=/blackout_kick,cycle_targets=1,if=(!prev_gcd.1.blackout_kick)&(prev_gcd.1.strike_of_the_windlord|prev_gcd.1.fists_of_fury)&active_enemies<2
-- actions.serenity+=/fists_of_fury,if=((equipped.drinking_horn_cover&buff.pressure_point.remains<=2&set_bonus.tier20_4pc)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
-- actions.serenity+=/fists_of_fury,if=((!equipped.drinking_horn_cover|buff.bloodlust.up|buff.serenity.remains<1)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
-- actions.serenity+=/spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
-- actions.serenity+=/rising_sun_kick,cycle_targets=1,if=active_enemies>=3
-- actions.serenity+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick
-- actions.serenity+=/blackout_kick,cycle_targets=1,if=!prev_gcd.1.blackout_kick
-- actions.serenity+=/rushing_jade_wind,if=!prev_gcd.1.rushing_jade_wind
--
-- actions.st=call_action_list,name=cd
-- actions.st+=/energizing_elixir,if=chi<=1&(cooldown.rising_sun_kick.remains=0|(artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains=0)|energy<50)
-- actions.st+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
-- actions.st+=/tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&energy.time_to_max<=0.5&chi.max-chi>=2
-- actions.st+=/strike_of_the_windlord,if=!talent.serenity.enabled|cooldown.serenity.remains>=10
-- actions.st+=/rising_sun_kick,cycle_targets=1,if=((chi>=3&energy>=40)|chi>=5)&(!talent.serenity.enabled|cooldown.serenity.remains>=6)
-- actions.st+=/fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
-- actions.st+=/fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
-- actions.st+=/fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
-- actions.st+=/rising_sun_kick,cycle_targets=1,if=!talent.serenity.enabled|cooldown.serenity.remains>=5
-- actions.st+=/whirling_dragon_punch
-- actions.st+=/crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
-- actions.st+=/crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
-- actions.st+=/spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
-- actions.st+=/rushing_jade_wind,if=chi.max-chi>1&!prev_gcd.1.rushing_jade_wind
-- actions.st+=/blackout_kick,cycle_targets=1,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&((cooldown.rising_sun_kick.remains>1&(!artifact.strike_of_the_windlord.enabled|cooldown.strike_of_the_windlord.remains>1)|chi>2)&(cooldown.fists_of_fury.remains>1|chi>3)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
-- actions.st+=/chi_wave,if=energy.time_to_max>1
-- actions.st+=/chi_burst,if=energy.time_to_max>1
-- actions.st+=/tiger_palm,cycle_targets=1,if=!prev_gcd.1.tiger_palm&(chi.max-chi>=2|energy.time_to_max<1)
-- actions.st+=/chi_wave
-- actions.st+=/chi_burst