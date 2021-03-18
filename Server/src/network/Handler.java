package network;
import database.Crypto;
import database.Type;
import game.Map;
import game.User;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;

import org.json.simple.JSONObject;

import packet.CTSHeader;
import packet.Packet;
import database.DataBase;
import database.GameData;

public final class Handler extends ChannelInboundHandlerAdapter {
    private static final Logger logger = Logger.getLogger(Handler.class.getName());
	public static boolean isRunning = true;
    
    @Override
	public void channelRead(final ChannelHandlerContext ctx, final Object msg) {
		final User userOrNull = User.getOrNullByContext(ctx);
    	JSONObject packet = (JSONObject) msg;
		CTSHeader ctsHeader = CTSHeader.fromInt(Integer.parseInt(packet.get("header").toString()));
		switch (ctsHeader) {
			case LOGIN:
				{
					final String id = packet.get("id").toString().trim();
					final String password = packet.get("password").toString().trim();

					if (id.equals("") || password.equals("")) {
						return;
					}

					try {
						ResultSet rs = DataBase.executeQuery("SELECT * FROM `user` WHERE `id` = '" + id + "';");

						if (rs.next()) {
							final String encryptedPassword = Crypto.encrypt(password);
							if (encryptedPassword.equals(rs.getString("password"))) {
								// 먼저 접속중인 계정이 있다면
								if (User.getOrNullByNo(rs.getInt("no")) != null) {
									// TODO 강제 종료
									return;
								}

								// 로그인 처리
								User user = new User(ctx, rs);
								User.put(ctx, user);

								ctx.writeAndFlush(Packet.loginMessage(user));
								Map.getMap(user.getMap()).getField(user.getSeed()).addUser(user);
								user.loadData();
							} else {
								ctx.writeAndFlush(Packet.loginMessage(1));
							}
						} else {
							ctx.writeAndFlush(Packet.loginMessage(1));
						}

						rs.close();
					} catch (SQLException e) {
						// SQL Error
						ctx.writeAndFlush(Packet.loginMessage(2));
						logger.warning(e.toString());
					}
				}
				break;

	    	case REGISTER:
	    		{
					// 가입 정보를 읽어온다
					String readID = (String) packet.get("id");
					String readPass = (String) packet.get("password");
					String readName = (String) packet.get("name");
					String readMail = (String) packet.get("mail");
					int readNo = (int) packet.get("no");
					if (readID.equals("") || readPass.equals("") || readName.equals("") || readMail.equals("")) {
						return;
					}
					// 직업 리스트에 없는 직업일 경우
					if (!GameData.getRegisters().containsKey(readNo)) {
						return;
					}
					try {
						// 아이디로 검색
						ResultSet rs = DataBase.executeQuery("SELECT * FROM `user` WHERE `id` = '" + readID + "';");
						if (rs.next()) {
							ctx.writeAndFlush(Packet.registerMessage(1));
							rs.close();
							return;
						}
						// 닉네임으로 검색
						rs = DataBase.executeQuery("SELECT * FROM `user` WHERE `name` = '" + readName + "';");
						if (rs.next()) {
							ctx.writeAndFlush(Packet.registerMessage(2));
							rs.close();
							return;
						}
						rs.close();
					} catch (SQLException e) {
						// SQL Error
						ctx.writeAndFlush(Packet.loginMessage(3));
						logger.warning(e.toString());
						return;
					}
					// 비밀번호를 암호화
					readPass = Crypto.encrypt(readPass);
					// 직업 정보 불러오기
					GameData.Register r = GameData.getRegisters().get(readNo);
					GameData.Job j = GameData.getJobs().get(r.getJob());
					// 데이터베이스에 넣자
					DataBase.insertUser(readID, readPass, readName, readMail, r.getImage(), r.getJob(), r.getMap(), r.getX(), r.getY(), r.getLevel(), j.getHp());
					ctx.writeAndFlush(Packet.registerMessage(0));
				}
				break;

			case MOVE_CHARACTER:
				assert userOrNull != null;
				userOrNull.move(Type.Direction.fromInt((int) packet.get("type")));
				break;

			case TURN_CHARACTER:
				assert userOrNull != null;
				userOrNull.turn(Type.Direction.fromInt((int) packet.get("type")));

				break;

	    	case REMOVE_EQUIP_ITEM:
				assert userOrNull != null;
				userOrNull.equipItem(Type.Item.fromInt((int) packet.get("type")), 0);

				break;

	    	case USE_STAT_POINT:
				assert userOrNull != null;
				userOrNull.useStatPoint(Type.Status.fromInt((int) packet.get("type")));

				break;

			case ACTION:
				assert userOrNull != null;
				userOrNull.action();

				break;

			case USE_ITEM:
				assert userOrNull != null;
				userOrNull.useItemByIndex((int) packet.get("index"), (int) packet.get("amount"));

				break;

			case USE_SKILL:
				assert userOrNull != null;
				userOrNull.useSkill((int) packet.get("no"));

				break;

			case DROP_ITEM:
				assert userOrNull != null;
				userOrNull.dropItemByIndex((int) packet.get("index"), (int) packet.get("amount"));

				break;

			case DROP_GOLD:
				assert userOrNull != null;
				userOrNull.dropGold((int) packet.get("amount"));

				break;

			case PICK_ITEM:
				assert userOrNull != null;
				userOrNull.pickItem();

				break;

			case CHAT_NORMAL:
				assert userOrNull != null;
				userOrNull.chatNormal((String) packet.get("message"));

				break;

			case CHAT_WHISPER:
				assert userOrNull != null;
				userOrNull.chatWhisper((String) packet.get("to"), (String) packet.get("message"));

				break;

			case CHAT_PARTY:
				assert userOrNull != null;
				userOrNull.chatParty((String) packet.get("message"));

				break;

			case CHAT_GUILD:
				assert userOrNull != null;
				userOrNull.chatGuild((String) packet.get("message"));

				break;

			case CHAT_ALL:
				assert userOrNull != null;
				userOrNull.chatAll((String) packet.get("message"));

				break;

            case CHAT_BALLOON_START:
				assert userOrNull != null;
				userOrNull.startShowingBalloon();

                break;

	    	case OPEN_REGISTER_WINDOW:
				ctx.writeAndFlush(Packet.openRegisterWindow());
				break;

	    	case CHANGE_ITEM_INDEX:
				assert userOrNull != null;
				userOrNull.changeItemIndex((int) packet.get("index1"), (int) packet.get("index2"));

				break;

			case REQUEST_TRADE:
				assert userOrNull != null;
				userOrNull.requestTrade((int) packet.get("partner"));

				break;

			case RESPONSE_TRADE:
				assert userOrNull != null;
				userOrNull.responseTrade((int) packet.get("type"), (int) packet.get("partner"));

				break;

			case LOAD_TRADE_ITEM:
				assert userOrNull != null;
				userOrNull.loadTradeItem((int) packet.get("index"), (int) packet.get("amount"), (int) packet.get("tradeIndex"));

				break;

			case DROP_TRADE_ITEM:
				assert userOrNull != null;
				userOrNull.dropTradeItem((int) packet.get("index"));

				break;

			case CHANGE_TRADE_GOLD:
				assert userOrNull != null;
				userOrNull.changeTradeGold((int) packet.get("amount"));

				break;

			case FINISH_TRADE:
				assert userOrNull != null;
				userOrNull.acceptTrade();

				break;

			case CANCEL_TRADE:
				assert userOrNull != null;
				userOrNull.cancelTrade();

				break;

			case SELECT_MESSAGE:
				assert userOrNull != null;
				userOrNull.updateMessage((int) packet.get("select"));

				break;

			case CREATE_PARTY:
				assert userOrNull != null;
				userOrNull.createParty();

				break;

			case INVITE_PARTY:
				assert userOrNull != null;
				userOrNull.inviteParty((int) packet.get("other"));

				break;

			case RESPONSE_PARTY:
				assert userOrNull != null;
				userOrNull.responseParty((int) packet.get("type"), (int) packet.get("partyNo"));

				break;

			case QUIT_PARTY:
				assert userOrNull != null;
				userOrNull.quitParty();

				break;

			case KICK_PARTY:
				assert userOrNull != null;
				userOrNull.kickParty((int) packet.get("member"));

				break;

			case BREAK_UP_PARTY:
				assert userOrNull != null;
				userOrNull.breakUpParty();

				break;

			case CREATE_GUILD:
				assert userOrNull != null;
				userOrNull.createGuild((String) packet.get("name"));

				break;

			case INVITE_GUILD:
				assert userOrNull != null;
				userOrNull.inviteGuild((int) packet.get("other"));

				break;

			case RESPONSE_GUILD:
				assert userOrNull != null;
				userOrNull.responseGuild((int) packet.get("type"), (int) packet.get("guildNo"));

				break;

			case QUIT_GUILD:
				assert userOrNull != null;
				userOrNull.quitGuild();

				break;

			case KICK_GUILD:
				assert userOrNull != null;
				userOrNull.kickGuild((int) packet.get("member"));

				break;

			case BREAK_UP_GUILD:
				assert userOrNull != null;
				userOrNull.breakUpGuild();

				break;

			case BUY_SHOP_ITEM:
				assert userOrNull != null;
				userOrNull.buyShopItem((int) packet.get("shopNo"), (int) packet.get("index"), (int) packet.get("amount"));

				break;

			case SET_SLOT:
				assert userOrNull != null;
				userOrNull.setSlot((int) packet.get("index"), (int) packet.get("item_index"));

				break;

			case DEL_SLOT:
				assert userOrNull != null;
				userOrNull.delSlot((int) packet.get("index"));

				break;

			default:
				assert(false) : "Invalid CTSHeader";
				logger.warning("Invalid CTSHeader");
    	}
    }

    @Override
	public void channelRegistered(final ChannelHandlerContext ctx) {
		logger.info(ctx.channel().remoteAddress().toString() + " 접속");
    }
    
    @Override
	public void channelUnregistered(final ChannelHandlerContext ctx) {
		User.remove(ctx);
		logger.info(ctx.channel().remoteAddress().toString() + " 접속 해제");
    }
    
    @Override
    public void exceptionCaught(final ChannelHandlerContext ctx, final Throwable cause) {
		ctx.fireExceptionCaught(cause);
	}
}