package game;

import io.netty.channel.ChannelHandlerContext;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Random;
import java.util.Vector;
import java.util.logging.Logger;

import packet.Packet;
import database.*;
import database.GameData.*;

public class User extends Character {
	private static final Logger logger = Logger.getLogger(User.class.getName());
	private static final Hashtable<ChannelHandlerContext, User> usersHashtable = new Hashtable<>();
	private static final int MAX_INVENTORY_COUNT = 35;

	private ChannelHandlerContext mCtx;
	// 유저 정보
	private String mId;
	private String mPassword;
	private String mMail;
	private int mGuildNo;
	private int mJob;
	private int mPureStr;
	private int mPureDex;
	private int mPureAgi;
	private int mStatPoint;
	private int mSkillPoint;
	private int mTitle;
	private boolean mbAdmin;
	// 장착 아이템
	private int mWeapon = 0;
	private int mShield = 0;
	private int mHelmet = 0;
	private int mArmor = 0;
	private int mCape = 0;
	private int mShoes = 0;
	private int mAccessory = 0;
    // 인벤토리 등
	private final Hashtable<Integer, Item> mItemBagHashtable = new Hashtable<>();
	private final Hashtable<Integer, Skill> mSkillBagHashtable = new Hashtable<>();
	// 거래 관련
	private int mTradePartner;
	private final Hashtable<Integer, Item> mTradeItemsHashtable = new Hashtable<>();
	private int mTradeGold;
	private boolean mbAcceptTrade = false;
	// 커뮤니티 관련
	private int mPartyNo;
	// NPC 관련
	private final Message mMessage = new Message();
    // 말풍선
    private static int mStandardDelay = -1;
    private boolean mbBalloonShowing = false;
    private long mStartChattingTime;
    // 쿨타임
	private final CoolTime mCoolTime = new CoolTime();
	public CoolTime getCoolTime() { return mCoolTime; }
	private long mLastTime = System.currentTimeMillis() / 100;

	public static boolean put(ChannelHandlerContext ctx, User user) {
		if (usersHashtable.containsKey(ctx)) {
			return false;
		}
		usersHashtable.put(ctx, user);
		return true;
	}

	public static User getOrNullByContext(ChannelHandlerContext ctx) {
		return usersHashtable.get(ctx);
	}

	public static User getOrNullByNo(int userNo) {
		for (User user : usersHashtable.values()) {
			if (user.getNo() == userNo) {
				return user;
			}
		}
		return null;
	}

	public static Hashtable<ChannelHandlerContext, User> getAll() {
		return usersHashtable;
	}

	public static boolean remove(ChannelHandlerContext ctx) {
		if (usersHashtable.containsKey(ctx)) {
			usersHashtable.get(ctx).exitGracefully();
			usersHashtable.remove(ctx);
			return true;
		}
		return false;
	}

	public User(ChannelHandlerContext ctx, ResultSet rs) {
		try {
			mCtx = ctx;
			mNo = rs.getInt("no");
			mId = rs.getString("id");
			mPassword = rs.getString("password");
			mName = rs.getString("name");
			mTitle = rs.getInt("title");
			mGuildNo = rs.getInt("guild");
			mMail = rs.getString("mail");
			mImage = rs.getString("image");
			mJob = rs.getInt("job");
			mPureStr = rs.getInt("str");
			mPureDex = rs.getInt("dex");
			mPureAgi = rs.getInt("agi");
			mStatPoint = rs.getInt("stat_point");
			mSkillPoint = rs.getInt("skill_point");
			mHp = rs.getInt("hp");
			mMp = rs.getInt("mp");
			mLevel = rs.getInt("level");
			mExp = rs.getInt("exp");
			mGold = rs.getInt("gold");
			mMap = rs.getInt("map");
			mSeed = rs.getInt("seed");
			mX = rs.getInt("x");
			mY = rs.getInt("y");
			mDirection = Type.Direction.fromInt(rs.getInt("direction"));
			mMoveSpeed = rs.getInt("speed");
			mbAdmin = rs.getInt("admin") == 0;
			mTeam = mNo;
			mCharacterType = Type.Character.USER;
			mRandom = new Random();
		} catch (SQLException e) {
			logger.warning(e.getMessage());
		}
	}
	
	public ChannelHandlerContext getCtx() {
		return mCtx;
	}
	
	public String getID() {
		return mId;
	}
	
	public String getPassword() {
		return mPassword;
	}

	// 타이틀
	public int getTitle() {
		return mTitle;
	}

