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

mysql_database node.moodle['database'] do
  connection :host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']
  encoding 'UTF8'
  action :create
end

moodle_version = '2.4.1'

ark "moodle" do
  url "http://downloads.sourceforge.net/project/moodle/Moodle/stable24/moodle-latest-24.tgz?r=&ts=1362482456&use_mirror=heanet"
  version moodle_version
end

directory node.moodle.data_dir do
  owner 'www-data'
  group 'www-data'
  mode 0777
end

bash "configure-moodle" do
  cwd "/usr/local/moodle/moodle"
  code <<-CODE
    set -e
    chmod a+w .
    sudo -u www-data /usr/bin/php admin/cli/install.php \
      --non-interactive \
      --lang=en \
      --wwwroot=#{node.moodle['url']} \
      --dataroot=#{node.moodle['data_dir']} \
      --dbuser=root \
      --dbpass=#{node['mysql']['server_root_password']} \
      --adminuser=admin \
      --adminpass=adminpass \
      --fullname="TestSite" \
      --shortname="test" \
      --agree-license
    chmod 644 config.php
    chmod 755 .
  CODE

  not_if 'test -f /usr/local/moodle/moodle/config.php'
end

# tar claims /vagrant is read-only when unpacking
# so we move all this afterwards
moodle_dir = "moodle-#{moodle_version}"
bash "move-to-vagrant" do
  code <<-CODE
    set -e
    cp -r /usr/local/#{moodle_dir} /vagrant
    rm -rf /usr/local/#{moodle_dir}
    ln -s /vagrant/#{moodle_dir} /usr/local/#{moodle_dir}
  CODE
  only_if do
    File.directory?("/vagrant") && ! File.directory?("/vagrant/#{moodle_dir}")
  end
end

cron "moodle-maintenance" do
  minute '*/15'
  user 'www-data'
  command "/usr/bin/php /usr/local/moodle/moodle/admin/cli/cron.php"
end

apache_site 'default' do
  enable false
end

web_app 'moodle' do
  template 'moodle.conf.erb'
end
