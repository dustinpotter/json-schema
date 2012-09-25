module JSON
  class Schema
    class FormatAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        return if data.blank?

        case current_schema.schema['format']

        # Timestamp in restricted ISO-8601 YYYY-MM-DDThh:mm:ssZ with optional decimal fraction of the second
        when 'date-time'
          if data.is_a?(String)
            error_message = "The property '#{build_fragment(fragments)}' must be a date/time in the ISO-8601 format of YYYY-MM-DDThh:mm:ssZ or YYYY-MM-DDThh:mm:ss.ssZ"
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
            r = Regexp.new('^\d\d\d\d-\d\d-\d\dT(\d\d):(\d\d):(\d\d)([\.,]\d+)?Z$')
            if (m = r.match(data))
              parts = data.split("T")
              begin
                Date.parse(parts[0])
              rescue Exception
                validation_error(error_message, fragments, current_schema, self, options[:record_errors])
                return
              end
              begin
                validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if m[1].to_i > 23
                validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if m[2].to_i > 59
                validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if m[3].to_i > 59
              rescue Exception
                validation_error(error_message, fragments, current_schema, self, options[:record_errors])
                return
              end
            else
              validation_error(error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          end

        # Date in the format of YYYY-MM-DD
        when 'date'
          if data.is_a?(String)
            error_message = "The property '#{build_fragment(fragments)}' must be a date in the format of YYYY-MM-DD"
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
            r = Regexp.new('^\d\d\d\d-\d\d-\d\d$')
            if (m = r.match(data))
              begin
                Date.parse(data)
              rescue Exception
                validation_error(error_message, fragments, current_schema, self, options[:record_errors])
                return
              end
            else
              validation_error(error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          end

        # Time in the format of HH:MM:SS
        when 'time'
          if data.is_a?(String)
            error_message = "The property '#{build_fragment(fragments)}' must be a time in the format of hh:mm:ss"
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
            r = Regexp.new('^(\d\d):(\d\d):(\d\d)$')
            if (m = r.match(data))
              validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if m[1].to_i > 23
              validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if m[2].to_i > 59
              validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if m[3].to_i > 59
            else
              validation_error(error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          end

        # IPv4 in dotted-quad format
        when 'ip-address', 'ipv4'
          if data.is_a?(String)
            error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv4 address"
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
            r = Regexp.new('^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}$')
            if (m = r.match(data))
              1.upto(4) do |x|
                validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if m[x].to_i > 255
              end
            else
              validation_error(error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          end

        # IPv6 in standard format (including abbreviations)
        when 'ipv6'
          if data.is_a?(String)
            error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv6 address"
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
            r = Regexp.new('^[a-f0-9:]+$')
            if (m = r.match(data))
              # All characters are valid, now validate structure
              parts = data.split(":")
              validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if parts.length > 8
              condensed_zeros = false
              parts.each do |part|
                if part.length == 0
                  validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if condensed_zeros
                  condensed_zeros = true
                end
                validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if part.length > 4
              end
            else
              validation_error(error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          end

        # added for cj
        # Date in the format of MM.DD.YY[YY]
        when 'us-date'
          if data.is_a?(String)
            error_message = "The property '#{build_fragment(fragments)}' must be a date in the format of DD/MM/YYYY"
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
            r = Regexp.new('^\d\d.\d\d.\d\d(\d\d)?$')
            if (m = r.match(data))
              begin
                Date.parse(data)
              rescue Exception
                validation_error(error_message, fragments, current_schema, self, options[:record_errors])
                return
              end
            else
              validation_error(error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          end

        when 'email'
          error_message = "The email address '#{build_fragment(fragments)}' is not formatted correctly"
          if data.is_a?(String)
            r = Regexp.new('^\w+([\w\-\.\+\'])*@([\w\-]+\.)*[\w\-]+$')
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return unless (m = r.match((data)))
            # todo: check for specific phoney emails?
          else
            validation_error(error_message, fragments, current_schema, self, options[:record_errors])
            return 
          end

        when 'phone'
          error_message = "The phone number '#{build_fragment(fragments)}' is not formatted correctly. It must include area code (like: 999-999-9999)"
          if data.is_a?(String)
            r = Regexp.new('^[\(]?[0-9]{3}[\)]?[\s\-\.]?[0-9]{3}[\s\-\.]?[0-9]{4}([\s]*[x#\-][0-9]+)?$')
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return unless (m = r.match((data)))
            # todo: check for specific phoney numbers?
          else
            validation_error(error_message, fragments, current_schema, self, options[:record_errors])
            return 
          end

        when 'zip'
          error_message = "The zip code '#{build_fragment(fragments)}' is not formatted correctly"
          if data.is_a?(String)
            r = Regexp.new('^\d{5}(-\d{4})?$')
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return unless (m = r.match((data)))
            # todo: check for specific phoney zips?
          else
            validation_error(error_message, fragments, current_schema, self, options[:record_errors])
            return
          end

        when 'postal'
          error_message = "The postal code '#{build_fragment(fragments)}' is not formatted correctly"
          if data.is_a?(String)
            r = Regexp.new('^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$')
            validation_error(error_message, fragments, current_schema, self, options[:record_errors]) and return unless (m = r.match((data)))
            # todo: check for specific phoney codes?
          else
            validation_error(error_message, fragments, current_schema, self, options[:record_errors])
            return          
          end
        end

      end
    end
  end
end
