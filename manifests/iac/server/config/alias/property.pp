# Define: scriptura::server::config::alias::property
#
# You need to specify the property title as the name of the XML tag element
# e.g. property0, property1, ...
#
# Sample Usage:
#
# scriptura::server::config::alias::property { 'property0':
#   version      => '7.3.24-1.cgk.el6',
#   config_alias => 'alias0',
#   type         => 'string',
#   name         => 'com.id.scriptura.jms.configuration.session.alias.broker',
#   value        => 'sonic-mq'
# }
#
define scriptura::server::config::alias::property(
  $version = undef,
  $config_alias = undef,
  $type = undef,
  $name = undef,
  $value = ''
){

  if ($type == undef or $name == undef) {
    fail("Scriptura::Server::Config::Alias[${config_alias}]::Property[${title}]: parameters version, config_alias, type, name and value must be defined")
  }

  $scriptura_version_withoutrelease = regsubst($version, '^(\d+\.\d+\.\d+)-\d+\..*$', '\1')
  $scriptura_major_minor_version = regsubst($scriptura_version_withoutrelease, '^(\d+\.\d+).\d+$', '\1')
  $scriptura_config_location = "/data/scriptura/scriptura-${scriptura_major_minor_version}/configuration"

  if ($value == undef or $value == '') {
    $set_properties_value = " #empty"
  } else {
    $set_properties_value = "/#text ${value}"
  }

  augeas { "scriptura/configuration/aliases/${config_alias}/properties/${title}/add" :
    lens    => 'Xml.lns',
    incl    => "${scriptura_config_location}/configuration.xml",
    context => "/files/${scriptura_config_location}/configuration.xml",
    changes => [
      "set config/aliases/${config_alias}/properties/${title}/type/#text ${type}",
      "set config/aliases/${config_alias}/properties/${title}/name/#text ${name}",
      "set config/aliases/${config_alias}/properties/${title}/value${set_properties_value}"
    ],
    onlyif  => "match config/aliases/${config_alias}/properties/${title}/name/#text[. = \"${name}\"] size == 0"
  }

}
