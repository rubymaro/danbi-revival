package game;

import packet.Packet;
import java.util.Hashtable;
import java.util.Vector;

public class Party {
    private final static Hashtable<Integer, Party> parties = new Hashtable<>();
    
    private final int mMaster;
    private final Vector<Integer> mMembersVector = new Vector<>();

    public Party(int masterNo) {
        mMaster = masterNo;
        join(mMaster);
    }

    public boolean join(int userNo) {
        if (mMembersVector.contains(userNo)) {
            return false;
        }
        User newMember = User.getOrNullByNo(userNo);
        for (Integer member : mMembersVector) {
            User partyMember = User.getOrNullByNo(member);
            partyMember.getCtx().writeAndFlush(Packet.setPartyMember(newMember));
            newMember.getCtx().writeAndFlush(Packet.setPartyMember(partyMember));
        }
        newMember.getCtx().writeAndFlush(Packet.setPartyMember(newMember));

        newMember.setPartyNo(mMaster);
        mMembersVector.addElement(userNo);
        return true;
    }

    public boolean exit(int userNo) {
        if (!mMembersVector.contains(userNo)) {
            return false;
        }
        for (Integer member : mMembersVector) {
            User partyMember = User.getOrNullByNo(member);
            partyMember.getCtx().writeAndFlush(Packet.removePartyMember(userNo));
        }
        User.getOrNullByNo(userNo).setPartyNo(0);
        mMembersVector.removeElement(userNo);
        return true;
    }

    public void breakUp() {
        for (Integer member : mMembersVector) {
            User partyMember = User.getOrNullByNo(member);
            partyMember.setPartyNo(0);
        }
        mMembersVector.clear();
        parties.remove(mMaster);
    }

    public Vector<Integer> getMembers() {
        return mMembersVector;
    }

    public static boolean add(int masterNo) {
        if (parties.containsKey(masterNo)) {
            return false;
        }
        parties.put(masterNo, new Party(masterNo));
        return true;
    }

    public static Party get(int masterNo) {
        if (!parties.containsKey(masterNo)) {
            return null;
        }
        return parties.get(masterNo);
    }
}