	public void setTitle(int title) {
		mTitle = title;
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{ Type.Status.TITLE.getValue() }, new Integer[]{ mTitle }));
		Map.getMap(mMap).getField(mSeed).sendToOthers(this, Packet.updateCharacter(mCharacterType, mNo,
				new int[]{ Type.Status.TITLE.getValue() }, new Integer[]{ mTitle }));
	}

	// 길드
	public int getGuild() {
		return mGuildNo;
	}

	public void setGuild(int guild) {
		mGuildNo = guild;
		mCtx.writeAndFlush(Packet.setGuild(mGuildNo));
	}
	
	public String getMail() {
		return mMail;
	}

	// 이미지
	public void setImage(String image) {
		mImage = image;
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{ Type.Status.IMAGE.getValue() }, new String[]{ mImage }));
		Map.getMap(mMap).getField(mSeed).sendToOthers(this, Packet.updateCharacter(mCharacterType, mNo,
				new int[]{ Type.Status.IMAGE.getValue() }, new String[]{ mImage }));
	}

	// 직업
	public int getJob() {
		return mJob;
	}

	public void setJob(int job) {
		mJob = job;
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{ Type.Status.JOB.getValue() }, new Integer[]{ job }));
		Map.getMap(mMap).getField(mSeed).sendToOthers(this, Packet.updateCharacter(mCharacterType, mNo,
				new int[]{ Type.Status.JOB.getValue() }, new Integer[]{ mJob }));
	}
	
	public int getStr() {
		int n = 0;
		// 스텟 Str
		n += mPureStr;
		// 직업 기본 Str
		n += GameData.getJobs().get(mJob).getStr() * mLevel;
		// 아이템으로 오르는 Str
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getStr();
			n += findItemByIndex(mWeapon).getStr();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getStr();
			n += findItemByIndex(mShield).getStr();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getStr();
			n += findItemByIndex(mHelmet).getStr();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getStr();
			n += findItemByIndex(mArmor).getStr();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getStr();
			n += findItemByIndex(mCape).getStr();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getStr();
			n += findItemByIndex(mShoes).getStr();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getStr();
			n += findItemByIndex(mAccessory).getStr();
		}
		return n;
	}
	
	public int getPureStr() {
		return mPureStr;
	}
	
	public int getDex() {
		int n = 0;
		// 스텟 Dex
		n += mPureDex;
		// 직업 기본 Dex
		n += GameData.getJobs().get(mJob).getDex() * mLevel;
		// 아이템으로 오르는 Dex
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getDex();
			n += findItemByIndex(mWeapon).getDex();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getDex();
			n += findItemByIndex(mShield).getDex();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getDex();
			n += findItemByIndex(mHelmet).getDex();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getDex();
			n += findItemByIndex(mArmor).getDex();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getDex();
			n += findItemByIndex(mCape).getDex();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getDex();
			n += findItemByIndex(mShoes).getDex();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getDex();
			n += findItemByIndex(mAccessory).getDex();
		}
		return n;
	}
	
	public int getPureDex() {
		return mPureDex;
	}
	
	public int getAgi() {
		int n = 0;
		// 스텟 Agi
		n += mPureAgi;
		// 직업 기본 Agi
		n += GameData.getJobs().get(mJob).getAgi() * mLevel;
		// 아이템으로 오르는 Agi
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getAgi();
			n += findItemByIndex(mWeapon).getAgi();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getAgi();
			n += findItemByIndex(mShield).getAgi();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getAgi();
			n += findItemByIndex(mHelmet).getAgi();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getAgi();
			n += findItemByIndex(mArmor).getAgi();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getAgi();
			n += findItemByIndex(mCape).getAgi();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getAgi();
			n += findItemByIndex(mShoes).getAgi();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getAgi();
			n += findItemByIndex(mAccessory).getAgi();
		}
		return n;
	}
	
	public int getPureAgi() {
		return mPureAgi;
	}

	public void gainHp(int value) {
		// 최대 HP 이상인 경우 보정
		if (mHp + value > getMaxHp()) {
			value = getMaxHp() - mHp;
		}
		mHp += value;
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{ Type.Status.HP.getValue() }, new Integer[]{ mHp }));
		Map.getMap(mMap).getField(mSeed).sendToOthers(this, Packet.updateCharacter(mCharacterType, mNo,
				new int[]{ Type.Status.HP.getValue() }, new Integer[]{ mHp }));
	}

	public void loseHp(int value) {
		gainHp(-value);
		if (mHp - value < 0) {
			// 쥬금
			return;
		}
	}

	// 최대 HP
	public int getMaxHp() {
		int n = 0;
		// 직업 기본 Hp
		n += GameData.getJobs().get(mJob).getHp() * mLevel;
		// 아이템으로 오르는 Hp
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getHp();
			n += findItemByIndex(mWeapon).getHp();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getHp();
			n += findItemByIndex(mShield).getHp();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getHp();
			n += findItemByIndex(mHelmet).getHp();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getHp();
			n += findItemByIndex(mArmor).getHp();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getHp();
			n += findItemByIndex(mCape).getHp();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getHp();
			n += findItemByIndex(mShoes).getHp();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getHp();
			n += findItemByIndex(mAccessory).getHp();
		}
		return n;
	}

	public void gainMp(int value) {
		// 최대 MP 이상인 경우 보정
		if (mMp + value > getMaxMp()) {
			value = getMaxMp() - mMp;
		}
		mMp += value;
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{ Type.Status.MP.getValue() }, new Integer[]{ mMp }));
	}

	public boolean loseMp(int value) {
		if (mMp - value < 0) {
			return false;
		}
		gainMp(-value);
		return true;
	}

	// 최대 MP
	public int getMaxMp() {
		int n = 0;
		// 직업 기본 Mp
		n += GameData.getJobs().get(mJob).getMp() * mLevel;
		// 아이템으로 오르는 Mp
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getMp();
			n += findItemByIndex(mWeapon).getMp();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getMp();
			n += findItemByIndex(mShield).getMp();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getMp();
			n += findItemByIndex(mHelmet).getMp();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getMp();
			n += findItemByIndex(mArmor).getMp();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getMp();
			n += findItemByIndex(mCape).getMp();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getMp();
			n += findItemByIndex(mShoes).getMp();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getMp();
			n += findItemByIndex(mAccessory).getMp();
		}
		return n;
	}

	// 치명타율
	public int getCritical() {
		int n = 0;
		// 아이템으로 오르는 Critical
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getCritical();
			n += findItemByIndex(mWeapon).getCritical();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getCritical();
			n += findItemByIndex(mShield).getCritical();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getCritical();
			n += findItemByIndex(mHelmet).getCritical();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getCritical();
			n += findItemByIndex(mArmor).getCritical();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getCritical();
			n += findItemByIndex(mCape).getCritical();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getCritical();
			n += findItemByIndex(mShoes).getCritical();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getCritical();
			n += findItemByIndex(mAccessory).getCritical();
		}
		return n;
	}

	// 회피율
	public int getAvoid() {
		int n = 0;
		// 아이템으로 오르는 Avoid
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getAvoid();
			n += findItemByIndex(mWeapon).getAvoid();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getAvoid();
			n += findItemByIndex(mShield).getAvoid();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getAvoid();
			n += findItemByIndex(mHelmet).getAvoid();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getAvoid();
			n += findItemByIndex(mArmor).getAvoid();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getAvoid();
			n += findItemByIndex(mCape).getAvoid();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getAvoid();
			n += findItemByIndex(mShoes).getAvoid();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getAvoid();
			n += findItemByIndex(mAccessory).getAvoid();
		}
		return n;
	}

	// 명중률
	public int getHit() {
		int n = 0;
		// 아이템으로 오르는 Hit
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getHit();
			n += findItemByIndex(mWeapon).getHit();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getHit();
			n += findItemByIndex(mShield).getHit();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getHit();
			n += findItemByIndex(mHelmet).getHit();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getHit();
			n += findItemByIndex(mArmor).getHit();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getHit();
			n += findItemByIndex(mCape).getHit();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getHit();
			n += findItemByIndex(mShoes).getHit();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getHit();
			n += findItemByIndex(mAccessory).getHit();
		}
		return n;
	}

	// 물리 데미지
	public int getDamage() {
		int n = 0;
		// 아이템으로 오르는 Damage
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getDamage();
			n += findItemByIndex(mWeapon).getDamage();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getDamage();
			n += findItemByIndex(mShield).getDamage();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getDamage();
			n += findItemByIndex(mHelmet).getDamage();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getDamage();
			n += findItemByIndex(mArmor).getDamage();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getDamage();
			n += findItemByIndex(mCape).getDamage();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getDamage();
			n += findItemByIndex(mShoes).getDamage();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getDamage();
			n += findItemByIndex(mAccessory).getDamage();
		}
		return n;
	}

	// 마법 데미지
	public int getMagicDamage() {
		int n = 0;
		// 아이템으로 오르는 MagicDamage
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getMagicDamage();
			n += findItemByIndex(mWeapon).getMagicDamage();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getMagicDamage();
			n += findItemByIndex(mShield).getMagicDamage();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getMagicDamage();
			n += findItemByIndex(mHelmet).getMagicDamage();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getMagicDamage();
			n += findItemByIndex(mArmor).getMagicDamage();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getMagicDamage();
			n += findItemByIndex(mCape).getMagicDamage();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getMagicDamage();
			n += findItemByIndex(mShoes).getMagicDamage();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getMagicDamage();
			n += findItemByIndex(mAccessory).getMagicDamage();
		}
		return n;
	}

	// 물리 방어력
	public int getDefense() {
		int n = 0;
		// 아이템으로 오르는 Defense
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getDefense();
			n += findItemByIndex(mWeapon).getDefense();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getDefense();
			n += findItemByIndex(mShield).getDefense();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getDefense();
			n += findItemByIndex(mHelmet).getDefense();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getDefense();
			n += findItemByIndex(mArmor).getDefense();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getDefense();
			n += findItemByIndex(mCape).getDefense();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getDefense();
			n += findItemByIndex(mShoes).getDefense();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getDefense();
			n += findItemByIndex(mAccessory).getDefense();
		}
		return n;
	}

	// 마법 방어력
	public int getMagicDefense() {
		int n = 0;
		// 아이템으로 오르는 MagicDefense
		if (mWeapon > 0) {
			n += GameData.getItems().get(findItemByIndex(mWeapon).getNo()).getMagicDefense();
			n += findItemByIndex(mWeapon).getMagicDefense();
		}
		if (mShield > 0) {
			n += GameData.getItems().get(findItemByIndex(mShield).getNo()).getMagicDefense();
			n += findItemByIndex(mShield).getMagicDefense();
		}
		if (mHelmet > 0) {
			n += GameData.getItems().get(findItemByIndex(mHelmet).getNo()).getMagicDefense();
			n += findItemByIndex(mHelmet).getMagicDefense();
		}
		if (mArmor > 0) {
			n += GameData.getItems().get(findItemByIndex(mArmor).getNo()).getMagicDefense();
			n += findItemByIndex(mArmor).getMagicDefense();
		}
		if (mCape > 0) {
			n += GameData.getItems().get(findItemByIndex(mCape).getNo()).getMagicDefense();
			n += findItemByIndex(mCape).getMagicDefense();
		}
		if (mShoes > 0) {
			n += GameData.getItems().get(findItemByIndex(mShoes).getNo()).getMagicDefense();
			n += findItemByIndex(mShoes).getMagicDefense();
		}
		if (mAccessory > 0) {
			n += GameData.getItems().get(findItemByIndex(mAccessory).getNo()).getMagicDefense();
			n += findItemByIndex(mAccessory).getMagicDefense();
		}
		return n;
	}

	// 필요 경험치
	public int getMaxExp() {
		// 필요 경험치 계산식
		int n = 0;
		n += mLevel * mLevel * 10;
		return n;
	}

	// 경험치 획득
	public void gainExp(int value) {
		int maxExp = getMaxExp();
		mExp += value;
		// 현재 경험치가 최대 경험치를 초과한 경우
		if (mExp >= maxExp) {
			// 레벨 업
			mExp = 0;
			mLevel++;
			mStatPoint += 5;
			mSkillPoint += 1;
			// HP 및 MP 회복
			mHp = getMaxHp();
			mMp = getMaxMp();
			// 변화한 스텟 정보를 보냄
			mCtx.writeAndFlush(Packet.updateStatus(
					new int[]{Type.Status.LEVEL.getValue(), Type.Status.STAT_POINT.getValue(), Type.Status.SKILL_POINT.getValue(), Type.Status.STR.getValue(), Type.Status.DEX.getValue(),
							Type.Status.AGI.getValue(), Type.Status.HP.getValue(), Type.Status.MAX_HP.getValue(), Type.Status.MP.getValue(), Type.Status.MAX_MP.getValue(), Type.Status.MAX_EXP.getValue()},
					new Integer[]{mLevel, mStatPoint, mSkillPoint, getStr(), getDex(), getAgi(), mHp, getMaxHp(), mMp, getMaxMp(), getMaxExp()}));
			Map.getMap(mMap).getField(mSeed).sendToOthers(this, Packet.updateCharacter(mCharacterType, mNo,
					new int[]{ Type.Status.LEVEL.getValue(), Type.Status.HP.getValue(), Type.Status.MAX_HP.getValue() },
					new Integer[] { mLevel, mHp, getMaxHp() }));
			animation(25);
		}
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{Type.Status.EXP.getValue()}, new Integer[]{mExp}));
	}

	// 경험치 잃음
	public void loseExp(int value) {
		if (mExp - value < 0) {
			value = mExp;
		}
		gainExp(-value);
	}

	public void gainGold(int value) {
		mGold += value;
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{Type.Status.GOLD.getValue()}, new Integer[]{mGold}));
	}

	public boolean loseGold(int value) {
		if (mGold < value) {
			return false;
		}
		gainGold(-value);
		return true;
	}

	public int getStatPoint() {
		return mStatPoint;
	}

	public int getSkillPoint() {
		return mSkillPoint;
	}

	public boolean isAdmin() {
		return mbAdmin;
	}

	public int getWeapon() {
		return mWeapon;
	}

	public int getShield() {
		return mShield;
	}

	public int getHelmet() {
		return mHelmet;
	}

	public int getArmor() {
		return mArmor;
	}

	public int getCape() {
		return mCape;
	}
	
	public int getShoes() {
		return mShoes;
	}
	
	public int getAccessory() {
		return mAccessory;
	}

	public int getMaxInventory() {
		return MAX_INVENTORY_COUNT;
	}

	// 정보 가져오기
	public void loadData() {
		loadEquipItem();
		loadInventory();
		loadSkillList();
		loadGuildMember();
		loadSlot();
	}
	
	// 장착한 아이템 불러오기
	public void loadEquipItem() {
		try {
			ResultSet rs = DataBase.executeQuery("SELECT * FROM `equip` WHERE `user_no` = '" + mNo + "';");
	    	if (rs.next()) {
	    		mWeapon = rs.getInt("weapon");
	    		mShield = rs.getInt("shield");
	    		mHelmet = rs.getInt("helmet");
	    		mArmor = rs.getInt("armor");
	    		mCape = rs.getInt("cape");
	    		mShoes = rs.getInt("shoes");
	    		mAccessory = rs.getInt("accessory");
	    	} else {
				DataBase.insertEquip(mNo);
			}
			rs.close();
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	// 인벤토리 불러오기
	public void loadInventory() {
		try {
			ResultSet rs = DataBase.executeQuery("SELECT * FROM `item` WHERE `user_no` = '" + mNo + "';");
			while (rs.next()) {
				mItemBagHashtable.put(rs.getInt("index"), new Item(rs));
				mCtx.writeAndFlush(Packet.setItem(mItemBagHashtable.get(rs.getInt("index"))));
			}
			rs.close();
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	// 스킬 불러오기
	public void loadSkillList() {
		try {
			ResultSet rs = DataBase.executeQuery("SELECT * FROM `skill` WHERE `user_no` = '" + mNo + "';");
			while (rs.next()) {
				mSkillBagHashtable.put(rs.getInt("skill_no"), new Skill(mNo, rs.getInt("skill_no")));
				mCtx.writeAndFlush(Packet.setSkill(mSkillBagHashtable.get(rs.getInt("skill_no"))));
			}
			rs.close();
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	// 길드 멤버 불러오기
	public void loadGuildMember() {
		if (mGuildNo == 0) {
			return;
		}
		try {
			ResultSet rs = DataBase.executeQuery("SELECT * FROM `user` WHERE `guild` = '" + mGuildNo + "';");
			while (rs.next()) {
				User member = User.getOrNullByNo(rs.getInt("no"));
				if (member == null) {
					mCtx.writeAndFlush(Packet.setGuildMember(rs.getInt("no"), rs.getString("name"), rs.getString("image"),
							rs.getInt("level"), rs.getInt("job"), rs.getInt("hp"), rs.getInt("hp")));
				} else {
					mCtx.writeAndFlush(Packet.setGuildMember(member));
				}
			}
			rs.close();
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	// 스텟 포인트 사용
	public void useStatPoint(final Type.Status stat) {
		if (mStatPoint <= 0) {
			return;
		}
		// 올릴 수 있는 스텟만 올리고
		switch (stat) {
			case STR:
				mPureStr++;
				mCtx.writeAndFlush(Packet.updateStatus(new int[]{ stat.getValue() }, new Integer[]{ getStr() }));
				break;

			case DEX:
				mPureDex++;
				mCtx.writeAndFlush(Packet.updateStatus(new int[]{ stat.getValue() }, new Integer[]{ getDex() }));
				break;

			case AGI:
				mPureAgi++;
				mCtx.writeAndFlush(Packet.updateStatus(new int[]{ stat.getValue() }, new Integer[]{ getAgi() }));
				break;

			default:
				return;
		}
		// 스포 하나 까자
		mStatPoint--;
		mCtx.writeAndFlush(Packet.updateStatus(new int[]{Type.Status.STAT_POINT.getValue()}, new Integer[]{mStatPoint}));
	}
	
	// 아이템 장착
	public void equipItem(Type.Item type, int index) {
		int oldEquip = 0;
		switch (type) {
			case WEAPON:
				oldEquip = mWeapon;
				mWeapon = index;
				break;

			case SHIELD:
				oldEquip = mShield;
				mShield = index;
				break;

			case HELMET:
				oldEquip = mHelmet;
				mHelmet = index;
				break;

			case ARMOR:
				oldEquip = mArmor;
				mArmor = index;
				break;

			case CAPE:
				oldEquip = mCape;
				mCape = index;
				break;

			case SHOES:
				oldEquip = mShoes;
				mShoes = index;
				break;

			case ACCESSORY:
				oldEquip = mAccessory;
				mAccessory = index;
				break;

			default:
				return;
		}
		// 이전에 장착했던 아이템과 현재 장착한 아이템
		Item lastEquippedItem = findItemByIndex(oldEquip);
		Item nowEquipItem = findItemByIndex(index);
		// 장착 상태 변경 후 인벤토리 업데이트
		if (lastEquippedItem != null) {
			lastEquippedItem.setEquipped(false);
			mCtx.writeAndFlush(Packet.updateItem(1, lastEquippedItem));
		}
		if (nowEquipItem != null) {
			nowEquipItem.setEquipped(true);
			mCtx.writeAndFlush(Packet.updateItem(1, nowEquipItem));
		}
		// HP, MP 보정
		if (getMaxHp() < mHp) {
			mHp = getMaxHp();
		}
		if (getMaxMp() < mMp) {
			mMp = getMaxMp();
		}
		// TODO : Type.Status.WEAPON + type는 임시. 수정 요망
		mCtx.writeAndFlush(Packet.updateStatus(
				new int[]{ Type.Status.WEAPON.getValue() + type.getValue(), Type.Status.STR.getValue(), Type.Status.DEX.getValue(), Type.Status.AGI.getValue(), Type.Status.MAX_HP.getValue(), Type.Status.HP.getValue(),
						Type.Status.MAX_MP.getValue(), Type.Status.MP.getValue(), Type.Status.CRITICAL.getValue(), Type.Status.AVOID.getValue(), Type.Status.HIT.getValue() },
				new Integer[]{ index, getStr(), getDex(), getAgi(), getMaxHp(), mHp, getMaxMp(), mMp, getCritical(), getAvoid(), getHit() }));
		Map.getMap(mMap).getField(mSeed).sendToOthers(this, Packet.updateCharacter(Type.Character.USER, mNo,
				new int[]{ Type.Status.MAX_HP.getValue(), Type.Status.HP.getValue() }, new Integer[]{ getMaxHp(), mHp }));
	}

	// 아이템 번호로 아이템 획득
	public boolean gainItem(int itemNo, int num) {
		int gap = 0;
		int index = getEmptyIndex();
		ItemData itemData = GameData.getItems().get(itemNo);
		Item item = findLazyItemByNo(itemNo);
		// 이미 있던 아이템일 경우 채워줌
		if (item != null) {
			gap = item.getAmount() + num - itemData.getMaxLoad();
			item.addAmount(num);
			num = gap;
			mCtx.writeAndFlush(Packet.updateItem(1, item));
		}
		while (num > 0) {
			if (index == -1) {
				// 나머지 아이템 드랍
				Map.getMap(mMap).getField(mSeed).loadDropItem(itemNo, num, mX, mY);
				return false;
			}
			// 계속해서 아이템 채우자
			mItemBagHashtable.put(index, new Item(mNo, itemNo, num, index, itemData.isTradeable() ? 1 : 0));
			mCtx.writeAndFlush(Packet.setItem(mItemBagHashtable.get(index)));
			index = getEmptyIndex();
			num -= itemData.getMaxLoad();
		}
		return true;
	}

	// 능력치 있는 장비 아이템 획득
	public boolean gainItem(int itemNo, Item item) {
		int index = getEmptyIndex();
		if (index == -1) {
			return false;
		}
		mItemBagHashtable.put(index, new Item(mNo, item.getNo(), index, item));
		mCtx.writeAndFlush(Packet.setItem(mItemBagHashtable.get(index)));
		return true;
	}

	// 아이템 No로 아이템 잃음 (퀘스트 등)
	public boolean loseItemByNo(int itemNo, int num) {
		if (itemNo <= 0 || num <= 0) {
			return false;
		}
		int gap = 0;
		Item item = findItemByNo(itemNo);
		// 아이템이 없거나 잃을 갯수가 더 많은 경우
		if (item == null || getTotalItemAmount(item.getNo()) < num) {
			return false;
		}
		// 모든 아이템을 잃을 때까지 반복
		do {
			gap = num - item.getAmount();
			item.addAmount(-num);
			if (item.getAmount() == 0) {
				// 아이템 삭제
				mItemBagHashtable.remove(item.getIndex());
				mCtx.writeAndFlush(Packet.updateItem(0, item));
			} else {
				// 아이템 갯수 업데이트
				mCtx.writeAndFlush(Packet.updateItem(1, item));
			}
			num = gap;
		} while (num > 0);
		return true;
	}

	// Index로 아이템 잃음 (직접 드랍하는 경우)
	public boolean loseItemByIndex(int index, int num) {
		Item item = findItemByIndex(index);
		// 아이템이 없거나 잃을 갯수가 더 많은 경우
		if (item == null || item.getAmount() < num) {
			return false;
		}
		item.addAmount(-num);
		if (item.getAmount() == 0) {
			// 아이템 삭제
			mItemBagHashtable.remove(item.getIndex());
			mCtx.writeAndFlush(Packet.updateItem(0, item));
		} else {
			// 아이템 갯수 업데이트
			mCtx.writeAndFlush(Packet.updateItem(1, item));
		}
		return true;
	}
	
	// 비어있는 인덱스를 획득
	public int getEmptyIndex() {
		for (int i = 1; i <= MAX_INVENTORY_COUNT; i++) {
			if (!mItemBagHashtable.containsKey(i)) {
				return i;
			}
		}
		return -1;
	}
	
	// 가지고 있는 아이템 총량을 획득
	public int getTotalItemAmount(int itemNo) {
		int num = 0;
		for (Item item : mItemBagHashtable.values()) {
			if (item.getNo() == itemNo) {
				num += item.getAmount();
			}
		}
		return num;
	}
	
	// Index로 아이템 검색
	public Item findItemByIndex(int index) {
		if (!mItemBagHashtable.containsKey(index)) {
			return null;
		}
		return mItemBagHashtable.get(index);
	}

	// No로 아이템 검색
	public Item findItemByNo(int itemNo) {
		for (Item item : mItemBagHashtable.values()) {
			if (item.getNo() == itemNo) {
				return item;
			}
		}
		return null;
	}

	// No로 여유 있는 아이템 검색
	public Item findLazyItemByNo(int itemNo) {
		for (Item item : mItemBagHashtable.values()) {
			// 아이템이 꽉 찬 경우가 아니라면
			if (item.getNo() == itemNo && item.getAmount() < GameData.getItems().get(item.getNo()).getMaxLoad()) {
				return item;
			}
		}
		return null;
	}

	// 아이템 인덱스 변경
	public void changeItemIndex(int index1, int index2) {
		Item presentItem = findItemByIndex(index1);
		Item targetItem = findItemByIndex(index2);
		// 아이템이 없으면 반환
		if (presentItem == null) {
			return;
		}
		if (presentItem.isEquipped()) {
			return;
		}
		if (targetItem != null) {
			if (targetItem.isEquipped()) {
				return;
			}
			// 아이템 간 인덱스 변경
			mItemBagHashtable.remove(index1);
			mItemBagHashtable.remove(index2);
			presentItem.setIndex(index2);
			targetItem.setIndex(index1);
			mItemBagHashtable.put(index2, presentItem);
			mItemBagHashtable.put(index1, targetItem);
			mCtx.write(Packet.setItem(presentItem));
			mCtx.writeAndFlush(Packet.setItem(targetItem));
		} else {
			// 빈 곳으로 아이템 이동
			mCtx.write(Packet.updateItem(0, presentItem));
			mItemBagHashtable.remove(index1);
			presentItem.setIndex(index2);
			mItemBagHashtable.put(index2, presentItem);
			mCtx.writeAndFlush(Packet.setItem(presentItem));
		}

	}

	// Index로 아이템 사용
	public boolean useItemByIndex(int index, int amount) {
		Item item = findItemByIndex(index);
		// 아이템이 없으면 반환
		if (item == null) {
			return false;
		}
		// 갯수가 적으면 반환
		if (item.getAmount() < amount) {
			return false;
		}
		ItemData itemData = GameData.getItems().get(item.getNo());
		// 레벨이 낮으면 반환
		if (mLevel < itemData.getLimitLevel()) {
			return false;
		}
		// 직업이 다르고 아이템도 공용이 아니면 반환
		if (mJob != itemData.getJob() && itemData.getJob() != 0) {
			return false;
		}
		// 소모품이면 아이템 잃음
		if (itemData.isConsumable()) {
			loseItemByIndex(index, amount);
		}
		// 아이템이 아니라면 장착해보자
		if (itemData.getType() != Type.Item.ITEM) {
			equipItem(itemData.getType(), item.getIndex());
		}
		// 함수가 있을 경우 실행
		String function = itemData.getFunction();
		if (function != "") {
			Functions.execute(Functions.item, function, new Object[]{this, item});
		}
		return true;
	}

	// No로 아이템 사용
	public boolean useItemByNo(int itemNo, int amount) {
		Item item = findItemByNo(itemNo);
		// 아이템이 없으면 반환
		if (item == null) {
			return false;
		}
		// 갯수가 적으면 반환
		if (item.getAmount() < amount) {
			return false;
		}
		ItemData itemData = GameData.getItems().get(item.getNo());
		// 레벨이 낮으면 반환
		if (mLevel < itemData.getLimitLevel()) {
			return false;
		}
		// 직업이 다르고 아이템도 공용이 아니면 반환
		if (mJob != itemData.getJob() && itemData.getJob() != 0) {
			return false;
		}
		// 소모품이면 아이템 잃음
		if (itemData.isConsumable()) {
			loseItemByNo(itemNo, amount);
		}
		// 함수가 있을 경우 실행
		String function = GameData.getItems().get(item.getNo()).getFunction();
		if (function != "") {
			Functions.execute(Functions.item, function, new Object[]{this, item});
		}
		return true;
	}

	// No로 아이템 버리기
	public boolean dropItemByNo(int itemNo, int amount) {
		Item item = findItemByNo(itemNo);
		// 아이템이 없으면 반환
		if (item == null) {
			return false;
		}
		// 갯수가 적으면 반환
		if (item.getAmount() < amount || amount <= 0) {
			return false;
		}
		ItemData itemData = GameData.getItems().get(item.getNo());
		loseItemByNo(itemNo, amount);
		if (itemData.getType() == Type.Item.ITEM) {
			Map.getMap(mNo).getField(mSeed).loadDropItem(itemNo, amount, mX, mY);
		} else {
			Map.getMap(mNo).getField(mSeed).loadDropItem(itemNo, item, mX, mY);
		}
		return true;
	}

	// Index로 아이템 버리기
	public boolean dropItemByIndex(int index, int amount) {
		Item item = findItemByIndex(index);
		// 아이템이 없으면 반환
		if (item == null) {
			return false;
		}
		// 갯수가 적으면 반환
		if (item.getAmount() < amount || amount <= 0) {
			return false;
		}
		ItemData itemData = GameData.getItems().get(item.getNo());
		loseItemByIndex(index, amount);
		if (itemData.getType() == Type.Item.ITEM) {
			Map.getMap(mNo).getField(mSeed).loadDropItem(item.getNo(), amount, mX, mY);
		} else {
			Map.getMap(mNo).getField(mSeed).loadDropItem(item.getNo(), item, mX, mY);
		}
		return true;
	}

	// 골드 버리기
	public boolean dropGold(int amount) {
		if (mGold < amount) {
			return false;
		}
		loseGold(amount);
		Map.getMap(mNo).getField(mSeed).loadDropGold(amount, mX, mY);
		return true;
	}

	// 아이템 줍기
	public void pickItem() {
		Field field = Map.getMap(mMap).getField(mSeed);
		// 골드 먼저 줍자
		Field.DropGold dropGold = field.pickGold(mX, mY);
		Field.DropItem dropItem;
		// 골드가 없다면
		if (dropGold == null) {
			// 아이템을 줍자
			dropItem = field.pickItem(mX, mY);
			// 아이템도 없다면 반환
			if (dropItem == null) {
				return;
			}
		}
		else {
			// 골드가 있다면 획득하고 반환
			gainGold(dropGold.getAmount());
			field.removeDropGold(dropGold);
			return;
		}
		// 비어있는 인덱스를 획득
		int index = getEmptyIndex();
		if (index == -1) {
			return;
		}
		ItemData itemData = GameData.getItems().get(dropItem.getItemNo());
		if (itemData.getType() != Type.Item.ITEM) {
			// 장비 아이템일 경우 기존 능력치 얻어가자
			gainItem(dropItem.getItemNo(), dropItem.getItem());
		} else {
			// 일반 아이템일 경우 그냥 얻자
			gainItem(dropItem.getItemNo(), dropItem.getAmount());
		}
		field.removeDropItem(dropItem);
	}

	// No로 스킬 검색
	public GameData.Skill findSkillByNo(int skillNo) {
		if (!mSkillBagHashtable.containsKey(skillNo)) {
			return null;
		}
		return mSkillBagHashtable.get(skillNo);
	}

	// Index로 스킬 검색
	public GameData.Skill findSkillByIndex(int itemNo) {
		for (GameData.Skill skill : mSkillBagHashtable.values()) {
			if (skill.getNo() == itemNo) {
				return skill;
			}
		}
		return null;
	}

	// 스킬 배우기
	public boolean studySkill(int skillNo) {
		if (mSkillBagHashtable.containsKey(skillNo)) {
			return false;
		}
		GameData.Skill skill = new GameData.Skill(mNo, skillNo);
		mSkillBagHashtable.put(skillNo, skill);
		mCtx.writeAndFlush(Packet.setSkill(skill));
		return true;
	}

	// 스킬 지우기
	public boolean forgetSkill(int skillNo) {
		if (!mSkillBagHashtable.containsKey(skillNo)) {
			return false;
		}
		mCtx.writeAndFlush(Packet.updateSkill(0, mSkillBagHashtable.get(skillNo)));
		mSkillBagHashtable.remove(skillNo);
		return true;
	}

	// No로 스킬 사용
	public boolean useSkill(int skillNo) {
		GameData.Skill skill = findSkillByNo(skillNo);
		if (skill == null) {
			return false;
		}
		if (mCoolTime.getCoolTime(skill.getNo()) > 0) {
			return false;
		}
		// 함수가 있을 경우 실행
		String function = GameData.getSkills().get(skill.getNo()).getFunction();
		if (function != "") {
			Functions.execute(Functions.skill, function, new Object[]{this, skill});
		}
		return true;
	}

	// 거래 요청
	public boolean requestTrade(int partnerNo) {
		User partner = User.getOrNullByNo(partnerNo);
		// 거래 중이라면 반환
		if (nowTrading()) {
			return false;
		}
		// 파트너가 없으면 반환
		if (partner == null) {
			return false;
		}
		// 상대 유저가 거래중이라면 반환
		if (partner.nowTrading()) {
			return false;
		}
		// 거래 요청
		partner.getCtx().writeAndFlush(Packet.requestTrade(mNo));
		return true;
	}

	// 거래 수락 및 거절
	public void responseTrade(int type, int partnerNo) {
		User partner = User.getOrNullByNo(partnerNo);
		// 파트너가 없으면 반환
		if (partner == null) {
			return;
		}
		// 파트너가 교환중이면 반환
		if (partner.nowTrading()) {
			return;
		}
		switch (type) {
			case 0:
				// 수락
				mTradePartner = partnerNo;
				mCtx.writeAndFlush(Packet.openTradeWindow(partnerNo));
				partner.mTradePartner = mNo;
				partner.getCtx().writeAndFlush(Packet.openTradeWindow(mNo));
				break;

			case 1:
				// 거절
				//partner.finishTrade();
				break;

			default:
		}
	}

	// 거래 아이템 올리기
	public void loadTradeItem(int index, int amount, int tradeIndex) {
		// 거래 중 아니라면 반환
		if (!nowTrading()) {
			return;
		}
		// 거래 종료 대기 중이라면 반환
		if (mbAcceptTrade || User.getOrNullByNo(mTradePartner).mbAcceptTrade) {
			return;
		}
		Item item = findItemByIndex(index);
		// 아이템이 없다면 반환
		if (item == null) {
			return;
		}
		// 거래 불가능한 아이템일 경우 반환
		if (!item.isTradeable()) {
			return;
		}
		// 장착중이라면 반환
		if (item.isEquipped()) {
			return;
		}
		// 소지 갯수보다 거래하려는 갯수가 많을 경우 반환
		if (item.getAmount() < amount) {
			return;
		}
		// 해당 공간에 이미 아이템이 있는 경우 반환
		if (mTradeItemsHashtable.containsKey(tradeIndex)) {
			return;
		}
		// 거래하려는 아이템을 거래 목록에 올림
		Item tradeItem = item.clone();
		tradeItem.setIndex(tradeIndex);
		tradeItem.setAmount(amount);
		mTradeItemsHashtable.put(tradeIndex, tradeItem);
		// 아이템 잃음
		loseItemByIndex(index, amount);
		// 거래 아이템 로드
		mCtx.writeAndFlush(Packet.loadTradeItem(tradeItem));
		User.getOrNullByNo(mTradePartner).getCtx().writeAndFlush(Packet.loadTradeItem(tradeItem));
	}

	// 거래 아이템 내리기
	public void dropTradeItem(int index) {
		// 거래 중 아니라면 반환
		if (!nowTrading()) {
			return;
		}
		// 거래 종료 대기 중이라면 반환
		if (mbAcceptTrade || User.getOrNullByNo(mTradePartner).mbAcceptTrade) {
			return;
		}
		// 아이템이 없으면 반환
		if (!mTradeItemsHashtable.containsKey(index)) {
			return;
		}
		Item item = mTradeItemsHashtable.get(index);
		ItemData itemData = GameData.getItems().get(item.getNo());
		// 일반 아이템일 경우 그냥 얻고, 장비 아이템일 경우 능력치 보존
		if (itemData.getType() == Type.Item.ITEM) {
			gainItem(item.getNo(), item.getAmount());
		} else {
			gainItem(item.getNo(), item);
		}
		// 거래 아이템 리스트에서 제거
		mTradeItemsHashtable.remove(index);
		// 거래 아이템 삭제
		mCtx.writeAndFlush(Packet.dropTradeItem(mNo, index));
		User.getOrNullByNo(mTradePartner).getCtx().writeAndFlush(Packet.dropTradeItem(mNo, index));
	}

	// 거래 골드 변경
	public void changeTradeGold(int value) {
		// 거래 중 아니라면 반환
		if (!nowTrading()) {
			return;
		}
		// 거래 종료 대기 중이라면 반환
		if (mbAcceptTrade || User.getOrNullByNo(mTradePartner).mbAcceptTrade) {
			return;
		}
		// 가진 골드와 거래중인 골드의 합보다 많으면 반환
		if (mTradeGold + mGold < value) {
			return;
		}
		gainGold(mTradeGold);
		loseGold(value);
		mTradeGold = value;
		// 골드 변경하렴
		mCtx.writeAndFlush(Packet.changeTradeGold(mNo, mTradeGold));
		User.getOrNullByNo(mTradePartner).getCtx().writeAndFlush(Packet.changeTradeGold(mNo, mTradeGold));
	}

	// 거래 종료 대기
	public void acceptTrade() {
		// 거래 중 아니라면 반환
		if (!nowTrading()) {
			return;
		}
		User partner = User.getOrNullByNo(mTradePartner);
		// 상대방도 거래 종료 대기 중이라면
		if (partner.mbAcceptTrade) {
			finishTrade();
		} else {
			mbAcceptTrade = true;
		}
		mCtx.writeAndFlush(Packet.acceptTrade(mNo));
		partner.getCtx().writeAndFlush(Packet.acceptTrade(mNo));
	}

	// 거래 종료
	public void finishTrade() {
		// 거래 중 아니라면 반환
		if (!nowTrading()) {
			return;
		}
		User partner = User.getOrNullByNo(mTradePartner);
		// 아이템 및 골드 획득
		for (Item i : partner.mTradeItemsHashtable.values()) {
			ItemData iData = GameData.getItems().get(i.getNo());
			if (iData.getType() == Type.Item.ITEM) {
				gainItem(i.getNo(), i.getAmount());
			} else {
				gainItem(i.getNo(), i);
			}
		}
		gainGold(partner.mTradeGold);
		// 파트너 아이템 및 골드 획득
		for (Item i : mTradeItemsHashtable.values()) {
			ItemData iData = GameData.getItems().get(i.getNo());
			if (iData.getType() == Type.Item.ITEM) {
				partner.gainItem(i.getNo(), i.getAmount());
			} else {
				partner.gainItem(i.getNo(), i);
			}
		}
		partner.gainGold(mTradeGold);
		// 거래 관련 변수 초기화
		mTradePartner = 0;
		mbAcceptTrade = false;
		mTradeGold = 0;
		mTradeItemsHashtable.clear();
		partner.mTradePartner = 0;
		partner.mbAcceptTrade = false;
		partner.mTradeGold = 0;
		partner.mTradeItemsHashtable.clear();
	}

	// 거래 취소
	public void cancelTrade() {
		// 거래 중 아니라면 반환
		if (!nowTrading()) {
			return;
		}
		// 아이템 및 골드 돌려받기
		for (Item i : mTradeItemsHashtable.values()) {
			ItemData iData = GameData.getItems().get(i.getNo());
			if (iData.getType() == Type.Item.ITEM) {
				gainItem(i.getNo(), i.getAmount());
			} else {
				gainItem(i.getNo(), i);
			}
		}
		gainGold(mTradeGold);
		// 파트너 아이템 및 골드 돌려받기
		User partner = User.getOrNullByNo(mTradePartner);
		for (Item i : partner.mTradeItemsHashtable.values()) {
			ItemData iData = GameData.getItems().get(i.getNo());
			if (iData.getType() == Type.Item.ITEM) {
				partner.gainItem(i.getNo(), i.getAmount());
			} else {
				partner.gainItem(i.getNo(), i);
			}
		}
		partner.gainGold(partner.mTradeGold);
		// 거래 관련 변수 초기화
		mTradePartner = 0;
		mbAcceptTrade = false;
		mTradeGold = 0;
		mTradeItemsHashtable.clear();
		partner.mTradePartner = 0;
		partner.mbAcceptTrade = false;
		partner.mTradeGold = 0;
		partner.mTradeItemsHashtable.clear();
		mCtx.writeAndFlush(Packet.cancelTrade());
		partner.getCtx().writeAndFlush(Packet.cancelTrade());
	}

	// 거래 중 여부
	public boolean nowTrading() {
		// 거래 중이 아니라면
		if (mTradePartner == 0) {
			return false;
		}
		// 거래 상대 없다면
		if (User.getOrNullByNo(mTradePartner) == null) {
			cancelTrade();
			return false;
		}
		return true;
	}

	// 상점 열기
	public void openShop(int no) {
		mCtx.writeAndFlush(Packet.openShopWindow(no));
		for (ItemData shopItem : GameData.getShops().get(no).getAllItems().values()) {
			mCtx.writeAndFlush(Packet.setShopItem(shopItem.getNo(), shopItem.getPrice()));
		}
	}

	// 상점 아이템 구매
	public void buyShopItem(int shopNo, int index, int amount) {
		if (!GameData.getShops().containsKey(shopNo)) {
			return;
		}
		Shop shop = GameData.getShops().get(shopNo);
		if (shop.getItem(index) == null) {
			return;
		}
		ItemData item = shop.getItem(index);
		if (item.getType() == Type.Item.ITEM) {
			amount = amount > item.getMaxLoad() ? item.getMaxLoad() : amount;
		} else {
			amount = 1;
		}
		if (mGold < item.getPrice() * amount) {
			return;
		}
		loseGold(item.getPrice() * amount);
		gainItem(item.getNo(), amount);
	}

	// 파티 번호 설정
	public void setPartyNo(int partyNo) {
		mPartyNo = partyNo;
		mCtx.writeAndFlush(Packet.setParty(mPartyNo));
	}

	// 파티 번호 얻기
	public int getPartyNo() {
		return mPartyNo;
	}

	// 파티 생성
	public void createParty() {
		// 이미 파티가 있다면 반환
		if (nowJoinParty()) {
			return;
		}
		// 파티를 생성
		Party.add(mNo);
	}

	// 파티 요청
	public void inviteParty(int otherNo) {
		// 가입한 파티가 없다면 반환
		if (!nowJoinParty()) {
			return;
		}
		// 파티 멤버수가 최대라면 반환
		if (Party.get(mPartyNo).getMembers().size() >= 4) {
			return;
		}
		User other = User.getOrNullByNo(otherNo);
		User master = User.getOrNullByNo(mPartyNo);
		// 파티 마스터가 없다면 반환
		if (master == null) {
			return;
		}
		// 상대 유저가 없다면 반환
		if (other == null) {
			return;
		}
		// 상대에게 이미 파티가 있다면 반환
		if (other.mPartyNo > 0) {
			return;
		}
		// 파티 요청
		other.getCtx().writeAndFlush(Packet.inviteParty(mPartyNo, master.getName()));
	}

	// 파티 응답
	public void responseParty(int type, int partyNo) {
		// 이미 가입한 파티가 있다면 반환
		if (nowJoinParty()) {
			return;
		}
		switch (type) {
			case 0:
				// 수락
				Party.get(partyNo).join(mNo);
				break;

			case 1:
				// 거절
				break;

			default:
		}
	}

	// 파티 나가기
	public void quitParty() {
		// 가입한 파티가 없다면 반환
		if (!nowJoinParty()) {
			return;
		}
		// 파티 탈퇴
		Party.get(mPartyNo).exit(mNo);
	}

	// 파티 강퇴
	public void kickParty(int member) {
		// 가입한 파티가 없다면 반환
		if (!nowJoinParty()) {
			return;
		}
		// 파티 마스터가 아니라면 반환
		if (mPartyNo != mNo) {
			return;
		}
		// 마스터를 강퇴하려 하면 반환
		if (member == mPartyNo) {
			return;
		}
		Party.get(mPartyNo).exit(member);
	}

	// 파티 해체
	public void breakUpParty() {
		// 가입한 파티가 없다면 반환
		if (!nowJoinParty()) {
			return;
		}
		// 파티 마스터가 아니라면 반환
		if (mPartyNo != mNo) {
			return;
		}
		Party.get(mPartyNo).breakUp();
	}

	// 파티 가입 여부
	private boolean nowJoinParty() {
		// 가입한 파티가 없다면
		if (mPartyNo == 0) {
			return false;
		}
		Party party = Party.get(mPartyNo);
		// 해당 파티가 없다면
		if (party == null) {
			mPartyNo = 0;
			return false;
		}
		return true;
	}

	// 길드 생성
	public void createGuild(String guildName) {
		// 가입한 길드가 있다면 반환
		if (nowJoinGuild()) {
			return;
		}
		// 소지금이 적으면 반환
		if (mGold < 100000) {
			return;
		}
		loseGold(100000);
		Guild.add(mNo, guildName);
	}

	// 길드 요청
	public void inviteGuild(int otherNo) {
		// 가입한 길드가 없다면 반환
		if (!nowJoinGuild()) {
			return;
		}
		// 길드 멤버수가 최대라면 반환
		if (Guild.get(mGuildNo).getMembers().size() >= 40) {
			return;
		}
		User other = User.getOrNullByNo(otherNo);
		User master = User.getOrNullByNo(Guild.get(mGuildNo).getMaster());
		// 마스터가 없다면 반환
		if (master == null) {
			return;
		}
		// 자신이 마스터가 아니라면 반환
		if (!equals(master)) {
			return;
		}
		// 상대 유저가 없다면 반환
		if (other == null) {
			return;
		}
		// 상대에게 이미 길드가 있다면 반환
		if (other.mGuildNo > 0) {
			return;
		}
		// 길드 요청
		other.getCtx().writeAndFlush(Packet.inviteGuild(mGuildNo, master.getName()));
	}

	// 길드 응답
	public void responseGuild(int type, int guildNo) {
		// 이미 가입한 파티가 있다면 반환
		if (nowJoinGuild()) {
			return;
		}
		switch (type) {
			case 0:
				// 수락
				Guild.get(guildNo).join(mNo);
				break;

			case 1:
				// 거절
				break;

			default:
		}
	}

	// 길드 나가기
	public void quitGuild() {
		// 가입한 길드가 없다면 반환
		if (!nowJoinGuild()) {
			return;
		}
		// 길드 탈퇴
		Guild.get(mGuildNo).exit(mNo);
	}

	// 길드 강퇴
	public void kickGuild(int member) {
		// 가입한 길드가 없다면 반환
		if (!nowJoinGuild()) {
			return;
		}
		// 길드 마스터가 아니라면 반환
		if (mGuildNo != mNo) {
			return;
		}
		// 마스터를 강퇴하려 하면 반환
		if (member == mGuildNo) {
			return;
		}
		Guild.get(mGuildNo).exit(member);
	}

	// 길드 해체
	public void breakUpGuild() {
		// 가입한 길드가 없다면 반환
		if (!nowJoinGuild()) {
			return;
		}
		// 길드 마스터가 아니라면 반환
		if (mGuildNo != mNo) {
			return;
		}
		Guild.get(mGuildNo).breakUp();
	}

	// 길드 가입 여부
	private boolean nowJoinGuild() {
		// 가입한 파티가 없다면
		if (mGuildNo == 0) {
			return false;
		}
		Guild guild = Guild.get(mGuildNo);
		// 해당 길드가 없다면
		if (guild == null) {
			mGuildNo = 0;
			return false;
		}
		return true;
	}

	// 현재 대화 얻음
	public Message getMessage() {
		return mMessage;
	}

	// 대화 업데이트
	public void updateMessage(int select) {
		for (Npc npc : Map.getMap(mMap).getField(mSeed).getNPCs()) {
			if (npc.getNo() == mMessage.getNpc()) {
				mMessage.mMySelect = select;
				Functions.execute(Functions.npc, npc.getFunctionName(), new Object[]{ this, npc });
				break;
			}
		}
	}

	// 스페이스바 누를 경우 액션
	public void action() {
		// 다른 작업 중이라면 반환
		if (isBusy()) {
			return;
		}
		int newX = mX + (mDirection == Type.Direction.RIGHT ? 1 : mDirection == Type.Direction.LEFT ? -1 : 0);
		int newY = mY + (mDirection == Type.Direction.DOWN ? 1 : mDirection == Type.Direction.UP ? -1 : 0);
		// 에너미가 있을 경우 공격하고 반환
		for (Enemy enemy : Map.getMap(mMap).getField(mSeed).getAliveEnemies()) {
			if (enemy.getX() == newX && enemy.getY() == newY) {
				assault(enemy);
				return;
			}
		}
		// NPC가 있을 경우 대화하고 반환
		for (Npc npc : Map.getMap(mMap).getField(mSeed).getNPCs()) {
			if (npc.getX() == newX && npc.getY() == newY) {
				Functions.execute(Functions.npc, npc.getFunctionName(), new Object[]{ this, npc });
				return;
			}
		}
	}

	// 적 공격
	public void assault(Character target) {
		jump(target.mDirection, 0);
		target.animation(8);
		// 실 데미지를 계산
		int attackDamage = (getDamage() - target.getDefense()) *  (getDamage() - target.getDefense());
		boolean isFatal = getCritical() > mRandom.nextInt(100);
		if (isFatal) {
			attackDamage *= 2;
		}
		if (target.getClass().getName().equals("game.Enemy")) {
			// 타겟이 에너미인 경우
			Enemy e = (Enemy) target;
			e.displayDamage(attackDamage, isFatal);
			e.loseHp(attackDamage);
		} else if (target.getClass().getName().equals("game.User")) {
			// 타겟이 유저인 경우
			User user = (User) target;
			user.displayDamage(attackDamage, isFatal);
			user.loseHp(attackDamage);
		}
	}

	// 채팅
	public boolean chatCommand(String strMessage) {
		String command_param[] = strMessage.split(" ");
		// 콘솔 명령어가 실행되었는가
		boolean isCmdExecuted = true;
		switch (command_param[0]) {
			case "/공지":
				if (!mbAdmin) {
					isCmdExecuted = false;
					break;
				}
				for (User user : usersHashtable.values()) {
					user.getCtx().writeAndFlush(Packet.chatAll(mNo, "[공지] " + strMessage.replaceFirst("/공지 ", ""), 255, 38, 19));
				}
				break;

			case "/귓":
				strMessage = strMessage.replaceFirst("/귓 ", "");
				strMessage = strMessage.replaceFirst(command_param[1] + " ", "");
				chatWhisper(command_param[1], strMessage);
				break;

			case "/w":
				strMessage = strMessage.replaceFirst("/w ", "");
				strMessage = strMessage.replaceFirst(command_param[1] + " ", "");
				chatWhisper(command_param[1], strMessage);
				break;

			case "/파티":
				strMessage = strMessage.replaceFirst("/파티 ", "");
				chatParty(strMessage);
				break;

			case "/p":
				strMessage = strMessage.replaceFirst("/p ", "");
				chatParty(strMessage);
				break;

			case "/길드":
				strMessage = strMessage.replaceFirst("/길드 ", "");
				chatGuild(strMessage);
				break;

			case "/g":
				strMessage = strMessage.replaceFirst("/g ", "");
				chatGuild(strMessage);
				break;

			case "/전체":
				strMessage = strMessage.replaceFirst("/전체 ", "");
				chatAll(strMessage);
				break;

			case "/a":
				strMessage = strMessage.replaceFirst("/a ", "");
				chatAll(strMessage);
				break;

			// 커맨드 콘솔이 입력되지 않은 경우
			default:
				isCmdExecuted = false;
		}
		return isCmdExecuted;
	}

	// 일반 채팅
	public void chatNormal(String strMessage) {
		if (chatCommand(strMessage)) {
			return;
		}
		Vector<User> mapUsers = Map.getMap(mMap).getField(mSeed).getUsers();
		for (User user : mapUsers) {
			user.getCtx().writeAndFlush(Packet.chatNormal(mNo, mName + " : " + strMessage));
		}
		startShowingBalloon();
	}

	// 귓속말
	public void chatWhisper(String strTargetName, String strMessage) {
		if (chatCommand(strMessage)) {
			return;
		}
		User u_target = null;
		// 타겟이 본인일 경우
		if (mName.equals(strTargetName)) {
			return;
		}
		// 검색하려는 닉네임이 공백인 경우
		if (strTargetName.equals("")) {
			return;
		}
		// 메세지가 존재하지 않을 경우
		if (strMessage == null || strMessage.equals("")) {
			return;
		}
		// 닉네임으로 타겟 유저 검색
		for (User user : usersHashtable.values()) {
			if (user.getName().equals(strTargetName)) {
				u_target = user;
				break;
			}
		}
		// 타겟 유저가 접속 중이 아닐 경우
		if (u_target == null) {
			return;
		}
		// `상대`가 `나`로부터 받음
		u_target.getCtx().writeAndFlush(Packet.chatWhisper("[From:" + mName + "] " + strMessage, 25, 181, 254, 32, 32, 32));
		// `나`가 `상대`에게 보냄
		mCtx.writeAndFlush(Packet.chatWhisper("[To:" + u_target.getName() + "] " + strMessage, 25, 181, 254, 32, 32, 32));
	}

	// 파티 채팅
	public void chatParty(String strMessage) {
		if (chatCommand(strMessage)) {
			return;
		}
 		if (!nowJoinParty()) {
			return;
		}
 		for (int member : Party.get(mPartyNo).getMembers()) {
 			User user = User.getOrNullByNo(member);
 			user.getCtx().writeAndFlush(Packet.chatParty("[파티] " + mName + " : " + strMessage, 3, 201, 169, 32, 32, 32));
 		}
 	}
 
 	// 길드 채팅
 	public void chatGuild(String strMessage) {
		if (chatCommand(strMessage)) {
			return;
		}
 		if (!nowJoinGuild()) {
			return;
		}
 		for (int member : Guild.get(mGuildNo).getMembers()) {
 			User user = User.getOrNullByNo(member);
 			user.getCtx().writeAndFlush(Packet.chatGuild("[길드] " + mName + " : " + strMessage, 247, 202, 24, 32, 32, 32));
 		}
 	}

	// 전체 채팅
	public void chatAll(String strMessage) {
		if (chatCommand(strMessage)) {
			return;
		}
		for (User user : usersHashtable.values()) {
			user.getCtx().writeAndFlush(Packet.chatAll(mNo, "[전체] " + mName + " : " + strMessage, 255, 255, 255, 219, 10, 91));
		}
		startShowingBalloon();
	}

	// 다른 작업을 하고 있는지 (대화, 거래)
	private boolean isBusy() {
		// 대화 중
		if (mMessage.isStart()) {
			return true;
		}
		// 거래 중
		if (nowTrading()) {
			return true;
		}
		return false;
	}

    // 채팅
    public void startShowingBalloon() {
	    // 옵션 DB 에서 말풍선 표시 시간 취득
        try {
            if (mStandardDelay < 0) {
                ResultSet rs = DataBase.executeQuery("SELECT `value` FROM `setting_option` WHERE `name` = 'chatting_balloon_delay';");
                if (rs.next()) {
					mStandardDelay = rs.getInt(1);
					mStandardDelay /= 100;
                }
                rs.close();
            }
        } catch (SQLException e) {
            logger.warning(e.toString());
        }
		mbBalloonShowing = true;
		mStartChattingTime = System.currentTimeMillis() / 100;
    }

    public void endShowingBalloon(int no) {
        Vector<User> mapUsers = Map.getMap(mMap).getField(mSeed).getUsers();
        for (User user : mapUsers) {
			user.getCtx().writeAndFlush(Packet.removeChattingBalloon(no));
		}
		mbBalloonShowing = false;
    }

	public void update() {
		long nowTime = System.currentTimeMillis() / 100;
		// 쿨타임
		if (nowTime > mLastTime + 1)
		{
			mLastTime = System.currentTimeMillis() / 100;
			mCoolTime.coolDown();
		}
        // 말풍선
		if (mbBalloonShowing) {
            if (nowTime - mStartChattingTime >= mStandardDelay) {
                endShowingBalloon(mNo);
            }
        }
	}

	// 좌표 이동
	public void move(Type.Direction type) {
		// 다른 작업 중이라면 리프레쉬
		if (isBusy()) {
			mCtx.writeAndFlush(Packet.refreshCharacter(mCharacterType, mNo, mX, mY, mDirection));
			return;
		}
		// 이동
		switch (type) {
			case DOWN:
				moveDown();
				break;

			case LEFT:
				moveLeft();
				break;

			case RIGHT:
				moveRight();
				break;

			case UP:
				moveUp();
				break;

			default:
		}
		// 맵 이동 여부 판정
		Field gameField = Map.getMap(mMap).getField(mSeed);
		for (Portal portal : gameField.getPortals()) {
			if (portal.getX() == mX && portal.getY() == mY) {
				gameField.removeUser(this);
				mMap = portal.getNextMap();
				mX = portal.getNextX();
				mY = portal.getNextY();
				Map.getMap(portal.getNextMap()).getField(mSeed).addUser(this);
			}
		}
	}

	// 이동이 불가능한 경우 리프레쉬
	protected boolean moveUp() {
		if (!super.moveUp()) {
			mCtx.writeAndFlush(Packet.refreshCharacter(mCharacterType, mNo, mX, mY, mDirection));
		}
		return true;
	}

	protected boolean moveDown() {
		if (!super.moveDown()) {
			mCtx.writeAndFlush(Packet.refreshCharacter(mCharacterType, mNo, mX, mY, mDirection));
		}
		return true;
	}

	protected boolean moveLeft() {
		if (!super.moveLeft()) {
			mCtx.writeAndFlush(Packet.refreshCharacter(mCharacterType, mNo, mX, mY, mDirection));
		}
		return true;
	}

	protected boolean moveRight() {
		if (!super.moveRight()) {
			mCtx.writeAndFlush(Packet.refreshCharacter(mCharacterType, mNo, mX, mY, mDirection));
		}
		return true;
	}

	// 방향 전환
	public void turn(Type.Direction type) {
		// 다른 작업 중이라면 리프레쉬
		if (isBusy()) {
			mCtx.writeAndFlush(Packet.refreshCharacter(mCharacterType, mNo, mX, mY, mDirection));
			return;
		}
		switch (type) {
			case DOWN:
				turnDown();
				break;

			case LEFT:
				turnLeft();
				break;

			case RIGHT:
				turnRight();
				break;

			case UP:
				turnUp();
				break;

			default:
		}
	}

	// 슬롯 불러오기
	public void loadSlot() {
		try {
			ResultSet rs = DataBase.executeQuery("SELECT * FROM `slot` WHERE `no` = '" + mNo + "';");
			if (!rs.next()) {
				DataBase.executeUpdate("INSERT `slot` SET `no` = '" + mNo + "';");
			} else {
				// 슬롯 칸 개수
				final int slotSize = 10;
				for (int i = 0; i < slotSize; ++i) {
					final int nowSlot = rs.getInt("slot" + i);
					mCtx.writeAndFlush(Packet.setSlot(i, nowSlot));
					if (nowSlot != -1) {
						final SkillData nowSkill = GameData.getSkills().get(findSkillByIndex(nowSlot).getNo());
						mCoolTime.initCoolTime(i, nowSkill.getDelay(), nowSkill.getNo());
					}
				}
			}
			rs.close();
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public void setSlot(int index, int itemIndex) {
		final SkillData selectedSkill = GameData.getSkills().get(findSkillByIndex(itemIndex).getNo());
		if (selectedSkill.getLimitLevel() > mLevel) {
			return;
		}
		DataBase.setSlot(this, index, itemIndex);
		mCoolTime.initCoolTime(index, selectedSkill.getDelay(), selectedSkill.getNo());
		loadSlot();
	}

	public void delSlot(int index) {
		DataBase.delSlot(this, index);
		loadSlot();
	}

	// 게임 종료
	public void exitGracefully() {
		// 거래중이라면 거래 종료
		if (nowTrading()) {
			cancelTrade();
		}
		// 파티 가입중이라면 파티 탈퇴
		if (nowJoinParty()) {
			if (mPartyNo == mNo) {
				breakUpParty();
			} else {
				quitParty();
			}
		}
		// 맵에서 나가기
		Map.getMap(mMap).getField(mSeed).removeUser(this);
		// 유저 정보 업데이트
		DataBase.updateUser(this);
		// 장착 아이템 정보 업데이트
		DataBase.updateEquip(this);
		// 아이템과 스킬을 지운다
		DataBase.deleteItem(mNo);
		DataBase.deleteSkill(mNo);
		// 가진 아이템과 스킬을 넣자
		for (Item item : mItemBagHashtable.values()) {
			DataBase.insertItem(item);
		}
		for (GameData.Skill skill : mSkillBagHashtable.values()) {
			DataBase.insertSkill(skill);
		}
	}

	public class Message {
		private int mNpcNo;
		private int mNpcMessage;
		private int mNpcSelect;
		private int mMySelect;

		// 대화 중 여부
		public boolean isStart() {
			return mNpcNo > 0;
		}

		// 현재 대화중인 NPC
		public int getNpc() {
			return mNpcNo;
		}

		// 현재 메시지
		public int getMessage() {
			return mNpcMessage;
		}

		// 선택한 선택지
		public int getSelect() {
			return mMySelect;
		}

		// 대화 시작
		public void open(int npcNo, int npcSelect) {
			mNpcNo = npcNo;
			mNpcMessage = 0;
			mNpcSelect = npcSelect;
			mCtx.writeAndFlush(Packet.openMessageWindow(mNpcNo, mNpcMessage, mNpcSelect));
		}

		// 대화 종료
		public void close() {
			mNpcNo = 0;
			mCtx.writeAndFlush(Packet.closeMessageWindow());
		}

		// 대화 진행
		public void update(int message, int select) {
			mNpcMessage = message;
			mNpcSelect = select;
			mCtx.writeAndFlush(Packet.openMessageWindow(mNpcNo, mNpcMessage, mNpcSelect));
		}
	}

	class CoolTime
	{
		private Vector<int[]> mSlot = new Vector<>();
		private int mBasicAttack;
		private int mGlobal;

		public CoolTime() {
			for (int i = 0; i < 10; ++i) {
				int[] a = new int[3];
				mSlot.add(i, a);
			}
		}

		public int getSkillNo(int index) {
			return mSlot.get(index - 1)[0];
		}

		public int getBasicAttack() {
			return mBasicAttack;
		}

		public void setBasicAttack(int iValue) {
			mBasicAttack = iValue;
		}

		public void setGlobal(int value) {
			mGlobal = value;
		}

		public int getGlobal() {
			return mGlobal;
		}

		public void initCoolTime(int index, int value, int no) {
			mSlot.get(index)[0] = no;
			mSlot.get(index)[1] = 0;
			mSlot.get(index)[2] = value;
			mCtx.writeAndFlush(Packet.setCoolTime(mSlot.get(index)[1], mSlot.get(index)[2], index));
		}

		public int getCoolTime(int no) {
			for (int i = 0; i < 10; ++i) {
				if (mSlot.get(i)[0] == no) {
					return mSlot.get(i)[1];
				}
			}
			return -1;
		}

		public void setCoolTime(int value, int no) {
			for (int i = 0; i < 10; ++i) {
				if (mSlot.get(i)[0] == no) {
					mSlot.get(i)[1] = value;
					mCtx.writeAndFlush(Packet.setCoolTime(mSlot.get(i)[1], mSlot.get(i)[2], i));
				}
			}
		}

		public void coolDown() {
			for (int i = 0; i < 10; ++i) {
				if (mSlot.get(i)[1] > 0) {
					--mSlot.get(i)[1];
					mCtx.writeAndFlush(Packet.setCoolTime(mSlot.get(i)[1], mSlot.get(i)[2], i));
				}
			}
			if (mBasicAttack > 0) {
				--mBasicAttack;
			}
			if (mGlobal > 0) {
				--mGlobal;
			}
		}
	}
}