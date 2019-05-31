module Minitest
  module Assertions

    # Two reasons for this patch:
    # 1.  Method self.need_to_diff? is factored out,
    #     to allow the test to determine whether diff will be done.
    # 2.  Method self.diff is modified to always use ldiff,
    #     instead of using a platform-dependent diff program.

    def self.need_to_diff?(expect, butwas)
      (expect.include?("\n")    ||
          butwas.include?("\n")    ||
          expect.size > 30         ||
          butwas.size > 30         ||
          expect == butwas)        &&
          Minitest::Assertions.diff
    end

    def diff (exp, act)
      expect = mu_pp_for_diff exp
      butwas = mu_pp_for_diff act
      result = nil

      return "Expected: #{mu_pp exp}\n  Actual: #{mu_pp act}" unless
          Minitest::Assertions.need_to_diff? expect, butwas

      Tempfile.open("expect") do |a|
        a.puts expect
        a.flush

        Tempfile.open("butwas") do |b|
          b.puts butwas
          b.flush

          result = `#{Minitest::Assertions.diff} #{a.path} #{b.path}`
          result.sub!(/^\-\-\- .+/, "--- expected")
          result.sub!(/^\+\+\+ .+/, "+++ actual")

          if result.empty? then
            klass = exp.class
            result = [
                "No visible difference in the #{klass}#inspect output.\n",
                "You should look at the implementation of #== on ",
                "#{klass} or its members.\n",
                expect,
            ].join
          end
        end
      end

      result
    end

    def self.diff
      'ldiff -u 0'
    end
  end
end
