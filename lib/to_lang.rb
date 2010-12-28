require File.expand_path("../to_lang/codemap", __FILE__)
require File.expand_path("../to_lang/connector", __FILE__)
require File.expand_path("../to_lang/string_methods", __FILE__)

# {ToLang} is a Ruby library that adds language translation methods to strings, backed by the Google Translate API.
#
# @author Jimmy Cuadra
# @see https://github.com/jimmycuadra/to_lang Source on GitHub
#
module ToLang
  class << self
    # A {ToLang::Connector} object to use for translation requests.
    #
    # @return [ToLang::Constructor, NilClass] An initialized {ToLang::Connector connector} or nil.
    attr_reader :connector

    # Initializes {ToLang}, after which the translation methods will be available from strings.
    #
    # @param [String] key A Google Translate API key.
    #
    # @return [Boolean] True if initialization succeeded, false if this method has already been called successfully.
    #
    def start(key)
      return false if defined?(@connector) && !@connector.nil?
      @connector = ToLang::Connector.new(key)
      add_translation_methods
      true
    end

    private

    # Includes ToLang::StringMethods in String and adds dynamic methods
    # by overriding @method_missing@ and @respond_to?@.
    #
    def add_translation_methods
      String.class_eval do
        include StringMethods

        def method_missing(method, *args, &block)
          if method.to_s =~ /^to_(.*)_from_(.*)$/ && CODEMAP[$1] && CODEMAP[$2]
            new_method_name = "to_#{$1}_from_#{$2}".to_sym

            self.class.send(:define_method, new_method_name, Proc.new {
              translate(CODEMAP[$1], :from => CODEMAP[$2])
            })

            send new_method_name
          elsif method.to_s =~ /^to_(.*)$/ && CODEMAP[$1]
            new_method_name = "to_#{$1}".to_sym

            self.class.send(:define_method, new_method_name, Proc.new {
              translate(CODEMAP[$1])
            })

            send new_method_name
          else
            super
          end
        end

        def respond_to?(method, include_private = false)
          if method.to_s =~ /^to_(.*)_from_(.*)$/ && CODEMAP[$1] && CODEMAP[$2]
            true
          elsif method.to_s =~ /^to_(.*)$/ && CODEMAP[$1]
            true
          else
            super
          end
        end
      end
    end
  end
end
