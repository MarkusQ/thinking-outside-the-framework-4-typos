module Typo
    def self.levenshtein(s,t,limit)
        return 0          if s == t
        return t.length   if (s_ = s.length) == 0
        return s.length   if (t_ = t.length) == 0
        v = (0..t_).to_a
        x = i = j = cost = s_i = nil
        (0...s_).each { |i|
            x,v[0] = v[0],i+1
            s_i = s[i]
            (0...t_).each { |j|
                x,v[j+1] = v[j+1],[v[j]+1, v[j+1]+1, x+((s_i == t[j]) ? 0 : 1)].min
            }
            return limit+1 if v.min > limit
        }
        v.last
    end

    def self.edit_distance(w1,w2,limit=[w1.length,w2.length].max)
        lower_bound = (w1.length-w2.length).abs
        if lower_bound < limit
            levenshtein(w1,w2,limit)
        else
            lower_bound
        end
    end

    t = Time.now
    @dict       = File.readlines("american-english")
    p [:readlines,Time.now-t]; t = Time.now
    @dict       = @dict.map(&:chomp)
    p [:chomp,Time.now-t]; t = Time.now
    @dict       = @dict.group_by(&:downcase)
    p [:group_Bby,Time.now-t]; t = Time.now
    @words      = @dict.keys
    p [:keys,Time.now-t]; t = Time.now
    @by_1st2    = @words.group_by { |w| w[0,2] }
    p [:by_1st,Time.now-t]; t = Time.now
    @by_2nd2    = @words.group_by { |w| w[1,2] }
    p [:by_snd,Time.now-t]; t = Time.now
    @by_1st_3rd = @words.group_by { |w| "#{w[0,1]}#{w[2,1]}" }
    p [:by_1st_3rd,Time.now-t]; t = Time.now
    def self.closest_words(w)
        w = w.downcase
        return @dict[w] if @dict.has_key?(w)
        w_0_1 = w[0,2]
        w_1_2 = w[1,2]
        w_0_2 = "#{w[0,1]}#{w[2,1]}"
        one_off = [
          @by_1st2[   w_0_1],@by_1st2[w_1_2],@by_1st2[w_0_2],
          @by_2nd2[   w_0_1],@by_2nd2[w_1_2],
          @by_1st_3rd[w_0_1],                @by_1st_3rd[w_0_2]].compact
        closest_from(one_off,w,2) || closest_from([*one_off,@words],w,w.length+1)
    end
    def self.closest_from(dicts,w,best_score)
        best = []
        dicts.each { |dict|
            dict.each { |word|
                if best_score > (word.length-w.length).abs
                    score = edit_distance(w,word,best_score)
                    case score
                      when 0...best_score
                        best_score = score
                        best = @dict[word].dup
                      when best_score
                        best |= @dict[word]
                      end
                end
            }
        }
        !best.empty? && best
    end
end

words = File.read("testdata").split(/\W+/m)
t = Time.now()
words.each { |w| p [w,Typo.closest_words(w)] }
#200.times { GC.start; words.each { |w| Typo.closest_words(w) } }
puts "#{Time.now()-t} seconds"