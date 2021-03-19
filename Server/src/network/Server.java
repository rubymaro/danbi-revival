package network;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;

import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Logger;

import database.DataBase;
import database.GameData;
import game.*;
import config.Config;

public final class Server {
	private static final Logger logger = Logger.getLogger(Server.class.getName());
	private static final int TICK = 100;

    public static void main(final String[] args) throws InterruptedException {
		int port;
    	if (args.length > 0) {
			port = Integer.parseInt(args[0]);
		} else {
			port = Integer.parseInt(Config.getInstance().getProperty("Server.port"));
		}
		run(port);
    }

	private static void run(final int port) throws InterruptedException {
		EventLoopGroup bossGroup = new NioEventLoopGroup();
		EventLoopGroup workerGroup = new NioEventLoopGroup();

        try {
            ServerBootstrap bootStrap = new ServerBootstrap()
            	.group(bossGroup, workerGroup)
            	.channel(NioServerSocketChannel.class)
            	.childHandler(new Initializer())
            	.option(ChannelOption.SO_BACKLOG, 128)
            	.childOption(ChannelOption.SO_KEEPALIVE, true);
            
            logger.info("서버를 시작합니다. (" + port + ")");

            ChannelFuture f = bootStrap.bind(port).sync();
			final Properties properties = Config.getInstance();
            DataBase.connect(String.format("jdbc:mysql://%s/%s?characterEncoding=utf8", properties.getProperty("Database.host"), properties.getProperty("Database.database")),
			     properties.getProperty("Database.username"),
			     properties.getProperty("Database.password"));

			GameData.loadSettings();
            Map.loadMap();

			while (Handler.isRunning) {
				Thread.sleep(TICK);
				for (User user : User.getAll().values()) {
					user.update();
				}
				for (Map map : Map.getAll().values()) {
					map.update();
				}
			}

            f.channel().closeFuture().sync();
        } catch (SQLException throwables) {
			throwables.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
            workerGroup.shutdownGracefully();
            bossGroup.shutdownGracefully();

            bossGroup.terminationFuture().sync();
            workerGroup.terminationFuture().sync();
        }

		Runtime.getRuntime().addShutdownHook(new Thread() {
			public void run() {
				for (User user : User.getAll().values()) {
					user.exitGracefully();
				}
				logger.info("서버를 종료합니다.");
			}
		});
	}
}
