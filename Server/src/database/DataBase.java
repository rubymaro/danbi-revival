package database;

import game.User;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;

public class DataBase {
	private static final Logger logger = Logger.getLogger(DataBase.class.getName());
	private static Connection connection;

	public static void connect(final String host, final String id, final String pass) throws Exception {
		try {
			Class.forName("com.mysql.jdbc.Driver"); 
			connection = DriverManager.getConnection(host, id, pass);
			logger.info("데이터베이스 연결 완료.");
		} catch (SQLException sqex) {
			logger.warning(sqex.getMessage());
		}
	}
	
	// Select
	public static ResultSet executeQuery(final String query) throws SQLException {
		return connection.createStatement().executeQuery(query);
	}
	
	// Insert
	@SuppressWarnings("UnusedReturnValue")
	public static int executeUpdate(final String query) throws SQLException {
		return connection.createStatement().executeUpdate(query);
	}
	
	public static void insertUser(final String id,
								  final String pass,
								  final String name,
								  final String mail,
								  final String image,
								  final int job,
								  final int map,
								  final int x,
								  final int y,
								  final int level,
								  final int hp)  {
		try {
			StringBuilder sb;
			sb = new StringBuilder(1024);
			sb.append("INSERT `user` SET ")
					.append(queryFormat("id", id)).append(',')
					.append(queryFormat("pass", pass)).append(',')
					.append(queryFormat("name", name)).append(',')
					.append(queryFormat("mail", mail)).append(',')
					.append(queryFormat("image", image)).append(',')
					.append(queryFormat("job", job)).append(',')
					.append(queryFormat("map", map)).append(',')
					.append(queryFormat("x", x)).append(',')
					.append(queryFormat("y", y)).append(',')
					.append(queryFormat("level", level)).append(',')
					.append(queryFormat("hp", hp)).append(';');

			connection.createStatement().executeUpdate(sb.toString());
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void insertEquip(final int userNo) {
		try {
			connection.createStatement().executeUpdate("INSERT INTO `equip` (`user_no`) VALUES ('" + userNo + "');");
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void insertItem(final GameData.Item item) {
		try {
			StringBuilder sb;
			sb = new StringBuilder(1024);
			sb.append("INSERT `item` SET ")
					.append(queryFormat("user_no", item.getUserNo())).append(',')
					.append(queryFormat("item_no", item.getNo())).append(',')
					.append(queryFormat("amount", item.getAmount())).append(',')
					.append(queryFormat("index", item.getIndex())).append(',')
					.append(queryFormat("damage", item.getDamage())).append(',')
					.append(queryFormat("magic_damage", item.getMagicDamage())).append(',')
					.append(queryFormat("defense", item.getDefense())).append(',')
					.append(queryFormat("magic_defense", item.getMagicDefense())).append(',')
					.append(queryFormat("str", item.getStr())).append(',')
					.append(queryFormat("dex", item.getDex())).append(',')
					.append(queryFormat("agi", item.getAgi())).append(',')
					.append(queryFormat("hp", item.getHp())).append(',')
					.append(queryFormat("mp", item.getMp())).append(',')
					.append(queryFormat("critical", item.getCritical())).append(',')
					.append(queryFormat("avoid", item.getAvoid())).append(',')
					.append(queryFormat("hit", item.getHit())).append(',')
					.append(queryFormat("reinforce", item.getReinforce())).append(',')
					.append(queryFormat("trade", item.isTradeable() ? 1 : 0)).append(',')
					.append(queryFormat("equipped", item.isEquipped() ? 1 : 0)).append(';');

			connection.createStatement().executeUpdate(sb.toString());
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void insertSkill(final GameData.Skill skill) {
		try {

			String sb = "INSERT `skill` SET " +
					queryFormat("user_no", skill.getUserNo()) + ',' +
					queryFormat("skill_no", skill.getNo()) + ',' +
					queryFormat("rank", skill.getRank()) + ';';
			connection.createStatement().executeUpdate(sb);
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void insertGuild(final int masterNo, final String guildName) {
		try {

			String sb = "INSERT `guild` SET " +
					queryFormat("master", masterNo) + ',' +
					queryFormat("guild_name", guildName) + ';';
			connection.createStatement().executeUpdate(sb);
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void insertGuildMember(final int guildNo, final int userNo) {
		try {
			connection.createStatement().executeUpdate(
					"INSERT INTO `guild_member` (`guild_no`, `user_no`) VALUES ('" + guildNo + "', '" + userNo + "');");
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void updateUser(final User user) {
		try {

			String sb = "UPDATE `user` SET " +
					queryFormat("title", user.getTitle()) + ',' +
					queryFormat("guild", user.getGuild()) + ',' +
					queryFormat("image", user.getImage()) + ',' +
					queryFormat("job", user.getJob()) + ',' +
					queryFormat("str", user.getPureStr()) + ',' +
					queryFormat("dex", user.getPureDex()) + ',' +
					queryFormat("agi", user.getPureAgi()) + ',' +
					queryFormat("hp", user.getHp()) + ',' +
					queryFormat("mp", user.getMp()) + ',' +
					queryFormat("level", user.getLevel()) + ',' +
					queryFormat("exp", user.getExp()) + ',' +
					queryFormat("gold", user.getGold()) + ',' +
					queryFormat("map", user.getMap()) + ',' +
					queryFormat("x", user.getX()) + ',' +
					queryFormat("y", user.getY()) + ',' +
					queryFormat("direction", user.getDirection()) + ',' +
					queryFormat("speed", user.getMoveSpeed()) + ',' +
					queryFormat("stat_point", user.getStatPoint()) + ',' +
					queryFormat("skill_point", user.getSkillPoint()) + ',' +
					"WHERE " + queryFormat("no", user.getNo()) + ';';
			connection.createStatement().executeUpdate(sb);
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void updateGuildExit(final int userNo) {
		try {

			String sb = "UPDATE `user` SET " +
					queryFormat("guild", 0) +
					" WHERE " + queryFormat("no", userNo) + ';';
			connection.createStatement().executeUpdate(sb);
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}
	
	public static void updateEquip(final User user) {
		try {

			String sb = "UPDATE `equip` SET " +
					queryFormat("weapon", user.getWeapon()) + ',' +
					queryFormat("shield", user.getShield()) + ',' +
					queryFormat("helmet", user.getHelmet()) + ',' +
					queryFormat("armor", user.getArmor()) + ',' +
					queryFormat("cape", user.getCape()) + ',' +
					queryFormat("shoes", user.getShoes()) + ',' +
					queryFormat("accessory", user.getAccessory()) + ',' +
					" WHERE " + queryFormat("user_no", user.getNo()) + ';';
			connection.createStatement().executeUpdate(sb);
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void deleteItem(final int userNo) {
		try {
			connection.createStatement().executeUpdate("DELETE FROM `item` WHERE `user_no` = '" + userNo + "';");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void deleteSkill(final int userNo) {
		try {
			connection.createStatement().executeUpdate("DELETE FROM `skill` WHERE `user_no` = '" + userNo + "';");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void deleteGuild(final int masterNo) {
		try {
			connection.createStatement().executeUpdate("DELETE FROM `guild` WHERE `master` = '" + masterNo + "';");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void deleteGuildMember(final int guildNo, final int userNo) {
		try {
			connection.createStatement().executeUpdate(
					"DELETE FROM `guild_member` WHERE `guild_no` = '" + guildNo + "' AND `user_no` ='" + userNo + "';");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void setSlot(final User user, final int slotIndex, final int index) {
		try {
			ResultSet rs = connection.createStatement().executeQuery("SELECT * FROM `slot` WHERE `no` = '" + user.getNo() + "';");
			if (!rs.next()) {
				connection.createStatement().executeUpdate("INSERT `slot` SET " +
						"`no` = '" + user.getNo() + "';");
				rs.close();
			}
			if (slotIndex < 0 || slotIndex > 9) {
				return;
			}
			for (int i = 0; i < 10; ++i) {
				if (rs.getInt("slot" + i) == index) {
					return;
				}
			}
			String itemType = "slot" + slotIndex;
			connection.createStatement().executeUpdate("UPDATE `slot` SET " +
					"`" + itemType + "` = '" + index + "' " +
					"WHERE `no` = '" + user.getNo() + "';");
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	public static void delSlot(final User user, final int slotIndex) {
		try {
			ResultSet rs = connection.createStatement().executeQuery("SELECT * FROM `slot` WHERE `no` = '" + user.getNo() + "';");
			if (!rs.next()) {
				connection.createStatement().executeUpdate("INSERT `slot` SET " +
						"`no` = '" + user.getNo() + "';");
				rs.close();
			}
			if (slotIndex < 0 || slotIndex > 9) {
				return;
			}
			String itemType = "slot" + slotIndex;
			connection.createStatement().executeUpdate("UPDATE `slot` SET " +
					"`" + itemType + "` = '" + -1 + "' " +
					"WHERE `no` = '" + user.getNo() + "';");
		} catch (SQLException e) {
			logger.warning(e.toString());
		}
	}

	private static String queryFormat(final String field, final Object value) {
		return String.format("`%s` = '%s'", field, value.toString());
	}
}