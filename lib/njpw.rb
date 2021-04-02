require "njpw/version"
require 'i18n'

if I18n.respond_to?(:enforce_available_locales=)
  I18n.enforce_available_locales = true
end

I18n.available_locales = [:en, :ja]
I18n.default_locale = :ja

mydir = File.expand_path(File.dirname(__FILE__))
I18n.load_path += Dir[File.join(mydir, 'locales', '*.yml')]
I18n.reload! if I18n.backend.initialized?

module Njpw
  class Config
    @locale = nil
    @random = nil

    class << self
      attr_writer :locale
      attr_writer :random

      def locale
        @locale || I18n.locale
      end

      def own_locale
        @locale
      end

      def random
        @random || Random::DEFAULT
      end
    end
  end

  class Base
    Numbers = Array(0..9)
    ULetters = Array('A'..'Z')
    Letters = ULetters + Array('a'..'z')

    class << self
      def numerify(number_string)
        number_string.sub(/#/) { (rand(9)+1).to_s }.gsub(/#/) { rand(10).to_s }
      end

      def letterify(letter_string)
        letter_string.gsub(/\?/) { sample(ULetters) }
      end

      def bothify(string)
        letterify(numerify(string))
      end

      def regexify(re)
        re = re.source if re.respond_to?(:source)
        re.
          gsub(/^\/?\^?/, '').gsub(/\$?\/?$/, '').
          gsub(/\{(\d+)\}/, '{\1,\1}').gsub(/\?/, '{0,1}').
          gsub(/(\[[^\]]+\])\{(\d+),(\d+)\}/) {|match| $1 * sample(Array(Range.new($2.to_i, $3.to_i))) }.
          gsub(/(\([^\)]+\))\{(\d+),(\d+)\}/) {|match| $1 * sample(Array(Range.new($2.to_i, $3.to_i))) }.
          gsub(/(\\?.)\{(\d+),(\d+)\}/) {|match| $1 * sample(Array(Range.new($2.to_i, $3.to_i))) }.
          gsub(/\((.*?)\)/) {|match| sample(match.gsub(/[\(\)]/, '').split('|')) }.
          gsub(/\[([^\]]+)\]/) {|match| match.gsub(/(\w\-\w)/) {|range| sample(Array(Range.new(*range.split('-')))) } }.
          gsub(/\[([^\]]+)\]/) {|match| sample($1.split('')) }.
          gsub('\d') {|match| sample(Numbers) }.
          gsub('\w') {|match| sample(Letters) }
      end

      def fetch(key)
        fetched = sample(translate("my_faker.#{key}"))
        if fetched && fetched.match(/^\//) and fetched.match(/\/$/)
          regexify(fetched)
        else
          fetched
        end
      end

      def fetch_all(key)
        fetched = translate("my_faker.#{key}")
        fetched = fetched.last if fetched.size <= 1
        if !fetched.respond_to?(:sample) && fetched.match(/^\//) and fetched.match(/\/$/)
          regexify(fetched)
        else
          fetched
        end
      end

      def parse(key)
        fetched = fetch(key)
        parts = fetched.scan(/(\(?)#\{([A-Za-z]+\.)?([^\}]+)\}([^#]+)?/).map {|prefix, kls, meth, etc|
          cls = kls ? Njpw.const_get(kls.chop) : self

          text = prefix

          text += cls.respond_to?(meth) ? cls.send(meth) : fetch("#{(kls || self).to_s.split('::').last.downcase}.#{meth.downcase}")
          text += etc.to_s
        }
        parts.any? ? parts.join : numerify(fetched)
      end

      def translate(*args)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        opts[:locale] ||= Njpw::Config.locale
        opts[:raise] = true
        I18n.translate(*(args.push(opts)))
      rescue I18n::MissingTranslationData
        opts = args.last.is_a?(Hash) ? args.pop : {}
        opts[:locale] = :en
        I18n.translate(*(args.push(opts)))
      end

      def flexible(key)
        @flexible_key = key
      end

      def sample(list)
        list.respond_to?(:sample) ? list.sample(random: Njpw::Config.random) : list
      end

      def rand_in_range(from, to)
        from, to = to, from if to < from
        rand(from..to)
      end

      def rand(max = nil)
        max ? Njpw::Config.random.rand(max) : Njpw::Config.random.rand
      end
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'njpw','*.rb')).each {|f| require f }
