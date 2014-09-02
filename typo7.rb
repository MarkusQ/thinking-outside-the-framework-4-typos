module Typo
    def self.levenshtein(s,t,limit)
        s = s.downcase
        t = t.downcase
        return 0          if s == t
        return t.length   if (s_ = s.length) == 0
        return s.length   if (t_ = t.length) == 0
        v = (0..t_).to_a
        (0...s_).each { |i|
            x,v[0] = v[0],i+1
            (0...t_).each { |j|
                cost = (s[i] == t[j]) ? 0 : 1
                x,v[j+1] = v[j+1],[v[j]+1, v[j+1]+1, x+cost].min
            }
            return limit+1 if v.min > limit
        }
        v.last
    end

    def self.edit_distance(w1,w2,limit=[w1.length,w2.length].max)
        lower_bound = (w1.length-w2.length).abs
        if lower_bound <= limit
            levenshtein(w1,w2,limit)
        else
            lower_bound
        end
    end

    @dict = Hash.new { |h,k| h[k] = [] }
    File.readlines("american-english").map(&:chomp).each { |w| @dict[w.downcase] << w }
    @by_1st2 = Hash.new { |h,k| h[k] = [] }
    @by_2nd2 = Hash.new { |h,k| h[k] = [] }
    @by_1st_3rd = Hash.new { |h,k| h[k] = [] }
    @dict.keys.map { |w|
        @by_1st2[w[0,2]] << w
        @by_2nd2[w[1,2]] << w
        @by_1st_3rd["#{w[0,1]}#{w[2,1]}"] << w
    }
    def self.closest_words(w)
        return @dict[w.downcase] if @dict.keys.include?(w.downcase)
        w_0_2 = "#{w[0,1]}#{w[2,1]}"
        one_off = 
          @by_1st2[w[0,2]] | @by_1st2[w[1,2]] | @by_1st2[w_0_2] |
          @by_2nd2[w[0,2]] | @by_2nd2[w[1,2]] |
          @by_1st_3rd[w[0,2]]                 | @by_1st_3rd[w_0_2]
        closest_from(one_off,w,1) || closest_from(@dict.keys,w,w.length+1)
    end
    def self.closest_from(dict,w,best_score)
        best = []
        dict.each { |word|
            if best_score >= word.length-w.length
                score = edit_distance(w,word,best_score+1)
                case score
                  when 0...best_score
                    best_score = score
                    best = @dict[word].dup
                  when best_score
                    best |= @dict[word]
                  end
            end
        }
        !best.empty? && best
    end
end

File.read("testdata").split(/\W+/m).each { |w| p [w,Typo.closest_words(w)] }
