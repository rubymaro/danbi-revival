module Config
  WINDOW_WIDTH = 1920
  WINDOW_HEIGHT = 1080
  FULLSCREEN_LAUNCHING = true
  FILENAME_CURSOR_ICON = "cursor.png"

  RECV_PACKET_MAX_LENGTH = 1024
  REFRESHING_SERVER_CONNECTION_STATE_DELAY_SEC = 7

  ServerInfo = Struct.new(:ip, :port, :name)
  SERVER_INFOS = [
    ServerInfo.new("127.0.0.1", 50000, "루프백 서버"),
    ServerInfo.new("127.0.0.1", 20021, "다람쥐 서버")
  ]

  Font.default_name = "NanumBarunGothic"
end