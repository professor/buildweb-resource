#!/usr/bin/env ruby

require_relative '../input'

require 'net/http'
require 'json'

module Commands

  class Check

    attr_reader :destination
    attr_reader :input

    def initialize(destination:, input: Input.instance)
      @destination = destination
      @input = input

    end

    def source
      input.source
    end

    def require_source(name)
      v = source[name]
      raise InputError, %("source.#{name}" must be defined) if v.nil?
      v
    end

    def params
      input.params
    end

    def require_param(name)
      v = params[name]
      raise InputError, %("params.#{name}" must be defined) if v.nil?
      v
    end

    def version
      input.version
    end

    def require_version(name)
      version[name]
    end

    def product
      @product ||= begin
        require_source('product')
      end
    end

    def concourse_latest
      @latest ||= begin
        require_version('ref')
      end
    end

    def debug(msg)
      puts(msg) if source.debug
    end

    def buildweb_url(product)
      "http://buildapi.eng.vmware.com/ob/build/?product=#{product}&buildstate=succeeded&releasetag__isnull=False&_format=json"
    end

    def array_to_version_hash(versions)
      versions.map { |version| {"ref" => version}}
    end

    def run!
      url = buildweb_url(product)
      response = Net::HTTP.get_response(URI.parse(url))
      data = response.body
      result = JSON.parse(data)

      # we assume that the API sorts them by time, latest at the end
      versions = result["_list"].map { |item| item["version"]}
      last_version = versions.last

      if concourse_latest == last_version
        last_version = [{"ref" => last_version}]
        puts last_version.to_json
      else
        versions_hash = array_to_version_hash(versions)
        puts versions_hash.to_json
      end
    end
  end

end

if $PROGRAM_NAME == __FILE__
  command = Commands::Check.new(destination: ARGV.shift)
  begin
    command.run!
  rescue InputError => e
    STDERR.puts e.message
    exit(1)
  end
end
