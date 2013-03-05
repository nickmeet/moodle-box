include_recipe "mysql::server"
include_recipe "mysql::ruby"
include_recipe "apache2::mod_php5"
%w[
  aspell
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

ark "moodle" do
  url "http://downloads.sourceforge.net/project/moodle/Moodle/stable24/moodle-latest-24.tgz?r=&ts=1362482456&use_mirror=heanet"
  version '2.4.1'
end

directory node.moodle['data_dir'] do
  owner 'www-data'
  group 'www-data'
  mode 0777
end

directory '/usr/local/moodle/moodle' do
  owner 'www-data'
  group 'www-data'
  mode 0755
end

bash "configure moodle" do
  user 'www-data'
  cwd '/usr/local/moodle/moodle/admin/cli'
  code <<-CODE
    /usr/bin/php install.php \
      --non-interactive \
      --lang=en \
      --wwwroot=http://localhost:8080 \
      --dataroot=#{node.moodle['data_dir']} \
      --dbuser=root \
      --dbpass=#{node['mysql']['server_root_password']} \
      --adminuser=admin \
      --adminpass=adminpass \
      --fullname="TestSite" \
      --shortname="test" \
      --agree-license
  CODE

  not_if 'test -f /usr/local/moodle/moodle/config.php'
end

apache_site 'default' do
  enable false
end

web_app 'moodle' do
  template 'moodle.conf.erb'
end
