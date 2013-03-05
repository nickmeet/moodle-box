name             "moodle-box"
maintainer       "Jonas Pfenniger"
maintainer_email "jonas@mediacore.com"
license          "MIT"
description      "Moodle vagrant box for testing"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"
%w[
  ark
  apache2
  database
  mysql
].each { |cb| depends cb }

supports 'ubuntu'
