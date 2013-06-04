#
# Cookbook Name:: windows-hostname
# Recipe:: default
#
# Copyright (C) 2013 Shay Bergmann
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'socket'
include_recipe 'windows'

node[:set_fqdn] =~ /^([^.]+)\.(.+)/
hostname = $1
domainname = $2

fqdn = "#{hostname}.#{domainname}"

# On EC2 we have to prevent EC2 Config Service from setting the computer name on boot. Otherwise we end up
# up in a nasty reboot loop...
cookbook_file 'C:\Program Files\Amazon\Ec2ConfigService\Settings\config.xml' do
	source 'config.xml'
	only_if do
		File.exist? 'C:\Program Files\Amazon\Ec2ConfigService\Settings\config.xml'
	end
end

windows_batch 'change_computer_name' do
	ignore_failure true
	code <<-EOH
		netdom computername #{Socket.gethostname} /add:#{fqdn}
		netdom computername #{Socket.gethostname} /makeprimary:#{fqdn}
		netdom computername #{Socket.gethostname} /remove:#{Socket.gethostname}
		netdom computername #{Socket.gethostname} /remove:#{Socket.gethostbyname(Socket.gethostname).first}
		shutdown -r
	EOH
	not_if do
		Socket.gethostbyname(Socket.gethostname).first == "#{hostname}.#{domainname}"
	end
end