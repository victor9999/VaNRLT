local locale = VaNRLT.locale

local l = GetLocale()

if l == "ruRU" then
	locale.flask_ap = "Настой бесконечной ярости"
	locale.flask_spd = "Настой ледяного змея"
	locale.flask_hp = "Настой каменной крови"
	locale.flask_haste = "Зелье быстроты"
	locale.flask_critspd = "Зелье дикой магии"
	locale.flask_armor = "Зелье несокрушимости"
	locale.flask_mana = "Рунический флакон с зельем маны"
else
	locale.flask_ap = "Flask of Endless Rage"
	locale.flask_spd = "Flask of the Frost Wyrm"
	locale.flask_hp = "Flask of Stoneblood"
	locale.flask_haste = "Potion of Speed"
	locale.flask_critspd = "Potion of Wild Magic"
	locale.flask_armor = "Indestructible Potion"
	locale.flask_mana = "Runic Mana Potion"
end