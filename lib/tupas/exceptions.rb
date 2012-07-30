module Tupas
  module Exceptions
    class InvalidResponseMessage < ArgumentError; end
    class InvalidResponseHashAlgorithm < ArgumentError; end
    class InvalidMacForResponseMessage < ArgumentError; end
    class InvalidResponseMessageType < ArgumentError; end
    class IncompleteResponseMessage < ArgumentError; end
    class TypeNotFoundResponseMessage < ArgumentError; end
  end
end