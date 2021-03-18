package game;

import database.DataBase;
import packet.Packet;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Vector;
import java.util.logging.Logger;

public class Guild {
    private static final Logger logger = Logger.getLogger(Guild.class.getName());
    private static final Hashtable<Integer, Guild> guilds = new Hashtable<>();

    private final int mMaster;
    private final String mName;
    private final Vector<Integer> mMembersVector = new Vector<>();

    public Guild(int master, String name) {
        mMaster = master;
        mName = name;
        join(master);
        DataBase.insertGuild(master, name);
    }

    public Guild(int master, String name, boolean loading) {
        mMaster = master;
        mName = name;
        if (!loading) {
            join(master);
        }
    }

    public int getMaster() {
        return mMaster;
    }

    public String getName() {
        return mName;
    }

    public Vector<Integer> getMembers() {
        return mMembersVector;
    }

    public static void load() throws SQLException {
        ResultSet rs = DataBase.executeQuery("SELECT * FROM `guild`;");
        while (rs.next()) {
            int masterNo = rs.getInt("master");
            String guildName = rs.getString("guild_name");
            Guild guild = new Guild(masterNo, guildName, true);
            ResultSet memberRs = DataBase.executeQuery("SELECT * FROM `user` WHERE `guild` = '" + masterNo +"';");
            while (memberRs.next()) {
                guild.mMembersVector.addElement(memberRs.getInt("no"));
            }
            memberRs.close();
            guilds.put(masterNo, guild);
        }
        rs.close();
        logger.info("길드 정보 로드 완료.");
    }

    public static boolean add(int masterNo, String name) {
        if (guilds.containsKey(masterNo)) {
            return false;
        }
        guilds.put(masterNo, new Guild(masterNo, name));
        return true;
    }

    public static Guild get(int masterNo) {
        if (!guilds.containsKey(masterNo)) {
            return null;
        }
        return guilds.get(masterNo);
    }

    public boolean join(int userNo) {
        if (mMembersVector.contains(userNo)) {
            return false;
        }
        User newMember = User.getOrNullByNo(userNo);
        for (Integer member : mMembersVector) {
            User guildMember = User.getOrNullByNo(member);
            guildMember.getCtx().writeAndFlush(Packet.setGuildMember(newMember));
            newMember.getCtx().writeAndFlush(Packet.setGuildMember(guildMember));
        }
        newMember.getCtx().writeAndFlush(Packet.setGuildMember(newMember));
        newMember.setGuild(mMaster);
        mMembersVector.addElement(userNo);
        DataBase.insertGuildMember(mMaster, userNo);
        return true;
    }

    public boolean exit(int userNo) {
        if (!mMembersVector.contains(userNo)) {
            return false;
        }
        for (Integer member : mMembersVector) {
            User guildMember = User.getOrNullByNo(member);
            if (guildMember != null) {
                guildMember.getCtx().writeAndFlush(Packet.removeGuildMember(userNo));
            }
        }
        User exitUser = User.getOrNullByNo(userNo);
        if (exitUser != null) {
            exitUser.setGuild(0);
        } else {
            DataBase.updateGuildExit(userNo);
        }
        mMembersVector.removeElement(userNo);
        DataBase.deleteGuildMember(mMaster, userNo);
        return true;
    }

    public void breakUp() {
        for (Integer member : mMembersVector) {
            User guildMember = User.getOrNullByNo(member);
            guildMember.setGuild(0);
        }
        mMembersVector.clear();
        guilds.remove(mMaster);
    }
}