package database;

import java.util.HashMap;

public class Type {
    public enum Character {
        USER(0),
        NPC(1),
        ENEMY(2);

        private static HashMap<Integer, Character> caches;

        private final int mValue;

        Character(final int value) {
            mValue = value;
        }

        public static Character fromInt(final int value) {
            if (caches == null) {
                caches = new HashMap<>();
                for (Character cache : values()) {
                    caches.put(cache.mValue, cache);
                }
            }
            return caches.get(value);
        }

        public int getValue() {
            return mValue;
        }
    }

    public enum Enemy {
        PRACTICE(0),
        PACIFISM(1),
        CAUTIOUS(2),
        PROTECTIVE(3),
        AGGRESSIVE(4),
        UNBEATABLE(5),
        TRAP(6);

        private static HashMap<Integer, Enemy> caches;

        private final int mValue;

        Enemy(final int value) {
            mValue = value;
        }

        public static Enemy fromInt(final int value) {
            if (caches == null) {
                caches = new HashMap<>();
                for (Enemy cache : values()) {
                    caches.put(cache.mValue, cache);
                }
            }
            return caches.get(value);
        }

        public int getValue() {
            return mValue;
        }
    }

    public enum Direction {
        DOWN(2),
        LEFT(4),
        RIGHT(6),
        UP(8);

        private static HashMap<Integer, Direction> caches;

        private final int mValue;

        Direction(final int value) {
            mValue = value;
        }

        public static Direction fromInt(final int value) {
            if (caches == null) {
                caches = new HashMap<>();
                for (Direction cache : values()) {
                    caches.put(cache.mValue, cache);
                }
            }
            return caches.get(value);
        }

        public int getValue() {
            return mValue;
        }
    }

    public enum Item {
        WEAPON(0),
        SHIELD(1),
        HELMET(2),
        ARMOR(3),
        CAPE(4),
        SHOES(5),
        ACCESSORY(6),
        ITEM(7);

        private static HashMap<Integer, Item> caches;

        private final int mValue;

        Item(final int value) {
            mValue = value;
        }

        public static Item fromInt(final int value) {
            if (caches == null) {
                caches = new HashMap<>();
                for (Item cache : values()) {
                    caches.put(cache.mValue, cache);
                }
            }
            return caches.get(value);
        }

        public int getValue() {
            return mValue;
        }
    }

    public enum Status {
        TITLE(0),
        IMAGE(1),
        JOB(2),
        STR(3),
        DEX(4),
        AGI(5),
        CRITICAL(6),
        AVOID(7),
        HIT(8),
        STAT_POINT(9),
        SKILL_POINT(10),
        HP(11),
        MAX_HP(12),
        MP(13),
        MAX_MP(14),
        LEVEL(15),
        EXP(16),
        MAX_EXP(17),
        GOLD(18),
        WEAPON(19),
        SHIELD(20),
        HELMET(21),
        ARMOR(22),
        CAPE(23),
        SHOES(24),
        ACCESSORY(25);

        private static HashMap<Integer, Status> caches;

        private final int mValue;

        Status(final int value) {
            mValue = value;
        }

        public static Status fromInt(final int value) {
            if (caches == null) {
                caches = new HashMap<>();
                for (Status cache : values()) {
                    caches.put(cache.mValue, cache);
                }
            }
            return caches.get(value);
        }

        public int getValue() {
            return mValue;
        }
    }
}