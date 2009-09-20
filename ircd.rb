#!/usr/bin/env ruby

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Danopia nor the names of its contributors may be used
#   to endorse or promote products derived from this software without specific
#   prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'yaml'
require 'rubygems'
require 'daemons'

require 'ircserver'
require 'ircchannel'
require 'ircclient'

class ServerConfig
	def self.load(filename)
		@yaml = YAML.load(File.open(filename))
	end
	
	# Shorter way to access data
	def self.method_missing(m, *args, &blck)
		raise ArgumentError, "wrong number of arguments (#{args.length} for 0)" if args.length > 0
		raise NoMethodError, "undefined method '#{m}' for #{self}" unless @yaml.has_key?(m.to_s.gsub('_', '-'))
		@yaml[m.to_s.gsub('_', '-')]
	end
end

# Load the config
ServerConfig.load('rbircd.conf')

# Daemons.daemonize
$server = IRCServer.new(ServerConfig.server_name)
$server.add_listener ServerConfig.listen_host, ServerConfig.listen_port.to_i

$server.debug = true

$server.run
loop do
	sleep 60
	$server.clients.each do |value|
		begin
			value.puts "PING :#{$server.name}"
		rescue => detail
			value.close
			$server.clients.delete(value)
		end	
	end
end
