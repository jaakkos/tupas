module Tupas
  module Messages
    module Mac
      module_function
      def calculate_hash(algorithm, values)
        calculate_hex_hash_with(algorithm, join_values(values))
      end

      def join_values(values)
        (values.join('&') + '&')
      end

      # REVIEW: Wrapper for Digest, if we need to changed to different lib - jaakko
      def calculate_hex_hash_with(algorithm, string = '')
        case algorithm
          when :md5
            Digest::MD5.hexdigest(string)
          when :sha_1
            Digest::SHA1.hexdigest(string)
          when :sha_256
            Digest::SHA256.hexdigest(string)
          else
            raise ArgumentError, "Unkown hash algorithm: #{algorithm}"
        end
      end

    end
  end
end