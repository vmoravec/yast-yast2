# encoding: utf-8

# ***************************************************************************
#
# Copyright (c) 2002 - 2014 Novell, Inc.
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#
# ***************************************************************************
#
# File:	modules/SuSEFirewallServices.rb
# Package:	Firewall Services, Ports Aliases.
# Summary:	Definition of Supported Firewall Services and Port Aliases.
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# Global Definition of Firewall Services
# Defined using TCP, UDP and RPC ports and IP protocols and Broadcast UDP
# ports. Results are cached, so repeating requests are answered faster.

require "yast"

module Yast
  class SuSEFirewalServiceNotFound < StandardError
    def initialize message
      super message
    end
  end

  class SuSEFirewallServicesClass < Module
    include Yast::Logger

    # this is how services defined by package are distinguished
    DEFINED_BY_PKG_PREFIX = "service:"

    SERVICES_DIR = "/etc/sysconfig/SuSEfirewall2.d/services/"

    # please, check it with configuration in refresh-srv-def-by-pkgs-trans.sh script
    SERVICES_TEXTDOMAIN = "firewall-services"

    DEFAULT_SERVICE = {
      "tcp_ports"       => [],
      "udp_ports"       => [],
      "rpc_ports"       => [],
      "ip_protocols"    => [],
      "broadcast_ports" => [],
      "name"            => "",
      "description"     => "",
    }

    READ_ONLY_SERVICE_FEATURES = ["name", "description"]

    IGNORED_SERVICES = ["TEMPLATE", "..", "."]

    def main
      textdomain "base"

      Yast.import "FileUtils"

      #
      # IF YOU NEED TO ADD ANOTHER SERVICE, CREATE THE SERVICE DEFINITION
      # IN A FILE AND ADD IT TO THE PACKAGE TO WHICH IT BELONGS.
      # USE /etc/sysconfig/SuSEfirewall2.d/services/TEMPLATE FOR THAT.
      #
      # MORE INFORMATION IN FEATURE #300687: Ports for SuSEfirewall added via packages.
      # ANOTHER REFERENCE: Bugzilla #246911.
      #
      # See also http://kobliha-suse.blogspot.cz/2008/06/firewall-services-defined-by-packages.html
      #
      #
      # Names assigned to Port and Protocol numbers can be found
      # here:
      #
      # http://www.iana.org/assignments/protocol-numbers
      # http://www.iana.org/assignments/port-numbers
      #
      # Format of SERVICES
      #
      #   "service-id" : $[
      #     "name"            : _("Service Name"),
      #     "tcp_ports"       : list <tcp_ports>,
      #     "udp_ports"       : list <udp_ports>,
      #     "rpc_ports"       : list <rpc_ports>,
      #     "ip_protocols"    : list <ip_protocols>,
      #     "broadcast_ports" : list <broadcast_ports>,
      #   ],
      #
      @services = nil

      # firewall needs restarting
      @sfws_modified = false

      @known_services_features = {
        "TCP"       => "tcp_ports",
        "UDP"       => "udp_ports",
        "RPC"       => "rpc_ports",
        "IP"        => "ip_protocols",
        "BROADCAST" => "broadcast_ports"
      }

      @known_metadata = { "Name" => "name", "Description" => "description" }

      # Services definitions for conversion to the new ones.
      @OLD_SERVICES = {
        "http"         => {
          "tcp_ports"  => ["http"],
          "convert_to" => ["service:apache2", "service:lighttpd"]
        },
        "https"        => {
          "tcp_ports"  => ["https"],
          "convert_to" => ["service:apache2-ssl", "service:lighttpd-ssl"]
        },
        "smtp"         => { "tcp_ports" => ["smtp"], "convert_to" => [] },
        "pop3"         => { "tcp_ports" => ["pop3"], "convert_to" => [] },
        "pop3s"        => { "tcp_ports" => ["pop3s"], "convert_to" => [] },
        "imap"         => {
          "tcp_ports"  => ["imap"],
          "convert_to" => ["service:courier-imapd"]
        },
        "imaps"        => {
          "tcp_ports"  => ["imaps"],
          "convert_to" => ["service:courier-imap-ssl"]
        },
        "samba-server" => {
          "tcp_ports"       => ["netbios-ssn", "microsoft-ds"],
          # TCP: 139, 445
          "udp_ports"       => ["netbios-ns", "netbios-dgm"],
          # UDP: 137, 138
          "broadcast_ports" => ["netbios-ns", "netbios-dgm"],
          # UDP: 137, 138
          "convert_to"      => []
        },
        "ssh"          => {
          "tcp_ports"  => ["ssh"],
          "convert_to" => ["service:sshd"]
        },
        "rsync"        => { "tcp_ports" => ["rsync"], "convert_to" => [] },
        "dhcp-server"  => {
          "udp_ports"       => ["bootps"],
          "broadcast_ports" => ["bootps"],
          "convert_to"      => ["service:dhcp-server"]
        },
        "dhcp-client"  => { "udp_ports" => ["bootpc"], "convert_to" => [] },
        "dns-server"   => {
          "tcp_ports"  => ["domain"],
          "udp_ports"  => ["domain"],
          "convert_to" => ["service:bind"]
        },
        "nfs-client"   => {
          "rpc_ports"  => ["portmap", "status", "nlockmgr"],
          "convert_to" => ["service:nfs-client"]
        },
        "nfs-server"   => {
          "rpc_ports"  => [
            "portmap",
            "status",
            "nlockmgr",
            "mountd",
            "nfs",
            "nfs_acl"
          ],
          "convert_to" => []
        },
        "nis-client"   => {
          "rpc_ports"  => ["portmap", "ypbind"],
          "convert_to" => ["service:ypserv"]
        },
        "nis-server"   => {
          "rpc_ports"  => [
            "portmap",
            "ypserv",
            "fypxfrd",
            "ypbind",
            "yppasswdd"
          ],
          "convert_to" => []
        },
        # Default SUSE installation
        "vnc"          => {
          "tcp_ports"  => ["5801", "5901"],
          "convert_to" => []
        },
        "tftp"         => { "udp_ports" => ["tftp"], "convert_to" => [] },
        # Internet Printing Protocol as a Server
        "ipp-tcp"      => {
          "tcp_ports"  => ["ipp"],
          "convert_to" => []
        },
        # Internet Printing Protocol as a Client
        # IPP Client needs to listen for broadcast messages
        "ipp-udp"      => {
          "udp_ports"       => ["ipp"],
          "broadcast_ports" => ["ipp"],
          "convert_to"      => []
        },
        "ntp-server"   => {
          "udp_ports"       => ["ntp"],
          "broadcast_ports" => ["ntp"],
          "convert_to"      => ["service:ntp"]
        },
        "ldap"         => {
          "tcp_ports"  => ["ldap"],
          "convert_to" => ["service:openldap"]
        },
        "ldaps"        => { "tcp_ports" => ["ldaps"], "convert_to" => [] },
        "ipsec"        => {
          "udp_ports"    => ["isakmp", "ipsec-nat-t"],
          "ip_protocols" => ["esp"],
          "convert_to"   => []
        },
        "slp-daemon"   => {
          "tcp_ports"       => ["svrloc"],
          "udp_ports"       => ["svrloc"],
          "broadcast_ports" => ["svrloc"],
          "convert_to"      => []
        },
        # See bug #118200 for more information
        "xdmcp"        => {
          "tcp_ports"       => ["xdmcp"],
          "udp_ports"       => ["xdmcp"],
          "broadcast_ports" => ["xdmcp"],
          "convert_to"      => []
        },
        # See bug #118196 for more information
        "fam"          => {
          "rpc_ports"  => ["sgi_fam"],
          "convert_to" => []
        },
        # requested by thofmann
        "open-pbs"     => {
          # /etc/services says: The following entries are invalid, but needed
          "tcp_ports"  => [
            "pbs",
            "pbs_mom",
            "pbs_resmom",
            "pbs_sched"
          ],
          "udp_ports"  => ["pbs_resmom"],
          "convert_to" => []
        },
        "mysql-server" => {
          "tcp_ports"  => ["mysql"],
          "convert_to" => ["service:mysql"]
        },
        "iscsi-server" => {
          "tcp_ports"  => ["iscsi-target"],
          "convert_to" => ["service:iscsitarget"]
        }
      }

    end

    # Returns whether the service ID is defined by package.
    # Returns 'false' if it isn't.
    #
    # @param [String] service
    # @return	[Boolean] whether service is defined by package
    #
    # @example
    #	ServiceDefinedByPackage ("http-server") -> false
    #	ServiceDefinedByPackage ("service:http-server") -> true
    def ServiceDefinedByPackage(service)
      service.start_with? DEFINED_BY_PKG_PREFIX
    end

    # Creates a file name from service name defined by package.
    # Service MUST be defined by package, otherwise it returns 'nil'.
    #
    # @param [String] service name (e.g., 'service:abc')
    # @return [String] file name (e.g., 'abc')
    #
    # @example
    #	GetFilenameFromServiceDefinedByPackage ("service:abc") -> "abc"
    #	GetFilenameFromServiceDefinedByPackage ("abc") -> nil
    def GetFilenameFromServiceDefinedByPackage(service)
      if !ServiceDefinedByPackage(service)
        log.error "Service #{service} is not defined by package"
        return nil
      end

      service[/\A#{DEFINED_BY_PKG_PREFIX}(.*)/, 1]
    end

    # Returns SCR Agent definition.
    #
    # @return [Yast::Term] with agent definition
    # @param string full filename path (to read by this agent)
    def GetMetadataAgent(filefullpath)
      term(
        :IniAgent,
        filefullpath,
        {
          "options"  => [
            "global_values",
            "flat",
            "read_only",
            "ignore_case_regexps"
          ],
          "comments" => [
            # jail followed by anything but jail (immediately)
            "^[ \t]*#[^#].*$",
            # jail alone
            "^[ \t]*\#$",
            # (empty space)
            "^[ \t]*$",
            # sysconfig entries
            "^[ \t]*[a-zA-Z0-9_]+.*"
          ],
          "params"   => [
            { "match" => ["^##[ \t]*([^:]+):[ \t]*(.*)[ \t]*$", "%s: %s"] }
          ]
        }
      )
    end

    # Returns service definition.
    # See @services for the format.
    # If `silent` is not defined or set to `true`, function throws an exception
    # SuSEFirewalServiceNotFound if service is not found on disk.
    #
    # @param [String] service name
    # @param [String] (optional) whether to silently return nil
    #                 when service is not found (default false)
    def service_details(service_name, silent = false)
      service = all_services[service_name]
      if service.nil? and !silent
        log.error "Uknown service '#{service_name}'"
        log.info "Known services: #{all_services.keys}"

        raise(
          SuSEFirewalServiceNotFound,
          _("Service with name '%{service_name}' does not exist") % { :service_name => service_name }
        )
      end

      service
    end

    # Returns all known services loaded from disk on-the-fly
    def all_services
      ReadServicesDefinedByRPMPackages() if @services.nil?
      @services
    end

    # Reads definition of services that can be used in FW_CONFIGURATIONS_[EXT|INT|DMZ]
    # in SuSEfirewall2.
    #
    # @return [Boolean] if successful
    def ReadServicesDefinedByRPMPackages
      @services ||= {}

      if !FileUtils.Exists(SERVICES_DIR) ||
          !FileUtils.IsDirectory(SERVICES_DIR)
        log.error "Cannot read #{SERVICES_DIR}"
        return false
      end

      all_definitions = SCR.Read(path(".target.dir"), SERVICES_DIR)
      all_definitions.reject! do |service|
        IGNORED_SERVICES.include?(service)
      end

      service_name = nil
      filefullpath = nil

      # for all files in that directory
      Builtins.foreach(all_definitions) do |filename|
        # "service:abc_server" to distinguis between dynamic definition and the static one
        service_name = DEFINED_BY_PKG_PREFIX + filename
        # Do not read already known services
        next unless @services[service_name].nil?

        filefullpath = SERVICES_DIR + filename
        @services[service_name] = {}

        # Registering sysconfig agent for this file
        if !SCR.RegisterAgent(
            path(".firewall_service_definition"),
            term(:ag_ini, term(:SysConfigFile, filefullpath))
          )
          log.error "Cannot register agent for #{filefullpath}"
          next
        end

        definition = nil
        definition_values = nil

        Builtins.foreach(@known_services_features) do |known_feature, map_key|
          definition = Convert.to_string(
            SCR.Read(
              Builtins.add(path(".firewall_service_definition"), known_feature)
            )
          )
          definition = "" if definition == nil
          # map of services contains list of entries
          definition_values = Builtins.splitstring(definition, " \t\n")
          definition_values = Builtins.filter(definition_values) do |one_value|
            one_value != ""
          end
          @services[service_name][map_key] = definition_values
        end

        # Unregistering sysconfig agent for this file
        SCR.UnregisterAgent(path(".firewall_service_definition"))

        # Fallback for presented service
        @services[service_name]["name"] = _("Service: %{filename}") % { :filename => filename }
        @services[service_name]["description"] = ""

        # Registering sysconfig agent for this file (to get metadata)
        if SCR.RegisterAgent(
            path(".firewall_service_metadata"),
            term(:ag_ini, GetMetadataAgent(filefullpath))
          )
          Builtins.foreach(@known_metadata) do |metadata_feature, metadata_key|
            definition = Convert.to_string(
              SCR.Read(
                Builtins.add(
                  path(".firewall_service_metadata"),
                  metadata_feature
                )
              )
            )
            next if definition.nil? || definition == ""
            # call gettext to translate the metadata
            @services[service_name][metadata_key] = Builtins.dgettext(SERVICES_TEXTDOMAIN, definition)
          end

          SCR.UnregisterAgent(path(".firewall_service_metadata"))
        else
          log.error "Cannot register agent for #{filefullpath} (metadata)"
        end
      end

      true
    end

    # Function returns if the service_id is a known (defined) service
    #
    # @param [String] service_id
    # @return	[Boolean] if is known (defined)
    def IsKnownService(service_id)
      !service_details(service_id, true).nil?
    end

    # Function returns the map of supported (known) services.
    #
    # @return [Hash{String => String}] supported services
    #
    #
    # **Structure:**
    #
    #
    #     	$[ service_id : localized_service_name ]
    #     	$[
    #     	  "dns-server" : "DNS Server",
    #         "vnc" : "Remote Administration",
    #       ]
    def GetSupportedServices
      supported_services = {}

      all_services.each do |service_id, service_definition|
        Ops.set(
          supported_services,
          service_id,
          # TRANSLATORS: Name of unknown service. %1 is a requested service id like nis-server
          Ops.get_string(
            service_definition,
            "name",
            Builtins.sformat(_("Unknown service '%1'"), service_id)
          )
        )
      end

      deep_copy(supported_services)
    end

    # Returns list of service-ids defined by packages.
    #
    # @return [Array<String>] service ids
    def GetListOfServicesAddedByPackage
      all_services.keys
    end

    # Function returns needed TCP ports for service
    #
    # @param [String] service
    # @return	[Array<String>] of needed TCP ports
    def GetNeededTCPPorts(service)
      service_details(service)["tcp_ports"] || []
    end

    # Function returns needed UDP ports for service
    #
    # @param [String] service
    # @return	[Array<String>] of needed UDP ports
    def GetNeededUDPPorts(service)
      service_details(service)["udp_ports"] || []
    end

    # Function returns needed RPC ports for service
    #
    # @param [String] service
    # @return	[Array<String>] of needed RPC ports
    def GetNeededRPCPorts(service)
      service_details(service)["rpc_ports"] || []
    end

    # Function returns needed IP protocols for service
    #
    # @param [String] service
    # @return	[Array<String>] of needed IP protocols
    def GetNeededIPProtocols(service)
      service_details(service)["ip_protocols"] || []
    end

    # Function returns description of a firewall service
    #
    # @param [String] service
    # @return	[String] service description
    def GetDescription(service)
      service_details(service)["description"] || []
    end

    # Sets that configuration was modified
    def SetModified
      @sfws_modified = true

      nil
    end

    # Sets that configuration was not modified
    def ResetModified
      @sfws_modified = false

      nil
    end

    # Returns whether configuration was modified
    #
    # @return [Boolean] modified
    def GetModified
      @sfws_modified
    end

    # Function returns needed ports allowing broadcast
    #
    # @param [String] service
    # @return	[Array<String>] of needed broadcast ports
    def GetNeededBroadcastPorts(service)
      service_details(service)["broadcast_ports"] || []
    end

    # Function returns needed ports and protocols for service.
    # Service needs to be known (installed in the system).
    # Function throws an exception SuSEFirewalServiceNotFound
    # if service is not known (undefined).
    #
    # @param [String] service
    # @return	[Hash{String => Array<String>}] of needed ports and protocols
    #
    # @example
    #	GetNeededPortsAndProtocols ("service:aaa") -> $[
    #		"tcp_ports"       : [ "122", "ftp-data" ],
    #		"udp_ports"       : [ "427" ],
    #		"rpc_ports"       : [ "portmap", "ypbind" ],
    #		"ip_protocols"    : [],
    #		"broadcast_ports" : [ "427" ],
    #	];
    def GetNeededPortsAndProtocols(service)
      DEFAULT_SERVICE.merge(service_details(service))
    end

    # Immediately writes the configuration of service defined by package to the
    # service definition file. Service must be defined by package, this function
    # doesn't work for hard-coded services (SuSEFirewallServices).
    # Function throws an exception SuSEFirewalServiceNotFound
    # if service is not known (undefined) or it is not a service
    # defined by package.
    #
    # @param [String] service ID (e.g., "service:ssh")
    # @param map <string, list <string> > of full service definition
    # @return [Boolean] if successful (nil in case of developer's mistake)
    #
    # @see #IsKnownService()
    # @see #ServiceDefinedByPackage()
    #
    # @example
    #	SetNeededPortsAndProtocols (
    #		"service:something",
    #		$[
    #			"tcp_ports"       : [ "22", "ftp-data", "400:420" ],
    #			"udp_ports"       : [ ],
    #			"rpc_ports"       : [ "portmap", "ypbind" ],
    #			"ip_protocols"    : [ "esp" ],
    #			"broadcast_ports" : [ ],
    #		]
    #	);
    def SetNeededPortsAndProtocols(service, store_definition)
      if !IsKnownService(service)
        log.error "Service #{service} is unknown"
        raise(
          SuSEFirewalServiceNotFound,
          _("Service with name '%{service_name}' does not exist") % { :service_name => service_name }
        )
      end

      # create the filename from service name
      filename = GetFilenameFromServiceDefinedByPackage(service)
      if filename == nil || filename == ""
        log.error "Can't operate with filename '#{filename}' created from '#{service}'"
        return false
      end

      # full path to the filename
      filefullpath = SERVICES_DIR + filename

      if !FileUtils.Exists(filefullpath)
        log.error "File '#{filefullpath}' doesn't exist"
        return false
      end

      # Registering sysconfig agent for that file
      if !SCR.RegisterAgent(
          path(".firewall_service_definition"),
          term(:ag_ini, term(:SysConfigFile, filefullpath))
        )
        log.error "Cannot register agent for #{filefullpath}"
        return false
      end

      ks_features_backward = Builtins.mapmap(@known_services_features) do |sysconfig_id, ycp_id|
        { ycp_id => sysconfig_id }
      end

      write_ok = true

      # we can have this service already in memory
      new_store_definition = deep_copy(store_definition)

      Builtins.foreach(store_definition) do |ycp_id, one_def|
        # Skipping read-only features
        next if READ_ONLY_SERVICE_FEATURES.include? ycp_id

        sysconfig_id = Ops.get(ks_features_backward, ycp_id)
        if sysconfig_id == nil
          log.error "Unknown key '#{ycp_id}'"
          write_ok = false
          next
        end
        one_def = Builtins.filter(one_def) do |one_def_item|
          one_def_item != nil && one_def_item != "" &&
            !Builtins.regexpmatch(one_def_item, "^ *$")
        end
        service_entry_path = Path.new(".firewall_service_definition.#{sysconfig_id}")
        service_entry_value = one_def.join(" ")
        if !SCR.Write(service_entry_path, service_entry_value)
          log.error "Cannot write #{service_entry_value} to #{service_entry_path}",
          write_ok = false
          next
        end
        # new definition of the service
        Ops.set(new_store_definition, ycp_id, one_def)
      end

      # flush the cache to the disk
      if write_ok
        if !SCR.Write(path(".firewall_service_definition"), nil)
          log.error "Cannot write to disk!"
          write_ok = false
        else
          # not only store to disk but also to the memory
          @services[service] = new_store_definition
          SetModified()
        end
      end

      # Unregistering sysconfig agent for that file
      SCR.UnregisterAgent(path(".firewall_service_definition"))

      log.info "Call SetNeededPortsAndProtocols(#{service}, ...) result is #{write_ok}"
      write_ok
    end

    # Function returns list of possibly conflicting services.
    # Conflicting services are for instance nis-client and nis-server.
    # DEPRECATED - we currently don't have such services - services are defined by packages.
    #
    # @return	[Array<String>] of conflicting services
    def GetPossiblyConflictServices
      []
    end

    publish :variable => :OLD_SERVICES, :type => "map <string, map <string, any>>"
    publish :function => :ServiceDefinedByPackage, :type => "boolean (string)"
    publish :function => :GetFilenameFromServiceDefinedByPackage, :type => "string (string)"
    publish :function => :ReadServicesDefinedByRPMPackages, :type => "boolean ()"
    publish :function => :IsKnownService, :type => "boolean (string)"
    publish :function => :GetSupportedServices, :type => "map <string, string> ()"
    publish :function => :GetListOfServicesAddedByPackage, :type => "list <string> ()"
    publish :function => :GetNeededTCPPorts, :type => "list <string> (string)"
    publish :function => :GetNeededUDPPorts, :type => "list <string> (string)"
    publish :function => :GetNeededRPCPorts, :type => "list <string> (string)"
    publish :function => :GetNeededIPProtocols, :type => "list <string> (string)"
    publish :function => :GetDescription, :type => "string (string)"
    publish :function => :SetModified, :type => "void ()"
    publish :function => :ResetModified, :type => "void ()"
    publish :function => :GetModified, :type => "boolean ()"
    publish :function => :GetNeededBroadcastPorts, :type => "list <string> (string)"
    publish :function => :GetNeededPortsAndProtocols, :type => "map <string, list <string>> (string)"
    publish :function => :SetNeededPortsAndProtocols, :type => "boolean (string, map <string, list <string>>)"
    publish :function => :GetPossiblyConflictServices, :type => "list <string> ()"
  end

  SuSEFirewallServices = SuSEFirewallServicesClass.new
  SuSEFirewallServices.main
end
