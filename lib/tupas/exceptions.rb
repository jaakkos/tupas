# -*- encoding : utf-8 -*-
module Tupas
  module Exceptions
    class InvalidResponseMessage < ArgumentError; end
    class InvalidTupasProvider < ArgumentError; end
    class InvalidResponseHashAlgorithm < ArgumentError; end
    class InvalidMacForResponseMessage < ArgumentError; end
    class InvalidResponseMessageType < ArgumentError; end
    class IncompleteResponseMessage < ArgumentError; end
    class TypeNotFoundResponseMessage < ArgumentError; end
    class InvalidResponseString < ArgumentError; end
  end
end
