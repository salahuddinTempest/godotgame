class_name MonsterTiers
extends RefCounted
## Monster tier definitions per CLAUDE.md.

static func get_tier_name(tier: Constants.MonsterTier) -> String:
	match tier:
		Constants.MonsterTier.TIER_1_MINION: return "Common Minion"
		Constants.MonsterTier.TIER_2_ELITE: return "Elite Monster"
		Constants.MonsterTier.TIER_3_RARE: return "Rare Creature"
		Constants.MonsterTier.TIER_4_LEGENDARY: return "Legendary Beast"
		Constants.MonsterTier.TIER_5_ANCIENT: return "Ancient Legend"
		Constants.MonsterTier.BOSS: return "Boss"
	return "Unknown"

static func get_tier_color(tier: Constants.MonsterTier) -> Color:
	match tier:
		Constants.MonsterTier.TIER_1_MINION: return Color.WHITE
		Constants.MonsterTier.TIER_2_ELITE: return Color.GREEN
		Constants.MonsterTier.TIER_3_RARE: return Color.BLUE
		Constants.MonsterTier.TIER_4_LEGENDARY: return Color.PURPLE
		Constants.MonsterTier.TIER_5_ANCIENT: return Color.ORANGE
		Constants.MonsterTier.BOSS: return Color.RED
	return Color.WHITE
