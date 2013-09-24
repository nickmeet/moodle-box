include_recipe "mysql::server"
include_recipe "mysql::ruby"
include_recipe "apache2::mod_php5"
%w[
  aspell
  git
  graphviz

  php5-curl
  php5-gd
  php5-intl
  php5-mysql
  php5-mcrypt
  php5-xmlrpc
].each{|p| package(p) }

### Local vars ###
moodle_version = '2.5'
moodle_dir = "moodle-#{moodle_version}"

## Prepare
mysql_database node.moodle['database'] do
  connection :host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']
  encoding 'UTF8'
  action :create
end

directory node.moodle.data_dir do
  owner 'www-data'
  group 'www-data'
  mode 0777
end

###
###  WARNING: vboxfs is really clunky and fails in many ways. There is a reason
###           why I'm not working directly in the /vagrant folder.
###

git "moodle" do
    repository "git://git.moodle.org/moodle.git"
    reference "MOODLE_25_STABLE"
    action :checkout
    destination "/usr/local/moodle"
end

# install.php doesn't create the config.php file when run in /vagrant
bash "configure-moodle" do
  cwd "/usr/local/moodle"
  code <<-CODE
    set -e
    sudo sed -i '/post_max_size/ s/8M/50M/' /etc/php5/apache2/php.ini
    sudo sed -i '/upload_max_filesize/ s/2M/50M/' /etc/php5/apache2/php.ini
    sudo sed -i '/max_execution_time/ s/30/600/' /etc/php5/apache2/php.ini
    chmod a+w .
    sudo -u www-data /usr/bin/php admin/cli/install.php \
      --non-interactive \
      --lang=en \
      --wwwroot=http://128.178.146.104:8081 \
      --dataroot=#{node.moodle['data_dir']} \
      --dbuser=root \
      --dbpass="#{node['mysql']['server_root_password']}" \
      --adminuser=admin \
      --adminpass=adminpass \
      --fullname="TestSite" \
      --shortname="test" \
      --agree-license > #{node.moodle['data_dir']}/php-install.log 2>&1
    chmod 644 config.php
    chmod 755 .
  CODE
  creates '/usr/local/moodle/config.php'
end

# tar claims /vagrant is read-only when unpacking
# so we move all this afterwards
# bash "move-to-vagrant" do
#   source = "/usr/local/#{moodle_dir}"
#   target = "/vagrant/#{moodle_dir}"
#   code <<-CODE
#     set -e
#     if [ -d #{target} ]; then
#       # Already exists. Instead we're going to re-provision the DB
#       sudo -u www-data /usr/bin/php #{target}/admin/cli/install_database.php
#     else
#       cp -r #{source} /vagrant
#     fi
#     rm -rf #{source}
#     ln -s #{target} #{source}
#   CODE
#   only_if { File.directory?('/vagrant') && File.directory?("/usr/local/#{moodle_dir}") }
# end

cron "moodle-maintenance" do
  minute '*/15'
  user 'www-data'
  command "/usr/bin/php /usr/local/moodle/admin/cli/cron.php"
end

apache_site 'default' do
  enable false
end

web_app 'moodle' do
  template 'moodle.conf.erb'
end
