package game;

import database.GameData;

public class Npc extends Character {
    private final String mFunctionName;

    public Npc(final GameData.NPC npc) {
        mNo = npc.getNo();
        mName = npc.getName();
        mImage = npc.getImage();
        mMap = npc.getMap();
        mX = npc.getX();
        mY = npc.getY();
        mDirection = npc.getDirection();
        mFunctionName = npc.getFunction();
    }

    public String getFunctionName() {
        return mFunctionName;
    }
}
