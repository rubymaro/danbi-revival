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
      is_matched = false
      chunk = @tcp_socket.read_nonblock(Config::RECV_PACKET_MAX_LENGTH)
      for i in 0...chunk.length
        case chunk[i]
        when '{'
          @number_of_solo_brace += 1
        when '}'
          @number_of_solo_brace -= 1
          is_matched = (0 == @number_of_solo_brace)
          if is_matched
            @buffer << chunk[0..i]
            puts "[R ecv](#{@buffer.length}) " << @buffer
            PacketHandler.process(HTTPLite::JSON.parse(@buffer))
            if i + 1 < chunk.length
              @buffer = chunk[i + 1..-1]
            else
              @buffer = ""
            end
          end
        end
      end
      if !is_matched
        @buffer << chunk
      end

    rescue IO::WaitReadable
      #putc '.'
    end
  end

  def has_socket?
    return nil != @tcp_socket
  end
end