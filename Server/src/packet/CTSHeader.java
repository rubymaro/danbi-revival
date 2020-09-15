package packet;

import java.util.HashMap;

public enum CTSHeader {
	LOGIN(0),
	REGISTER(1),
	MOVE_CHARACTER(2),
	TURN_CHARACTER(3),
	REMOVE_EQUIP_ITEM(4),
	USE_STAT_POINT(5),
	ACTION(6),
	USE_ITEM(7),
	USE_SKILL(8),
	DROP_ITEM(9),
	DROP_GOLD(10),
	PICK_ITEM(11),
	CHAT_NORMAL(12),
	CHAT_WHISPER(13),
	CHAT_PARTY(14),
	CHAT_GUILD(15),
	CHAT_ALL(16),
	CHAT_BALLOON_START(17),

	OPEN_REGISTER_WINDOW(100),
	CHANGE_ITEM_INDEX(101),
	REQUEST_TRADE(102),
	RESPONSE_TRADE(103),
	LOAD_TRADE_ITEM(104),
	DROP_TRADE_ITEM(105),
	CHANGE_TRADE_GOLD(106),
	FINISH_TRADE(107),
	CANCEL_TRADE(108),
	SELECT_MESSAGE(109),
	CREATE_PARTY(110),
	INVITE_PARTY(111),
	RESPONSE_PARTY(112),
	QUIT_PARTY(113),
	KICK_PARTY(114),
	BREAK_UP_PARTY(115),
	CREATE_GUILD(116),
	INVITE_GUILD(117),
	RESPONSE_GUILD(118),
	QUIT_GUILD(119),
	KICK_GUILD(120),
	BREAK_UP_GUILD(121),
	BUY_SHOP_ITEM(122),

	SET_SLOT(200),
	DEL_SLOT(201);

	private static HashMap<Integer, CTSHeader> caches;

	private int mValue;

	CTSHeader(final int value) {
		mValue = value;
	}

	public static CTSHeader fromInt(final int value) {
		if (caches == null) {
			caches = new HashMap<Integer, CTSHeader>();
			for (CTSHeader cache : values()) {
				caches.put(cache.mValue, cache);
			}
		}
		return caches.get(value);
	}

	public int getValue() {
		return mValue;
	}
}