# io_portalwar::config_properties
#
# Take a hash of potential configuration.properties settings and write them to the file
#
# This class is to allow the setting of arbitrary settings in configuration.properties
# Some use cases:
# 1. Set WebUserID, which the installer forces to PTWEBSERVER regardless of input
# 2. Set the Web Profile after install as the installer does not accept custom values
#
# Updated to lookup io_portalwar::config_properties hash key as part of DPK delivered site_list hash
# This is less correct from Puppet perspective, but keeps more in line with DPK structures, 
# and lowers duplicated hiera data.
#
# @example
#   include io_portalwar::config_properties
class io_portalwar::config_properties (
  $pia_domain_list   = $io_portalwar::pia_domain_list,
){

  notify { 'Updating configuration.properties': }

    $pia_domain_list.each |$domain_name, $pia_domain_info| {
    $ps_cfg_home_dir = $pia_domain_info['ps_cfg_home_dir']


    $site_list   = $pia_domain_info['site_list']
    $site_list.each |$site_name, $site_info| {
      $config     = "${ps_cfg_home_dir}/webserv/${domain_name}/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/${site_name}/configuration.properties"
      # $title = current class name, so hiera data is keyed of class::name under site_list hash, to fit with Oracle DPK
      $properties  = $site_info[$title]

      $properties.each | $setting, $value | {
        ini_setting { "${domain_name}, ${site_name} ${setting} ${value}" :
          ensure  => present,
          path    => $config,
          section => '',
          setting => $setting,
          value   => $value,
        }
      }
    } # end site_list
  } # end pia_domain_list
}
