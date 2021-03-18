class Network
  def initialize
    @tcp_socket = nil
    @number_of_solo_brace = 0
    @buffer = ""
  end

  def connect(server_info)
    disconnect
    @tcp_socket = TCPSocket.new(server_info.ip, server_info.port)
  end

  def disconnect
    if nil != @tcp_socket
      @tcp_socket.close
      @tcp_socket = nil
      @number_of_solo_brace = 0
      @buffer = ""
    end
  end

  def send(hash)
    json = HTTPLite::JSON.stringify(hash)
    length_header = [json.length].pack("N")
    packet = length_header + json
    puts "[S end](#{packet.length}) " + packet
    @tcp_socket.write(packet + "\n")
    @tcp_socket.flush
  end

  def update
    begin
      chunk = @tcp_socket.read_nonblock(Config::RECV_PACKET_MAX_LENGTH)
      while chunk.length > 0
        is_json_matched = false
        for i in 0...chunk.length
          case chunk[i]
          when '{'
            @number_of_solo_brace += 1
          when '}'
            @number_of_solo_brace -= 1
            is_json_matched = (0 == @number_of_solo_brace)
            if is_json_matched
              @buffer << chunk[0..i]
              puts "[R ecv](#{@buffer.length}) " << @buffer
              PacketHandler.process(HTTPLite::JSON.parse(@buffer))
              @buffer = ""
              chunk = chunk[i + 1..-1]
              break
            end
          end
        end
        if !is_json_matched
          @buffer << chunk
          chunk = ""
        end
      end

    rescue IO::WaitReadable
      putc '.'
    end
  end

  def has_socket?
    return nil != @tcp_socket
  end
end