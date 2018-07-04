module Storey
  class GenLoadCommand

    def self.call(options={})
      switches = {}
      if options[:file].present?
        switches[:file] = Shellwords.escape(options[:file])
      end
      switches[:command] = %Q("#{options[:command]}") if options[:command].present?

      command_parts = ["psql"]

      if options[:database_url].present?
        command_parts << options[:database_url]
      else
        switches[:dbname] = options[:database]
        switches[:username] = options[:username] if options[:username].present?
        switches[:host] = options[:host] if options[:host].present?
        switches[:port] = options[:port] if options[:port].present?
        if options[:password].present?
          switches[:password] = options[:password]
        else
          switches['no-password'] = nil
        end
      end

      command_parts << Utils.command_line_switches_from(switches)
      command_parts.join(' ')
    end

  end
end
